import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_widgets.dart';
import 'order_detail_lookup.dart';
import 'widgets/activity_log_card.dart';
import 'widgets/detail_actions_card.dart';
import 'widgets/detail_info_card.dart';
import 'widgets/tracking_hero.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.maDon});

  final String maDon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = findOrder(ref.watch(orderControllerProvider), maDon);
    final session = ref.watch(currentSessionProvider);

    if (order == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy đơn thu gom.')),
      );
    }

    final selectedOrder = order;
    final addresses = ref.watch(allAddressesProvider);
    final wastes = ref.watch(wasteTypesProvider);
    final staff = ref.watch(staffProfilesProvider);
    final logs =
        ref
            .watch(activityLogsProvider)
            .where((log) => log.maDon == selectedOrder.maDon)
            .toList()
          ..sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
    final address = findAddress(addresses, selectedOrder.diaChiId);
    final waste = findWaste(wastes, selectedOrder.loaiRacId);
    final staffProfile = findStaff(
      staff,
      selectedOrder.nhanVienHienTaiId ?? selectedOrder.nhanVienDeXuatId,
    );

    return AppPage(
      maxWidth: 760,
      title: selectedOrder.maDon,
      subtitle: 'Chi tiết đơn thu gom',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.md,
          AppSpacing.screenHorizontal,
          AppSpacing.xxl,
        ),
        children: [
          TrackingHero(order: selectedOrder, staff: staffProfile),
          const SizedBox(height: AppSpacing.sectionGap),
          DetailInfoCard(
            order: selectedOrder,
            address: address,
            waste: waste,
            staff: staffProfile,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(
            title: 'Tiến trình',
            subtitle: 'Trạng thái xử lý theo thời gian thực',
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: OrderTimeline(status: selectedOrder.trangThai),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(
            title: 'Hoạt động gần đây',
            subtitle: 'Các mốc cập nhật của đơn',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (logs.isEmpty)
            const EmptyState(
              icon: Icons.history,
              title: 'Chưa có hoạt động mới',
              message: 'Khi nhân viên cập nhật, lịch sử sẽ hiển thị tại đây.',
            )
          else
            ...logs.map(
              (log) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ActivityLogCard(log: log),
              ),
            ),
          if (session?.role == UserRole.customer &&
              selectedOrder.trangThai != 'HOAN_THANH') ...[
            const SizedBox(height: AppSpacing.sectionGap),
            DetailActionsCard(order: selectedOrder),
          ],
        ],
      ),
    );
  }
}
