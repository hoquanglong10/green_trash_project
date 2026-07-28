import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class BookingSubmitPanel extends StatelessWidget {
  const BookingSubmitPanel({
    super.key,
    required this.canSubmit,
    required this.estimate,
    required this.staffLabel,
    required this.onSubmit,
    this.validationMessage,
  });

  final bool canSubmit;
  final String estimate;
  final String staffLabel;
  final VoidCallback onSubmit;
  final String? validationMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
                        estimate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        staffLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 150,
                  child: FilledButton.icon(
                    onPressed: canSubmit ? onSubmit : null,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Gửi đơn'),
                  ),
                ),
              ],
            ),
            if (validationMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  validationMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
