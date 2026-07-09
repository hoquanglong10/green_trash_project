import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/status_mapper.dart';
import '../../models/app_models.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.compact = false,
    this.dark = false,
    this.stacked = false,
    this.logoSize,
  });

  final bool compact;
  final bool dark;
  final bool stacked;
  final double? logoSize;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? AppColors.textInverse : AppColors.primary;
    final supporting = dark
        ? AppColors.opacity(AppColors.white, 0.72)
        : AppColors.muted;
    final markSize = logoSize ?? (compact ? 34.0 : 44.0);

    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LogoMark(size: markSize, dark: dark),
          const SizedBox(height: AppSpacing.md),
          Text(
            'GreenTrash',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Thu gom thông minh',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: supporting,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoMark(size: markSize, dark: dark),
        SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GreenTrash',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            if (!compact)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  'Thu gom thông minh',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: supporting,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 40, this.dark = false});

  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        AppAssets.logoMark,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: dark ? AppColors.textInverse : AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.recycling,
              color: dark ? AppColors.primary : AppColors.textInverse,
              size: size * 0.54,
            ),
          );
        },
      ),
    );
  }
}

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.white = false,
    this.width = 186,
    this.height = 46,
  });

  final bool white;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (white) {
      final markSize = height * 0.9;
      return SizedBox(
        width: width,
        height: height,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.logoMark,
                width: markSize,
                height: markSize,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                color: AppColors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'GreenTrash',
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontSize: height * 0.5,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        AppAssets.logo,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class AppTextInput extends StatelessWidget {
  const AppTextInput({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.minLines,
    this.maxLines = 1,
    this.suffixText,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: AppColors.text),
        ),
        const SizedBox(height: AppSpacing.labelInputGap),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            minLines: minLines,
            maxLines: obscureText ? 1 : maxLines,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: hint,
              suffixText: suffixText,
              prefixIcon: icon == null
                  ? null
                  : Icon(icon, size: 18, color: AppColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: icon == null
          ? FilledButton(onPressed: onPressed, child: Text(label))
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(label),
            ),
    );
  }
}

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.socialButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DividerLabel extends StatelessWidget {
  const DividerLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.hint,
    this.onTap,
    this.trailing,
  });

  final String hint;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                hint,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(width: 1, height: 24, color: AppColors.border),
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class HomeBrandHeader extends StatelessWidget {
  const HomeBrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.promoCardRadius),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.primary),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: 72,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.opacity(AppColors.slate, 0.18),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.accent),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.textInverse,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.opacity(AppColors.white, 0.86),
                              ),
                        ),
                        if (actionLabel != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            height: 32,
                            child: FilledButton(
                              onPressed: onAction,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.textInverse,
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: Text(actionLabel!),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    trailing!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.bottomNavigationBar,
    this.maxWidth = 430,
    this.leading,
    this.titleWidget,
    this.appBarHeight,
    this.appBarBackgroundColor,
    this.appBarTitleColor,
    this.appBarSubtitleColor,
    this.scaffoldBackgroundColor,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final Widget? bottomNavigationBar;
  final double maxWidth;
  final Widget? leading;
  final Widget? titleWidget;
  final double? appBarHeight;
  final Color? appBarBackgroundColor;
  final Color? appBarTitleColor;
  final Color? appBarSubtitleColor;
  final Color? scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        leading: leading,
        backgroundColor: appBarBackgroundColor,
        toolbarHeight: appBarHeight,
        title:
            titleWidget ??
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ).copyWith(color: appBarTitleColor ?? AppColors.textInverse),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ).copyWith(
                          color:
                              appBarSubtitleColor ?? AppColors.textInverseMuted,
                        ),
                  ),
              ],
            ),
        actions: actions,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ],
          ),
        ),
        ?trailingWidget,
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.compact = false});

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = orderStatusStyle(status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : AppSpacing.md,
          vertical: compact ? AppSpacing.xs : AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.icon, size: compact ? 13 : 15, color: style.foreground),
            const SizedBox(width: AppSpacing.xs),
            Text(
              style.label,
              style: TextStyle(
                color: style.foreground,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 10 : 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 3,
              child: ColoredBox(color: color),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.opacity(color, 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(icon, color: color, size: 19),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
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

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.address,
    required this.wasteType,
    required this.onTap,
    this.staffName,
  });

  final PickupOrder order;
  final CustomerAddress? address;
  final WasteType? wasteType;
  final String? staffName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.recycling,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.maDon,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${formatDayMonth(order.ngayThuGom)} • ${order.khungGio}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: order.trangThai, compact: true),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoRow(
                icon: Icons.delete_outline,
                text:
                    '${wasteType?.tenLoaiRac ?? order.loaiRacId} • ${formatKg(order.khoiLuongDuKien)}',
              ),
              const SizedBox(height: AppSpacing.sm),
              _InfoRow(
                icon: Icons.place_outlined,
                text: address?.shortAddress ?? order.diaChiId,
              ),
              if (staffName != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(icon: Icons.badge_outlined, text: staffName!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final currentIndex = orderStatusIndex(status);
    return Column(
      children: [
        for (var index = 0; index < orderTimeline.length; index++)
          _TimelineRow(
            status: orderTimeline[index],
            done: status == 'HUY' ? false : index <= currentIndex,
            last: index == orderTimeline.length - 1,
          ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(icon, size: 28, color: AppColors.primaryDark),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.primaryDark),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.status,
    required this.done,
    required this.last,
  });

  final String status;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final style = orderStatusStyle(status);
    final color = done ? style.foreground : AppColors.textMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? style.background : AppColors.surfaceAlt,
              ),
              child: Icon(style.icon, size: 15, color: color),
            ),
            if (!last)
              Container(
                width: 2,
                height: 22,
                color: done ? AppColors.opacity(color, 0.36) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              style.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: done ? AppColors.text : AppColors.muted,
                fontWeight: done ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
