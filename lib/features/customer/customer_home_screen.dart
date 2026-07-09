import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/status_mapper.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';
import 'booking_screen.dart';
import 'order_detail_screen.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final orders = ref.watch(customerOrdersProvider);
    final subscription = ref.watch(currentSubscriptionProvider);
    final packages = ref.watch(packagesProvider);
    final package = packages.isEmpty ? null : packages.first;
    final notifications = ref.watch(notificationsProvider);
    final allAddresses = ref.watch(allAddressesProvider);
    final wastes = ref.watch(wasteTypesProvider);
    final staff = ref.watch(staffProfilesProvider);
    final activeOrder = _activeOrder(orders);

    return AppPage(
      maxWidth: 900,
      titleWidget: const BrandWordmark(white: true, width: 210, height: 52),
      appBarHeight: 96,
      title: 'Trang chủ',
      scaffoldBackgroundColor: HomeTrialColors.gray,
      appBarBackgroundColor: HomeTrialColors.green,
      appBarTitleColor: HomeTrialColors.white,
      appBarSubtitleColor: AppColors.opacity(HomeTrialColors.white, 0.82),
      leading: IconButton(
        tooltip: 'Đăng xuất',
        onPressed: () => ref.read(currentSessionProvider.notifier).state = null,
        icon: const Icon(Icons.menu_rounded, size: 32),
      ),
      actions: [
        SizedBox(
          width: kToolbarHeight,
          child: IconButton(
            tooltip: 'Thông báo',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined, size: 32),
          ),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final padding = const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            AppSpacing.xxl,
          );

          final actionColumn = _CustomerActionColumn(
            user: user,
            activeOrder: activeOrder,
            package: package,
            subscription: subscription,
            addresses: allAddresses,
            wastes: wastes,
            staff: staff,
            onBooking: () => _openBooking(context),
          );
          final activityColumn = _CustomerActivityColumn(
            orders: orders,
            notifications: notifications,
            addresses: allAddresses,
            wastes: wastes,
            staff: staff,
            orderLimit: wide ? 5 : 3,
          );

          if (wide) {
            return ListView(
              padding: padding,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: actionColumn),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(flex: 4, child: activityColumn),
                  ],
                ),
              ],
            );
          }

          return ListView(
            padding: padding,
            children: [
              actionColumn,
              const SizedBox(height: AppSpacing.sectionGap),
              activityColumn,
            ],
          );
        },
      ),
    );
  }

  static PickupOrder? _activeOrder(List<PickupOrder> orders) {
    for (final order in orders) {
      if (order.trangThai != 'HOAN_THANH' && order.trangThai != 'HUY') {
        return order;
      }
    }
    return null;
  }

  static void _openBooking(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BookingScreen()));
  }
}

class _CustomerActionColumn extends StatelessWidget {
  const _CustomerActionColumn({
    required this.user,
    required this.activeOrder,
    required this.package,
    required this.subscription,
    required this.addresses,
    required this.wastes,
    required this.staff,
    required this.onBooking,
  });

  final AppUser user;
  final PickupOrder? activeOrder;
  final PickupPackage? package;
  final PackageSubscription? subscription;
  final List<CustomerAddress> addresses;
  final List<WasteType> wastes;
  final List<StaffProfile> staff;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    final selectedOrder = activeOrder;
    final selectedPackage = package;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HomeHeroCard(
          title: 'Xin chào, ${user.hoTen}',
          subtitle: activeOrder == null
              ? 'Đặt lịch thu gom và theo dõi nhân viên xử lý theo thời gian thực.'
              : 'Đơn của bạn đang được xử lý. GreenTrash sẽ cập nhật từng bước.',
          actionLabel: 'Đặt đơn mới',
          onAction: onBooking,
        ),
        const SizedBox(height: AppSpacing.md),
        _LiveOrderCard(
          order: selectedOrder,
          address: selectedOrder == null
              ? null
              : _findAddress(addresses, selectedOrder.diaChiId),
          waste: selectedOrder == null
              ? null
              : _findWaste(wastes, selectedOrder.loaiRacId),
          staffProfile: selectedOrder == null
              ? null
              : _findStaff(
                  staff,
                  selectedOrder.nhanVienHienTaiId ??
                      selectedOrder.nhanVienDeXuatId,
                ),
          onBooking: onBooking,
        ),
        const SizedBox(height: AppSpacing.md),
        if (selectedPackage != null)
          _SubscriptionCard(
            subscription: subscription,
            package: selectedPackage,
          )
        else
          const EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'Chưa có gói thu gom',
            message: 'Gói tháng hiện tại sẽ hiển thị tại đây.',
          ),
        const SizedBox(height: AppSpacing.md),
        _HomeSearchBar(
          hint: 'Tìm loại rác bạn muốn thu gom?',
          onTap: onBooking,
        ),
        const SizedBox(height: AppSpacing.md),
        _HomePrimaryButton(
          label: 'Lập Đơn Thu Gom Mới',
          icon: Icons.add_task_outlined,
          onPressed: onBooking,
        ),
      ],
    );
  }
}

