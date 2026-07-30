import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

var _callbackSequence = 0;

Future<http.Response> performReverseGeocodingRequest({
  required http.Client client,
  required Uri uri,
  required Map<String, String> headers,
}) {
  final completer = Completer<http.Response>();
  final callbackName =
      '_greenTrashReverse_${DateTime.now().microsecondsSinceEpoch}_${_callbackSequence++}';
  final script = web.HTMLScriptElement();
  late final Timer timer;
  var cleanedUp = false;

  void cleanUp() {
    if (cleanedUp) return;
    cleanedUp = true;
    timer.cancel();
    script.remove();
    web.window.delete(callbackName.toJS);
  }

  void completeError(String message) {
    if (!completer.isCompleted) {
      completer.completeError(http.ClientException(message, uri));
    }
    cleanUp();
  }

  final callback = ((JSAny? payload) {
    try {
      final dartPayload = payload?.dartify();
      if (dartPayload is! Map) {
        completeError('Dịch vụ bản đồ trả về dữ liệu không hợp lệ.');
        return;
      }
      if (!completer.isCompleted) {
        completer.complete(
          http.Response(
            jsonEncode(dartPayload),
            200,
            headers: const {'content-type': 'application/json; charset=utf-8'},
          ),
        );
      }
      cleanUp();
    } catch (_) {
      completeError('Không thể đọc dữ liệu từ dịch vụ bản đồ.');
    }
  }).toJS;

  timer = Timer(
    const Duration(seconds: 12),
    () => completeError('Tra cứu địa chỉ mất quá nhiều thời gian.'),
  );
  web.window.setProperty(callbackName.toJS, callback);
  script
    ..src = uri
        .replace(
          queryParameters: {
            ...uri.queryParameters,
            'json_callback': callbackName,
          },
        )
        .toString()
    ..async = true
    ..onerror = ((web.Event _) {
      completeError('Không thể tải dữ liệu từ dịch vụ bản đồ.');
    }).toJS;

  final head = web.document.head;
  if (head == null) {
    completeError('Trang web chưa sẵn sàng để tra cứu địa chỉ.');
  } else {
    head.append(script);
  }
  return completer.future;
}
