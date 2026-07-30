import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class OptionIcon extends StatelessWidget {
  const OptionIcon({super.key, required this.icon, required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: selected ? AppColors.green100 : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(
        icon,
        size: 19,
        color: selected ? AppColors.primary : AppColors.textMuted,
      ),
    );
  }
}
