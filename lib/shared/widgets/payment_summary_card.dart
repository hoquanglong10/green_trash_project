import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/status_mapper.dart';
import '../../models/app_models.dart';

class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({
    super.key,
    required this.payment,
    this.onConfirmPaid,
  });

  final PaymentRecord payment;
  final VoidCallback? onConfirmPaid;

  @override
  Widget build(BuildContext context) {
    final paid = payment.trangThai == 'DA_THANH_TOAN';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  paid
                      ? Icons.task_alt_rounded
                      : Icons.account_balance_wallet_rounded,
                  color: paid ? AppColors.success : AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thanh toán',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        paymentStatusLabel(payment.trangThai),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: paid
                              ? AppColors.primary
                              : AppColors.accentForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatMoney(payment.soTien),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _methodLabel(payment.phuongThuc),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            if (!paid && onConfirmPaid != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onConfirmPaid,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Xác nhận đã thanh toán'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _methodLabel(String method) {
    return switch (method) {
      'GOI_THANG' => 'Khấu trừ gói tháng',
      'TIEN_MAT' => 'Tiền mặt',
      'CHUYEN_KHOAN' => 'Chuyển khoản',
      _ => method,
    };
  }
}
