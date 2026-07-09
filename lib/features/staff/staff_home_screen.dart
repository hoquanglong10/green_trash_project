import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';
import 'staff_order_screen.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final offers = ref.watch(staffOfferOrdersProvider);
    final orders = ref.watch(staffOrdersProvider);
    final staffProfile = _findStaff(
      ref.watch(staffProfilesProvider),
      user.userId,
    );
    final addresses = ref.watch(allAddressesProvider);
    final wastes = ref.watch(wasteTypesProvider);
    final users = ref.watch(usersProvider);

    return AppPage(
      maxWidth: 760,
      title: 'Ca thu gom',
      subtitle:
          '${staffProfile?.maNhanVien ?? user.hoTen} • ${staffProfile?.gioBatDau ?? '06:00'}-${staffProfile?.gioKetThuc ?? '17:00'}',
      actions: [
        IconButton(
          tooltip: 'Đăng xuất',
          onPressed: () =>
              ref.read(currentSessionProvider.notifier).state = null,
          icon: const Icon(Icons.logout),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 680;
          final padding = const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.md,
            AppSpacing.screenHorizontal,
            AppSpacing.xxl,
          );

          if (wide) {
            return ListView(
              padding: padding,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _StaffShiftPanel(
                        profile: staffProfile,
                        offerCount: offers.length,
                        activeCount: orders.length,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _StaffOfferPanel(
                        offers: offers,
                        addresses: addresses,
                        wastes: wastes,
                        users: users,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                _AcceptedOrdersList(
                  orders: orders,
                  addresses: addresses,
                  wastes: wastes,
                ),
              ],
            );
          }

          return ListView(
            padding: padding,
            children: [
              _StaffShiftPanel(
                profile: staffProfile,
                offerCount: offers.length,
                activeCount: orders.length,
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              _StaffOfferPanel(
                offers: offers,
                addresses: addresses,
                wastes: wastes,
                users: users,
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              _AcceptedOrdersList(
                orders: orders,
                addresses: addresses,
                wastes: wastes,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StaffShiftPanel extends StatelessWidget {
  const _StaffShiftPanel({
    required this.profile,
    required this.offerCount,
    required this.activeCount,
  });

  final StaffProfile? profile;
  final int offerCount;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeBrandHeader(
          title: 'Sẵn sàng nhận đơn',
          subtitle:
              '${profile?.viTriHienTai ?? 'Chưa cập nhật vị trí'} • ${profile?.gioBatDau ?? '06:00'}-${profile?.gioKetThuc ?? '17:00'}',
          trailing: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.opacity(AppColors.white, 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.accent),
            ),
            child: const Icon(
              Icons.badge_outlined,
              color: AppColors.textInverse,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Đơn mới',
                value: offerCount.toString(),
                icon: Icons.notifications_active_outlined,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: MetricCard(
                label: 'Đang xử lý',
                value: activeCount.toString(),
                icon: Icons.route_outlined,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.my_location_outlined,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vị trí nhận đơn',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        profile?.viTriHienTai ?? 'Chưa cập nhật',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const StatusChip(status: 'CHO_XU_LY', compact: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StaffOfferPanel extends ConsumerWidget {
  const _StaffOfferPanel({
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
          title: 'Đơn mới gần bạn',
          subtitle: 'Nhận hoặc từ chối để hệ thống chuyển tiếp',
          trailing: Text(
            '${offers.length} đơn',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (offers.isEmpty)
          const EmptyState(
            icon: Icons.notifications_none,
            title: 'Chưa có đơn mới',
            message: 'Khi khách gần khu vực đặt lịch, đơn sẽ hiện tại đây.',
          )
        else
          ...offers.map((order) {
            final address = _findAddress(addresses, order.diaChiId);
            final waste = _findWaste(wastes, order.loaiRacId);
            final customer = _findUser(users, order.khachHangId);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _OfferCard(
                order: order,
                address: address,
                waste: waste,
                customer: customer,
                onReject: () {
                  final user = ref.read(currentUserProvider);
                  if (user == null) return;
                  ref
                      .read(orderControllerProvider.notifier)
                      .rejectOffer(maDon: order.maDon, nhanVienId: user.userId);
                },
                onAccept: () {
                  final user = ref.read(currentUserProvider);
                  if (user == null) return;
                  ref
                      .read(orderControllerProvider.notifier)
                      .acceptOffer(maDon: order.maDon, nhanVienId: user.userId);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StaffOrderScreen(maDon: order.maDon),
                    ),
                  );
                },
              ),
            );
          }),
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
    final currentAddress = address;

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.primary, width: 1.1),
      ),
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
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.recycling,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.maDon,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const StatusChip(status: 'CHO_XU_LY', compact: true),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${formatDayMonth(order.ngayThuGom)} • ${order.khungGio}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _OfferInfoRow(
              icon: Icons.person_outline,
              text: customer?.hoTen ?? order.khachHangId,
            ),
            const SizedBox(height: AppSpacing.sm),
            _OfferInfoRow(
              icon: Icons.delete_outline,
              text:
                  '${waste?.tenLoaiRac ?? order.loaiRacId} • ${formatKg(order.khoiLuongDuKien)}',
            ),
            const SizedBox(height: AppSpacing.sm),
            _OfferInfoRow(
              icon: Icons.place_outlined,
              text: currentAddress == null
                  ? order.diaChiId
                  : '${currentAddress.shortAddress}, ${currentAddress.quanHuyen}',
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_outlined),
                    label: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Nhận đơn'),
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

class _AcceptedOrdersList extends StatelessWidget {
  const _AcceptedOrdersList({
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
          title: 'Đơn đang xử lý',
          subtitle: 'Các đơn bạn đã nhận trong ca',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (orders.isEmpty)
          const EmptyState(
            icon: Icons.assignment_turned_in_outlined,
            title: 'Chưa nhận đơn nào',
            message: 'Sau khi bấm nhận đơn, đơn sẽ chuyển xuống danh sách này.',
          )
        else
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: OrderCard(
                order: order,
                address: _findAddress(addresses, order.diaChiId),
                wasteType: _findWaste(wastes, order.loaiRacId),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StaffOrderScreen(maDon: order.maDon),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _OfferInfoRow extends StatelessWidget {
  const _OfferInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.primaryDark),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.text),
          ),
        ),
      ],
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
