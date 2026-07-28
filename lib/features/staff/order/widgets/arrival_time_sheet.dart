import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/app_models.dart';
import '../../../../shared/widgets/app_widgets.dart';

Future<DateTime?> showArrivalTimeSheet(
  BuildContext context, {
  required PickupOrder order,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => _ArrivalTimeSheet(order: order),
  );
}

class _ArrivalTimeSheet extends StatefulWidget {
  const _ArrivalTimeSheet({required this.order});

  final PickupOrder order;

  @override
  State<_ArrivalTimeSheet> createState() => _ArrivalTimeSheetState();
}

class _ArrivalTimeSheetState extends State<_ArrivalTimeSheet> {
  late final List<DateTime> _options;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _options = _buildOptions(widget.order);
    _selected = _initialSelection(widget.order, _options);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chốt giờ dự kiến đến',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Chọn một mốc trong khung ${widget.order.khungGio}. Khách hàng sẽ thấy thời gian này ngay sau khi bạn nhận đơn.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_available_outlined,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          '${formatDate(widget.order.ngayThuGom)} • ${widget.order.khungGio}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Giờ đến dự kiến',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final option in _options)
                      ChoiceChip(
                        avatar: const Icon(Icons.schedule, size: 16),
                        label: Text(_formatTime(option)),
                        selected: option == _selected,
                        onSelected: (_) => setState(() => _selected = option),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryActionButton(
                  label: 'Nhận đơn lúc ${_formatTime(_selected)}',
                  icon: Icons.check_circle_outline,
                  onPressed: () => Navigator.of(context).pop(_selected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<DateTime> _buildOptions(PickupOrder order) {
  final limits = order.khungGio.split('-');
  final start = limits.isNotEmpty ? _minutes(limits.first) : null;
  final end = limits.length > 1 ? _minutes(limits.last) : null;
  final fallback = DateTime(
    order.ngayThuGom.year,
    order.ngayThuGom.month,
    order.ngayThuGom.day,
    8,
  );
  if (start == null || end == null || start >= end) return [fallback];

  return [
    for (var minute = start; minute < end; minute += 30)
      DateTime(
        order.ngayThuGom.year,
        order.ngayThuGom.month,
        order.ngayThuGom.day,
        minute ~/ 60,
        minute % 60,
      ),
  ];
}

DateTime _initialSelection(PickupOrder order, List<DateTime> options) {
  final current = order.gioChot;
  if (current != null) {
    for (final option in options) {
      if (option == current) return option;
    }
  }
  return options.first;
}

int? _minutes(String value) {
  final parts = value.trim().split(':');
  final hour = int.tryParse(parts.first);
  if (hour == null) return null;
  if (parts.length == 1) return hour * 60;
  final minute = int.tryParse(parts[1]);
  return minute == null ? null : hour * 60 + minute;
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
