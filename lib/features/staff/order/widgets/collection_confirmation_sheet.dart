import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/app_models.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../customer/booking/booking_calculator.dart';

class CollectionConfirmationDraft {
  const CollectionConfirmationDraft({
    required this.completion,
    this.evidenceBytes,
  });

  final CollectionCompletion completion;
  final Uint8List? evidenceBytes;
}

Future<CollectionConfirmationDraft?> showCollectionConfirmationSheet(
  BuildContext context, {
  required PickupOrder order,
  required String staffId,
  required List<WasteType> wasteTypes,
  required List<PriceItem> prices,
  required List<PackageSubscription> subscriptions,
  required List<PickupPackage> packages,
  required bool requiresCameraEvidence,
  Future<XFile?> Function()? captureEvidence,
}) {
  return showModalBottomSheet<CollectionConfirmationDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => _CollectionConfirmationSheet(
      order: order,
      staffId: staffId,
      wasteTypes: wasteTypes,
      prices: prices,
      subscriptions: subscriptions,
      packages: packages,
      requiresCameraEvidence: requiresCameraEvidence,
      captureEvidence: captureEvidence,
    ),
  );
}

class _CollectionConfirmationSheet extends StatefulWidget {
  const _CollectionConfirmationSheet({
    required this.order,
    required this.staffId,
    required this.wasteTypes,
    required this.prices,
    required this.subscriptions,
    required this.packages,
    required this.requiresCameraEvidence,
    this.captureEvidence,
  });

  final PickupOrder order;
  final String staffId;
  final List<WasteType> wasteTypes;
  final List<PriceItem> prices;
  final List<PackageSubscription> subscriptions;
  final List<PickupPackage> packages;
  final bool requiresCameraEvidence;
  final Future<XFile?> Function()? captureEvidence;

  @override
  State<_CollectionConfirmationSheet> createState() =>
      _CollectionConfirmationSheetState();
}

