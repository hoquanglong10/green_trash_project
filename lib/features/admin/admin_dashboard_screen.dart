import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';
import '../../shared/widgets/dashboard_shell.dart';
import '../customer/order_detail_screen.dart';
import 'admin_assignment_screen.dart';

void _noop() {}

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        body: AppLoadingView(message: 'Đang tải bảng điều phối...'),
      );
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

    void openAssignments() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AdminAssignmentScreen()),
      );
    }

    return DashboardShell(
      maxContentWidth: 1120,
      selectedIndex: 0,
      destinations: [
        const DashboardDestination(
          icon: Icons.space_dashboard_outlined,
          selectedIcon: Icons.space_dashboard_rounded,
          label: 'Tổng quan',
          onSelected: _noop,
        ),
        DashboardDestination(
          icon: Icons.rule_folder_outlined,
          selectedIcon: Icons.rule_folder_rounded,
          label: 'Ngoại lệ',
          onSelected: openAssignments,
        ),
      ],
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: Center(
            child: Text(
              user.hoTen,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Đăng xuất',
          onPressed: () async {
            await ref.read(firebaseAuthenticationServiceProvider).signOut();
            ref.read(currentSessionProvider.notifier).state = null;
          },
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
            title: 'Tổng quan vận hành',
            subtitle:
                'Theo dõi khối lượng công việc và các trường hợp cần xử lý.',
            trailing: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.opacity(AppColors.white, 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.monitor_heart_outlined,
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
                  onPressed: openAssignments,
                  icon: const Icon(Icons.rule_folder_outlined),
                  label: const Text('Xử lý ngoại lệ phân công'),
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
            (profile) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _StaffAvailabilityRow(profile: profile),
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

class _StaffAvailabilityRow extends StatelessWidget {
  const _StaffAvailabilityRow({required this.profile});

  final StaffProfile profile;

  @override
  Widget build(BuildContext context) {
    final available = profile.trangThaiLamViec == 'SAN_SANG';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            available ? Icons.radio_button_checked : Icons.schedule_rounded,
            color: available ? AppColors.success : AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.maNhanVien,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${profile.gioBatDau}-${profile.gioKetThuc} • ${profile.viTriHienTai}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            available ? 'Sẵn sàng' : 'Bận',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: available ? AppColors.success : AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
