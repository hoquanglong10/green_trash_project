import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../location/presentation/widgets/live_location_map.dart';
import '../../orders/application/order_workflow_providers.dart';
import '../../orders/domain/order_workflow_models.dart';
import '../../../models/app_models.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/activity_log_card.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/collection_record_card.dart';
import '../../../shared/widgets/payment_summary_card.dart';
import 'order_detail_lookup.dart';
import 'widgets/detail_actions_card.dart';
import 'widgets/detail_info_card.dart';
import 'widgets/tracking_hero.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.maDon});

  final String maDon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = findOrder(
      ref.watch(firebaseEnabledProvider)
          ? ref.watch(customerOrdersProvider)
          : ref.watch(orderControllerProvider),
      maDon,
    );
    final session = ref.watch(currentSessionProvider);

    if (order == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy đơn thu gom.')),
      );
    }

    final selectedOrder = order;
    final addresses = ref.watch(allAddressesProvider);
    final wastes = ref.watch(wasteTypesProvider);
    final staff = ref.watch(staffProfilesProvider);
    final logs = [...ref.watch(orderActivityLogsProvider(selectedOrder.maDon))]
      ..sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
    final address = findAddress(addresses, selectedOrder.diaChiId);
    final waste = findWaste(wastes, selectedOrder.loaiRacId);
    final staffProfile = findStaff(
      staff,
      selectedOrder.nhanVienHienTaiId ?? selectedOrder.nhanVienDeXuatId,
    );
    final record = ref.watch(collectionRecordProvider(selectedOrder.maDon));
    final payment = ref.watch(paymentRecordProvider(selectedOrder.maDon));
    final actualWaste = record == null
        ? null
        : findWaste(wastes, record.loaiRacThucTeId);

    return AppPage(
      maxWidth: 760,
      title: selectedOrder.maDon,
      subtitle: 'Chi tiết đơn thu gom',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.md,
          AppSpacing.screenHorizontal,
          AppSpacing.xxl,
        ),
        children: [
          TrackingHero(order: selectedOrder, staff: staffProfile),
          if (selectedOrder.trangThai == 'CHO_XU_LY' ||
              selectedOrder.trangThai == 'CHO_NHAN') ...[
            const SizedBox(height: AppSpacing.md),
            StaffMatchingCard(staff: staffProfile),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          DetailInfoCard(
            order: selectedOrder,
            address: address,
            waste: waste,
            staff: staffProfile,
          ),
          if (address != null &&
              {
                'DANG_DEN',
                'DA_DEN',
                'DANG_CAN_RAC',
              }.contains(selectedOrder.trangThai)) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(
              title: 'Theo dõi nhân viên',
              subtitle:
                  'Vị trí sẽ tự cập nhật khi nhân viên đang thực hiện đơn',
            ),
            const SizedBox(height: AppSpacing.sm),
            LiveLocationMap(destination: address, staff: staffProfile),
          ],
          if (record != null) ...[
            const SizedBox(height: AppSpacing.md),
            CollectionRecordCard(record: record, waste: actualWaste),
          ],
          if (payment != null) ...[
            const SizedBox(height: AppSpacing.md),
            PaymentSummaryCard(
              payment: payment,
              onConfirmPaid:
                  session?.role == UserRole.customer &&
                      payment.trangThai != 'DA_THANH_TOAN'
                  ? () async {
                      if (ref.read(firebaseEnabledProvider)) {
                        try {
                          await ref
                              .read(orderWorkflowRepositoryProvider)
                              .confirmPayment(
                                ConfirmPaymentCommand(
                                  maDon: selectedOrder.maDon,
                                  thanhToanId: payment.thanhToanId,
                                  khachHangId: session!.user.userId,
                                  phuongThuc: payment.phuongThuc,
                                ),
                              );
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Khong the xac nhan thanh toan.'),
                              ),
                            );
                          }
                        }
                        return;
                      }
                      ref
                          .read(paymentRecordControllerProvider.notifier)
                          .markPaid(selectedOrder.maDon);
                      ref
                          .read(collectionRecordControllerProvider.notifier)
                          .markPaid(selectedOrder.maDon);
                      ref
                          .read(orderControllerProvider.notifier)
                          .confirmPayment(
                            maDon: selectedOrder.maDon,
                            customerId: session!.user.userId,
                          );
                    }
                  : null,
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(
            title: 'Tiến trình',
            subtitle: 'Trạng thái xử lý theo thời gian thực',
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: OrderTimeline(status: selectedOrder.trangThai),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(
            title: 'Hoạt động gần đây',
            subtitle: 'Các mốc cập nhật của đơn',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (logs.isEmpty)
            const EmptyState(
              icon: Icons.history,
              title: 'Chưa có hoạt động mới',
              message: 'Khi nhân viên cập nhật, lịch sử sẽ hiển thị tại đây.',
            )
          else
            ...logs.map(
              (log) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ActivityLogCard(log: log),
              ),
            ),
          if (session?.role == UserRole.customer &&
              selectedOrder.trangThai != 'HOAN_THANH' &&
              selectedOrder.trangThai != 'HUY') ...[
            const SizedBox(height: AppSpacing.sectionGap),
            DetailActionsCard(order: selectedOrder),
          ],
        ],
      ),
    );
  }
}
