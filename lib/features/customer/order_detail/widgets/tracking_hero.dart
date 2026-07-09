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
      title: _heroTitle(order.trangThai),
      subtitle: _heroSubtitle(order, staff),
      trailing: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.opacity(AppColors.white, 0.14),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.accent),
        ),
        child: Icon(_heroIcon(order.trangThai), color: AppColors.textInverse),
      ),
    );
  }

  static IconData _heroIcon(String status) {
    return switch (status) {
      'CHO_XU_LY' => Icons.notifications_active_outlined,
      'DA_NHAN' => Icons.task_alt,
      'DANG_DEN' => Icons.local_shipping_outlined,
      'DA_DEN' => Icons.location_on_outlined,
      'DANG_CAN_RAC' => Icons.scale_outlined,
      'HOAN_THANH' => Icons.verified_outlined,
      'HUY' => Icons.cancel_outlined,
      _ => Icons.receipt_long_outlined,
    };
  }

  static String _heroTitle(String status) {
    return switch (status) {
      'CHO_XU_LY' => 'Đang tìm nhân viên',
      'DA_NHAN' => 'Nhân viên đã nhận đơn',
      'DANG_DEN' => 'Nhân viên đang đến',
      'DA_DEN' => 'Nhân viên đã đến điểm lấy',
      'DANG_CAN_RAC' => 'Đang cân và kiểm tra',
      'HOAN_THANH' => 'Đơn đã hoàn thành',
      'HUY' => 'Đơn đã hủy',
      _ => 'Đang cập nhật đơn',
    };
  }

  static String _heroSubtitle(PickupOrder order, StaffProfile? staff) {
    if (order.trangThai == 'CHO_XU_LY') {
      if (staff == null) {
        return 'GreenTrash đang tìm nhân viên sẵn sàng gần khu vực của bạn.';
      }
      return 'Thông báo đã gửi đến ${staff.maNhanVien} tại ${staff.viTriHienTai}.';
    }
    if (staff == null) return 'GreenTrash sẽ tiếp tục cập nhật trạng thái đơn.';
    return '${staff.maNhanVien} phụ trách đơn trong khung ${order.khungGio}.';
  }
}
