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
      foreground: AppColors.accent,
      background: AppColors.accentLight,
      icon: Icons.schedule,
    ),
    'CHO_NHAN' => const StatusStyle(
      label: 'Chờ nhận',
      foreground: AppColors.secondary,
      background: AppColors.secondaryLight,
      icon: Icons.assignment_ind_outlined,
    ),
    'DA_NHAN' => const StatusStyle(
      label: 'Đã nhận',
      foreground: AppColors.primary,
      background: AppColors.primaryLight,
      icon: Icons.task_alt,
    ),
    'DANG_DEN' => const StatusStyle(
      label: 'Đang đến',
      foreground: AppColors.secondary,
      background: AppColors.secondaryLight,
      icon: Icons.local_shipping_outlined,
    ),
    'DA_DEN' => const StatusStyle(
      label: 'Đã đến',
      foreground: AppColors.support,
      background: AppColors.supportLight,
      icon: Icons.location_on_outlined,
    ),
    'DANG_CAN_RAC' => const StatusStyle(
      label: 'Đang cân rác',
      foreground: AppColors.support,
      background: AppColors.supportLight,
      icon: Icons.scale_outlined,
    ),
    'HOAN_THANH' => const StatusStyle(
      label: 'Hoàn thành',
      foreground: AppColors.success,
      background: AppColors.primaryLight,
      icon: Icons.verified_outlined,
    ),
    'MAC_DINH' => const StatusStyle(
      label: 'Mặc định',
      foreground: AppColors.primaryDark,
      background: AppColors.surfaceAlt,
      icon: Icons.home_outlined,
    ),
    'HUY' => const StatusStyle(
      label: 'Đã hủy',
      foreground: AppColors.slate,
      background: AppColors.surfaceAlt,
      icon: Icons.cancel_outlined,
    ),
    _ => StatusStyle(
      label: status,
      foreground: AppColors.muted,
      background: AppColors.surfaceAlt,
      icon: Icons.info_outline,
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
