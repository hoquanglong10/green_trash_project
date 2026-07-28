import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/schema_contract.dart';

void main() {
  test('Firestore JSON collection fields mirror the Dart contract', () {
    final json =
        jsonDecode(File('docs/firestore_schema.json').readAsStringSync())
            as Map<String, dynamic>;
    final jsonCollections = json['collections'] as List<dynamic>;
    final jsonByName = <String, Map<String, dynamic>>{
      for (final item in jsonCollections.cast<Map<String, dynamic>>())
        item['name'] as String: item,
    };

    expect(jsonByName.keys.toSet(), greenTrashSchemaByName.keys.toSet());
    for (final schema in greenTrashSchemas) {
      final jsonSchema = jsonByName[schema.name]!;
      expect(
        jsonSchema['documentIdField'],
        schema.documentIdField,
        reason: '${schema.name} has a different document ID field.',
      );
      final jsonFields = (jsonSchema['fields'] as Map<String, dynamic>).keys
          .toSet();
      expect(
        jsonFields,
        schema.fieldNames,
        reason: '${schema.name} fields differ between JSON and Dart.',
      );
    }
  });
}
