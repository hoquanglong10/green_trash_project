import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/app_models.dart';

class LiveLocationMap extends StatelessWidget {
  const LiveLocationMap({
    super.key,
    required this.destination,
    required this.staff,
  });

  final CustomerAddress destination;
  final StaffProfile? staff;

  @override
  Widget build(BuildContext context) {
    if (!destination.hasPickupCoordinate) {
      return const _MissingPickupLocationCard();
    }
    final activeStaff = staff;
    if (activeStaff == null || !activeStaff.hasLiveLocation) {
      return const _WaitingForLiveLocationCard();
    }

    final staffPoint = LatLng(activeStaff.toaDoLat!, activeStaff.toaDoLng!);
    final destinationPoint = LatLng(destination.toaDoLat, destination.toaDoLng);
    final center = LatLng(
      (staffPoint.latitude + destinationPoint.latitude) / 2,
      (staffPoint.longitude + destinationPoint.longitude) / 2,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.location_searching_outlined,
                    color: AppColors.secondary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vị trí nhân viên',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        activeStaff.capNhatViTriLuc == null
                            ? 'Đang cập nhật trực tiếp'
                            : 'Cập nhật ${formatDateTime(activeStaff.capNhatViTriLuc!)}',
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
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 210,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: FlutterMap(
                  options: MapOptions(initialCenter: center, initialZoom: 13),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.green_trash_project',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: staffPoint,
                          width: 44,
                          height: 44,
                          child: const _MapMarker(
                            icon: Icons.local_shipping_outlined,
                            color: AppColors.secondary,
                          ),
                        ),
                        Marker(
                          point: destinationPoint,
                          width: 44,
                          height: 44,
                          child: const _MapMarker(
                            icon: Icons.home_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Xe thu gom đang ở biểu tượng xanh dương. Điểm lấy rác là biểu tượng xanh lá.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingPickupLocationCard extends StatelessWidget {
  const _MissingPickupLocationCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.location_off_outlined, color: AppColors.warning),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Đơn cũ chưa có điểm thu gom trên bản đồ.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitingForLiveLocationCard extends StatelessWidget {
  const _WaitingForLiveLocationCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đang chờ vị trí nhân viên',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Bản đồ sẽ tự cập nhật khi nhân viên bắt đầu chia sẻ vị trí.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
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

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}
