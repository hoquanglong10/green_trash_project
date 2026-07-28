import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/app_models.dart';
import '../../../../shared/widgets/app_widgets.dart';

class StaffOrderHeader extends StatelessWidget {
  const StaffOrderHeader({
    super.key,
    required this.order,
    required this.customer,
  });

  final PickupOrder order;
  final AppUser? customer;

  @override
  Widget build(BuildContext context) {
    return HomeBrandHeader(
      title: _title(order.trangThai),
      subtitle: _subtitle(order, customer),
      trailing: SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              key: ValueKey(order.trangThai),
              duration: const Duration(milliseconds: 520),
              tween: Tween(begin: 0, end: _progress(order.trangThai)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => CircularProgressIndicator(
                value: value,
                strokeWidth: 3,
                backgroundColor: AppColors.opacity(AppColors.white, 0.18),
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.opacity(AppColors.white, 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon(order.trangThai),
                size: 21,
                color: AppColors.textInverse,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle(PickupOrder order, AppUser? customer) {
    final base =
        '${customer?.hoTen ?? order.khachHangId} • ${formatDayMonth(order.ngayThuGom)} • ${order.khungGio}';
    final arrival = order.gioChot;
    if (arrival == null || order.trangThai == 'CHO_XU_LY') return base;
    return '$base • Đến lúc ${_formatTime(arrival)}';
  }

  String _title(String status) {
    return switch (status) {
      'CHO_XU_LY' => 'Đơn đang chờ nhận',
      'CHO_NHAN' => 'Đơn đang chờ nhận',
      'DA_NHAN' => 'Đã nhận và chốt giờ',
      'DANG_DEN' => 'Đang di chuyển',
      'DA_DEN' => 'Đã đến điểm lấy',
      'DANG_CAN_RAC' => 'Cân và lập biên bản',
      'HOAN_THANH' => 'Thu gom thành công',
      'HUY' => 'Đơn đã hủy',
      _ => 'Đơn thu gom',
    };
  }

  IconData _icon(String status) {
    return switch (status) {
      'CHO_XU_LY' => Icons.notifications_active_outlined,
      'CHO_NHAN' => Icons.assignment_ind_outlined,
      'DA_NHAN' => Icons.task_alt,
      'DANG_DEN' => Icons.route_outlined,
      'DA_DEN' => Icons.location_on_outlined,
      'DANG_CAN_RAC' => Icons.scale_outlined,
      'HOAN_THANH' => Icons.verified_outlined,
      'HUY' => Icons.cancel_outlined,
      _ => Icons.assignment_outlined,
    };
  }

  double _progress(String status) {
    return switch (status) {
      'CHO_XU_LY' => 0.08,
      'CHO_NHAN' => 0.14,
      'DA_NHAN' => 0.36,
      'DANG_DEN' => 0.55,
      'DA_DEN' => 0.72,
      'DANG_CAN_RAC' => 0.88,
      'HOAN_THANH' => 1,
      _ => 0,
    };
  }

  String _formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}
