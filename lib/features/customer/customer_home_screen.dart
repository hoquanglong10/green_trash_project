import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/status_mapper.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';
import '../../shared/widgets/dashboard_shell.dart';
import '../../shared/widgets/home_dashboard_widgets.dart';
import '../notifications/presentation/customer_notifications_screen.dart';
import '../notifications/presentation/widgets/notification_bell.dart';
import '../orders/presentation/order_history_screen.dart';
import 'address_book/presentation/address_book_screen.dart';
import 'booking_screen.dart';
import 'customer_feature_menu_screen.dart';
import 'order_detail_screen.dart';
import 'secondary/application/customer_secondary_providers.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        body: AppLoadingView(message: 'Đang chuẩn bị trang chủ...'),
      );
    }

    final orders = ref.watch(customerOrdersProvider);
    final addresses = ref.watch(allAddressesProvider);
    final wastes = ref.watch(wasteTypesProvider);
    final staff = ref.watch(staffProfilesProvider);
    final notifications = ref.watch(notificationsProvider);
    final subscription = ref.watch(
      customerSecondaryCurrentSubscriptionProvider,
    );
    final packages = ref.watch(packagesProvider);
    final package = _findPackageForSubscription(packages, subscription);
    final activeOrder = _findActiveOrder(orders);
    final recentOrders = orders
        .where((order) => order.maDon != activeOrder?.maDon)
        .take(2)
        .toList();

    void openBooking() {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const BookingScreen()));
    }

    void openHistory() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const OrderHistoryScreen(audience: OrderHistoryAudience.customer),
        ),
      );
    }

    void openNotifications() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CustomerNotificationsScreen()),
      );
    }

    void openAddressBook() {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AddressBookScreen()));
    }

    void openCustomerFeatures() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const CustomerFeatureMenuScreen(),
        ),
      );
    }

    return DashboardShell(
      maxContentWidth: 1120,
      drawer: _CustomerDrawer(
        user: user,
        onCustomerFeatures: openCustomerFeatures,
        onAddressBook: openAddressBook,
        onLogout: () async {
          await ref.read(firebaseAuthenticationServiceProvider).signOut();
          ref.read(currentSessionProvider.notifier).state = null;
        },
      ),
      destinations: [
        DashboardDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: 'Trang chủ',
          onSelected: () {},
        ),
        DashboardDestination(
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long_rounded,
          label: 'Đơn hàng',
          onSelected: openHistory,
        ),
        DashboardDestination(
          icon: Icons.notifications_none_rounded,
          selectedIcon: Icons.notifications_rounded,
          label: 'Thông báo',
          onSelected: openNotifications,
        ),
        DashboardDestination(
          icon: Icons.location_on_outlined,
          selectedIcon: Icons.location_on_rounded,
          label: 'Địa chỉ',
          onSelected: openAddressBook,
        ),
        DashboardDestination(
          icon: Icons.apps_outlined,
          selectedIcon: Icons.apps_rounded,
          label: 'Tiện ích',
          onSelected: openCustomerFeatures,
        ),
      ],
      actions: [
        NotificationBell(
          notifications: notifications,
          onViewAll: openNotifications,
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  wide ? AppSpacing.xxl : AppSpacing.screenHorizontal,
                  AppSpacing.xl,
                  wide ? AppSpacing.xxl : AppSpacing.screenHorizontal,
                  AppSpacing.xxxl,
                ),
                sliver: SliverList.list(
                  children: [
                    _PageGreeting(user: user),
                    const SizedBox(height: AppSpacing.lg),
                    _WelcomeHero(
                      user: user,
                      activeOrder: activeOrder,
                      onAction: activeOrder == null
                          ? openBooking
                          : () => _openOrder(context, activeOrder),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _CurrentOrderModule(
                              order: activeOrder,
                              address: _findAddress(
                                addresses,
                                activeOrder?.diaChiId,
                              ),
                              waste: _findWaste(wastes, activeOrder?.loaiRacId),
                              staff: _findStaff(
                                staff,
                                activeOrder?.nhanVienHienTaiId ??
                                    activeOrder?.nhanVienDeXuatId,
                              ),
                              onBooking: openBooking,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          SizedBox(
                            width: 330,
                            child: _QuickActions(
                              hasActiveOrder: activeOrder != null,
                              onBooking: activeOrder == null
                                  ? openBooking
                                  : () => _openOrder(context, activeOrder),
                              onHistory: openHistory,
                              onNotifications: openNotifications,
                              onSupport: () => _showSupport(context),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _CurrentOrderModule(
                        order: activeOrder,
                        address: _findAddress(addresses, activeOrder?.diaChiId),
                        waste: _findWaste(wastes, activeOrder?.loaiRacId),
                        staff: _findStaff(
                          staff,
                          activeOrder?.nhanVienHienTaiId ??
                              activeOrder?.nhanVienDeXuatId,
                        ),
                        onBooking: openBooking,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _QuickActions(
                        hasActiveOrder: activeOrder != null,
                        onBooking: activeOrder == null
                            ? openBooking
                            : () => _openOrder(context, activeOrder),
                        onHistory: openHistory,
                        onNotifications: openNotifications,
                        onSupport: () => _showSupport(context),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _PackageModule(
                              package: package,
                              subscription: subscription,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: _RecentOrdersModule(
                              orders: recentOrders,
                              addresses: addresses,
                              wastes: wastes,
                              staff: staff,
                              onViewAll: openHistory,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _PackageModule(
                        package: package,
                        subscription: subscription,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _RecentOrdersModule(
                        orders: recentOrders,
                        addresses: addresses,
                        wastes: wastes,
                        staff: staff,
                        onViewAll: openHistory,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static PickupPackage? _findPackageForSubscription(
    List<PickupPackage> packages,
    PackageSubscription? subscription,
  ) {
    if (packages.isEmpty) {
      return null;
    }

    if (subscription == null) {
      return packages.first;
    }

    for (final package in packages) {
      if (package.goiId == subscription.goiId) {
        return package;
      }
    }
    return packages.first;
  }
}

class _PageGreeting extends StatelessWidget {
  const _PageGreeting({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weekdays[now.weekday - 1]}, ${formatDate(now)}',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Chào ${_firstName(user.hoTen)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 23,
          backgroundColor: AppColors.green100,
          foregroundColor: AppColors.primaryDark,
          child: Text(
            _initials(user.hoTen),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({
    required this.user,
    required this.activeOrder,
    required this.onAction,
  });

  final AppUser user;
  final PickupOrder? activeOrder;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final hasActiveOrder = activeOrder != null;
    return Container(
      constraints: const BoxConstraints(minHeight: 188),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -28,
            child: Icon(
              hasActiveOrder
                  ? Icons.local_shipping_rounded
                  : Icons.recycling_rounded,
              size: 154,
              color: AppColors.opacity(AppColors.white, 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroEyebrow(
                        label: hasActiveOrder
                            ? orderStatusStyle(activeOrder!.trangThai).label
                            : 'Sẵn sàng thu gom',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        hasActiveOrder
                            ? 'Đơn của bạn đang được xử lý'
                            : 'Biến rác thành một hành động xanh',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.textInverse,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        hasActiveOrder
                            ? 'Theo dõi vị trí và từng mốc xử lý ngay trong ứng dụng.'
                            : 'Đặt lịch trong vài bước, GreenTrash sẽ kết nối nhân viên phù hợp.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textInverseMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        height: 42,
                        child: FilledButton.icon(
                          onPressed: onAction,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.green800,
                          ),
                          icon: Icon(
                            hasActiveOrder
                                ? Icons.route_rounded
                                : Icons.add_rounded,
                            size: 18,
                          ),
                          label: Text(
                            hasActiveOrder ? 'Theo dõi đơn' : 'Đặt lịch ngay',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 92),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroEyebrow extends StatelessWidget {
  const _HeroEyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: AppColors.textInverseMuted),
        ),
      ],
    );
  }
}

class _CurrentOrderModule extends StatelessWidget {
  const _CurrentOrderModule({
    required this.order,
    required this.address,
    required this.waste,
    required this.staff,
    required this.onBooking,
  });

  final PickupOrder? order;
  final CustomerAddress? address;
  final WasteType? waste;
  final StaffProfile? staff;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    final currentOrder = order;
    if (currentOrder == null) {
      return _ModuleSurface(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.event_available_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Bạn chưa có lịch thu gom',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tạo lịch mới để nhân viên gần khu vực có thể nhận đơn.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onBooking,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tạo lịch thu gom'),
              ),
            ],
          ),
        ),
      );
    }

    final style = orderStatusStyle(currentOrder.trangThai);
    return _ModuleSurface(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: () => _openOrder(context, currentOrder),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn đang hoạt động',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          formatOrderCode(currentOrder.maDon),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: currentOrder.trangThai, compact: true),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _LiveStatusLine(
                icon: style.icon,
                color: style.foreground,
                text: _activeOrderMessage(currentOrder, staff),
              ),
              const SizedBox(height: AppSpacing.lg),
              OrderJourneyBar(status: currentOrder.trangThai),
              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xl,
                runSpacing: AppSpacing.sm,
                children: [
                  _CompactFact(
                    icon: Icons.schedule_rounded,
                    value:
                        '${formatDayMonth(currentOrder.ngayThuGom)} • ${currentOrder.khungGio}',
                  ),
                  _CompactFact(
                    icon: Icons.recycling_rounded,
                    value:
                        '${waste?.tenLoaiRac ?? currentOrder.loaiRacId} • ${formatKg(currentOrder.khoiLuongDuKien)}',
                  ),
                  _CompactFact(
                    icon: Icons.location_on_rounded,
                    value: address?.shortAddress ?? currentOrder.diaChiId,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Xem chi tiết',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                    size: 18,
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

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.hasActiveOrder,
    required this.onBooking,
    required this.onHistory,
    required this.onNotifications,
    required this.onSupport,
  });

  final bool hasActiveOrder;
  final VoidCallback onBooking;
  final VoidCallback onHistory;
  final VoidCallback onNotifications;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        hasActiveOrder ? Icons.route_rounded : Icons.add_task_rounded,
        hasActiveOrder ? 'Theo dõi' : 'Đặt lịch',
        hasActiveOrder ? 'Đơn hiện tại' : 'Thu gom mới',
        AppColors.primary,
        onBooking,
      ),
      (
        Icons.history_rounded,
        'Lịch sử',
        'Các đơn đã đặt',
        AppColors.processing,
        onHistory,
      ),
      (
        Icons.notifications_rounded,
        'Thông báo',
        'Cập nhật mới',
        AppColors.warning,
        onNotifications,
      ),
      (
        Icons.support_agent_rounded,
        'Hỗ trợ',
        'Liên hệ nhanh',
        AppColors.success,
        onSupport,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Thao tác nhanh',
          subtitle: 'Các chức năng bạn thường dùng',
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.42,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return _QuickActionTile(
              icon: action.$1,
              title: action.$2,
              subtitle: action.$3,
              color: action.$4,
              onTap: action.$5,
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageModule extends StatelessWidget {
  const _PackageModule({required this.package, required this.subscription});

  final PickupPackage? package;
  final PackageSubscription? subscription;

  @override
  Widget build(BuildContext context) {
    final currentPackage = package;
    if (currentPackage == null) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Chưa có gói thu gom',
        message: 'Gói tháng hiện tại sẽ hiển thị tại đây.',
      );
    }

    final currentSubscription = subscription;
    final limit = currentPackage.hanMucKgThang.toDouble();

    final used = (currentSubscription?.soKgDaDung ?? 0)
        .toDouble()
        .clamp(0.0, limit)
        .toDouble();

    final remaining = currentSubscription == null
        ? limit
        : currentSubscription.soKgConLai
              .toDouble()
              .clamp(0.0, limit)
              .toDouble();

    final progress = limit <= 0
        ? 0.0
        : (used / limit).clamp(0.0, 1.0).toDouble();

    final status = currentSubscription?.trangThai;

    final isActive = status == 'CON_HL' || status == 'CON_HIEU_LUC';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Gói thu gom',
          subtitle: 'Hạn mức sử dụng trong tháng',
        ),
        const SizedBox(height: AppSpacing.md),
        _ModuleSurface(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentPackage.tenGoi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            isActive ? 'Đang có hiệu lực' : 'Cần gia hạn',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: isActive
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AnimatedProgressBar(value: progress),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _PackageValue(
                        label: 'Đã dùng',
                        value: formatKg(used),
                      ),
                    ),
                    Expanded(
                      child: _PackageValue(
                        label: 'Còn lại',
                        value: formatKg(remaining),
                        align: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: _PackageValue(
                        label: 'Phí vượt',
                        value: formatMoney(currentPackage.phiVuotGoi),
                        align: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PackageValue extends StatelessWidget {
  const _PackageValue({
    required this.label,
    required this.value,
    this.align = TextAlign.left,
  });

  final String label;
  final String value;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: switch (align) {
        TextAlign.right => CrossAxisAlignment.end,
        TextAlign.center => CrossAxisAlignment.center,
        _ => CrossAxisAlignment.start,
      },
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _RecentOrdersModule extends StatelessWidget {
  const _RecentOrdersModule({
    required this.orders,
    required this.addresses,
    required this.wastes,
    required this.staff,
    required this.onViewAll,
  });

  final List<PickupOrder> orders;
  final List<CustomerAddress> addresses;
  final List<WasteType> wastes;
  final List<StaffProfile> staff;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Đơn gần đây',
          subtitle: 'Hai đơn được cập nhật gần nhất',
          trailing: TextButton(
            onPressed: onViewAll,
            child: const Text('Xem tất cả'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (orders.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Chưa có lịch sử',
            message: 'Đơn hoàn thành hoặc đã hủy sẽ xuất hiện tại đây.',
          )
        else
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: OrderCard(
                order: order,
                address: _findAddress(addresses, order.diaChiId),
                wasteType: _findWaste(wastes, order.loaiRacId),
                staffName: _findStaff(
                  staff,
                  order.nhanVienHienTaiId ?? order.nhanVienDeXuatId,
                )?.maNhanVien,
                onTap: () => _openOrder(context, order),
              ),
            ),
          ),
      ],
    );
  }
}

class _ModuleSurface extends StatelessWidget {
  const _ModuleSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _LiveStatusLine extends StatelessWidget {
  const _LiveStatusLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactFact extends StatelessWidget {
  const _CompactFact({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

class _CustomerDrawer extends StatelessWidget {
  const _CustomerDrawer({
    required this.user,
    required this.onCustomerFeatures,
    required this.onAddressBook,
    required this.onLogout,
  });

  final AppUser user;
  final VoidCallback onCustomerFeatures;
  final VoidCallback onAddressBook;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandLogo(logoSize: 40),
                  const SizedBox(height: AppSpacing.xxl),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.green100,
                    child: Text(
                      _initials(user.hoTen),
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user.hoTen,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Tài khoản'),
              onTap: () {
                Navigator.of(context).pop();
                onCustomerFeatures();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Sổ địa chỉ'),
              onTap: () {
                Navigator.of(context).pop();
                onAddressBook();
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Đăng xuất'),
              onTap: onLogout,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

PickupOrder? _findActiveOrder(List<PickupOrder> orders) {
  for (final order in orders) {
    if (order.trangThai != 'HOAN_THANH' && order.trangThai != 'HUY') {
      return order;
    }
  }
  return null;
}

CustomerAddress? _findAddress(List<CustomerAddress> addresses, String? id) {
  if (id == null) return null;
  for (final address in addresses) {
    if (address.diaChiId == id) return address;
  }
  return null;
}

WasteType? _findWaste(List<WasteType> wastes, String? id) {
  if (id == null) return null;
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

String _activeOrderMessage(PickupOrder order, StaffProfile? staff) {
  return switch (order.trangThai) {
    'CHO_XU_LY' => 'Đang tìm nhân viên phù hợp trong khu vực của bạn.',
    'CHO_NHAN' => 'Đang chờ ${staff?.maNhanVien ?? 'nhân viên'} xác nhận đơn.',
    'DA_NHAN' => '${staff?.maNhanVien ?? 'Nhân viên'} đã nhận và chuẩn bị đi.',
    'DANG_DEN' => '${staff?.maNhanVien ?? 'Nhân viên'} đang di chuyển đến bạn.',
    'DA_DEN' => 'Nhân viên đã đến điểm lấy rác.',
    'DANG_CAN_RAC' => 'Rác đang được kiểm tra và cân thực tế.',
    _ => 'Đơn đang được GreenTrash cập nhật.',
  };
}

void _openOrder(BuildContext context, PickupOrder order) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => OrderDetailScreen(maDon: order.maDon)),
  );
}

void _showSupport(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(content: Text('Yêu cầu hỗ trợ đã được ghi nhận.')),
    );
}

String _firstName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  return parts.isEmpty ? fullName : parts.last;
}

String _initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return 'GT';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
