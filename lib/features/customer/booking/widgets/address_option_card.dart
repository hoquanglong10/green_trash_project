import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/app_models.dart';
import '../../../../shared/widgets/app_widgets.dart';
import 'option_icon.dart';

class AddressOptionCard extends StatelessWidget {
  const AddressOptionCard({
    super.key,
    required this.selected,
    required this.address,
    required this.onTap,
  });

  final bool selected;
  final CustomerAddress address;
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
              OptionIcon(
                icon: address.macDinh
                    ? Icons.home_work_outlined
                    : Icons.place_outlined,
                selected: selected,
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
                            address.shortAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (address.macDinh)
                          const StatusChip(status: 'MAC_DINH', compact: true),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${address.quanHuyen}, ${address.tinhThanh}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
