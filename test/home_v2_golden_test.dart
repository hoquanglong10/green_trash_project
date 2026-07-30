import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/core/theme/app_theme.dart';
import 'package:green_trash_project/features/auth/auth_gate.dart';
import 'package:green_trash_project/features/customer/customer_home_screen.dart';
import 'package:green_trash_project/features/staff/staff_home_screen.dart';
import 'package:green_trash_project/models/app_models.dart';
import 'package:green_trash_project/providers/app_providers.dart';

void main() {
  testWidgets('customer home V3 visual baseline', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const customer = AppUser(
      userId: 'USER_KH_001',
      hoTen: 'Minh Anh',
      email: 'customer@greentrash.vn',
      soDienThoai: '0900000001',
      role: UserRole.customer,
    );
    const session = AppSession(user: customer, role: UserRole.customer);
    const previewKey = Key('customer-home-v2-preview');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentSessionProvider.overrideWith((ref) => session)],
        child: RepaintBoundary(
          key: previewKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              );
            },
            home: const CustomerHomeScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    await expectLater(
      find.byKey(previewKey),
      matchesGoldenFile('goldens/customer_home_v2.png'),
    );
  });

  testWidgets('login V3 visual baseline', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const previewKey = Key('login-v2-preview');

    await tester.pumpWidget(
      ProviderScope(
        child: RepaintBoundary(
          key: previewKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            home: const LoginScreen(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));

    await expectLater(
      find.byKey(previewKey),
      matchesGoldenFile('goldens/login_v2.png'),
    );
  });

  testWidgets('staff home V3 visual baseline', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const staff = AppUser(
      userId: 'USER_NV_001',
      hoTen: 'Trần Duy',
      email: 'staff@greentrash.vn',
      soDienThoai: '0900000002',
      role: UserRole.staff,
    );
    const session = AppSession(user: staff, role: UserRole.staff);
    const previewKey = Key('staff-home-v2-preview');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentSessionProvider.overrideWith((ref) => session)],
        child: RepaintBoundary(
          key: previewKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              );
            },
            home: const StaffHomeScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    await expectLater(
      find.byKey(previewKey),
      matchesGoldenFile('goldens/staff_home_v2.png'),
    );
  });
}