class _HomeHeroCard extends StatelessWidget {
  const _HomeHeroCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [HomeTrialColors.green, HomeTrialColors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              bottom: -18,
              child: Icon(
                Icons.recycling,
                color: AppColors.opacity(HomeTrialColors.white, 0.13),
                size: 148,
              ),
            ),
            Positioned(
              top: 22,
              right: 98,
              child: Icon(
                Icons.eco_outlined,
                color: AppColors.opacity(HomeTrialColors.amber, 0.78),
                size: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: HomeTrialColors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.opacity(
                                  HomeTrialColors.white,
                                  0.90,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          height: 40,
                          child: FilledButton.icon(
                            onPressed: onAction,
                            style: FilledButton.styleFrom(
                              backgroundColor: HomeTrialColors.white,
                              foregroundColor: HomeTrialColors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.add_task_outlined, size: 18),
                            label: Text(actionLabel),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.opacity(HomeTrialColors.white, 0.16),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      border: Border.all(
                        color: AppColors.opacity(HomeTrialColors.white, 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: HomeTrialColors.white,
                      size: 38,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: HomeTrialColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: HomeTrialColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 21, color: HomeTrialColors.muted),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                hint,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: HomeTrialColors.muted),
              ),
            ),
            Container(width: 1, height: 24, color: HomeTrialColors.border),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.qr_code_scanner_outlined,
              size: 21,
              color: HomeTrialColors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePrimaryButton extends StatelessWidget {
  const _HomePrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: HomeTrialColors.green,
          foregroundColor: HomeTrialColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _LiveOrderCard extends StatelessWidget {
  const _LiveOrderCard({
    required this.order,
    required this.address,
    required this.waste,
    required this.staffProfile,
    required this.onBooking,
  });

  final PickupOrder? order;
  final CustomerAddress? address;
  final WasteType? waste;
  final StaffProfile? staffProfile;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    final currentOrder = order;
    if (currentOrder == null) {
      return Card(
        color: HomeTrialColors.white,
        shape: _homeCardShape(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: HomeTrialColors.greenSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.add_location_alt_outlined,
                  color: HomeTrialColors.green,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sẵn sàng đặt lịch',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Tạo đơn mới để hệ thống gửi cho nhân viên gần bạn.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Đặt đơn',
                onPressed: onBooking,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      );
    }

    final assignedStaff = staffProfile;
    final message = switch (currentOrder.trangThai) {
      'CHO_XU_LY' =>
        assignedStaff == null
            ? 'Đang tìm nhân viên gần khu vực của bạn.'
            : 'Đã gửi thông báo đến ${assignedStaff.maNhanVien}.',
      'DA_NHAN' =>
        assignedStaff == null
            ? 'Nhân viên đã nhận đơn.'
            : '${assignedStaff.maNhanVien} đã nhận đơn.',
      'DANG_DEN' => 'Nhân viên đang di chuyển đến điểm lấy.',
      'DA_DEN' => 'Nhân viên đã đến điểm lấy.',
      'DANG_CAN_RAC' => 'Nhân viên đang kiểm tra và cân rác.',
      _ => 'Đơn đang được cập nhật.',
    };

    return Card(
      color: HomeTrialColors.white,
      shape: _homeCardShape(),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(maDon: currentOrder.maDon),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Đơn đang theo dõi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HomeTrialColors.slate,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _HomeStatusChip(status: currentOrder.trangThai),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${currentOrder.maDon} • ${formatDayMonth(currentOrder.ngayThuGom)} • ${currentOrder.khungGio}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HomeTrialColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoLine(
                icon: Icons.notifications_active_outlined,
                text: message,
              ),
              const SizedBox(height: AppSpacing.sm),
              _InfoLine(
                icon: Icons.delete_outline,
                text:
                    '${waste?.tenLoaiRac ?? currentOrder.loaiRacId} • ${formatKg(currentOrder.khoiLuongDuKien)}',
              ),
              const SizedBox(height: AppSpacing.sm),
              _InfoLine(
                icon: Icons.place_outlined,
                text: address?.shortAddress ?? currentOrder.diaChiId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.subscription, required this.package});

  final PackageSubscription? subscription;
  final PickupPackage package;

  @override
  Widget build(BuildContext context) {
    final used = subscription?.soKgDaDung ?? 0;
    final remaining = subscription?.soKgConLai ?? package.hanMucKgThang;
    final total = used + remaining;
    final progress = total == 0
        ? 0.0
        : (used / total).clamp(0.0, 1.0).toDouble();

    return Card(
      color: HomeTrialColors.white,
      shape: _homeCardShape(),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: HomeTrialColors.greenSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: HomeTrialColors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.tenGoi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: HomeTrialColors.slate,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      _PaymentStatusBadge(
                        label: paymentStatusLabel(
                          subscription?.trangThai ?? 'CON_HL',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: HomeTrialColors.amberSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_outlined,
                    color: HomeTrialColors.amber,
                    size: 21,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: HomeTrialColors.greenSoft,
              color: HomeTrialColors.green,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(child: _PackageStat(value: formatKg(used))),
                Expanded(
                  child: _PackageStat(
                    value: formatKg(remaining),
                    align: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: _PackageStat(
                    value: formatMoney(package.phiVuotGoi),
                    align: TextAlign.right,
                    color: HomeTrialColors.green,
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

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomeTrialColors.greenSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: HomeTrialColors.green,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CustomerActivityColumn extends StatelessWidget {
  const _CustomerActivityColumn({
    required this.orders,
    required this.notifications,
    required this.addresses,
    required this.wastes,
    required this.staff,
    required this.orderLimit,
  });

  final List<PickupOrder> orders;
  final List<AppNotification> notifications;
  final List<CustomerAddress> addresses;
  final List<WasteType> wastes;
  final List<StaffProfile> staff;
  final int orderLimit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomeSectionHeader(
          title: 'Đơn gần đây',
          subtitle: 'Theo dõi các đơn đã đặt',
          trailing: Text(
            '${orders.length} đơn',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HomeTrialColors.green,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (orders.isEmpty)
          const EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'Chưa có đơn thu gom',
            message: 'Các đơn đã đặt sẽ xuất hiện tại đây.',
          )
        else
          ...orders
              .take(orderLimit)
              .map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _RecentOrderCard(
                    order: order,
                    address: _findAddress(addresses, order.diaChiId),
                    waste: _findWaste(wastes, order.loaiRacId),
                    staffProfile: _findStaff(
                      staff,
                      order.nhanVienHienTaiId ?? order.nhanVienDeXuatId,
                    ),
                  ),
                ),
              ),
        const SizedBox(height: AppSpacing.lg),
        const _HomeSectionHeader(
          title: 'Thông báo',
          subtitle: 'Cập nhật mới nhất',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (notifications.isEmpty)
          const EmptyState(
            icon: Icons.notifications_none,
            title: 'Không có thông báo mới',
            message: 'Khi có cập nhật về đơn, bạn sẽ thấy tại đây.',
          )
        else
          ...notifications
              .take(3)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _NotificationCard(notification: item),
                ),
              ),
      ],
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: HomeTrialColors.slate,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HomeTrialColors.muted),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _HomeStatusChip extends StatelessWidget {
  const _HomeStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = orderStatusStyle(status).label;
    final color = _homeStatusColor(status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _homeStatusBackground(status),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_homeStatusIcon(status), size: 13, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _homeStatusColor(String status) {
  return switch (status) {
    'CHO_XU_LY' || 'CHO_NHAN' => HomeTrialColors.amber,
    'DA_NHAN' || 'HOAN_THANH' => HomeTrialColors.green,
    'DANG_DEN' || 'DA_DEN' || 'DANG_CAN_RAC' => HomeTrialColors.blue,
    'HUY' => HomeTrialColors.slate,
    _ => HomeTrialColors.purple,
  };
}

Color _homeStatusBackground(String status) {
  return switch (status) {
    'CHO_XU_LY' || 'CHO_NHAN' => HomeTrialColors.amberSoft,
    'DA_NHAN' || 'HOAN_THANH' => HomeTrialColors.greenSoft,
    'DANG_DEN' || 'DA_DEN' || 'DANG_CAN_RAC' => HomeTrialColors.blueSoft,
    'HUY' => HomeTrialColors.slateSoft,
    _ => HomeTrialColors.purpleSoft,
  };
}

IconData _homeStatusIcon(String status) {
  return switch (status) {
    'CHO_XU_LY' || 'CHO_NHAN' => Icons.schedule,
    'DA_NHAN' || 'HOAN_THANH' => Icons.check_circle_outline,
    'DANG_DEN' || 'DA_DEN' || 'DANG_CAN_RAC' => Icons.sync_outlined,
    'HUY' => Icons.cancel_outlined,
    _ => Icons.info_outline,
  };
}

RoundedRectangleBorder _homeCardShape() {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.xl),
    side: const BorderSide(color: HomeTrialColors.border),
  );
}

class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard({
    required this.order,
    required this.address,
    required this.waste,
    required this.staffProfile,
  });

  final PickupOrder order;
  final CustomerAddress? address;
  final WasteType? waste;
  final StaffProfile? staffProfile;

  @override
  Widget build(BuildContext context) {
    final assignedStaff = staffProfile;
    final assigneeLabel = assignedStaff == null
        ? 'Đang tìm nhân viên'
        : order.nhanVienHienTaiId == null
        ? 'Đã báo ${assignedStaff.maNhanVien}'
        : '${assignedStaff.maNhanVien} đã nhận';
    final statusColor = _homeStatusColor(order.trangThai);

    return Card(
      color: HomeTrialColors.white,
      shape: _homeCardShape(),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(maDon: order.maDon),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _homeStatusBackground(order.trangThai),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      _homeStatusIcon(order.trangThai),
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.maDon,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: HomeTrialColors.slate,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '${formatDayMonth(order.ngayThuGom)} • ${order.khungGio}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: HomeTrialColors.muted),
                        ),
                      ],
                    ),
                  ),
                  _HomeStatusChip(status: order.trangThai),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoLine(
                icon: Icons.delete_outline,
                text:
                    '${waste?.tenLoaiRac ?? order.loaiRacId} • ${formatKg(order.khoiLuongDuKien)}',
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InfoLine(
                      icon: Icons.place_outlined,
                      text: address?.shortAddress ?? order.diaChiId,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: Text(
                      assigneeLabel,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: HomeTrialColors.white,
      shape: _homeCardShape(),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: notification.trangThaiDoc == 'CHUA_DOC'
                    ? HomeTrialColors.blueSoft
                    : HomeTrialColors.purpleSoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.notifications_none,
                color: notification.trangThaiDoc == 'CHUA_DOC'
                    ? HomeTrialColors.blue
                    : HomeTrialColors.purple,
                size: 19,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.tieuDe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: HomeTrialColors.slate,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    notification.noiDung,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: HomeTrialColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (notification.trangThaiDoc == 'CHUA_DOC')
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: HomeTrialColors.amber,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PackageStat extends StatelessWidget {
  const _PackageStat({
    required this.value,
    this.align = TextAlign.left,
    this.color,
  });

  final String value;
  final TextAlign align;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      textAlign: align,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: color ?? HomeTrialColors.slate,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: HomeTrialColors.slate),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
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

StaffProfile? _findStaff(List<StaffProfile> staff, String? id) {
  if (id == null) return null;
  for (final profile in staff) {
    if (profile.nhanVienId == id) return profile;
  }
  return null;
}
