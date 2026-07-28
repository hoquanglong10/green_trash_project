import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class OfferCountdown extends StatefulWidget {
  const OfferCountdown({
    super.key,
    required this.expiresAt,
    required this.onExpired,
  });

  final DateTime? expiresAt;
  final VoidCallback onExpired;

  @override
  State<OfferCountdown> createState() => _OfferCountdownState();
}

class _OfferCountdownState extends State<OfferCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _didExpire = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant OfferCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expiresAt != widget.expiresAt) {
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urgent = _remaining.inSeconds <= 30;
    final color = urgent ? AppColors.accent : AppColors.secondary;
    final background = urgent
        ? AppColors.accentLight
        : AppColors.secondaryLight;

    return Semantics(
      label: 'Thời gian phản hồi còn lại ${_label(_remaining)}',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _label(_remaining),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _start() {
    _timer?.cancel();
    _didExpire = false;
    _tick();
    if (!_didExpire && widget.expiresAt != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  void _tick() {
    final expiresAt = widget.expiresAt;
    if (expiresAt == null) {
      if (mounted) setState(() => _remaining = Duration.zero);
      return;
    }
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _timer?.cancel();
      if (mounted) setState(() => _remaining = Duration.zero);
      if (!_didExpire) {
        _didExpire = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onExpired();
        });
      }
      return;
    }
    if (mounted) setState(() => _remaining = remaining);
  }

  String _label(Duration value) {
    final seconds = value.inSeconds.clamp(0, 5999);
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
  }
}
