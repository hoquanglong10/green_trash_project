import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';

class ServicePriceScreen extends ConsumerWidget {
  const ServicePriceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wasteTypes = ref.watch(wasteTypesProvider);
    final prices = ref.watch(pricesProvider);

    return AppPage(
      title: 'Loại rác và bảng giá',
      subtitle: 'Giá thu gom hiện tại',
      maxWidth: 700,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          const HomeBrandHeader(
            title: 'Bảng giá thu gom',
            subtitle:
                'Đơn giá được tính theo khối lượng rác thực tế sau khi cân.',
            trailing: Icon(
              Icons.price_check_outlined,
              size: 40,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          SectionHeader(
            title: 'Danh sách dịch vụ',
            subtitle: '${wasteTypes.length} loại rác đang được hỗ trợ',
          ),
          const SizedBox(height: AppSpacing.sm),

          if (wasteTypes.isEmpty)
            const EmptyState(
              icon: Icons.recycling_outlined,
              title: 'Chưa có loại rác',
              message: 'Danh sách loại rác sẽ xuất hiện tại đây.',
            )
          else
            ...wasteTypes.map((waste) {
              final price = _findPrice(
                prices: prices,
                wasteTypeId: waste.loaiRacId,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ServicePriceCard(waste: waste, price: price),
              );
            }),
        ],
      ),
    );
  }

  PriceItem? _findPrice({
    required List<PriceItem> prices,
    required String wasteTypeId,
  }) {
    for (final price in prices) {
      if (price.loaiRacId == wasteTypeId) {
        return price;
      }
    }

    return null;
  }
}

class _ServicePriceCard extends StatelessWidget {
  const _ServicePriceCard({required this.waste, required this.price});

  final WasteType waste;
  final PriceItem? price;

  @override
  Widget build(BuildContext context) {
    final displayColor = _colorForWaste(waste.nhomRac);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.opacity(displayColor, 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                _iconForWaste(waste.nhomRac),
                color: displayColor,
                size: 25,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    waste.tenLoaiRac,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    waste.nhomRac,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: displayColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    waste.moTa,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          price?.tenDichVu ?? 'Chưa có dịch vụ',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        price == null
                            ? 'Chưa có giá'
                            : '${formatMoney(price!.donGiaKg)}/kg',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.green,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForWaste(String group) {
    final normalizedGroup = group.toLowerCase();

    if (normalizedGroup.contains('hữu cơ')) {
      return Icons.eco_outlined;
    }

    if (normalizedGroup.contains('tái chế')) {
      return Icons.recycling_outlined;
    }

    return Icons.delete_outline;
  }

  Color _colorForWaste(String group) {
    final normalizedGroup = group.toLowerCase();

    if (normalizedGroup.contains('hữu cơ')) {
      return AppColors.green;
    }

    if (normalizedGroup.contains('tái chế')) {
      return AppColors.blue;
    }

    return AppColors.amber;
  }
}
