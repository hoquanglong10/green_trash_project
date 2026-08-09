import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_widgets.dart';
import 'widgets/notification_list_item.dart';

enum _NotificationFilter { all, unread, read }

class CustomerNotificationsScreen extends ConsumerStatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  ConsumerState<CustomerNotificationsScreen> createState() =>
      _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState
    extends ConsumerState<CustomerNotificationsScreen> {
  _NotificationFilter _filter = _NotificationFilter.all;

  // Chỉ lưu trạng thái đọc trong lần chạy hiện tại.
  final Set<String> _locallyReadIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);

    final unreadCount = notifications
        .where((notification) => !_isRead(notification))
        .length;

    final filteredNotifications = _filterNotifications(notifications);

    return AppPage(
      maxWidth: 900,
      title: 'Thông báo',
      subtitle: 'Cập nhật đơn thu gom của bạn',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.xxl,
        ),
        children: [
          _buildSummaryCard(total: notifications.length, unread: unreadCount),

          const SizedBox(height: AppSpacing.md),

          _buildFilterChips(total: notifications.length, unread: unreadCount),

          const SizedBox(height: AppSpacing.lg),

          if (filteredNotifications.isEmpty)
            _buildEmptyState()
          else
            for (
              var index = 0;
              index < filteredNotifications.length;
              index++
            ) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _openNotification(filteredNotifications[index]);
                },
                child: NotificationListItem(
                  notification: _displayNotification(
                    filteredNotifications[index],
                  ),
                ),
              ),

              if (index != filteredNotifications.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }

  // =========================
  // THẺ TỔNG QUAN
  // =========================

  Widget _buildSummaryCard({required int total, required int unread}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primary,
              size: 27,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unread == 0
                      ? 'Bạn đã đọc tất cả thông báo'
                      : '$unread thông báo chưa đọc',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tổng cộng $total thông báo',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          if (unread > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded),
              label: const Text('Đọc tất cả'),
            ),
        ],
      ),
    );
  }

  // =========================
  // BỘ LỌC
  // =========================

  Widget _buildFilterChips({required int total, required int unread}) {
    final read = total - unread;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ChoiceChip(
          label: Text('Tất cả ($total)'),
          selected: _filter == _NotificationFilter.all,
          onSelected: (_) {
            setState(() {
              _filter = _NotificationFilter.all;
            });
          },
        ),

        ChoiceChip(
          label: Text('Chưa đọc ($unread)'),
          selected: _filter == _NotificationFilter.unread,
          onSelected: (_) {
            setState(() {
              _filter = _NotificationFilter.unread;
            });
          },
        ),

        ChoiceChip(
          label: Text('Đã đọc ($read)'),
          selected: _filter == _NotificationFilter.read,
          onSelected: (_) {
            setState(() {
              _filter = _NotificationFilter.read;
            });
          },
        ),
      ],
    );
  }

  List<AppNotification> _filterNotifications(
    List<AppNotification> notifications,
  ) {
    switch (_filter) {
      case _NotificationFilter.unread:
        return notifications
            .where((notification) => !_isRead(notification))
            .toList();

      case _NotificationFilter.read:
        return notifications
            .where((notification) => _isRead(notification))
            .toList();

      case _NotificationFilter.all:
        return notifications;
    }
  }

  // =========================
  // TRẠNG THÁI ĐỌC
  // =========================

  bool _isRead(AppNotification notification) {
    return notification.trangThaiDoc == 'DA_DOC' ||
        _locallyReadIds.contains(notification.thongBaoId);
  }

  void _markAsRead(AppNotification notification) {
    if (_isRead(notification)) {
      return;
    }

    setState(() {
      _locallyReadIds.add(notification.thongBaoId);
    });
  }

  void _markAllAsRead() {
    final notifications = ref.read(notificationsProvider);

    setState(() {
      for (final notification in notifications) {
        _locallyReadIds.add(notification.thongBaoId);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu tất cả thông báo là đã đọc'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Tạo bản hiển thị đã đọc để dấu chấm vàng biến mất.
  AppNotification _displayNotification(AppNotification notification) {
    if (!_isRead(notification)) {
      return notification;
    }

    return AppNotification(
      thongBaoId: notification.thongBaoId,
      nguoiNhanId: notification.nguoiNhanId,
      maDon: notification.maDon,
      tieuDe: notification.tieuDe,
      noiDung: notification.noiDung,
      trangThaiDoc: 'DA_DOC',
      thoiGian: notification.thoiGian,
    );
  }

  // =========================
  // CHI TIẾT THÔNG BÁO
  // =========================

  Future<void> _openNotification(AppNotification notification) async {
    _markAsRead(notification);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            _notificationIcon(notification.tieuDe),
            size: 36,
            color: AppColors.primary,
          ),
          title: Text(notification.tieuDe),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.noiDung,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: AppSpacing.lg),

                const Divider(),

                const SizedBox(height: AppSpacing.sm),

                _NotificationDetailRow(
                  label: 'Thời gian',
                  value: _formatDateTime(notification.thoiGian),
                ),

                if (notification.maDon != null &&
                    notification.maDon!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _NotificationDetailRow(
                    label: 'Mã đơn',
                    value: notification.maDon!,
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),

                const _NotificationDetailRow(
                  label: 'Trạng thái',
                  value: 'Đã đọc',
                ),
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

  IconData _notificationIcon(String title) {
    final value = title.toLowerCase();

    if (value.contains('hoàn thành')) {
      return Icons.task_alt_rounded;
    }

    if (value.contains('cân')) {
      return Icons.scale_rounded;
    }

    if (value.contains('đến')) {
      return Icons.location_on_rounded;
    }

    if (value.contains('di chuyển')) {
      return Icons.route_rounded;
    }

    if (value.contains('nhận đơn')) {
      return Icons.assignment_turned_in_outlined;
    }

    return Icons.notifications_rounded;
  }

  String _formatDateTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');

    return '$hour:$minute • '
        '$day/$month/${value.year}';
  }

  Widget _buildEmptyState() {
    late String title;
    late String message;
    late IconData icon;

    switch (_filter) {
      case _NotificationFilter.unread:
        title = 'Không còn thông báo chưa đọc';
        message = 'Bạn đã xem hết các thông báo mới.';
        icon = Icons.mark_email_read_outlined;
        break;

      case _NotificationFilter.read:
        title = 'Chưa có thông báo đã đọc';
        message = 'Các thông báo bạn đã xem sẽ xuất hiện ở đây.';
        icon = Icons.drafts_outlined;
        break;

      case _NotificationFilter.all:
        title = 'Chưa có thông báo';
        message = 'Cập nhật về đơn thu gom sẽ hiển thị tại đây.';
        icon = Icons.notifications_none_outlined;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(icon, size: 56, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _NotificationDetailRow extends StatelessWidget {
  const _NotificationDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
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
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
