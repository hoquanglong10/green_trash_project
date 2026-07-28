import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/app_models.dart';
import '../../../../shared/widgets/app_widgets.dart';

class TrackingHero extends StatelessWidget {
  const TrackingHero({super.key, required this.order, required this.staff});

  final PickupOrder order;
  final StaffProfile? staff;

  @override
  Widget build(BuildContext context) {
    return HomeBrandHeader(
      title: _heroTitle(order),
      subtitle: _heroSubtitle(order, staff),
      trailing: _TrackingStatusVisual(status: order.trangThai),
    );
  }

  String _heroTitle(PickupOrder order) {
    if (order.trangThai == 'CHO_XU_LY' && order.waitingForSupport) {
      return 'Đang chờ hỗ trợ';
    }
    return switch (order.trangThai) {
      'CHO_XU_LY' => 'Đang chờ nhân viên nhận',
      'CHO_NHAN' => 'Đang chờ nhân viên xác nhận',
      'DA_NHAN' => 'Nhân viên đã nhận đơn',
      'DANG_DEN' => 'Nhân viên đang đến',
      'DA_DEN' => 'Nhân viên đã đến điểm lấy',
      'DANG_CAN_RAC' => 'Đang cân và kiểm tra',
      'HOAN_THANH' => 'Đơn đã hoàn thành',
      'HUY' => 'Đơn đã hủy',
      _ => 'Đang cập nhật đơn',
    };
  }

  String _heroSubtitle(PickupOrder order, StaffProfile? staff) {
    if (order.trangThai == 'CHO_XU_LY') {
      if (order.waitingForSupport) {
        return 'Chưa có nhân viên phù hợp. Đơn đã được chuyển vào hàng chờ hỗ trợ.';
      }
      if (staff == null) {
        return 'Đơn đang hiển thị cho các nhân viên sẵn sàng.';
      }
      return 'Đã gửi yêu cầu đến ${staff.maNhanVien} tại ${staff.viTriHienTai}.';
    }
    if (staff == null) {
      return 'GreenTrash sẽ tiếp tục cập nhật trạng thái đơn.';
    }
    final arrival = order.gioChot;
    if (arrival != null && order.trangThai == 'DA_NHAN') {
      return '${staff.maNhanVien} dự kiến đến lúc ${_formatTime(arrival)}.';
    }
    return '${staff.maNhanVien} phụ trách đơn trong khung ${order.khungGio}.';
  }

  String _formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}

class StaffMatchingCard extends StatelessWidget {
  const StaffMatchingCard({super.key, required this.staff});

  final StaffProfile? staff;

  @override
  Widget build(BuildContext context) {
    final selectedStaff = staff;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SearchingLogo(size: 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedStaff == null
                              ? 'Đang chờ nhân viên nhận đơn'
                              : 'Đang chờ ${selectedStaff.maNhanVien} xác nhận',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Bạn có thể rời màn hình này. Trạng thái sẽ tự cập nhật khi một nhân viên nhận đơn.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadius.pill),
                    ),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      backgroundColor: AppColors.surfaceAlt,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Danh sách đơn đang được cập nhật theo thời gian thực',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingStatusVisual extends StatelessWidget {
  const _TrackingStatusVisual({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == 'CHO_XU_LY' || status == 'CHO_NHAN') {
      return const _SearchingLogo(size: 52, inverse: true);
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.opacity(AppColors.white, 0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accent),
      ),
      child: Icon(_heroIcon(status), color: AppColors.textInverse),
    );
  }

  IconData _heroIcon(String status) {
    return switch (status) {
      'DA_NHAN' => Icons.task_alt,
      'DANG_DEN' => Icons.local_shipping_outlined,
      'DA_DEN' => Icons.location_on_outlined,
      'DANG_CAN_RAC' => Icons.scale_outlined,
      'HOAN_THANH' => Icons.verified_outlined,
      'HUY' => Icons.cancel_outlined,
      _ => Icons.receipt_long_outlined,
    };
  }
}

class _SearchingLogo extends StatefulWidget {
  const _SearchingLogo({required this.size, this.inverse = false});

  final double size;
  final bool inverse;

  @override
  State<_SearchingLogo> createState() => _SearchingLogoState();
}

class _SearchingLogoState extends State<_SearchingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.inverse
        ? AppColors.opacity(AppColors.white, 0.16)
        : AppColors.primaryLight;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.94 + (_controller.value * 0.06);
        return Transform.scale(scale: scale, child: child);
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                backgroundColor: background,
                color: widget.inverse ? AppColors.accent : AppColors.secondary,
              ),
            ),
            Container(
              width: widget.size - 10,
              height: widget.size - 10,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: LogoMark(size: widget.size - 26, dark: widget.inverse),
            ),
          ],
        ),
      ),
    );
  }
}
