import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';
import '../../shared/widgets/dashboard_shell.dart';
import '../../shared/widgets/home_dashboard_widgets.dart';
import '../orders/presentation/order_history_screen.dart';
import '../reference_data/application/reference_data_providers.dart';
import 'domain/staff_availability.dart';
import 'order/staff_order_flow.dart';
import 'staff_order_screen.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        body: AppLoadingView(message: 'Đang tải ca thu gom...'),
      );
    }

    final offers = ref.watch(staffOfferOrdersProvider);
    final activeOrders = ref.watch(staffOrdersProvider);
    final history = ref.watch(staffOrderHistoryProvider);
    final profile = _findStaff(ref.watch(staffProfilesProvider), user.userId);
    final addresses = ref.watch(allAddressesProvider);
    final wastes = ref.watch(wasteTypesProvider);
    final users = ref.watch(usersProvider);

    void openHistory() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const OrderHistoryScreen(audience: OrderHistoryAudience.staff),
        ),
      );
    }

    Future<void> handleLogout() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.logout_rounded,
              size: 36,
              color: AppColors.warning,
            ),
            title: const Text('Xác nhận đăng xuất'),
            content: const Text(
              'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản nhân viên không?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Hủy'),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Đăng xuất'),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !context.mounted) {
        return;
      }

      try {
        await ref.read(firebaseAuthenticationServiceProvider).signOut();

        ref.read(currentSessionProvider.notifier).state = null;
      } catch (error) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể đăng xuất: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    return DashboardShell(
      maxContentWidth: 1160,
      drawer: _StaffDrawer(
        user: user,
        profile: profile,
        onLogout: handleLogout,
      ),
      destinations: [
        DashboardDestination(
          icon: Icons.space_dashboard_outlined,
          selectedIcon: Icons.space_dashboard_rounded,
          label: 'Ca làm',
          onSelected: () {},
        ),
        DashboardDestination(
          icon: Icons.history_outlined,
          selectedIcon: Icons.history_rounded,
          label: 'Lịch sử',
          onSelected: openHistory,
        ),
      ],
      actions: [
        IconButton(
          tooltip: 'Lịch sử công việc',
          onPressed: openHistory,
          icon: const Icon(Icons.history_rounded),
        ),
        const SizedBox(width: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: TextButton.icon(
            onPressed: handleLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Đăng xuất'),
          ),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 860;
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
                    _StaffGreeting(user: user, profile: profile),
                    const SizedBox(height: AppSpacing.lg),
                    _ShiftControl(
                      profile: profile,
                      activeOrderCount: activeOrders.length,
                      onToggle: profile == null
                          ? null
                          : () => _toggleAvailability(
                              context,
                              ref,
                              profile,
                              hasActiveOrder: activeOrders.isNotEmpty,
                            ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _OperationStats(
                      offerCount: offers.length,
                      activeCount: activeOrders.length,
                      completedCount: history
                          .where((order) => order.trangThai == 'HOAN_THANH')
                          .length,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              children: [
                                _ActiveMissionSection(
                                  orders: activeOrders,
                                  addresses: addresses,
                                  wastes: wastes,
                                ),
                                if (activeOrders.isEmpty) ...[
                                  const SizedBox(height: AppSpacing.xxl),
                                  _OfferInbox(
                                    offers: offers,
                                    addresses: addresses,
                                    wastes: wastes,
                                    users: users,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(
                            flex: 4,
                            child: _StaffHistorySection(
                              orders: history.take(2).toList(),
                              addresses: addresses,
                              wastes: wastes,
                              onViewAll: openHistory,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _ActiveMissionSection(
                        orders: activeOrders,
                        addresses: addresses,
                        wastes: wastes,
                      ),
                      if (activeOrders.isEmpty) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        _OfferInbox(
                          offers: offers,
                          addresses: addresses,
                          wastes: wastes,
                          users: users,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      _StaffHistorySection(
                        orders: history.take(2).toList(),
                        addresses: addresses,
                        wastes: wastes,
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

  Future<void> _toggleAvailability(
    BuildContext context,
    WidgetRef ref,
    StaffProfile profile, {
    required bool hasActiveOrder,
  }) async {
    if (hasActiveOrder) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hãy hoàn tất hoặc hủy công việc đang xử lý trước.'),
        ),
      );
      return;
    }

    final nextStatus = nextStaffAvailabilityStatus(profile.trangThaiLamViec);
    if (ref.read(firebaseEnabledProvider)) {
      try {
        await ref
            .read(referenceDataRepositoryProvider)
            .updateStaffAvailability(
              staffId: profile.nhanVienId,
              status: nextStatus,
            );
        ref.invalidate(firestoreStaffProfilesProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                nextStatus == 'SAN_SANG'
                    ? 'Đã bật nhận đơn.'
                    : 'Đã tạm dừng nhận đơn.',
              ),
            ),
          );
        }
      } on FirebaseException catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_availabilityErrorMessage(error.code))),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể cập nhật trạng thái nhận đơn.'),
            ),
          );
        }
      }
      return;
    }

    ref
        .read(staffProfileControllerProvider.notifier)
        .setWorkStatus(profile.nhanVienId, nextStatus);
    if (nextStatus == 'TAM_NGHI') {
      ref
          .read(orderControllerProvider.notifier)
          .releaseOffersForStaff(profile.nhanVienId);
    } else {
      ref.read(orderControllerProvider.notifier).retryWaitingOrders();
    }
  }

  String _availabilityErrorMessage(String code) {
    return switch (code) {
      'permission-denied' =>
        'Firestore chưa cho phép cập nhật trạng thái nhân viên.',
      'not-found' => 'Không tìm thấy hồ sơ nhân viên theo UID đăng nhập.',
      'unavailable' => 'Mất kết nối Firestore. Vui lòng thử lại.',
      _ => 'Không thể bật nhận đơn ($code).',
    };
  }
}

