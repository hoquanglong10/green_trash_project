import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/app_models.dart';
import 'option_icon.dart';

class WasteOptionCard extends StatelessWidget {
  const WasteOptionCard({
    super.key,
    required this.waste,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final WasteType waste;
  final PriceItem? price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priceItem = price;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  OptionIcon(icon: Icons.recycling, selected: selected),
                  const Spacer(),
                  Icon(
                    selected ? Icons.check_circle : Icons.add_circle_outline,
                    color: selected ? AppColors.primary : AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                waste.nhomRac,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                waste.tenLoaiRac,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
              const Spacer(),
              Text(
                priceItem == null
                    ? 'Chưa có giá'
                    : '${formatMoney(priceItem.donGiaKg)}/kg',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
