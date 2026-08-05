import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import '../../shared/widgets/app_widgets.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({
    super.key,
    required this.payment,
    required this.invoice,
  });

  final PaymentRecord payment;
  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Chi tiết hóa đơn',
      subtitle: invoice.hoaDonId,
      maxWidth: 650,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          const HomeBrandHeader(
            title: 'Hóa đơn GreenTrash',
            subtitle: 'Thông tin chi tiết dịch vụ thu gom',
            trailing: Icon(
              Icons.receipt_long_outlined,
              color: AppColors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 54,
                    color: AppColors.green,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Đã thanh toán',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.green,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    formatMoney(invoice.tongTien),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(
            title: 'Thông tin hóa đơn',
            subtitle: 'Chi tiết khối lượng và đơn giá',
          ),
          const SizedBox(height: AppSpacing.sm),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _InvoiceRow(label: 'Mã hóa đơn', value: invoice.hoaDonId),
                  _InvoiceRow(label: 'Mã đơn thu gom', value: invoice.maDon),
                  _InvoiceRow(
                    label: 'Ngày tạo',
                    value: formatDate(invoice.thoiGianTao),
                  ),
                  _InvoiceRow(
                    label: 'Khối lượng thực tế',
                    value: formatKg(invoice.soKgThucTe),
                  ),
                  _InvoiceRow(
                    label: 'Đơn giá',
                    value: '${formatMoney(invoice.donGia)}/kg',
                  ),
                  const Divider(),
                  _InvoiceRow(
                    label: 'Tổng thanh toán',
                    value: formatMoney(invoice.tongTien),
                    highlighted: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          const SectionHeader(title: 'Thông tin thanh toán'),
          const SizedBox(height: AppSpacing.sm),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _InvoiceRow(
                    label: 'Mã thanh toán',
                    value: payment.thanhToanId,
                  ),
                  _InvoiceRow(
                    label: 'Phương thức',
                    value: _paymentMethodLabel(payment.phuongThuc),
                  ),
                  _InvoiceRow(
                    label: 'Mã giao dịch',
                    value: payment.maGiaoDichNgoai ?? 'Không có',
                  ),
                  _InvoiceRow(
                    label: 'Thời gian',
                    value: formatDate(payment.thoiGian),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'TIEN_MAT':
        return 'Tiền mặt';
      case 'BANKING':
      case 'CHUYEN_KHOAN':
        return 'Chuyển khoản ngân hàng';
      case 'VI_DIEN_TU':
        return 'Ví điện tử';
      case 'GOI_THANG':
        return 'Gói thu gom tháng';
      default:
        return method;
    }
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: highlighted ? AppColors.green : AppColors.text,
              fontWeight: highlighted ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
