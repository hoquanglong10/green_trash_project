import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/app_models.dart';
import '../../../../shared/widgets/app_widgets.dart';

class StaffProgressCard extends StatelessWidget {
  const StaffProgressCard({super.key, required this.order});

  final PickupOrder order;

  @override
  Widget build(BuildContext context) {
    final guide = _guide(order.trangThai);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: guide.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(guide.icon, color: guide.color, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        guide.message,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(order.trangThai),
                duration: const Duration(milliseconds: 520),
                tween: Tween(begin: 0, end: guide.progress),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => LinearProgressIndicator(
                  value: value,
                  minHeight: 7,
                  backgroundColor: AppColors.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation(guide.color),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            OrderTimeline(status: order.trangThai),
          ],
        ),
      ),
    );
  }

  _ProgressGuide _guide(String status) {
    return switch (status) {
      'CHO_XU_LY' || 'CHO_NHAN' => const _ProgressGuide(
        title: 'Kiểm tra và phản hồi đơn',
        message: 'Xem địa chỉ, loại rác và chốt giờ đến trước khi nhận.',
        icon: Icons.assignment_ind_outlined,
        color: AppColors.accent,
        background: AppColors.accentLight,
        progress: 0.12,
      ),
      'DA_NHAN' => const _ProgressGuide(
        title: 'Chuẩn bị di chuyển',
        message: 'Khi bắt đầu đi, cập nhật trạng thái để khách hàng theo dõi.',
        icon: Icons.task_alt,
        color: AppColors.primary,
        background: AppColors.primaryLight,
        progress: 0.36,
      ),
      'DANG_DEN' => const _ProgressGuide(
        title: 'Đang trên đường đến',
        message: 'Xác nhận ngay khi đã có mặt tại địa chỉ thu gom.',
        icon: Icons.route_outlined,
        color: AppColors.secondary,
        background: AppColors.secondaryLight,
        progress: 0.56,
      ),
      'DA_DEN' => const _ProgressGuide(
        title: 'Bàn giao tại điểm lấy',
        message: 'Kiểm tra sơ bộ rồi bắt đầu cân rác cùng khách hàng.',
        icon: Icons.location_on_outlined,
        color: AppColors.support,
        background: AppColors.supportLight,
        progress: 0.72,
      ),
      'DANG_CAN_RAC' => const _ProgressGuide(
        title: 'Cân và lập biên bản',
        message: 'Ghi loại rác, kg thực tế, ảnh và phí trước khi hoàn tất.',
        icon: Icons.scale_outlined,
        color: AppColors.support,
        background: AppColors.supportLight,
        progress: 0.88,
      ),
      'HOAN_THANH' => const _ProgressGuide(
        title: 'Đã hoàn thành',
        message: 'Biên bản đã lưu và khách hàng đã nhận thông báo.',
        icon: Icons.verified_outlined,
        color: AppColors.primary,
        background: AppColors.primaryLight,
        progress: 1,
      ),
      _ => const _ProgressGuide(
        title: 'Đơn đã dừng xử lý',
        message: 'Xem lịch sử hoạt động để biết lý do cập nhật.',
        icon: Icons.cancel_outlined,
        color: AppColors.slate,
        background: AppColors.surfaceAlt,
        progress: 0,
      ),
    };
  }
}

class _ProgressGuide {
  const _ProgressGuide({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.background,
    required this.progress,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Color background;
  final double progress;
}
