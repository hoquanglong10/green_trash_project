import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import 'app_widgets.dart';

class HistoryOrderCard extends StatelessWidget {
  const HistoryOrderCard({
    super.key,
    required this.order,
    required this.address,
    required this.wasteType,
    required this.eventTime,
    required this.onTap,
  });

  final PickupOrder order;
  final CustomerAddress? address;
  final WasteType? wasteType;
  final DateTime eventTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateText = formatDayMonth(eventTime).split('/');
    final cancelled = order.trangThai == 'HUY';
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: cancelled ? AppColors.danger : AppColors.success,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HistoryDateTile(
                        day: dateText.first,
                        month: dateText.length > 1 ? 'Th ${dateText.last}' : '',
                        cancelled: cancelled,
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
                                    formatOrderCode(order.maDon),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                StatusChip(
                                  status: order.trangThai,
                                  compact: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${cancelled ? 'Đã hủy' : 'Hoàn tất'} • ${formatDateTime(eventTime)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _HistoryInfoLine(
                              icon: Icons.delete_outline_rounded,
                              text:
                                  '${wasteType?.tenLoaiRac ?? order.loaiRacId} • ${formatKg(order.khoiLuongDuKien)}',
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _HistoryInfoLine(
                              icon: Icons.location_on_outlined,
                              text: address?.shortAddress ?? order.diaChiId,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryDateTile extends StatelessWidget {
  const _HistoryDateTile({
    required this.day,
    required this.month,
    required this.cancelled,
  });

  final String day;
  final String month;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    final color = cancelled ? AppColors.danger : AppColors.primary;
    return SizedBox(
      width: 42,
      child: Column(
        children: [
          Text(
            day,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            month,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryInfoLine extends StatelessWidget {
  const _HistoryInfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryDark),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
