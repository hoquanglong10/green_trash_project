import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';

class StaffOrderScreen extends ConsumerWidget {
  const StaffOrderScreen({super.key, required this.maDon});

  final String maDon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = _findOrder(ref.watch(orderControllerProvider), maDon);
    if (order == null) {
      return const Scaffold(body: Center(child: Text('Không tìm thấy đơn.')));
    }

    final address = _findAddress(
      ref.watch(allAddressesProvider),
      order.diaChiId,
    );
    final waste = _findWaste(ref.watch(wasteTypesProvider), order.loaiRacId);
    final customer = _findUser(ref.watch(usersProvider), order.khachHangId);

    return AppPage(
      maxWidth: 760,
      title: order.maDon,
      subtitle: 'Xử lý thu gom',
      bottomNavigationBar: _StaffActionBar(order: order),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.md,
          AppSpacing.screenHorizontal,
          140,
        ),
        children: [
          _StaffJobHero(order: order, customer: customer),
          const SizedBox(height: AppSpacing.sectionGap),
          _JobInfoCard(
            order: order,
            customer: customer,
            address: address,
            waste: waste,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Gọi khách'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Bản đồ'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(
            title: 'Tiến trình xử lý',
            subtitle: 'Cập nhật từng bước sau khi nhận đơn',
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: OrderTimeline(status: order.trangThai),
            ),
          ),
        ],
      ),
    );
  }

  PickupOrder? _findOrder(List<PickupOrder> orders, String id) {
    for (final order in orders) {
      if (order.maDon == id) return order;
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
}

class _StaffJobHero extends StatelessWidget {
  const _StaffJobHero({required this.order, required this.customer});

  final PickupOrder order;
  final AppUser? customer;

  @override
  Widget build(BuildContext context) {
    return HomeBrandHeader(
      title: _title(order.trangThai),
      subtitle:
          '${customer?.hoTen ?? order.khachHangId} • ${formatDayMonth(order.ngayThuGom)} • ${order.khungGio}',
      trailing: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.opacity(AppColors.white, 0.14),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.accent),
        ),
        child: Icon(_icon(order.trangThai), color: AppColors.textInverse),
      ),
    );
  }

  static String _title(String status) {
    return switch (status) {
      'CHO_XU_LY' => 'Đơn mới gần bạn',
      'DA_NHAN' => 'Đơn đã nhận',
      'DANG_DEN' => 'Đang di chuyển',
      'DA_DEN' => 'Đã đến điểm lấy',
      'DANG_CAN_RAC' => 'Cân và lập biên bản',
      'HOAN_THANH' => 'Đơn đã hoàn thành',
      'HUY' => 'Đơn đã hủy',
      _ => 'Đơn thu gom',
    };
  }

  static IconData _icon(String status) {
    return switch (status) {
      'CHO_XU_LY' => Icons.notifications_active_outlined,
      'DA_NHAN' => Icons.task_alt,
      'DANG_DEN' => Icons.route_outlined,
      'DA_DEN' => Icons.location_on_outlined,
      'DANG_CAN_RAC' => Icons.scale_outlined,
      'HOAN_THANH' => Icons.verified_outlined,
      'HUY' => Icons.cancel_outlined,
      _ => Icons.assignment_outlined,
    };
  }
}

class _JobInfoCard extends StatelessWidget {
  const _JobInfoCard({
    required this.order,
    required this.customer,
    required this.address,
    required this.waste,
  });

