import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/core/theme/app_theme.dart';
import 'package:green_trash_project/features/customer/booking_screen.dart';
import 'package:green_trash_project/features/customer/customer_home_screen.dart';
import 'package:green_trash_project/features/customer/order_detail_screen.dart';
import 'package:green_trash_project/models/app_models.dart';
import 'package:green_trash_project/providers/app_providers.dart';
import 'package:green_trash_project/shared/widgets/app_widgets.dart';

void main() {
  const customer = AppUser(
    userId: 'USER_KH_001',
    hoTen: 'Minh Anh',
    email: 'customer@greentrash.vn',
    soDienThoai: '0900000001',
    role: UserRole.customer,
  );
  const session = AppSession(user: customer, role: UserRole.customer);

  Future<void> pumpCustomerScreen(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(497, 921);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentSessionProvider.overrideWith((ref) => session)],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('customer home renders on mobile', (tester) async {
    await pumpCustomerScreen(tester, const CustomerHomeScreen());

    expect(tester.takeException(), isNull);
    expect(find.byType(BrandWordmark), findsOneWidget);
  });

  testWidgets('booking screen renders on mobile', (tester) async {
    await pumpCustomerScreen(tester, const BookingScreen());

    expect(tester.takeException(), isNull);
    expect(
      find.text('Lập đơn thu gom mới', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Địa chỉ lấy rác', skipOffstage: false), findsOneWidget);
  });

  testWidgets('order detail renders on mobile', (tester) async {
    await pumpCustomerScreen(tester, const OrderDetailScreen(maDon: 'DON_002'));

    expect(tester.takeException(), isNull);
    expect(find.text('Chi tiết đơn thu gom'), findsOneWidget);
    expect(
      find.text('Đang tìm nhân viên', skipOffstage: false),
      findsOneWidget,
    );
  });
}
