import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class OptionIcon extends StatelessWidget {
  const OptionIcon({super.key, required this.icon, required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Icon(
        icon,
        size: 20,
        color: selected ? AppColors.textInverse : AppColors.primaryDark,
      ),
    );
  }
}
