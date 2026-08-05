import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/app_widgets.dart';
import 'invoice_detail_screen.dart';
import 'secondary/application/customer_secondary_providers.dart';
import 'secondary/domain/customer_billing_models.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingState = ref.watch(customerBillingProvider);
    final payments = ref.watch(customerPaymentsProvider);
    final invoices = ref.watch(customerInvoicesProvider);

    return AppPage(
      title: 'Thanh toán và hóa đơn',
      subtitle: 'Lịch sử giao dịch',
      maxWidth: 700,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          const HomeBrandHeader(
            title: 'Lịch sử thanh toán',
            subtitle: 'Theo dõi giao dịch và xem chi tiết hóa đơn thu gom.',
            trailing: Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          if (billingState.isLoading) ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.md),
                      Text('Đang tải lịch sử thanh toán...'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
          ],

          if (billingState.errorMessage != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.amber),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(billingState.errorMessage!)),
                    TextButton(
                      onPressed: () {
                        ref.read(customerBillingProvider.notifier).reload();
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
          ],
          SectionHeader(
            title: 'Các giao dịch',
            subtitle: '${payments.length} giao dịch',
          ),
          const SizedBox(height: AppSpacing.sm),

          if (payments.isEmpty)
            const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Chưa có giao dịch',
              message: 'Các giao dịch thanh toán sẽ xuất hiện tại đây.',
            )
          else
            ...payments.map((payment) {
              final invoice = _findInvoice(invoices, payment.thanhToanId);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _PaymentCard(
                  payment: payment,
                  invoice: invoice,
                  onTap: invoice == null
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => InvoiceDetailScreen(
                                payment: payment,
                                invoice: invoice,
                              ),
                            ),
                          );
                        },
                ),
              );
            }),
        ],
      ),
    );
  }

  CustomerInvoice? _findInvoice(
    List<CustomerInvoice> invoices,
    String paymentId,
  ) {
    for (final invoice in invoices) {
      if (invoice.thanhToanId == paymentId) {
        return invoice;
      }
    }

    return null;
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.invoice,
    required this.onTap,
  });

  final CustomerPayment payment;
  final CustomerInvoice? invoice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(payment.trangThai);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.opacity(statusColor, 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      _statusIcon(payment.trangThai),
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.thanhToanId,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Đơn ${payment.maDon}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatMoney(payment.soTien),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.green,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 17,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    formatDate(payment.thoiGian),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.opacity(statusColor, 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      _statusLabel(payment.trangThai),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Icon(
                    invoice == null
                        ? Icons.hourglass_empty
                        : Icons.receipt_long_outlined,
                    size: 18,
                    color: invoice == null ? AppColors.amber : AppColors.blue,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      invoice == null
                          ? 'Chưa có hóa đơn'
                          : 'Nhấn để xem hóa đơn ${invoice!.hoaDonId}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: invoice == null
                            ? AppColors.amber
                            : AppColors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (invoice != null)
                    const Icon(Icons.chevron_right, color: AppColors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'DA_THANH_TOAN':
      case 'DA_TT':
        return 'Đã thanh toán';
      case 'CHO_THANH_TOAN':
        return 'Chờ thanh toán';
      case 'THAT_BAI':
        return 'Thất bại';
      case 'HOAN_TIEN':
        return 'Đã hoàn tiền';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'DA_THANH_TOAN':
      case 'DA_TT':
        return AppColors.green;
      case 'CHO_THANH_TOAN':
        return AppColors.amber;
      case 'HOAN_TIEN':
        return AppColors.purple;
      default:
        return AppColors.slate;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'DA_THANH_TOAN':
      case 'DA_TT':
        return Icons.check_circle_outline;
      case 'CHO_THANH_TOAN':
        return Icons.schedule;
      case 'HOAN_TIEN':
        return Icons.replay;
      default:
        return Icons.error_outline;
    }
  }
}
