import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/core/theme/app_theme.dart';
import 'package:green_trash_project/features/customer/customer_home_screen.dart';
import 'package:green_trash_project/features/staff/staff_home_screen.dart';
import 'package:green_trash_project/models/app_models.dart';
import 'package:green_trash_project/providers/app_providers.dart';
import 'package:green_trash_project/shared/widgets/dashboard_shell.dart';

void main() {
  const customer = AppUser(
    userId: 'USER_KH_001',
    hoTen: 'Minh Anh',
    email: 'customer@greentrash.vn',
    soDienThoai: '0900000001',
    role: UserRole.customer,
  );
  const staff = AppUser(
    userId: 'USER_NV_001',
    hoTen: 'Trần Duy',
    email: 'staff@greentrash.vn',
    soDienThoai: '0900000002',
    role: UserRole.staff,
  );

  Future<void> pumpHome(
    WidgetTester tester, {
    required Size size,
    required AppSession session,
    required Widget home,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentSessionProvider.overrideWith((ref) => session)],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: home,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
  }

  for (final size in const [
    Size(320, 800),
    Size(375, 812),
    Size(390, 844),
    Size(430, 932),
    Size(1100, 800),
  ]) {
    testWidgets('customer home V3 fits ${size.width.toInt()}px', (
      tester,
    ) async {
      await pumpHome(
        tester,
        size: size,
        session: const AppSession(user: customer, role: UserRole.customer),
        home: const CustomerHomeScreen(),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(DashboardShell), findsOneWidget);
    });
  }

  for (final size in const [Size(360, 800), Size(1100, 800)]) {
    testWidgets('staff home V3 fits ${size.width.toInt()}px', (tester) async {
      await pumpHome(
        tester,
        size: size,
        session: const AppSession(user: staff, role: UserRole.staff),
        home: const StaffHomeScreen(),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(DashboardShell), findsOneWidget);
      expect(find.text('Hộp đơn mới'), findsNothing);
    });
  }
}
