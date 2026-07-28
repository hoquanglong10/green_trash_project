import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/core/theme/app_theme.dart';
import 'package:green_trash_project/features/staff/staff_order_screen.dart';
import 'package:green_trash_project/models/app_models.dart';
import 'package:green_trash_project/providers/app_providers.dart';

void main() {
  const staff = AppUser(
    userId: 'USER_NV_001',
    hoTen: 'Trần Duy',
    email: 'staff@greentrash.vn',
    soDienThoai: '0900000002',
    role: UserRole.staff,
  );
  const session = AppSession(user: staff, role: UserRole.staff);

  Future<void> pumpStaffOrder(WidgetTester tester) async {
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
          home: const StaffOrderScreen(maDon: 'DON_002'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('staff detail content is not covered by its bottom action bar', (
    tester,
  ) async {
    await pumpStaffOrder(tester);

    final header = find.text('Đơn đang chờ nhận');
    final accept = find.text('Nhận và chốt giờ');
    expect(header, findsOneWidget);
    expect(accept, findsOneWidget);
    expect(header.hitTestable(), findsOneWidget);
    expect(tester.getCenter(header).dy, lessThan(tester.getCenter(accept).dy));
  });

  testWidgets('staff can complete the entire mocked pickup flow', (
    tester,
  ) async {
    await pumpStaffOrder(tester);

    await tester.tap(find.text('Nhận và chốt giờ'));
    await tester.pumpAndSettle();
    expect(find.text('Chốt giờ dự kiến đến'), findsOneWidget);

    await tester.tap(find.textContaining('Nhận đơn lúc'));
    await tester.pumpAndSettle();
    expect(find.text('Bắt đầu di chuyển'), findsOneWidget);

    await tester.tap(find.text('Bắt đầu di chuyển'));
    await tester.pumpAndSettle();
    expect(find.text('Xác nhận đã đến'), findsOneWidget);

    await tester.tap(find.text('Xác nhận đã đến'));
    await tester.pumpAndSettle();
    expect(find.text('Bắt đầu cân rác'), findsOneWidget);

    await tester.tap(find.text('Bắt đầu cân rác'));
    await tester.pumpAndSettle();
    expect(find.text('Lập biên bản'), findsOneWidget);

    await tester.tap(find.text('Lập biên bản'));
    await tester.pumpAndSettle();
    expect(find.text('Biên bản thu gom'), findsOneWidget);
    await tester.tap(find.text('Thêm ảnh demo'));
    await tester.pump();
    await tester.tap(find.text('Xác nhận hoàn thành'));
    await tester.pumpAndSettle();

    expect(find.text('Thu gom thành công'), findsWidgets);
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Biên bản đã lưu'), findsOneWidget);
    expect(find.text('Nhận và chốt giờ'), findsNothing);
  });
}
