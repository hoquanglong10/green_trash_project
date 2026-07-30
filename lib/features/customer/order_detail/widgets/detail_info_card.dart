import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/app_models.dart';
import '../../../../shared/widgets/app_widgets.dart';

class DetailInfoCard extends StatelessWidget {
  const DetailInfoCard({
    super.key,
    required this.order,
    required this.address,
    required this.waste,
    required this.staff,
  });

  final PickupOrder order;
  final CustomerAddress? address;
  final WasteType? waste;
  final StaffProfile? staff;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.recycling_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        waste?.tenLoaiRac ?? order.loaiRacId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${formatDayMonth(order.ngayThuGom)} • ${order.khungGio}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: order.trangThai, compact: true),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.xs),
            DetailRow(
              icon: Icons.scale_outlined,
              label: 'Dự kiến',
              value: formatKg(order.khoiLuongDuKien),
            ),
            DetailRow(
              icon: Icons.place_outlined,
              label: 'Địa chỉ',
              value: address?.shortAddress ?? order.diaChiId,
            ),
            DetailRow(
              icon: Icons.payments_outlined,
              label: 'Tính phí',
              value: order.hinhThucTinhPhi == 'GOI_THANG'
                  ? 'Gói tháng'
                  : 'Theo kg',
            ),
            DetailRow(
              icon: Icons.badge_outlined,
              label: 'Nhân viên',
              value: _staffStatusLabel(order, staff),
            ),
            if (order.gioChot != null)
              DetailRow(
                icon: Icons.schedule_outlined,
                label: 'Giờ đến',
                value: 'Dự kiến ${_formatTime(order.gioChot!)}',
              ),
            if (order.ghiChu.isNotEmpty)
              DetailRow(
                icon: Icons.notes_outlined,
                label: 'Ghi chú',
                value: order.ghiChu,
              ),
          ],
        ),
      ),
    );
  }

  static String _staffStatusLabel(PickupOrder order, StaffProfile? staff) {
    if (staff == null) return 'Đang chờ nhân viên nhận đơn';
    if (order.nhanVienHienTaiId == null) {
      return 'Đã gửi thông báo đến ${staff.maNhanVien} • ${staff.viTriHienTai}';
    }
    return '${staff.maNhanVien} • ${staff.viTriHienTai}';
  }

  static String _formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryDark),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
