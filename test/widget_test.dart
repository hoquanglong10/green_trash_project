import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/main.dart';
import 'package:green_trash_project/schema_contract.dart';

void main() {
  test('schema contract contains DON_THU_GOM', () {
    final schema = greenTrashSchemaByName[donThuGomCollection];

    expect(schema, isNotNull);
    expect(schema!.documentIdField, 'maDon');
    expect(schema.fieldNames, contains('khachHangId'));
    expect(schema.fieldNames, contains('nhanVienHienTaiId'));
    expect(schema.fieldNames, contains('trangThai'));
  });

  testWidgets('app starts on login screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('GreenTrash'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
