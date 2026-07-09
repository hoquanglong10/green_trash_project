import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';

class AdminAssignmentScreen extends ConsumerStatefulWidget {
  const AdminAssignmentScreen({super.key});

  @override
  ConsumerState<AdminAssignmentScreen> createState() =>
      _AdminAssignmentScreenState();
}

class _AdminAssignmentScreenState extends ConsumerState<AdminAssignmentScreen> {
  String? _selectedOrderId;
  String? _selectedStaffId;

  @override
  Widget build(BuildContext context) {
    final orders = ref
        .watch(adminOrdersProvider)
        .where(
          (order) =>
              order.trangThai == 'CHO_XU_LY' && order.nhanVienDeXuatId == null,
        )
        .toList();
    final staff = ref.watch(staffProfilesProvider);
    final addresses = ref.watch(allAddressesProvider);
    final wastes = ref.watch(wasteTypesProvider);

    if (!orders.any((order) => order.maDon == _selectedOrderId)) {
      _selectedOrderId = orders.isNotEmpty ? orders.first.maDon : null;
    }
    if (!staff.any((profile) => profile.nhanVienId == _selectedStaffId)) {
      _selectedStaffId = staff.isNotEmpty ? staff.first.nhanVienId : null;
    }

    return AppPage(
      title: 'Phân công đơn',
      subtitle: 'Điều phối nhân viên thu gom',
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FilledButton.icon(
            onPressed: _selectedOrderId == null || _selectedStaffId == null
                ? null
                : () {
                    ref
                        .read(orderControllerProvider.notifier)
                        .assignStaff(
                          maDon: _selectedOrderId!,
                          nhanVienId: _selectedStaffId!,
                        );
                    Navigator.pop(context);
                  },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Xác nhận phân công'),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.sm,
          AppSpacing.screenHorizontal,
          120,
        ),
        children: [
          const SectionHeader(title: 'Đơn chờ xử lý'),
          const SizedBox(height: AppSpacing.sm),
          if (orders.isEmpty)
            const EmptyState(
              icon: Icons.task_alt,
              title: 'Không còn đơn chờ xử lý',
              message: 'Khi có đơn mới, admin có thể phân công tại đây.',
            )
          else
            ...orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _SelectableOrderCard(
                  selected: _selectedOrderId == order.maDon,
                  order: order,
                  address: _findAddress(addresses, order.diaChiId),
                  waste: _findWaste(wastes, order.loaiRacId),
                  onTap: () => setState(() => _selectedOrderId = order.maDon),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Nhân viên'),
          const SizedBox(height: AppSpacing.sm),
          ...staff.map(
            (profile) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SelectableStaffCard(
                selected: _selectedStaffId == profile.nhanVienId,
                profile: profile,
                onTap: () {
                  setState(() => _selectedStaffId = profile.nhanVienId);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  CustomerAddress? _findAddress(List<CustomerAddress> addresses, String id) {
    for (final address in addresses) {
      if (address.diaChiId == id) return address;
    }
    return null;
  }

  WasteType? _findWaste(List<WasteType> wastes, String id) {
    for (final waste in wastes) {
      if (waste.loaiRacId == id) return waste;
    }
    return null;
  }
}

class _SelectableOrderCard extends StatelessWidget {
  const _SelectableOrderCard({
    required this.selected,
    required this.order,
    required this.address,
    required this.waste,
    required this.onTap,
  });

  final bool selected;
  final PickupOrder order;
  final CustomerAddress? address;
  final WasteType? waste;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.3 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.maDon,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(waste?.tenLoaiRac ?? order.loaiRacId),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      address?.shortAddress ?? order.diaChiId,
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
        ),
      ),
    );
  }
}

class _SelectableStaffCard extends StatelessWidget {
  const _SelectableStaffCard({
    required this.selected,
    required this.profile,
    required this.onTap,
  });

  final bool selected;
  final StaffProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.3 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: ListTile(
          leading: Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.primary : AppColors.muted,
          ),
          title: Text(profile.maNhanVien),
          subtitle: Text(
            '${profile.viTriHienTai} • ${profile.gioBatDau}-${profile.gioKetThuc}',
          ),
          trailing: const Icon(Icons.badge_outlined),
        ),
      ),
    );
  }
}
