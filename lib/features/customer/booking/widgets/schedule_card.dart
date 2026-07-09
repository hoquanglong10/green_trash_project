import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import 'option_icon.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.ngayThuGom,
    required this.khungGio,
    required this.timeSlots,
    required this.kgController,
    required this.onPickDate,
    required this.onSelectSlot,
  });

  final DateTime ngayThuGom;
  final String? khungGio;
  final List<String> timeSlots;
  final TextEditingController kgController;
  final VoidCallback onPickDate;
  final ValueChanged<String> onSelectSlot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                const OptionIcon(
                  icon: Icons.calendar_month_outlined,
                  selected: true,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngày thu gom',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        formatDate(ngayThuGom),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Chọn ngày',
                  onPressed: onPickDate,
                  icon: const Icon(Icons.edit_calendar_outlined),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xxl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final slot in timeSlots)
                  _TimeSlotChip(
                    label: slot,
                    selected: khungGio == slot,
                    onTap: () => onSelectSlot(slot),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: kgController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Khối lượng dự kiến',
                suffixText: 'kg',
                prefixIcon: Icon(Icons.scale_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  const _TimeSlotChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? AppColors.textInverse : AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