  final PickupOrder order;
  final AppUser? customer;
  final CustomerAddress? address;
  final WasteType? waste;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
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
                      Text(
                        order.maDon,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        waste?.tenLoaiRac ?? order.loaiRacId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: order.trangThai, compact: true),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _InfoLine(
              icon: Icons.person_outline,
              label: 'Khách',
              value: customer?.hoTen ?? order.khachHangId,
            ),
            _InfoLine(
              icon: Icons.place_outlined,
              label: 'Địa chỉ',
              value: address == null
                  ? order.diaChiId
                  : '${address!.shortAddress}, ${address!.quanHuyen}',
            ),
            _InfoLine(
              icon: Icons.scale_outlined,
              label: 'Dự kiến',
              value: formatKg(order.khoiLuongDuKien),
            ),
            _InfoLine(
              icon: Icons.payments_outlined,
              label: 'Tính phí',
              value: order.hinhThucTinhPhi == 'GOI_THANG'
                  ? 'Gói tháng'
                  : 'Theo kg',
            ),
            _InfoLine(
              icon: Icons.notes_outlined,
              label: 'Ghi chú',
              value: order.ghiChu.isEmpty ? 'Không có' : order.ghiChu,
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffActionBar extends ConsumerWidget {
  const _StaffActionBar({required this.order});

  final PickupOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user != null &&
        order.trangThai == 'CHO_XU_LY' &&
        order.nhanVienDeXuatId == user.userId) {
      return _BottomSurface(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref
                      .read(orderControllerProvider.notifier)
                      .rejectOffer(maDon: order.maDon, nhanVienId: user.userId);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close_outlined),
                label: const Text('Từ chối'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () {
                  ref
                      .read(orderControllerProvider.notifier)
                      .acceptOffer(maDon: order.maDon, nhanVienId: user.userId);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Nhận đơn'),
              ),
            ),
          ],
        ),
      );
    }

    final next = _nextStatus(order.trangThai);
    final complete = order.trangThai == 'DANG_CAN_RAC';
    final finished =
        order.trangThai == 'HOAN_THANH' || order.trangThai == 'HUY';
    final canAdvance =
        !finished &&
        (complete || order.trangThai == 'CHO_NHAN' || next != null);

    return _BottomSurface(
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: finished
                  ? null
                  : () => ref
                        .read(orderControllerProvider.notifier)
                        .cancelOrder(order.maDon),
              icon: const Icon(Icons.block_outlined),
              label: const Text('Hủy'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: canAdvance
                  ? () {
                      if (complete) {
                        _showConfirmSheet(context, ref);
                      } else if (order.trangThai == 'CHO_NHAN') {
                        ref
                            .read(orderControllerProvider.notifier)
                            .acceptOrder(order.maDon);
                      } else if (next != null) {
                        ref
                            .read(orderControllerProvider.notifier)
                            .updateStatus(order.maDon, next);
                      }
                    }
                  : null,
              icon: Icon(
                complete ? Icons.verified_outlined : Icons.arrow_forward,
              ),
              label: Text(
                complete ? 'Hoàn thành' : _nextLabel(order.trangThai),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _nextStatus(String status) {
    return switch (status) {
      'CHO_NHAN' => 'DA_NHAN',
      'DA_NHAN' => 'DANG_DEN',
      'DANG_DEN' => 'DA_DEN',
      'DA_DEN' => 'DANG_CAN_RAC',
      _ => null,
    };
  }

  String _nextLabel(String status) {
    return switch (status) {
      'CHO_NHAN' => 'Nhận đơn',
      'DA_NHAN' => 'Đang đến',
      'DANG_DEN' => 'Đã đến',
      'DA_DEN' => 'Cân rác',
      'DANG_CAN_RAC' => 'Hoàn thành',
      'HOAN_THANH' => 'Đã xong',
      'HUY' => 'Đã hủy',
      _ => 'Cập nhật',
    };
  }

  void _showConfirmSheet(BuildContext context, WidgetRef ref) {
    final actualKgController = TextEditingController(
      text: order.khoiLuongDuKien.toStringAsFixed(1),
    );

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xác nhận thu gom',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: actualKgController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Khối lượng thực tế',
                    suffixText: 'kg',
                    prefixIcon: Icon(Icons.scale_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  color: AppColors.surfaceAlt,
                  child: ListTile(
                    leading: const Icon(Icons.camera_alt_outlined),
                    title: const Text('Ảnh xác nhận'),
                    subtitle: const Text('Chưa có ảnh xác nhận'),
                    trailing: IconButton(
                      tooltip: 'Thêm ảnh',
                      onPressed: () {},
                      icon: const Icon(Icons.add_a_photo_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ref
                          .read(orderControllerProvider.notifier)
                          .completeOrder(order.maDon);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Lưu biên bản và hoàn thành'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomSurface extends StatelessWidget {
  const _BottomSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryDark),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
