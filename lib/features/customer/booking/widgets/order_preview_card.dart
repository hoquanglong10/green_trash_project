import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/app_models.dart';
import 'option_icon.dart';

class OrderPreviewCard extends StatelessWidget {
  const OrderPreviewCard({
    super.key,
    required this.address,
    required this.waste,
    required this.staff,
    required this.kg,
    required this.date,
    required this.timeSlot,
    required this.paymentMethod,
    required this.estimate,
  });

  final CustomerAddress? address;
  final WasteType? waste;
  final StaffProfile? staff;
  final double? kg;
  final DateTime date;
  final String? timeSlot;
  final String paymentMethod;
  final String estimate;

  @override
  Widget build(BuildContext context) {
    final selectedKg = kg;
    final selectedStaff = staff;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const OptionIcon(
                  icon: Icons.receipt_long_outlined,
                  selected: true,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Tóm tắt đơn',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _PreviewRow(
              icon: Icons.place_outlined,
              label: 'Địa chỉ',
              value: address?.shortAddress ?? 'Chưa chọn',
            ),
            _PreviewRow(
              icon: Icons.recycling,
              label: 'Loại rác',
              value: waste?.tenLoaiRac ?? 'Chưa chọn',
            ),
            _PreviewRow(
              icon: Icons.schedule,
              label: 'Thời gian',
              value: '${formatDayMonth(date)} • ${timeSlot ?? 'Chưa chọn'}',
            ),
            _PreviewRow(
              icon: Icons.scale_outlined,
              label: 'Khối lượng',
              value: selectedKg == null ? 'Chưa nhập' : formatKg(selectedKg),
            ),
            _PreviewRow(
              icon: Icons.payments_outlined,
              label: 'Tính phí',
              value:
                  '${paymentMethod == 'GOI_THANG' ? 'Gói tháng' : 'Theo kg'} • $estimate',
            ),
            _PreviewRow(
              icon: Icons.badge_outlined,
              label: 'Nhân viên',
              value: selectedStaff == null
                  ? 'Hệ thống sẽ tìm nhân viên'
                  : '${selectedStaff.maNhanVien} • ${selectedStaff.viTriHienTai}',
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
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
          Icon(icon, size: 17, color: AppColors.primaryDark),
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
