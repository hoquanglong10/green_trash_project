import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);

    final unreadCount = notifications
        .where((notification) => notification.trangThaiDoc == 'CHUA_DOC')
        .length;

    final displayedNotifications = _showUnreadOnly
        ? notifications
              .where((notification) => notification.trangThaiDoc == 'CHUA_DOC')
              .toList()
        : notifications;

    return AppPage(
      title: 'Danh sách thông báo',
      subtitle: '$unreadCount thông báo chưa đọc',
      maxWidth: 700,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          HomeBrandHeader(
            title: 'Thông báo GreenTrash',
            subtitle:
                'Theo dõi trạng thái đơn hàng, gói tháng và các cập nhật mới.',
            actionLabel: unreadCount > 0 ? 'Đọc tất cả' : null,
            onAction: unreadCount > 0
                ? () async {
                    try {
                      await ref
                          .read(notificationsProvider.notifier)
                          .markAllAsRead();

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Đã đánh dấu tất cả thông báo là đã đọc',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Không thể cập nhật thông báo: $error'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                : null,
            trailing: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.white,
                  size: 42,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -7,
                    top: -7,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 22,
                        minHeight: 22,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.amber,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Text('Tất cả (${notifications.length})'),
                  selected: !_showUnreadOnly,
                  onSelected: (_) {
                    setState(() {
                      _showUnreadOnly = false;
                    });
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ChoiceChip(
                  label: Text('Chưa đọc ($unreadCount)'),
                  selected: _showUnreadOnly,
                  onSelected: (_) {
                    setState(() {
                      _showUnreadOnly = true;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          SectionHeader(
            title: _showUnreadOnly ? 'Thông báo chưa đọc' : 'Tất cả thông báo',
            subtitle:
                '${displayedNotifications.length} thông báo được hiển thị',
          ),

          const SizedBox(height: AppSpacing.sm),

          if (displayedNotifications.isEmpty)
            EmptyState(
              icon: _showUnreadOnly
                  ? Icons.mark_email_read_outlined
                  : Icons.notifications_none_outlined,
              title: _showUnreadOnly
                  ? 'Không còn thông báo chưa đọc'
                  : 'Chưa có thông báo',
              message: _showUnreadOnly
                  ? 'Bạn đã đọc tất cả thông báo.'
                  : 'Thông báo mới sẽ xuất hiện tại đây.',
            )
          else
            ...displayedNotifications.map(
              (notification) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _NotificationItem(
                  notification: notification,
                  onTap: () {
                    _openNotificationDetail(notification);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openNotificationDetail(AppNotification notification) async {
    try {
      await ref
          .read(notificationsProvider.notifier)
          .markAsRead(notification.thongBaoId);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể cập nhật trạng thái thông báo: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.blue,
            size: 36,
          ),
          title: Text(notification.tieuDe),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.noiDung),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                _DetailLine(
                  label: 'Thời gian',
                  value: _formatDateTime(notification.thoiGian),
                ),
                if (notification.maDon != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _DetailLine(label: 'Mã đơn', value: notification.maDon!),
                ],
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute - $day/$month/${dateTime.year}';
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.trangThaiDoc == 'CHUA_DOC';

    return Card(
      color: isUnread
          ? AppColors.opacity(AppColors.blue, 0.04)
          : AppColors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isUnread
                      ? AppColors.secondaryLight
                      : AppColors.supportLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  _notificationIcon(notification),
                  color: isUnread ? AppColors.blue : AppColors.purple,
                  size: 24,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.tieuDe,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: isUnread
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      notification.noiDung,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _formatShortDate(notification.thoiGian),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                        const Spacer(),
                        Text(
                          isUnread ? 'Chưa đọc' : 'Đã đọc',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: isUnread
                                    ? AppColors.blue
                                    : AppColors.green,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(
                          Icons.chevron_right,
                          size: 19,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _notificationIcon(AppNotification notification) {
    final title = notification.tieuDe.toLowerCase();

    if (title.contains('gói')) {
      return Icons.workspace_premium_outlined;
    }

    if (title.contains('thanh toán') || title.contains('hóa đơn')) {
      return Icons.receipt_long_outlined;
    }

    if (notification.maDon != null) {
      return Icons.local_shipping_outlined;
    }

    return Icons.notifications_none_outlined;
  }

  String _formatShortDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute • $day/$month/${dateTime.year}';
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
