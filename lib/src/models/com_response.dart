import 'dart:convert';
import 'dart:typed_data';
import 'package:api_com/api_com.dart';
import 'package:api_com/src/core/com.dart';
import 'package:api_com/src/utils/tracked_map.dart';
import 'package:http/http.dart' as http;
import 'package:palestine_console/palestine_console.dart';

class ComResponse<Model> {
  ComResponse({
    required this.status,
    required this.request,
    this.response,
    this.payload,
  });
  factory ComResponse.fromResponse({
    required http.Response response,
    required ComRequest request,
    Function(dynamic)? preDecorder,
  }) {
    final ResponseStatus status =
        ComInterface.statusCodeToResponseStatus(response.statusCode);
    Model? payload;
    if (request.decoder != null) {
      try {
        dynamic decodedBody = _decodeUtf8BodyBytes(response.bodyBytes);

        if (preDecorder != null && request.ignorePreDecoder == false) {
          decodedBody = preDecorder(decodedBody);
        }

        // Wrap in TrackedMap so we can report the exact failing key path
        TrackedMap.lastAccessedPath = null;
        if (decodedBody is Map<String, dynamic>) {
          decodedBody = TrackedMap(decodedBody);
        }

        payload = request.decoder!(decodedBody, status) as Model?;
      } catch (e, stackTrace) {
        final failedKey = TrackedMap.lastAccessedPath;
        Print.red(
          'Unable to decode payload.\n'
          '  Model: $Model\n'
          '${failedKey != null ? '  Failed at key: $failedKey\n' : ''}'
          '  URL: ${request.getUrl()}\n'
          '  Error: $e\n'
          '  StackTrace: $stackTrace',
          name: apiComPackageName,
        );
      }
    }

    return ComResponse(
      response: response,
      request: request,
      status: status,
      payload: payload,
    );
  }

  /// Original [ComRequest] used to get the response
  final ComRequest request;

  /// Raw response from the server [http.Response]
  final http.Response? response;
  final ResponseStatus status;

  bool get isSuccess => status == ResponseStatus.success;
  int? get statusCode => response?.statusCode;

  Model Function(dynamic rawPayload, ResponseStatus status)? decoder;

  Model? payload;

  static dynamic _decodeUtf8BodyBytes(Uint8List body) {
    final Map<String, dynamic> decodedJson = jsonDecode(utf8.decode(body));

    return decodedJson;
  }
}
