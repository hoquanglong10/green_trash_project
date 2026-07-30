import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/app_models.dart';
import '../../../../shared/widgets/app_widgets.dart';

class StaffOrderInfoCard extends StatelessWidget {
  const StaffOrderInfoCard({
    super.key,
    required this.order,
    required this.customer,
    required this.address,
    required this.waste,
  });

  final PickupOrder order;
  final AppUser? customer;
  final CustomerAddress? address;
  final WasteType? waste;

  @override
  Widget build(BuildContext context) {
    final currentAddress = address;
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
                        order.maDon,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        waste?.tenLoaiRac ?? order.loaiRacId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
            _InfoLine(
              icon: Icons.person_outline,
              label: 'Khách',
              value: customer?.hoTen ?? order.khachHangId,
            ),
            _InfoLine(
              icon: Icons.phone_outlined,
              label: 'Liên hệ',
              value: customer?.soDienThoai ?? 'Chưa có số điện thoại',
            ),
            _InfoLine(
              icon: Icons.place_outlined,
              label: 'Địa chỉ',
              value: currentAddress == null
                  ? order.diaChiId
                  : '${currentAddress.shortAddress}, ${currentAddress.quanHuyen}',
            ),
            _InfoLine(
              icon: Icons.event_outlined,
              label: 'Lịch hẹn',
              value:
                  '${formatDate(order.ngayThuGom)} • ${order.khungGio}${_arrivalSuffix(order.gioChot)}',
            ),
            _InfoLine(
              icon: Icons.scale_outlined,
              label: 'Dự kiến',
              value: formatKg(order.khoiLuongDuKien),
            ),
            _InfoLine(
              icon: Icons.payments_outlined,
              label: 'Tính phí',
              value: order.hinhThucTinhPhi == 'GOI_THANG'
                  ? 'Gói tháng'
                  : 'Theo kg',
            ),
            _InfoLine(
              icon: Icons.notes_outlined,
              label: 'Ghi chú',
              value: order.ghiChu.isEmpty ? 'Không có' : order.ghiChu,
            ),
          ],
        ),
      ),
    );
  }

  String _arrivalSuffix(DateTime? arrival) {
    if (arrival == null) return '';
    final time =
        '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')}';
    return ' • Đã chốt $time';
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
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
            width: 74,
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