class _CollectionConfirmationSheetState
    extends State<_CollectionConfirmationSheet> {
  static const _maximumEvidenceBytes = 650 * 1024;

  late final TextEditingController _kgController;
  late String _wasteId;
  Uint8List? _evidenceBytes;
  bool _hasMockEvidence = false;
  bool _capturingEvidence = false;
  bool _paymentConfirmed = false;
  bool _showError = false;
  String _paymentMethod = 'TIEN_MAT';

  @override
  void initState() {
    super.initState();
    _wasteId =
        widget.wasteTypes.any(
          (waste) => waste.loaiRacId == widget.order.loaiRacId,
        )
        ? widget.order.loaiRacId
        : widget.wasteTypes.first.loaiRacId;
    _kgController = TextEditingController(
      text: widget.order.khoiLuongDuKien.toStringAsFixed(1),
    )..addListener(_refreshEstimate);
  }

  @override
  void dispose() {
    _kgController
      ..removeListener(_refreshEstimate)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kg = _actualKg;
    final price = findPrice(widget.prices, _wasteId);
    final subscription = _subscriptionForCustomer();
    final package = _packageFor(subscription);
    final amount = kg == null
        ? 0
        : calculatePaymentAmount(
            paymentMethod: widget.order.hinhThucTinhPhi,
            price: price,
            kg: kg,
            subscription: subscription,
            package: package,
          );
    final paymentLabel = estimatePaymentLabel(
      paymentMethod: widget.order.hinhThucTinhPhi,
      price: price,
      kg: kg,
      subscription: subscription,
      package: package,
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biên bản thu gom',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Xác nhận dữ liệu thực tế trước khi hoàn thành ${widget.order.maDon}.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _wasteId,
                  decoration: const InputDecoration(
                    labelText: 'Loại rác thực tế',
                    prefixIcon: Icon(Icons.recycling),
                  ),
                  items: [
                    for (final waste in widget.wasteTypes)
                      DropdownMenuItem(
                        value: waste.loaiRacId,
                        child: Text(waste.tenLoaiRac),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _wasteId = value);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextInput(
                  label: 'Khối lượng thực tế',
                  hint: 'Nhập số kg đã cân',
                  controller: _kgController,
                  icon: Icons.scale_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  suffixText: 'kg',
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Ảnh xác nhận',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _EvidenceCaptureCard(
                  imageBytes: _evidenceBytes,
                  isCapturing: _capturingEvidence,
                  isRequired: widget.requiresCameraEvidence,
                  onCapture: _captureEvidence,
                  onRemove: _removeEvidence,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.order.hinhThucTinhPhi == 'GOI_THANG'
                                  ? 'Đối soát gói tháng'
                                  : 'Phí thu gom dự kiến',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              paymentLabel,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (amount > 0)
                  _PaymentConfirmation(
                    amount: amount,
                    method: _paymentMethod,
                    confirmed: _paymentConfirmed,
                    onMethodChanged: (method) {
                      setState(() {
                        _paymentMethod = method;
                        _paymentConfirmed = false;
                      });
                    },
                    onConfirmedChanged: (value) {
                      setState(() => _paymentConfirmed = value);
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Đã đối soát trong hạn mức gói tháng, không phát sinh thanh toán.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_showError) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _validationMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.accentForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                PrimaryActionButton(
                  label: 'Xác nhận hoàn thành',
                  icon: Icons.verified_outlined,
                  onPressed: () => _submit(amount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double? get _actualKg {
    final value = double.tryParse(_kgController.text.replaceAll(',', '.'));
    return value == null || value <= 0 ? null : value;
  }

  String get _validationMessage {
    if (_actualKg == null) return 'Khối lượng thực tế phải lớn hơn 0.';
    if (!_hasEvidence && widget.requiresCameraEvidence) {
      return 'Vui lòng chụp ảnh xác nhận trước khi hoàn thành.';
    }
    return 'Vui lòng kiểm tra lại dữ liệu biên bản.';
  }

  PackageSubscription? _subscriptionForCustomer() {
    for (final subscription in widget.subscriptions) {
      if (subscription.khachHangId == widget.order.khachHangId) {
        return subscription;
      }
    }
    return null;
  }

  PickupPackage? _packageFor(PackageSubscription? subscription) {
    if (subscription == null) return null;
    for (final package in widget.packages) {
      if (package.goiId == subscription.goiId) return package;
    }
    return null;
  }

  void _refreshEstimate() {
    if (mounted) setState(() => _showError = false);
  }

  Future<void> _captureEvidence() async {
    final capture = widget.captureEvidence;
    if (capture == null) {
      setState(() {
        _hasMockEvidence = true;
        _showError = false;
      });
      return;
    }

    setState(() => _capturingEvidence = true);
    try {
      final image = await capture();
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      if (bytes.isEmpty || bytes.lengthInBytes > _maximumEvidenceBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ảnh quá lớn để lưu biên bản. Hãy chụp lại gần hơn.'),
          ),
        );
        return;
      }
      setState(() {
        _evidenceBytes = bytes;
        _hasMockEvidence = false;
        _showError = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở camera. Vui lòng kiểm tra quyền camera.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _capturingEvidence = false);
    }
  }

  void _removeEvidence() {
    setState(() {
      _evidenceBytes = null;
      _hasMockEvidence = false;
    });
  }

  void _submit(num amount) {
    final kg = _actualKg;
    if (kg == null || (widget.requiresCameraEvidence && !_hasEvidence)) {
      setState(() => _showError = true);
      return;
    }
    final now = DateTime.now();
    final paid = amount == 0 || _paymentConfirmed;
    final paymentMethod = amount == 0 ? 'GOI_THANG' : _paymentMethod;
    Navigator.of(context).pop(
      CollectionConfirmationDraft(
        completion: CollectionCompletion(
          record: CollectionRecord(
            bienBanId: 'BB_${widget.order.maDon}',
            maDon: widget.order.maDon,
            nhanVienId: widget.staffId,
            loaiRacThucTeId: _wasteId,
            khoiLuongThucTe: kg,
            anhXacNhanUrl: widget.requiresCameraEvidence
                ? null
                : 'mock://evidence/${widget.order.maDon}.jpg',
            phiPhaiTra: amount,
            trangThaiThanhToan: paid ? 'DA_THANH_TOAN' : 'CHO_THANH_TOAN',
            thoiGianLap: now,
          ),
          payment: PaymentRecord(
            thanhToanId: 'TT_${widget.order.maDon}',
            maDon: widget.order.maDon,
            khachHangId: widget.order.khachHangId,
            soTien: amount,
            phuongThuc: paymentMethod,
            trangThai: paid ? 'DA_THANH_TOAN' : 'CHO_THANH_TOAN',
            thoiGianTao: now,
            thoiGianThanhToan: paid ? now : null,
          ),
        ),
        evidenceBytes: _evidenceBytes,
      ),
    );
  }

  bool get _hasEvidence =>
      (_evidenceBytes?.isNotEmpty ?? false) || _hasMockEvidence;
}

class _EvidenceCaptureCard extends StatelessWidget {
  const _EvidenceCaptureCard({
    required this.imageBytes,
    required this.isCapturing,
    required this.isRequired,
    required this.onCapture,
    required this.onRemove,
  });

  final Uint8List? imageBytes;
  final bool isCapturing;
  final bool isRequired;
  final VoidCallback onCapture;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes != null && imageBytes!.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: hasImage ? AppColors.primaryLight : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: hasImage ? AppColors.primary : AppColors.border,
        ),
      ),
      child: hasImage
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.memory(imageBytes!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Ảnh xác nhận đã sẵn sàng',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onCapture,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Chụp lại'),
                    ),
                    IconButton(
                      tooltip: 'Xóa ảnh',
                      onPressed: onRemove,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            )
          : InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: isCapturing ? null : onCapture,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: isCapturing
                        ? const Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.add_a_photo_outlined,
                            color: AppColors.primary,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCapturing
                              ? 'Đang mở camera'
                              : isRequired
                              ? 'Chụp ảnh xác nhận'
                              : 'Thêm ảnh demo',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          isRequired
                              ? 'Bắt buộc để hoàn thành biên bản thu gom'
                              : 'Dùng khi xem trước flow không có Firebase',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.muted),
                ],
              ),
            ),
    );
  }
}

