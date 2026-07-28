import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../location/application/foreground_location_tracking_controller.dart';
import '../../location/presentation/widgets/live_location_map.dart';
import '../../location/presentation/widgets/location_sharing_card.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/activity_log_card.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/collection_record_card.dart';
import '../../../shared/widgets/payment_summary_card.dart';
import 'staff_order_flow.dart';
import 'staff_order_lookup.dart';
import 'widgets/staff_order_action_bar.dart';
import 'widgets/staff_order_header.dart';
import 'widgets/staff_order_info_card.dart';
import 'widgets/staff_progress_card.dart';

class StaffOrderScreen extends ConsumerStatefulWidget {
  const StaffOrderScreen({super.key, required this.maDon});

  final String maDon;

  @override
  ConsumerState<StaffOrderScreen> createState() => _StaffOrderScreenState();
}

class _StaffOrderScreenState extends ConsumerState<StaffOrderScreen> {
  static const _locationTrackingStatuses = {
    'DANG_DEN',
  };

  String? _trackingStaffId;
  String? _trackingOrderId;

  @override
  void dispose() {
    if (_trackingStaffId != null) {
      ref.read(foregroundLocationTrackerProvider.notifier).stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseEnabled = ref.watch(firebaseEnabledProvider);
    final orders = firebaseEnabled
        ? [
            ...ref.watch(staffOfferOrdersProvider),
            ...ref.watch(staffOrdersProvider),
            ...ref.watch(staffOrderHistoryProvider),
          ]
        : ref.watch(orderControllerProvider);
    final order = findStaffOrder(orders, widget.maDon);
    if (order == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy đơn thu gom.')),
      );
    }

    final addresses = ref.watch(allAddressesProvider);
    final wastes = ref.watch(wasteTypesProvider);
    final users = ref.watch(usersProvider);
    final address = findOrderAddress(addresses, order.diaChiId);
    final waste = findOrderWaste(wastes, order.loaiRacId);
    final customer = findOrderCustomer(users, order.khachHangId);
    final record = ref.watch(collectionRecordProvider(order.maDon));
    final payment = ref.watch(paymentRecordProvider(order.maDon));
    final actualWaste = findOrderWaste(wastes, record?.loaiRacThucTeId);
    final currentUser = ref.watch(currentUserProvider);
    final staffProfile = findOrderStaff(
      ref.watch(staffProfilesProvider),
      currentUser?.userId,
    );
    final shouldTrackLocation =
        firebaseEnabled &&
        currentUser != null &&
        order.nhanVienHienTaiId == currentUser.userId &&
        _locationTrackingStatuses.contains(order.trangThai);
    _syncLocationTracking(
      shouldTrack: shouldTrackLocation,
      staffId: currentUser?.userId,
      maDon: order.maDon,
      address: address,
    );
    final trackingState = shouldTrackLocation
        ? ref.watch(foregroundLocationTrackerProvider)
        : null;
    final logs = [...ref.watch(orderActivityLogsProvider(order.maDon))]
      ..sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
    final canChangeEta =
        currentUser != null &&
        order.nhanVienHienTaiId == currentUser.userId &&
        {'DA_NHAN', 'DANG_DEN'}.contains(order.trangThai);

    return AppPage(
      maxWidth: 760,
      title: order.maDon,
      subtitle: 'Quy trình thu gom',
      bottomNavigationBar: StaffOrderActionBar(order: order),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.md,
          AppSpacing.screenHorizontal,
          AppSpacing.xxl,
        ),
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: StaffOrderHeader(
              key: ValueKey(order.trangThai),
              order: order,
              customer: customer,
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          StaffOrderInfoCard(
            order: order,
            customer: customer,
            address: address,
            waste: waste,
          ),
          if (trackingState != null) ...[
            const SizedBox(height: AppSpacing.md),
            LocationSharingCard(
              state: trackingState,
              onRetry: () => ref
                  .read(foregroundLocationTrackerProvider.notifier)
                  .start(
                    staffId: currentUser!.userId,
                    maDon: order.maDon,
                    diaChiLat: _pickupLatitude(address),
                    diaChiLng: _pickupLongitude(address),
                  ),
            ),
          ],
          if (shouldTrackLocation &&
              address != null &&
              staffProfile?.hasLiveLocation == true) ...[
            const SizedBox(height: AppSpacing.md),
            LiveLocationMap(destination: address, staff: staffProfile),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: customer == null
                      ? null
                      : () => _showMockMessage(
                          context,
                          'Đang mở cuộc gọi đến ${customer.soDienThoai} (mock).',
                        ),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Gọi khách'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: address == null
                      ? null
                      : () => _showMockMessage(
                          context,
                          'Đã chọn ${address.shortAddress} trên bản đồ (mock).',
                        ),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Bản đồ'),
                ),
              ),
            ],
          ),
          if (canChangeEta) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => changeStaffArrivalTime(
                  context,
                  ref,
                  order: order,
                  staffId: currentUser.userId,
                ),
                icon: const Icon(Icons.update_outlined),
                label: const Text('Cập nhật giờ đến dự kiến'),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(
            title: 'Tiến trình xử lý',
            subtitle: 'Cập nhật đúng thứ tự để khách hàng theo dõi',
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: StaffProgressCard(
              key: ValueKey('progress-${order.trangThai}'),
              order: order,
            ),
          ),
          if (record != null) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            CollectionRecordCard(
              record: record,
              waste: actualWaste,
              title: 'Biên bản đã lưu',
            ),
          ],
          if (payment != null) ...[
            const SizedBox(height: AppSpacing.md),
            PaymentSummaryCard(payment: payment),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(
            title: 'Lịch sử cập nhật',
            subtitle: 'Mọi thao tác của đơn được lưu theo thời gian',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (logs.isEmpty)
            const EmptyState(
              icon: Icons.history,
              title: 'Chưa có cập nhật',
              message: 'Các bước xử lý sẽ xuất hiện tại đây.',
            )
          else
            ...logs.map(
              (log) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ActivityLogCard(log: log),
              ),
            ),
        ],
      ),
    );
  }

  void _showMockMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _syncLocationTracking({
    required bool shouldTrack,
    required String? staffId,
    required String maDon,
    required CustomerAddress? address,
  }) {
    if (shouldTrack && staffId != null) {
      if (_trackingStaffId == staffId && _trackingOrderId == maDon) return;
      _trackingStaffId = staffId;
      _trackingOrderId = maDon;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            _trackingStaffId != staffId ||
            _trackingOrderId != maDon) {
          return;
        }
        ref
            .read(foregroundLocationTrackerProvider.notifier)
            .start(
              staffId: staffId,
              maDon: maDon,
              diaChiLat: _pickupLatitude(address),
              diaChiLng: _pickupLongitude(address),
            );
      });
      return;
    }

    if (_trackingStaffId == null) return;
    _trackingStaffId = null;
    _trackingOrderId = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(foregroundLocationTrackerProvider.notifier).stop();
    });
  }

  static double? _pickupLatitude(CustomerAddress? address) {
    if (address == null || address.toaDoLat == 0 || address.toaDoLng == 0) {
      return null;
    }
    return address.toaDoLat;
  }

  static double? _pickupLongitude(CustomerAddress? address) {
    if (address == null || address.toaDoLat == 0 || address.toaDoLng == 0) {
      return null;
    }
    return address.toaDoLng;
  }
}
