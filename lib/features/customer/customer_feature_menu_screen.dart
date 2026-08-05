import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';
import '../notifications/presentation/customer_notifications_screen.dart';
import 'package_screen.dart';
import 'payment_history_screen.dart';
import 'profile_screen.dart';
import 'service_price_screen.dart';

class CustomerFeatureMenuScreen extends ConsumerWidget {
  const CustomerFeatureMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppPage(
      title: 'Tiện ích khách hàng',
      maxWidth: 600,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          const HomeBrandHeader(
            title: 'Dịch vụ của bạn',
            subtitle:
                'Xem bảng giá, quản lý gói tháng, hóa đơn và thông tin cá nhân.',
            trailing: Icon(
              Icons.dashboard_customize_outlined,
              size: 40,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          _FeatureMenuItem(
            icon: Icons.recycling_outlined,
            title: 'Loại rác và bảng giá',
            subtitle: 'Xem dịch vụ và đơn giá thu gom theo kg',
            color: AppColors.green,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ServicePriceScreen()),
              );
            },
          ),

          _FeatureMenuItem(
            icon: Icons.workspace_premium_outlined,
            title: 'Gói thu gom tháng',
            subtitle: 'Xem hạn mức, đăng ký hoặc gia hạn gói',
            color: AppColors.amber,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const PackageScreen()),
              );
            },
          ),

          _FeatureMenuItem(
            icon: Icons.receipt_long_outlined,
            title: 'Thanh toán và hóa đơn',
            subtitle: 'Xem lịch sử thanh toán và chi tiết hóa đơn',
            color: AppColors.blue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PaymentHistoryScreen(),
                ),
              );
            },
          ),

          _FeatureMenuItem(
            icon: Icons.person_outline,
            title: 'Hồ sơ cá nhân',
            subtitle: 'Xem và cập nhật thông tin tài khoản',
            color: AppColors.purple,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          _FeatureMenuItem(
            icon: Icons.notifications_none_outlined,
            title: 'Danh sách thông báo',
            subtitle: 'Xem các cập nhật mới từ GreenTrash',
            color: AppColors.amber,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CustomerNotificationsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(firebaseAuthenticationServiceProvider).signOut();
              ref.read(currentSessionProvider.notifier).state = null;
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

class _FeatureMenuItem extends StatelessWidget {
  const _FeatureMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.opacity(color, 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          title: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
