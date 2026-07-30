import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusStyle {
  const StatusStyle({
    required this.label,
    required this.foreground,
    required this.background,
    required this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData icon;
}

StatusStyle orderStatusStyle(String status) {
  return switch (status) {
    'CHO_XU_LY' => const StatusStyle(
      label: 'Chờ xử lý',
      foreground: AppColors.accentForeground,
      background: AppColors.accentLight,
      icon: Icons.schedule_rounded,
    ),
    'CHO_NHAN' => const StatusStyle(
      label: 'Chờ nhận',
      foreground: AppColors.accentForeground,
      background: AppColors.accentLight,
      icon: Icons.assignment_ind_rounded,
    ),
    'DA_NHAN' => const StatusStyle(
      label: 'Đã nhận',
      foreground: AppColors.success,
      background: AppColors.successLight,
      icon: Icons.check_circle_rounded,
    ),
    'DANG_DEN' => const StatusStyle(
      label: 'Đang đến',
      foreground: AppColors.secondary,
      background: AppColors.secondaryLight,
      icon: Icons.local_shipping_rounded,
    ),
    'DA_DEN' => const StatusStyle(
      label: 'Đã đến',
      foreground: AppColors.secondary,
      background: AppColors.secondaryLight,
      icon: Icons.location_on_rounded,
    ),
    'DANG_CAN_RAC' => const StatusStyle(
      label: 'Đang cân rác',
      foreground: AppColors.secondary,
      background: AppColors.secondaryLight,
      icon: Icons.scale_rounded,
    ),
    'HOAN_THANH' => const StatusStyle(
      label: 'Hoàn thành',
      foreground: AppColors.success,
      background: AppColors.successLight,
      icon: Icons.verified_rounded,
    ),
    'MAC_DINH' => const StatusStyle(
      label: 'Mặc định',
      foreground: AppColors.primaryDark,
      background: AppColors.surfaceAlt,
      icon: Icons.home_rounded,
    ),
    'HUY' => const StatusStyle(
      label: 'Đã hủy',
      foreground: AppColors.error,
      background: AppColors.errorLight,
      icon: Icons.cancel_rounded,
    ),
    _ => StatusStyle(
      label: status,
      foreground: AppColors.muted,
      background: AppColors.surfaceAlt,
      icon: Icons.info_rounded,
    ),
  };
}

String paymentStatusLabel(String status) {
  return switch (status) {
    'CON_HL' || 'CON_HIEU_LUC' => 'Còn hiệu lực',
    'DA_TT' || 'DA_THANH_TOAN' => 'Đã thanh toán',
    'CHO_THANH_TOAN' => 'Chờ thanh toán',
    _ => status,
  };
}

const orderTimeline = <String>[
  'CHO_XU_LY',
  'CHO_NHAN',
  'DA_NHAN',
  'DANG_DEN',
  'DA_DEN',
  'DANG_CAN_RAC',
  'HOAN_THANH',
];

int orderStatusIndex(String status) {
  final index = orderTimeline.indexOf(status);
  return index < 0 ? 0 : index;
}
