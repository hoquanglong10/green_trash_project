import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';
import '../customer/order_detail_screen.dart';
import 'admin_assignment_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final orders = ref.watch(adminOrdersProvider);
    final addresses = ref.watch(allAddressesProvider);
    final wastes = ref.watch(wasteTypesProvider);
    final staff = ref.watch(staffProfilesProvider);
    final pending = orders
        .where((order) => order.trangThai == 'CHO_XU_LY')
        .toList();
    final completed = orders
        .where((order) => order.trangThai == 'HOAN_THANH')
        .length;
    final totalKg = orders.fold<double>(
      0,
      (sum, order) => sum + order.khoiLuongDuKien,
    );

    return AppPage(
      title: 'Điều phối GreenTrash',
      subtitle: '${user.hoTen} • ADMIN',
      actions: [
        IconButton(
          tooltip: 'Đăng xuất',
          onPressed: () =>
              ref.read(currentSessionProvider.notifier).state = null,
          icon: const Icon(Icons.logout),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.sm,
          AppSpacing.screenHorizontal,
          AppSpacing.xxl,
        ),
        children: [
          HomeBrandHeader(
            title: 'Bảng điều phối hôm nay',
            subtitle: 'Theo dõi đơn, nhân viên và phân công thu gom.',
            trailing: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.opacity(AppColors.white, 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.accent),
              ),
              child: const Icon(
                Icons.dashboard_outlined,
                color: AppColors.textInverse,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 620;
              final cards = [
                MetricCard(
                  label: 'Tổng đơn',
                  value: orders.length.toString(),
                  icon: Icons.inventory_2_outlined,
                ),
                MetricCard(
                  label: 'Chờ xử lý',
                  value: pending.length.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.primaryDark,
                ),
                MetricCard(
                  label: 'Hoàn thành',
                  value: completed.toString(),
                  icon: Icons.verified_outlined,
                  color: AppColors.success,
                ),
                MetricCard(
                  label: 'Kg dự kiến',
                  value: formatKg(totalKg),
                  icon: Icons.scale_outlined,
                  color: AppColors.primaryDark,
                ),
              ];
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: narrow ? 2 : 4,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: narrow ? 1.6 : 1.45,
                children: cards,
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdminAssignmentScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment_ind_outlined),
                  label: const Text('Phân công đơn'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(title: 'Đơn cần xử lý'),
          const SizedBox(height: AppSpacing.sm),
          if (pending.isEmpty)
            const EmptyState(
              icon: Icons.task_alt,
              title: 'Không có đơn chờ xử lý',
              message: 'Các đơn mới sẽ xuất hiện tại đây.',
            )
          else
            ...pending.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: OrderCard(
                  order: order,
                  address: _findAddress(addresses, order.diaChiId),
                  wasteType: _findWaste(wastes, order.loaiRacId),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(maDon: order.maDon),
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Nhân viên đang sẵn sàng'),
          const SizedBox(height: AppSpacing.sm),
          ...staff.map(
            (profile) => Card(
              child: ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(profile.maNhanVien),
                subtitle: Text(
                  '${profile.gioBatDau}-${profile.gioKetThuc} • ${profile.viTriHienTai}',
                ),
                trailing: Text(
                  profile.trangThaiLamViec == 'SAN_SANG'
                      ? 'Sẵn sàng'
                      : profile.trangThaiLamViec,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  CustomerAddress? _findAddress(List<CustomerAddress> addresses, String id) {
    for (final address in addresses) {
      if (address.diaChiId == id) return address;
    }
    return null;
  }

  WasteType? _findWaste(List<WasteType> wastes, String id) {
    for (final waste in wastes) {
      if (waste.loaiRacId == id) return waste;
    }
    return null;
  }
}
