import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'option_icon.dart';

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.3 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              OptionIcon(icon: icon, selected: selected),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
