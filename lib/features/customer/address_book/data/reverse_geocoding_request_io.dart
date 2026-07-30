import 'package:http/http.dart' as http;

Future<http.Response> performReverseGeocodingRequest({
  required http.Client client,
  required Uri uri,
  required Map<String, String> headers,
}) {
  return client.get(uri, headers: headers);
}
