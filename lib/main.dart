import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';

void main() {
  runApp(const ProviderScope(child: GreenTrashApp()));
}

class GreenTrashApp extends StatelessWidget {
  const GreenTrashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenTrash',
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: GreenTrashApp());
  }
}
