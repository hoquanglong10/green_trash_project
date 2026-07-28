import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'app_widgets.dart';

Future<String?> showOrderReasonSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String confirmLabel,
  required List<String> suggestions,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => _OrderReasonSheet(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      suggestions: suggestions,
    ),
  );
}

class _OrderReasonSheet extends StatefulWidget {
  const _OrderReasonSheet({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.suggestions,
  });

  final String title;
  final String subtitle;
  final String confirmLabel;
  final List<String> suggestions;

  @override
  State<_OrderReasonSheet> createState() => _OrderReasonSheetState();
}

class _OrderReasonSheetState extends State<_OrderReasonSheet> {
  final _controller = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
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
                  widget.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final suggestion in widget.suggestions)
                      ChoiceChip(
                        label: Text(suggestion),
                        selected: _controller.text.trim() == suggestion,
                        onSelected: (_) {
                          setState(() {
                            _controller.text = suggestion;
                            _showError = false;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextInput(
                  label: 'Lý do',
                  hint: 'Nhập lý do cụ thể',
                  controller: _controller,
                  icon: Icons.notes_outlined,
                  minLines: 2,
                  maxLines: 3,
                ),
                if (_showError) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Vui lòng nhập lý do trước khi tiếp tục.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                PrimaryActionButton(
                  label: widget.confirmLabel,
                  icon: Icons.check_circle_outline,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final reason = _controller.text.trim();
    if (reason.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(reason);
  }
}
