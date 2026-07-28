import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/app_models.dart';
import '../../../../shared/widgets/app_widgets.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({
    super.key,
    required this.notifications,
    required this.onViewAll,
  });

  final List<AppNotification> notifications;
  final VoidCallback onViewAll;

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _anchorKey = GlobalKey();

  Future<void> _openMenu() async {
    final buttonBox =
        _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
    if (buttonBox == null || overlayBox == null) return;

    final topLeft = buttonBox.localToGlobal(
      Offset(0, buttonBox.size.height),
      ancestor: overlayBox,
    );
    final position = RelativeRect.fromRect(
      Rect.fromLTWH(topLeft.dx, topLeft.dy, buttonBox.size.width, 0),
      Offset.zero & overlayBox.size,
    );

    await showMenu<void>(
      context: context,
      position: position,
      elevation: 0,
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 320, maxWidth: 360),
      shape: const RoundedRectangleBorder(),
      items: [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _NotificationPopover(
            notifications: widget.notifications,
            onViewAll: () {
              Navigator.of(context).pop();
              widget.onViewAll();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = widget.notifications.any(
      (notification) => notification.trangThaiDoc == 'CHUA_DOC',
    );
    return SizedBox(
      key: _anchorKey,
      width: kToolbarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: 'Thông báo',
            onPressed: _openMenu,
            icon: const Icon(Icons.notifications_none_outlined, size: 32),
          ),
          if (hasUnread)
            Positioned(
              top: 15,
              right: 14,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationPopover extends StatefulWidget {
  const _NotificationPopover({
    required this.notifications,
    required this.onViewAll,
  });

  final List<AppNotification> notifications;
  final VoidCallback onViewAll;

  @override
  State<_NotificationPopover> createState() => _NotificationPopoverState();
}

class _NotificationPopoverState extends State<_NotificationPopover> {
  static const _initialLimit = 1;
  static const _expandedLimit = 3;
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    final limit = _showMore ? _expandedLimit : _initialLimit;
    final notifications = widget.notifications
        .take(limit)
        .toList(growable: false);
    final canShowMore =
        !_showMore && widget.notifications.length > _initialLimit;

    return SizedBox(
      width: 344,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.borderLight,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Thông báo',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: widget.onViewAll,
                          child: const Text('Xem tất cả'),
                        ),
                      ],
                    ),
                    const Divider(height: AppSpacing.lg),
                    if (notifications.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: EmptyState(
                          icon: Icons.notifications_none_outlined,
                          title: 'Chưa có thông báo',
                          message: 'Cập nhật đơn thu gom sẽ hiển thị tại đây.',
                        ),
                      )
                    else
                      ...notifications.indexed.map(
                        (entry) => Column(
                          children: [
                            _NotificationPreviewRow(notification: entry.$2),
                            if (entry.$1 < notifications.length - 1)
                              const Divider(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    if (canShowMore) ...[
                      const Divider(height: AppSpacing.lg),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _showMore = true),
                          icon: const Icon(Icons.keyboard_arrow_down_outlined),
                          label: const Text('Xem thêm'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            right: AppSpacing.xl,
            child: CustomPaint(
              size: Size(18, AppSpacing.md),
              painter: _PopoverPointerPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopoverPointerPainter extends CustomPainter {
  const _PopoverPointerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.surface);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotificationPreviewRow extends StatelessWidget {
  const _NotificationPreviewRow({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final unread = notification.trangThaiDoc == 'CHUA_DOC';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: unread ? AppColors.secondaryLight : AppColors.supportLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            Icons.notifications_none_outlined,
            size: 18,
            color: unread ? AppColors.secondary : AppColors.support,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.tieuDe,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                formatDateTime(notification.thoiGian),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        if (unread)
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
