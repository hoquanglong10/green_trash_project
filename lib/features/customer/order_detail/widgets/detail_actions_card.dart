import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../orders/application/order_workflow_providers.dart';
import '../../../orders/domain/order_workflow_models.dart';
import '../../../../models/app_models.dart';
import '../../../../providers/app_providers.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../../shared/widgets/order_reason_sheet.dart';

class DetailActionsCard extends ConsumerWidget {
  const DetailActionsCard({super.key, required this.order});

  final PickupOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final canCancel =
        user != null &&
        const {
          'CHO_XU_LY',
          'CHO_NHAN',
          'DA_NHAN',
          'DANG_DEN',
        }.contains(order.trangThai);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canCancel
                    ? () async {
                        final reason = await showOrderReasonSheet(
                          context,
                          title: 'Hủy đơn ${order.maDon}',
                          subtitle:
                              order.trangThai == 'DA_NHAN' ||
                                  order.trangThai == 'DANG_DEN'
                              ? 'Nhân viên đã nhận đơn. Lý do hủy sẽ được gửi ngay để họ dừng di chuyển.'
                              : 'Lý do hủy sẽ được lưu vào lịch sử xử lý đơn.',
                          confirmLabel: 'Xác nhận hủy đơn',
                          suggestions: const [
                            'Không còn nhu cầu thu gom',
                            'Muốn đổi lịch thu gom',
                            'Thông tin đơn chưa đúng',
                          ],
                        );
                        if (reason == null) return;
                        final canceled = ref.read(firebaseEnabledProvider)
                            ? await _cancelFirestoreOrder(
                                ref,
                                order: order,
                                actorId: user.userId,
                                reason: reason,
                              )
                            : ref
                                  .read(orderControllerProvider.notifier)
                                  .cancelOrder(
                                    maDon: order.maDon,
                                    actorId: user.userId,
                                    reason: reason,
                                  );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              canceled
                                  ? 'Đã hủy đơn và lưu lý do.'
                                  : 'Không thể hủy đơn ở trạng thái hiện tại.',
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Hủy đơn'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: PrimaryActionButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Đã gửi yêu cầu hỗ trợ cho GreenTrash (mock).',
                      ),
                    ),
                  );
                },
                icon: Icons.support_agent_outlined,
                label: 'Hỗ trợ',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _cancelFirestoreOrder(
  WidgetRef ref, {
  required PickupOrder order,
  required String actorId,
  required String reason,
}) async {
  try {
    await ref
        .read(orderWorkflowRepositoryProvider)
        .cancelOrder(
          CancelPickupOrderCommand(
            maDon: order.maDon,
            actorId: actorId,
            lyDo: reason,
          ),
        );
    return true;
  } on OrderWorkflowException {
    return false;
  } catch (_) {
    return false;
  }
}
