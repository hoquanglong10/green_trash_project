import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/app_models.dart';
import '../../../../providers/app_providers.dart';
import '../staff_order_flow.dart';

class StaffOrderActionBar extends ConsumerWidget {
  const StaffOrderActionBar({super.key, required this.order});

  final PickupOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null ||
        order.trangThai == 'HOAN_THANH' ||
        order.trangThai == 'HUY') {
      return const SizedBox.shrink();
    }

    final isOpenOrder =
        order.trangThai == 'CHO_XU_LY' &&
        !order.nhanVienTuChoiIds.contains(user.userId);
    final isAssigned =
        order.trangThai == 'CHO_NHAN' && order.nhanVienHienTaiId == user.userId;
    if (isOpenOrder || isAssigned) {
      return _BottomActionSurface(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isOpenOrder
                    ? () async {
                        final rejected = await rejectStaffOffer(
                          context,
                          ref,
                          order: order,
                          staffId: user.userId,
                        );
                        if (rejected && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    : () => cancelStaffOrder(
                        context,
                        ref,
                        order: order,
                        staffId: user.userId,
                      ),
                icon: Icon(
                  isOpenOrder ? Icons.close_outlined : Icons.block_outlined,
                ),
                label: Text(isOpenOrder ? 'Bỏ qua' : 'Hủy'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () => acceptStaffOrder(
                  context,
                  ref,
                  order: order,
                  staffId: user.userId,
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Nhận và chốt giờ'),
              ),
            ),
          ],
        ),
      );
    }

    if (order.nhanVienHienTaiId != user.userId) {
      return const SizedBox.shrink();
    }
    final action = _nextAction(order.trangThai);
    if (action == null) return const SizedBox.shrink();

    return _BottomActionSurface(
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => cancelStaffOrder(
                context,
                ref,
                order: order,
                staffId: user.userId,
              ),
              icon: const Icon(Icons.block_outlined),
              label: const Text('Hủy'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () {
                if (action.nextStatus == null) {
                  completeStaffOrder(
                    context,
                    ref,
                    order: order,
                    staffId: user.userId,
                  );
                  return;
                }
                advanceStaffOrder(
                  context,
                  ref,
                  order: order,
                  staffId: user.userId,
                  nextStatus: action.nextStatus!,
                );
              },
              icon: Icon(action.icon),
              label: Text(action.label),
            ),
          ),
        ],
      ),
    );
  }

  _StaffAction? _nextAction(String status) {
    return switch (status) {
      'DA_NHAN' => const _StaffAction(
        label: 'Bắt đầu di chuyển',
        icon: Icons.route_outlined,
        nextStatus: 'DANG_DEN',
      ),
      'DANG_DEN' => const _StaffAction(
        label: 'Xác nhận đã đến',
        icon: Icons.location_on_outlined,
        nextStatus: 'DA_DEN',
      ),
      'DA_DEN' => const _StaffAction(
        label: 'Bắt đầu cân rác',
        icon: Icons.scale_outlined,
        nextStatus: 'DANG_CAN_RAC',
      ),
      'DANG_CAN_RAC' => const _StaffAction(
        label: 'Lập biên bản',
        icon: Icons.fact_check_outlined,
      ),
      _ => null,
    };
  }
}

class _BottomActionSurface extends StatelessWidget {
  const _BottomActionSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _StaffAction {
  const _StaffAction({
    required this.label,
    required this.icon,
    this.nextStatus,
  });

  final String label;
  final IconData icon;
  final String? nextStatus;
}
