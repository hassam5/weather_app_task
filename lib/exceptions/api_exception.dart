import 'dart:convert';

import '../api/api_client.dart';



class APIException implements Exception {
  static const String BAD_REQUEST = 'api_common_bad_request';
  static const String UNAUTHORIZED = 'api_common_unauthorized';
  static const String FORBIDDEN = 'api_common_forbidden';
  static const String NOT_FOUND = 'api_common_not_found';
  static const String INTERNAL_SERVER_ERROR = 'api_common_internal_server_error';
  static const String UPGRADE_REQUIRED = 'api_common_upgrade_required';
  static const String BAD_RESPONSE_FORMAT = 'api_common_bad_response_format';
  static const String OTHER = 'api_common_http_error';
  static const String TIMEOUT = 'api_common_http_timeout';
  static const String UNKNOWN = 'unexpected_error';

  final String message;
  final APIError? error;
  final arguments;

  const APIException(this.message, {this.arguments, this.error});

  Map<String, dynamic> toJson() => {'message': message, 'error': error, 'arguments': '$arguments'};

  @override
  String toString() {
    return jsonEncode(this);
  }
}
