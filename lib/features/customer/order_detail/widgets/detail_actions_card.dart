import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/app_models.dart';
import '../../../../providers/app_providers.dart';

class DetailActionsCard extends ConsumerWidget {
  const DetailActionsCard({super.key, required this.order});

  final PickupOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCancel =
        order.trangThai == 'CHO_XU_LY' || order.trangThai == 'CHO_NHAN';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canCancel
                    ? () {
                        ref
                            .read(orderControllerProvider.notifier)
                            .cancelOrder(order.maDon);
                      }
                    : null,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Hủy đơn'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('Hỗ trợ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
