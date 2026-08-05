import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_widgets.dart';

class PackageScreen extends ConsumerWidget {
  const PackageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final packages = ref.watch(packagesProvider);
    final subscription = ref.watch(currentSubscriptionProvider);

    final currentPackage = _findPackage(
      packages: packages,
      packageId: subscription?.goiId,
    );

    return AppPage(
      title: 'Gói thu gom tháng',
      subtitle: 'Đăng ký và quản lý hạn mức',
      maxWidth: 700,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          const HomeBrandHeader(
            title: 'Gói thu gom GreenTrash',
            subtitle:
                'Tiết kiệm chi phí và theo dõi khối lượng rác sử dụng mỗi tháng.',
            trailing: Icon(
              Icons.workspace_premium_outlined,
              color: AppColors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          SectionHeader(
            title: 'Gói đang sử dụng',
            subtitle: subscription == null
                ? 'Bạn chưa đăng ký gói thu gom tháng'
                : 'Thông tin hạn mức hiện tại',
          ),
          const SizedBox(height: AppSpacing.sm),

          if (subscription == null || currentPackage == null)
            const _NoCurrentPackageCard()
          else
            _CurrentPackageCard(
              package: currentPackage,
              subscription: subscription,
            ),

          const SizedBox(height: AppSpacing.sectionGap),

          SectionHeader(
            title: 'Danh sách gói',
            subtitle: '${packages.length} gói đang được cung cấp',
          ),
          const SizedBox(height: AppSpacing.sm),

          if (packages.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: Text('Hiện chưa có gói thu gom')),
              ),
            )
          else
            ...packages.map((package) {
              final isCurrentPackage = subscription?.goiId == package.goiId;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _PackageCard(
                  package: package,
                  isCurrentPackage: isCurrentPackage,
                  onPressed: user == null
                      ? null
                      : () {
                          _confirmPackage(
                            context: context,
                            ref: ref,
                            khachHangId: user.userId,
                            package: package,
                            isRenew: isCurrentPackage,
                          );
                        },
                ),
              );
            }),
        ],
      ),
    );
  }

  PickupPackage? _findPackage({
    required List<PickupPackage> packages,
    required String? packageId,
  }) {
    if (packageId == null) return null;

    for (final package in packages) {
      if (package.goiId == packageId) {
        return package;
      }
    }

    return null;
  }

  Future<void> _confirmPackage({
    required BuildContext context,
    required WidgetRef ref,
    required String khachHangId,
    required PickupPackage package,
    required bool isRenew,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isRenew ? 'Xác nhận gia hạn' : 'Xác nhận đăng ký'),
          content: Text(
            isRenew
                ? 'Bạn có muốn gia hạn ${package.tenGoi} với giá '
                      '${formatMoney(package.giaGoi)} không?'
                : 'Bạn có muốn đăng ký ${package.tenGoi} với giá '
                      '${formatMoney(package.giaGoi)} không?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(isRenew ? 'Gia hạn' : 'Đăng ký'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(subscriptionsProvider.notifier)
          .subscribeOrRenew(khachHangId: khachHangId, package: package);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRenew
                ? 'Đã gia hạn và lưu gói vào Firestore'
                : 'Đã đăng ký và lưu gói vào Firestore',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể lưu gói tháng: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _NoCurrentPackageCard extends StatelessWidget {
  const _NoCurrentPackageCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.amber,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Chưa có gói tháng',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Chọn một gói bên dưới để bắt đầu sử dụng.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentPackageCard extends StatelessWidget {
  const _CurrentPackageCard({
    required this.package,
    required this.subscription,
  });

  final PickupPackage package;
  final PackageSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final limit = package.hanMucKgThang.toDouble();

    final progress = limit <= 0
        ? 0.0
        : (subscription.soKgDaDung / limit).clamp(0.0, 1.0).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.card_membership_outlined,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.tenGoi,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tháng ${subscription.thangNam}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text(
                    'Còn hiệu lực',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              backgroundColor: AppColors.primaryLight,
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _UsageItem(
                    label: 'Đã dùng',
                    value: formatKg(subscription.soKgDaDung),
                    color: AppColors.amber,
                  ),
                ),
                Expanded(
                  child: _UsageItem(
                    label: 'Còn lại',
                    value: formatKg(subscription.soKgConLai),
                    color: AppColors.green,
                  ),
                ),
                Expanded(
                  child: _UsageItem(
                    label: 'Hạn mức',
                    value: formatKg(package.hanMucKgThang),
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageItem extends StatelessWidget {
  const _UsageItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.isCurrentPackage,
    required this.onPressed,
  });

  final PickupPackage package;
  final bool isCurrentPackage;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  color: AppColors.amber,
                  size: 30,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.tenGoi,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        package.moTa,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _PackageInfoLine(
              icon: Icons.scale_outlined,
              label: 'Hạn mức',
              value: formatKg(package.hanMucKgThang),
            ),
            const SizedBox(height: AppSpacing.sm),

            _PackageInfoLine(
              icon: Icons.payments_outlined,
              label: 'Giá gói',
              value: formatMoney(package.giaGoi),
            ),
            const SizedBox(height: AppSpacing.sm),

            _PackageInfoLine(
              icon: Icons.add_chart_outlined,
              label: 'Phí vượt gói',
              value: '${formatMoney(package.phiVuotGoi)}/kg',
            ),
            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(
                  isCurrentPackage
                      ? Icons.autorenew
                      : Icons.check_circle_outline,
                ),
                label: Text(isCurrentPackage ? 'Gia hạn gói' : 'Đăng ký gói'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageInfoLine extends StatelessWidget {
  const _PackageInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
