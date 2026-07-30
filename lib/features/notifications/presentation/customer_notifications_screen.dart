import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/home_dashboard_widgets.dart';
import 'widgets/notification_list_item.dart';

class CustomerNotificationsScreen extends ConsumerWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return AppPage(
      maxWidth: 900,
      title: 'Thông báo',
      subtitle: 'Cập nhật đơn thu gom của bạn',
      child: notifications.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.notifications_none_outlined,
                title: 'Chưa có thông báo',
                message: 'Cập nhật về đơn thu gom sẽ hiển thị tại đây.',
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth >= 720
                    ? AppSpacing.xl
                    : AppSpacing.screenHorizontal;
                final list = ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.md,
                    horizontalPadding,
                    AppSpacing.xxl,
                  ),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, index) => AnimatedEntrance(
                    order: index.clamp(0, 5),
                    child: NotificationListItem(
                      notification: notifications[index],
                    ),
                  ),
                );
                return kIsWeb ? Scrollbar(child: list) : list;
              },
            ),
    );
  }
}
