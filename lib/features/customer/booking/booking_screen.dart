import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../orders/application/order_workflow_providers.dart';
import '../../orders/domain/order_workflow_models.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../address_book/presentation/address_book_screen.dart';
import '../address_book/presentation/address_form_screen.dart';
import '../order_detail_screen.dart';
import 'booking_calculator.dart';
import 'widgets/address_option_card.dart';
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
  late DateTime _ngayThuGom;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final slots = ref.read(timeSlotsProvider);
    _ngayThuGom = defaultBookingDate(now, slots);
    final availableSlots = availableTimeSlots(
      date: _ngayThuGom,
      timeSlots: slots,
      now: now,
    );
    _khungGio = availableSlots.isEmpty ? null : availableSlots.first;
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
      return const Scaffold(
        body: AppLoadingView(message: 'Đang chuẩn bị biểu mẫu...'),
      );
    }

    final addresses = ref.watch(customerAddressesProvider);
    final wastes = ref.watch(wasteTypesProvider);
    final prices = ref.watch(pricesProvider);
    final allTimeSlots = ref.watch(timeSlotsProvider);
    final staff = ref.watch(staffProfilesProvider);
    final subscription = ref.watch(currentSubscriptionProvider);
    final packages = ref.watch(packagesProvider);
    final package = packages.isEmpty ? null : packages.first;
    final customerOrders = ref.watch(customerOrdersProvider);
    final now = DateTime.now();
    final timeSlots = availableTimeSlots(
      date: _ngayThuGom,
      timeSlots: allTimeSlots,
      now: now,
    );
    final selectedSlot = timeSlots.contains(_khungGio) ? _khungGio : null;
    final hasActivePackage =
        subscription != null &&
        subscription.trangThai == 'CON_HL' &&
        package != null;
    final paymentMethod = hasActivePackage ? _hinhThucTinhPhi : 'THEO_KG';

    _diaChiId ??= addresses.isNotEmpty ? addresses.first.diaChiId : null;
    _loaiRacId ??= wastes.isNotEmpty ? wastes.first.loaiRacId : null;

    final selectedAddress = findAddress(addresses, _diaChiId);
    final selectedWaste = findWaste(wastes, _loaiRacId);
    final selectedPrice = findPrice(prices, _loaiRacId);
    final suggestedStaff = suggestedStaffForAddress(
      staff: staff,
      address: selectedAddress,
    );
    final kg = _selectedKg;
    final estimate = estimatePaymentLabel(
      paymentMethod: paymentMethod,
      price: selectedPrice,
      kg: kg,
      subscription: subscription,
      package: package,
    );
    final validation = validateBooking(
      address: selectedAddress,
      waste: selectedWaste,
      kg: kg,
      pickupDate: _ngayThuGom,
      timeSlot: selectedSlot,
      availableSlots: timeSlots,
      paymentMethod: paymentMethod,
      subscription: subscription,
      package: package,
      customerOrders: customerOrders,
      now: now,
    );

    final stepCanContinue = switch (_step) {
      0 => selectedAddress?.hasPickupCoordinate == true,
      1 => selectedWaste != null,
      2 => kg != null && selectedSlot != null,
      _ => validation.canSubmit,
    };

    final stepBody = switch (_step) {
      0 => ListView(
        key: const ValueKey('booking-address-step'),
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          SectionHeader(
            title: 'Địa chỉ lấy rác',
            subtitle: 'Nhân viên sẽ đến địa chỉ bạn chọn',
            trailing: addresses.isEmpty
                ? null
                : TextButton(
                    onPressed: _openAddressBook,
                    child: const Text('Quản lý'),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (addresses.isEmpty)
            Column(
              children: [
                const EmptyState(
                  icon: Icons.place_outlined,
                  title: 'Chưa có địa chỉ',
                  message: 'Thêm địa chỉ đầu tiên để tạo đơn thu gom.',
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryActionButton(
                  label: 'Thêm địa chỉ',
                  icon: Icons.add_location_alt_outlined,
                  onPressed: _addAddress,
                ),
              ],
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
        ],
      ),
      1 => ListView(
        key: const ValueKey('booking-waste-step'),
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          const SectionHeader(
            title: 'Bạn muốn thu gom gì?',
            subtitle: 'Chọn một nhóm rác để hệ thống ước tính chi phí',
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 620 ? 3 : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: columns == 1 ? 3.25 : 1.24,
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
        ],
      ),
      2 => ListView(
        key: const ValueKey('booking-schedule-step'),
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          const SectionHeader(
            title: 'Chọn lịch và khối lượng',
            subtitle: 'Đảm bảo bạn có mặt trong khung giờ đã chọn',
          ),
          const SizedBox(height: AppSpacing.md),
          ScheduleCard(
            ngayThuGom: _ngayThuGom,
            khungGio: selectedSlot,
            timeSlots: timeSlots,
            kgController: _kgController,
            onPickDate: _pickDate,
            onSelectSlot: (slot) => setState(() => _khungGio = slot),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            title: 'Cách tính phí',
            subtitle: 'Gói tháng được ưu tiên khi còn hạn mức',
          ),
          const SizedBox(height: AppSpacing.md),
          _PaymentMethodSection(
            paymentMethod: _hinhThucTinhPhi,
            package: package,
            subscription: subscription,
            selectedPrice: selectedPrice,
            packageAvailable: hasActivePackage,
            onChanged: (value) => setState(() => _hinhThucTinhPhi = value),
          ),
          const SizedBox(height: AppSpacing.xl),
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
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
      _ => ListView(
        key: const ValueKey('booking-review-step'),
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          const SectionHeader(
            title: 'Kiểm tra lại đơn',
            subtitle: 'Xác nhận thông tin trước khi gửi đến nhân viên',
          ),
          const SizedBox(height: AppSpacing.md),
          OrderPreviewCard(
            address: selectedAddress,
            waste: selectedWaste,
            staff: suggestedStaff,
            kg: kg,
            date: _ngayThuGom,
            timeSlot: selectedSlot,
            paymentMethod: paymentMethod,
            estimate: estimate,
          ),
          if (validation.message != null) ...[
            const SizedBox(height: AppSpacing.md),
            _BookingWarning(message: validation.message!),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    };

    return AppPage(
      maxWidth: 760,
      title: 'Đặt lịch thu gom',
      subtitle: 'Bước ${_step + 1} trên 4',
      child: Column(
        children: [
          _BookingProgress(currentStep: _step),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.standard,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.035, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: stepBody,
            ),
          ),
          _BookingWizardFooter(
            currentStep: _step,
            canContinue: stepCanContinue,
            estimate: estimate,
            staffLabel: suggestedStaff == null
                ? 'Đơn sẽ vào hàng chờ hỗ trợ'
                : 'Gửi đến ${suggestedStaff.maNhanVien}',
            onBack: _step == 0 ? null : () => setState(() => _step--),
            onContinue: () {
              if (_step < 3) {
                setState(() => _step++);
                return;
              }
              _createOrder(
                user,
                validation: validation,
                paymentMethod: paymentMethod,
                selectedSlot: selectedSlot,
              );
            },
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
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _ngayThuGom,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 90)),
    );
    if (picked != null) {
      final availableSlots = availableTimeSlots(
        date: picked,
        timeSlots: ref.read(timeSlotsProvider),
        now: now,
      );
      setState(() {
        _ngayThuGom = picked;
        _khungGio = availableSlots.isEmpty ? null : availableSlots.first;
      });
    }
  }

  Future<void> _addAddress() async {
    final addressId = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const AddressFormScreen()),
    );
    if (!mounted || addressId == null) return;
    setState(() => _diaChiId = addressId);
  }

  Future<void> _openAddressBook() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddressBookScreen()));
    if (!mounted) return;
    final addresses = ref.read(customerAddressesProvider);
    if (addresses.isEmpty) return;
    final selectedStillExists = addresses.any(
      (address) => address.diaChiId == _diaChiId,
    );
    if (!selectedStillExists) {
      setState(() => _diaChiId = addresses.first.diaChiId);
    }
  }

  Future<void> _createOrder(
    AppUser user, {
    required BookingValidation validation,
    required String paymentMethod,
    required String? selectedSlot,
  }) async {
    final kg = _selectedKg;
    if (!validation.canSubmit ||
        _diaChiId == null ||
        _loaiRacId == null ||
        selectedSlot == null ||
        kg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            validation.message ?? 'Vui lòng kiểm tra lại thông tin đặt lịch.',
          ),
        ),
      );
      return;
    }

    try {
      final order = ref.read(firebaseEnabledProvider)
          ? await ref
                .read(orderWorkflowRepositoryProvider)
                .createOrder(
                  CreatePickupOrderCommand(
                    khachHangId: user.userId,
                    diaChiId: _diaChiId!,
                    loaiRacId: _loaiRacId!,
                    khoiLuongDuKien: kg,
                    ngayThuGom: _ngayThuGom,
                    khungGio: selectedSlot,
                    hinhThucTinhPhi: paymentMethod,
                    ghiChu: _noteController.text.trim(),
                  ),
                )
          : ref
                .read(orderControllerProvider.notifier)
                .createOrder(
                  khachHangId: user.userId,
                  diaChiId: _diaChiId!,
                  loaiRacId: _loaiRacId!,
                  khoiLuongDuKien: kg,
                  ngayThuGom: _ngayThuGom,
                  khungGio: selectedSlot,
                  hinhThucTinhPhi: paymentMethod,
                  ghiChu: _noteController.text.trim(),
                );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(maDon: order.maDon),
        ),
      );
    } on OrderWorkflowException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_firebaseBookingMessage(error))));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Khong the tao don luc nay. Vui long thu lai.'),
          ),
        );
      }
    }
  }

  void _refreshEstimate() {
    if (mounted) setState(() {});
  }

  String _firebaseBookingMessage(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Firestore dang tu choi tao don. Can cap nhat Rules cua project truoc khi dat lich.',
      'unauthenticated' =>
        'Phien dang nhap da het han. Vui long dang nhap lai.',
      'unavailable' =>
        'Khong ket noi duoc Firestore. Kiem tra mang roi thu lai.',
      _ => error.message ?? 'Firestore khong the tao don (${error.code}).',
    };
  }
}

