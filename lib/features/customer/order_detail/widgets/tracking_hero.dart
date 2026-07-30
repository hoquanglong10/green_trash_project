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
    final waiting = order.trangThai == 'CHO_XU_LY' ||
        order.trangThai == 'CHO_NHAN';
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.hero,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'CẬP NHẬT TRỰC TIẾP',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.textInverseMuted,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _heroTitle(order),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textInverse,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _heroSubtitle(order, staff),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textInverseMuted,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                _TrackingStatusVisual(status: order.trangThai),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            color: AppColors.opacity(AppColors.green950, 0.24),
            child: waiting
                ? _WaitingSummary(order: order)
                : _AssignedStaffSummary(order: order, staff: staff),
          ),
        ],
      ),
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

class _WaitingSummary extends StatelessWidget {
  const _WaitingSummary({required this.order});

  final PickupOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.radar_rounded,
              color: AppColors.accent,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                order.waitingForSupport
                    ? 'Hệ thống đang mở rộng phạm vi tìm kiếm'
                    : 'Đang gửi đơn đến nhân viên sẵn sàng',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
          child: LinearProgressIndicator(
            minHeight: 4,
            backgroundColor: Color(0x35FFFFFF),
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _AssignedStaffSummary extends StatelessWidget {
  const _AssignedStaffSummary({required this.order, required this.staff});

  final PickupOrder order;
  final StaffProfile? staff;

  @override
  Widget build(BuildContext context) {
    final eta = order.gioChot;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.person_pin_circle_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                staff?.maNhanVien ?? 'Nhân viên đang cập nhật',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                eta == null
                    ? 'Khung giờ ${order.khungGio}'
                    : 'Dự kiến ${_time(eta)} • ${order.khungGio}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textInverseMuted,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Icon(
          Icons.wifi_tethering_rounded,
          color: AppColors.accent,
          size: 20,
        ),
      ],
    );
  }

  String _time(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller
        ..stop()
        ..value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
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
