import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/features/customer/address_book/application/reverse_geocoding_provider.dart';
import 'package:green_trash_project/features/customer/address_book/data/reverse_geocoding_service.dart';
import 'package:green_trash_project/core/theme/app_theme.dart';
import 'package:green_trash_project/features/customer/address_book/presentation/address_book_screen.dart';
import 'package:green_trash_project/models/app_models.dart';
import 'package:green_trash_project/providers/app_providers.dart';
import 'package:green_trash_project/providers/mock_event_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const customer = AppUser(
    userId: 'CUSTOMER_NEW',
    hoTen: 'Khách hàng mới',
    email: 'new@greentrash.vn',
    soDienThoai: '0900000000',
    role: UserRole.customer,
  );
  const session = AppSession(user: customer, role: UserRole.customer);

  group('CustomerAddressController', () {
    test('keeps exactly one default address', () {
      final controller = CustomerAddressController(const []);
      final firstId = controller.save(
        customerId: customer.userId,
        detail: '12 Nguyễn Văn Bảo',
        ward: 'Phường 4',
        district: 'Gò Vấp',
        city: 'TP. Hồ Chí Minh',
        latitude: 10.82,
        longitude: 106.68,
        isDefault: false,
      );
      final secondId = controller.save(
        customerId: customer.userId,
        detail: '30 Phan Văn Trị',
        ward: 'Phường 7',
        district: 'Gò Vấp',
        city: 'TP. Hồ Chí Minh',
        latitude: 0,
        longitude: 0,
        isDefault: false,
      );

      expect(
        controller.state
            .singleWhere((item) => item.diaChiId == firstId)
            .macDinh,
        isTrue,
      );
      controller.setDefault(customerId: customer.userId, addressId: secondId);
      expect(controller.state.where((item) => item.macDinh), hasLength(1));
      expect(
        controller.state.singleWhere((item) => item.macDinh).diaChiId,
        secondId,
      );

      controller.delete(customerId: customer.userId, addressId: secondId);
      expect(controller.state.single.macDinh, isTrue);
      expect(controller.state.single.diaChiId, firstId);
    });
  });

  testWidgets('new customer can add the first default address', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final reverseService = ReverseGeocodingService(
      minimumInterval: Duration.zero,
      client: MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'features': [
                {
                  'properties': {
                    'geocoding': {
                      'label':
                          '99 Quang Trung, Phường 10, '
                          'Thành phố Hồ Chí Minh, Việt Nam',
                      'housenumber': '99',
                      'street': 'Quang Trung',
                      'district': 'Phường 10',
                      'city': 'Thành phố Hồ Chí Minh',
                    },
                  },
                },
              ],
            }),
          ),
          200,
        ),
      ),
    );
    addTearDown(reverseService.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseEnabledProvider.overrideWith((ref) => false),
          currentSessionProvider.overrideWith((ref) => session),
          customerAddressControllerProvider.overrideWith(
            (ref) => CustomerAddressController(const []),
          ),
          reverseGeocodingServiceProvider.overrideWithValue(reverseService),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const AddressBookScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa có địa chỉ'), findsOneWidget);
    await tester.tap(find.text('Thêm địa chỉ đầu tiên'));
    await tester.pumpAndSettle();

    expect(find.byType(FlutterMap), findsOneWidget);
    final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
    map.options.onTap!(
      const TapPosition(Offset.zero, Offset.zero),
      const LatLng(10.814808, 106.632410),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField, skipOffstage: false);
    expect(fields, findsNWidgets(4));
    final detailField = tester.widget<TextField>(fields.first);
    expect(detailField.controller?.text, '99 Quang Trung');
    final scrollable = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pumpAndSettle();
    final saveButton = find.text('Lưu địa chỉ', skipOffstage: false);
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('99 Quang Trung'), findsOneWidget);
    expect(find.text('Mặc định'), findsOneWidget);
  });
}