class _StaffGreeting extends StatelessWidget {
  const _StaffGreeting({required this.user, required this.profile});

  final AppUser user;
  final StaffProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CA THU GOM HÔM NAY',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                profile?.maNhanVien ?? user.hoTen,
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
          child: const Icon(Icons.badge_rounded),
        ),
      ],
    );
  }
}

class _ShiftControl extends StatelessWidget {
  const _ShiftControl({
    required this.profile,
    required this.activeOrderCount,
    required this.onToggle,
  });

  final StaffProfile? profile;
  final int activeOrderCount;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final status = profile?.trangThaiLamViec ?? 'TAM_NGHI';
    final available = isStaffAvailable(status);
    final locked = activeOrderCount > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final statusLabel = locked
              ? 'Đang trong chuyến'
              : available
              ? 'Trực tuyến'
              : 'Tạm nghỉ';
          final statusControl = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                statusLabel,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.textInverse),
              ),
              const SizedBox(width: AppSpacing.sm),
              Switch(
                value: available,
                onChanged: locked || onToggle == null
                    ? null
                    : (_) => onToggle!(),
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        statusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textInverse,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Switch(
                      value: available,
                      onChanged: locked || onToggle == null
                          ? null
                          : (_) => onToggle!(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locked
                              ? 'Bạn đang thực hiện thu gom'
                              : available
                              ? 'Sẵn sàng nhận đơn mới'
                              : 'Đã tạm dừng nhận đơn',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.textInverse,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${profile?.gioBatDau ?? '06:00'}-${profile?.gioKetThuc ?? '17:00'} • ${profile?.viTriHienTai ?? 'Chưa cập nhật vị trí'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textInverseMuted),
                        ),
                      ],
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: AppSpacing.xl),
                    statusControl,
                  ],
                ],
              ),
              if (locked) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: AppColors.textInverseMuted,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Nhận đơn mới được khóa đến khi công việc hiện tại hoàn tất.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textInverseMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _OperationStats extends StatelessWidget {
  const _OperationStats({
    required this.offerCount,
    required this.activeCount,
    required this.completedCount,
  });

  final int offerCount;
  final int activeCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Đơn mới',
            value: offerCount.toString(),
            icon: Icons.notifications_active_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'Đang làm',
            value: activeCount.toString(),
            icon: Icons.route_rounded,
            color: AppColors.processing,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'Hoàn tất',
            value: completedCount.toString(),
            icon: Icons.task_alt_rounded,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _ActiveMissionSection extends StatelessWidget {
  const _ActiveMissionSection({
    required this.orders,
    required this.addresses,
    required this.wastes,
  });

  final List<PickupOrder> orders;
  final List<CustomerAddress> addresses;
  final List<WasteType> wastes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Nhiệm vụ hiện tại',
          subtitle: 'Công việc cần ưu tiên trong ca',
        ),
        const SizedBox(height: AppSpacing.md),
        if (orders.isEmpty)
          const EmptyState(
            icon: Icons.route_outlined,
            title: 'Chưa có nhiệm vụ',
            message: 'Đơn bạn nhận sẽ xuất hiện tại đây.',
          )
        else
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ActiveMissionCard(
                order: order,
                address: _findAddress(addresses, order.diaChiId),
                waste: _findWaste(wastes, order.loaiRacId),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActiveMissionCard extends StatelessWidget {
  const _ActiveMissionCard({
    required this.order,
    required this.address,
    required this.waste,
  });

  final PickupOrder order;
  final CustomerAddress? address;
  final WasteType? waste;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.green300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatOrderCode(order.maDon),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              StatusChip(status: order.trangThai, compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          OrderJourneyBar(status: order.trangThai),
          const SizedBox(height: AppSpacing.lg),
          _MissionFact(
            icon: Icons.recycling_rounded,
            value:
                '${waste?.tenLoaiRac ?? order.loaiRacId} • ${formatKg(order.khoiLuongDuKien)}',
          ),
          const SizedBox(height: AppSpacing.sm),
          _MissionFact(
            icon: Icons.location_on_rounded,
            value: address?.shortAddress ?? order.diaChiId,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openStaffOrder(context, order),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Tiếp tục xử lý'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferInbox extends ConsumerWidget {
  const _OfferInbox({
    required this.offers,
    required this.addresses,
    required this.wastes,
    required this.users,
  });

  final List<PickupOrder> offers;
  final List<CustomerAddress> addresses;
  final List<WasteType> wastes;
  final List<AppUser> users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Hộp đơn mới',
          subtitle: 'Nhận đơn phù hợp với vị trí và ca làm',
          trailing: Text(
            '${offers.length} đơn',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (offers.isEmpty)
          const EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'Chưa có đơn mới',
            message: 'Đơn gần khu vực sẽ tự xuất hiện tại đây.',
          )
        else
          ...offers.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _OfferCard(
                order: order,
                address: _findAddress(addresses, order.diaChiId),
                waste: _findWaste(wastes, order.loaiRacId),
                customer: _findUser(users, order.khachHangId),
                onReject: () async {
                  final user = ref.read(currentUserProvider);
                  if (user == null) return;
                  await rejectStaffOffer(
                    context,
                    ref,
                    order: order,
                    staffId: user.userId,
                  );
                },
                onAccept: () async {
                  final user = ref.read(currentUserProvider);
                  if (user == null) return;
                  final accepted = await acceptStaffOrder(
                    context,
                    ref,
                    order: order,
                    staffId: user.userId,
                  );
                  if (!context.mounted || !accepted) return;
                  _openStaffOrder(context, order);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.order,
    required this.address,
    required this.waste,
    required this.customer,
    required this.onReject,
    required this.onAccept,
  });

  final PickupOrder order;
  final CustomerAddress? address;
  final WasteType? waste;
  final AppUser? customer;
  final VoidCallback onReject;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'YÊU CẦU MỚI',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${formatDayMonth(order.ngayThuGom)} • ${order.khungGio}',
                maxLines: 2,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            customer?.hoTen ?? order.khachHangId,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),
          _MissionFact(
            icon: Icons.recycling_rounded,
            value:
                '${waste?.tenLoaiRac ?? order.loaiRacId} • ${formatKg(order.khoiLuongDuKien)}',
          ),
          const SizedBox(height: AppSpacing.sm),
          _MissionFact(
            icon: Icons.location_on_rounded,
            value: address == null
                ? order.diaChiId
                : '${address!.shortAddress}, ${address!.quanHuyen}',
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  child: const Text('Từ chối'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Nhận đơn'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaffHistorySection extends StatelessWidget {
  const _StaffHistorySection({
    required this.orders,
    required this.addresses,
    required this.wastes,
    required this.onViewAll,
  });

  final List<PickupOrder> orders;
  final List<CustomerAddress> addresses;
  final List<WasteType> wastes;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Đã xử lý',
          subtitle: 'Công việc gần nhất',
          trailing: TextButton(
            onPressed: onViewAll,
            child: const Text('Xem tất cả'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (orders.isEmpty)
          const EmptyState(
            icon: Icons.history_rounded,
            title: 'Chưa có lịch sử',
            message: 'Đơn đã xử lý sẽ xuất hiện tại đây.',
          )
        else
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: OrderCard(
                order: order,
                address: _findAddress(addresses, order.diaChiId),
                wasteType: _findWaste(wastes, order.loaiRacId),
                onTap: () => _openStaffOrder(context, order),
              ),
            ),
          ),
      ],
    );
  }
}

class _MissionFact extends StatelessWidget {
  const _MissionFact({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _StaffDrawer extends StatelessWidget {
  const _StaffDrawer({
    required this.user,
    required this.profile,
    required this.onLogout,
  });

  final AppUser user;
  final StaffProfile? profile;
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
                  Text(
                    user.hoTen,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    profile?.maNhanVien ?? user.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.badge_outlined),
              title: Text('Thông tin ca làm'),
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

StaffProfile? _findStaff(List<StaffProfile> staff, String id) {
  for (final profile in staff) {
    if (profile.nhanVienId == id) return profile;
  }
  return null;
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

AppUser? _findUser(List<AppUser> users, String id) {
  for (final user in users) {
    if (user.userId == id) return user;
  }
  return null;
}

void _openStaffOrder(BuildContext context, PickupOrder order) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => StaffOrderScreen(maDon: order.maDon)),
  );
}