class _PaymentConfirmation extends StatelessWidget {
  const _PaymentConfirmation({
    required this.amount,
    required this.method,
    required this.confirmed,
    required this.onMethodChanged,
    required this.onConfirmedChanged,
  });

  final num amount;
  final String method;
  final bool confirmed;
  final ValueChanged<String> onMethodChanged;
  final ValueChanged<bool> onConfirmedChanged;

  @override
  Widget build(BuildContext context) {
    final confirmationLabel = method == 'TIEN_MAT'
        ? 'Đã nhận đủ tiền mặt'
        : 'Đã kiểm tra chuyển khoản';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Thu ${formatMoney(amount)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'TIEN_MAT',
                  icon: Icon(Icons.payments_outlined),
                  label: Text('Tiền mặt'),
                ),
                ButtonSegment(
                  value: 'CHUYEN_KHOAN',
                  icon: Icon(Icons.account_balance_outlined),
                  label: Text('Chuyển khoản'),
                ),
              ],
              selected: {method},
              onSelectionChanged: (values) {
                onMethodChanged(values.first);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: confirmed,
            onChanged: onConfirmedChanged,
            title: Text(
              confirmationLabel,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              confirmed
                  ? 'Thanh toán sẽ được ghi nhận đã hoàn tất.'
                  : 'Có thể hoàn thành đơn và để khách thanh toán sau.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
