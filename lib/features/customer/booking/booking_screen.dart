import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../order_detail_screen.dart';
import 'booking_calculator.dart';
import 'widgets/address_option_card.dart';
import 'widgets/booking_submit_panel.dart';
import 'widgets/order_preview_card.dart';
import 'widgets/payment_method_card.dart';
import 'widgets/schedule_card.dart';
import 'widgets/waste_option_card.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _kgController = TextEditingController(text: '6');
  final _noteController = TextEditingController();
  String? _diaChiId;
  String? _loaiRacId;
  String? _khungGio;
  String _hinhThucTinhPhi = 'GOI_THANG';
  DateTime _ngayThuGom = DateTime(2026, 7, 9);

  @override
  void initState() {
    super.initState();
    _kgController.addListener(_refreshEstimate);
  }

  @override
  void dispose() {
    _kgController.removeListener(_refreshEstimate);
    _kgController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final addresses = ref.watch(customerAddressesProvider);
    final wastes = ref.watch(wasteTypesProvider);
    final prices = ref.watch(pricesProvider);
    final timeSlots = ref.watch(timeSlotsProvider);
    final staff = ref.watch(staffProfilesProvider);
    final subscription = ref.watch(currentSubscriptionProvider);
    final packages = ref.watch(packagesProvider);
    final package = packages.isEmpty ? null : packages.first;

    _diaChiId ??= addresses.isNotEmpty ? addresses.first.diaChiId : null;
    _loaiRacId ??= wastes.isNotEmpty ? wastes.first.loaiRacId : null;
    _khungGio ??= timeSlots.isEmpty
        ? null
        : (timeSlots.length > 1 ? timeSlots[1] : timeSlots.first);

    final selectedAddress = findAddress(addresses, _diaChiId);
    final selectedWaste = findWaste(wastes, _loaiRacId);
    final selectedPrice = findPrice(prices, _loaiRacId);
    final suggestedStaff = suggestedStaffForAddress(
      staff: staff,
      address: selectedAddress,
    );
    final kg = _selectedKg;
    final estimate = estimatePaymentLabel(
      paymentMethod: _hinhThucTinhPhi,
      price: selectedPrice,
      kg: kg,
      subscription: subscription,
      package: package,
    );
    final canSubmit =
        selectedAddress != null &&
        selectedWaste != null &&
        _khungGio != null &&
        kg != null &&
        kg > 0;

    return AppPage(
      maxWidth: 760,
      title: 'Đặt lịch thu gom',
      subtitle: 'Gửi đơn cho nhân viên gần nhất',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.md,
          AppSpacing.screenHorizontal,
          AppSpacing.xxl,
        ),
        children: [
          HomeBrandHeader(
            title: 'Lập đơn thu gom mới',
            subtitle:
                'Chọn thông tin thu gom, hệ thống sẽ ưu tiên nhân viên gần khu vực của bạn.',
            trailing: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.opacity(AppColors.white, 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.accent),
              ),
              child: const Icon(
                Icons.add_location_alt_outlined,
                color: AppColors.textInverse,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(
            title: 'Địa chỉ lấy rác',
            subtitle: 'Chọn nơi nhân viên sẽ đến',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (addresses.isEmpty)
            const EmptyState(
              icon: Icons.place_outlined,
              title: 'Chưa có địa chỉ',
              message: 'Bạn cần thêm địa chỉ trước khi tạo đơn thu gom.',
            )
          else
            ...addresses.map(
              (address) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AddressOptionCard(
                  selected: _diaChiId == address.diaChiId,
                  address: address,
                  onTap: () => setState(() => _diaChiId = address.diaChiId),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(
            title: 'Loại rác',
            subtitle: 'Dựa theo schema loai_rac và dich_vu_gia_bieu',
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 680 ? 3 : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: columns == 1 ? 3.45 : 1.28,
                children: [
                  for (final waste in wastes)
                    WasteOptionCard(
                      waste: waste,
                      price: findPrice(prices, waste.loaiRacId),
                      selected: _loaiRacId == waste.loaiRacId,
                      onTap: () => setState(() => _loaiRacId = waste.loaiRacId),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(
            title: 'Thời gian và khối lượng',
            subtitle: 'Chọn khung giờ khách có thể bàn giao rác',
          ),
          const SizedBox(height: AppSpacing.sm),
          ScheduleCard(
            ngayThuGom: _ngayThuGom,
            khungGio: _khungGio,
            timeSlots: timeSlots,
            kgController: _kgController,
            onPickDate: _pickDate,
            onSelectSlot: (slot) => setState(() => _khungGio = slot),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(
            title: 'Cách tính phí',
            subtitle: 'Gói tháng sẽ được ưu tiên nếu còn hạn mức',
          ),
          const SizedBox(height: AppSpacing.sm),
          _PaymentMethodSection(
            paymentMethod: _hinhThucTinhPhi,
            package: package,
            subscription: subscription,
            selectedPrice: selectedPrice,
            onChanged: (value) => setState(() => _hinhThucTinhPhi = value),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          TextField(
            controller: _noteController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Ghi chú cho nhân viên',
              hintText: 'Ví dụ: rác để trước cổng, gọi trước khi đến...',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          OrderPreviewCard(
            address: selectedAddress,
            waste: selectedWaste,
            staff: suggestedStaff,
            kg: kg,
            date: _ngayThuGom,
            timeSlot: _khungGio,
            paymentMethod: _hinhThucTinhPhi,
            estimate: estimate,
          ),
          const SizedBox(height: AppSpacing.md),
          BookingSubmitPanel(
            canSubmit: canSubmit,
            estimate: estimate,
            staffLabel: suggestedStaff == null
                ? 'Đang tìm nhân viên'
                : 'Gửi đến ${suggestedStaff.maNhanVien}',
            onSubmit: () => _createOrder(user),
          ),
        ],
      ),
    );
  }

  double? get _selectedKg {
    final value = double.tryParse(_kgController.text.replaceAll(',', '.'));
    if (value == null || value <= 0) return null;
    return value;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _ngayThuGom,
      firstDate: DateTime(2026, 7, 8),
      lastDate: DateTime(2026, 12, 31),
    );
    if (picked != null) {
      setState(() => _ngayThuGom = picked);
    }
  }

  void _createOrder(AppUser user) {
    final kg = _selectedKg;
    if (_diaChiId == null ||
        _loaiRacId == null ||
        _khungGio == null ||
        kg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại thông tin đặt lịch.'),
        ),
      );
      return;
    }

    final order = ref
        .read(orderControllerProvider.notifier)
        .createOrder(
          khachHangId: user.userId,
          diaChiId: _diaChiId!,
          loaiRacId: _loaiRacId!,
          khoiLuongDuKien: kg,
          ngayThuGom: _ngayThuGom,
          khungGio: _khungGio!,
          hinhThucTinhPhi: _hinhThucTinhPhi,
          ghiChu: _noteController.text.trim(),
        );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => OrderDetailScreen(maDon: order.maDon)),
    );
  }

  void _refreshEstimate() {
    if (mounted) setState(() {});
  }
}

class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection({
    required this.paymentMethod,
    required this.package,
    required this.subscription,
    required this.selectedPrice,
    required this.onChanged,
  });

  final String paymentMethod;
  final PickupPackage? package;
  final PackageSubscription? subscription;
  final PriceItem? selectedPrice;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final packageMethod = PaymentMethodCard(
      selected: paymentMethod == 'GOI_THANG',
      icon: Icons.inventory_2_outlined,
      title: 'Gói tháng',
      subtitle: package == null
          ? 'Chưa có gói'
          : '${formatKg(subscription?.soKgConLai ?? package!.hanMucKgThang)} còn lại',
      onTap: () => onChanged('GOI_THANG'),
    );
    final byKgMethod = PaymentMethodCard(
      selected: paymentMethod == 'THEO_KG',
      icon: Icons.scale_outlined,
      title: 'Theo kg',
      subtitle: selectedPrice == null
          ? 'Chưa có giá'
          : '${formatMoney(selectedPrice!.donGiaKg)}/kg',
      onTap: () => onChanged('THEO_KG'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              packageMethod,
              const SizedBox(height: AppSpacing.sm),
              byKgMethod,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: packageMethod),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: byKgMethod),
          ],
        );
      },
    );
  }
}
