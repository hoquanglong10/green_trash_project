import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../models/app_models.dart';
import '../../../../../shared/widgets/app_widgets.dart';

class AddressBookCard extends StatelessWidget {
  const AddressBookCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  final CustomerAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = address.toaDoLat != 0 || address.toaDoLng != 0;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: address.macDinh ? AppColors.green300 : AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  address.macDinh
                      ? Icons.home_rounded
                      : Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.diaChiChiTiet,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          if (address.macDinh)
                            const StatusChip(
                              label: 'Mặc định',
                              status: 'HOAN_THANH',
                              icon: Icons.check_circle_outline_rounded,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        [
                          address.phuongXa,
                          address.quanHuyen,
                          address.tinhThanh,
                        ].where((value) => value.trim().isNotEmpty).join(', '),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            hasCoordinates
                                ? Icons.gps_fixed_rounded
                                : Icons.gps_off_rounded,
                            size: 16,
                            color: hasCoordinates
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              hasCoordinates
                                  ? 'Đã lưu vị trí bản đồ'
                                  : 'Chưa có tọa độ, hệ thống sẽ ghép theo khu vực',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_AddressAction>(
                  tooltip: 'Tùy chọn địa chỉ',
                  onSelected: (action) {
                    switch (action) {
                      case _AddressAction.edit:
                        onEdit();
                        break;
                      case _AddressAction.delete:
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _AddressAction.edit,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Chỉnh sửa'),
                      ),
                    ),
                    PopupMenuItem(
                      value: _AddressAction.delete,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.danger,
                        ),
                        title: Text('Xóa địa chỉ'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!address.macDinh) ...[
              const Divider(height: AppSpacing.xxl),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onSetDefault,
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Đặt làm mặc định'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _AddressAction { edit, delete }
