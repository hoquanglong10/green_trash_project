import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../application/foreground_location_tracking_controller.dart';

class LocationSharingCard extends StatelessWidget {
  const LocationSharingCard({
    super.key,
    required this.state,
    required this.onRetry,
  });

  final LocationTrackingState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(state);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: visual.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: visual.loading
                  ? const Padding(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(visual.icon, color: visual.color, size: 21),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visual.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    visual.message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  if (state.lastUpdated != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Gửi lúc ${formatDateTime(state.lastUpdated!)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (visual.canRetry) ...[
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_outlined, size: 18),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _LocationVisual _visualFor(LocationTrackingState state) {
    return switch (state.phase) {
      LocationTrackingPhase.requestingPermission => const _LocationVisual(
        title: 'Đang bật chia sẻ vị trí',
        message: 'Đang xin quyền GPS để khách hàng theo dõi lộ trình.',
        icon: Icons.location_searching_outlined,
        color: AppColors.secondary,
        background: AppColors.secondaryLight,
        loading: true,
      ),
      LocationTrackingPhase.active => _LocationVisual(
        title: state.lastUpdated == null
            ? 'Đã cấp quyền, đang tìm GPS'
            : 'Đang chia sẻ vị trí trực tiếp',
        message:
            state.message ??
            'Vị trí được gửi khi bạn di chuyển tối thiểu 10 m.',
        icon: state.lastUpdated == null ? Icons.gps_not_fixed : Icons.gps_fixed,
        color: AppColors.primary,
        background: AppColors.primaryLight,
      ),
      LocationTrackingPhase.serviceDisabled => const _LocationVisual(
        title: 'Định vị đang tắt',
        message: 'Hãy bật dịch vụ định vị rồi thử lại.',
        icon: Icons.location_disabled_outlined,
        color: AppColors.accent,
        background: AppColors.accentLight,
        canRetry: true,
      ),
      LocationTrackingPhase.permissionDenied => const _LocationVisual(
        title: 'Chưa có quyền vị trí',
        message: 'Cho phép vị trí khi dùng ứng dụng để khách theo dõi đơn.',
        icon: Icons.location_off_outlined,
        color: AppColors.accent,
        background: AppColors.accentLight,
        canRetry: true,
      ),
      LocationTrackingPhase.permissionDeniedForever => const _LocationVisual(
        title: 'Cần cấp quyền trong cài đặt',
        message: 'Mở cài đặt ứng dụng và cho phép truy cập vị trí.',
        icon: Icons.settings_outlined,
        color: AppColors.accent,
        background: AppColors.accentLight,
        canRetry: true,
      ),
      LocationTrackingPhase.failed => _LocationVisual(
        title: 'Chưa gửi được vị trí',
        message: state.message ?? 'Kiểm tra mạng rồi thử lại.',
        icon: Icons.sync_problem_outlined,
        color: AppColors.accent,
        background: AppColors.accentLight,
        canRetry: true,
      ),
      LocationTrackingPhase.idle => const _LocationVisual(
        title: 'Chia sẻ vị trí đang chờ',
        message: 'Vị trí sẽ được bật khi bạn bắt đầu di chuyển.',
        icon: Icons.location_searching_outlined,
        color: AppColors.secondary,
        background: AppColors.secondaryLight,
      ),
    };
  }
}

class _LocationVisual {
  const _LocationVisual({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.background,
    this.loading = false,
    this.canRetry = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Color background;
  final bool loading;
  final bool canRetry;
}
