import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/order_history_sort.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/history_order_card.dart';
import '../../customer/order_detail_screen.dart';
import '../../staff/staff_order_screen.dart';

enum OrderHistoryAudience { customer, staff }

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key, required this.audience});

  final OrderHistoryAudience audience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStaff = audience == OrderHistoryAudience.staff;
    final orders = isStaff
        ? ref.watch(staffOrderHistoryProvider)
        : ref.watch(customerOrdersProvider);
    final addresses = ref.watch(allAddressesProvider);
    final wastes = ref.watch(wasteTypesProvider);

    return AppPage(
      title: isStaff ? 'Lịch sử công việc' : 'Lịch sử đơn',
      subtitle: isStaff
          ? 'Các đơn đã hoàn tất hoặc đã hủy'
          : 'Toàn bộ đơn thu gom của bạn',
      maxWidth: 900,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 720
              ? AppSpacing.xl
              : AppSpacing.screenHorizontal;
          final list = ListView.separated(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppSpacing.md,
              horizontalPadding,
              AppSpacing.xxl,
            ),
            itemCount: orders.isEmpty ? 2 : orders.length + 1,
            separatorBuilder: (_, index) =>
                SizedBox(height: index == 0 ? AppSpacing.md : AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index == 0) {
                return SectionHeader(
                  title: isStaff ? 'Đơn đã xử lý' : 'Tất cả đơn',
                  subtitle: isStaff
                      ? 'Mới nhất theo thời điểm hoàn tất hoặc hủy'
                      : '${orders.length} đơn đã đặt',
                  trailing: _OrderCount(value: orders.length),
                );
              }
              if (orders.isEmpty) {
                return EmptyState(
                  icon: Icons.history_outlined,
                  title: isStaff ? 'Chưa có lịch sử công việc' : 'Chưa có đơn',
                  message: isStaff
                      ? 'Các đơn hoàn tất hoặc đã hủy sẽ hiện tại đây.'
                      : 'Các đơn bạn đã đặt sẽ hiện tại đây.',
                );
              }
              final order = orders[index - 1];
              return HistoryOrderCard(
                order: order,
                address: _findAddress(addresses, order.diaChiId),
                wasteType: _findWaste(wastes, order.loaiRacId),
                eventTime: isStaff
                    ? historyOrderTimestamp(order)
                    : order.ngayTao,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => isStaff
                          ? StaffOrderScreen(maDon: order.maDon)
                          : OrderDetailScreen(maDon: order.maDon),
                    ),
                  );
                },
              );
            },
          );
          return kIsWeb ? Scrollbar(child: list) : list;
        },
      ),
    );
  }
}

class _OrderCount extends StatelessWidget {
  const _OrderCount({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          '$value đơn',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
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