class _BookingProgress extends StatelessWidget {
  const _BookingProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const steps = [
      (Icons.location_on_outlined, 'Địa chỉ'),
      (Icons.recycling_rounded, 'Loại rác'),
      (Icons.event_outlined, 'Lịch hẹn'),
      (Icons.task_alt_rounded, 'Xác nhận'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (var index = 0; index < steps.length; index++) ...[
            Expanded(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: AppMotion.fast,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: index < currentStep
                          ? AppColors.primary
                          : index == currentStep
                          ? AppColors.green100
                          : AppColors.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      index < currentStep
                          ? Icons.check_rounded
                          : steps[index].$1,
                      size: 17,
                      color: index < currentStep
                          ? AppColors.textInverse
                          : index == currentStep
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    steps[index].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: index == currentStep
                          ? AppColors.primaryDark
                          : AppColors.textMuted,
                      fontWeight: index == currentStep
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (index < steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 22),
                  color: index < currentStep
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _BookingWizardFooter extends StatelessWidget {
  const _BookingWizardFooter({
    required this.currentStep,
    required this.canContinue,
    required this.estimate,
    required this.staffLabel,
    required this.onBack,
    required this.onContinue,
  });

  final int currentStep;
  final bool canContinue;
  final String estimate;
  final String staffLabel;
  final VoidCallback? onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentStep == 3) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estimate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          staffLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Row(
              children: [
                if (onBack != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Quay lại'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  flex: onBack == null ? 1 : 2,
                  child: FilledButton.icon(
                    onPressed: canContinue ? onContinue : null,
                    icon: Icon(
                      currentStep == 3
                          ? Icons.send_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(currentStep == 3 ? 'Gửi đơn' : 'Tiếp tục'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingWarning extends StatelessWidget {
  const _BookingWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.yellow50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.yellow200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection({
    required this.paymentMethod,
    required this.package,
    required this.subscription,
    required this.selectedPrice,
    required this.packageAvailable,
    required this.onChanged,
  });

  final String paymentMethod;
  final PickupPackage? package;
  final PackageSubscription? subscription;
  final PriceItem? selectedPrice;
  final bool packageAvailable;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final packageMethod = PaymentMethodCard(
      selected: paymentMethod == 'GOI_THANG',
      icon: Icons.inventory_2_outlined,
      title: 'Gói tháng',
      subtitle: package == null
          ? 'Chưa có gói'
          : packageAvailable
          ? '${formatKg(subscription?.soKgConLai ?? package!.hanMucKgThang)} còn lại'
          : 'Gói không còn hiệu lực',
      onTap: packageAvailable ? () => onChanged('GOI_THANG') : null,
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
