import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import '../exceptions/api_exception.dart';


typedef FactoryConstructor<U> = U Function(dynamic);

class APIError {
  int errorCode;
  String errorMessage;

  APIError(this.errorCode, this.errorMessage);

  Map<String, dynamic> toJson() => {'errorCode': errorCode, 'errorMessage': errorMessage};

  @override
  String toString() {
    return jsonEncode(this);
  }
}

APIException _throwAPIException(Response response) {
  switch (response.statusCode) {
    case 400:
      APIError? apiError;
      if (response.body != null && response.body.isNotEmpty) {
        var jsonError = jsonDecode(response.body);
        apiError = APIError(jsonError['errorCode'], jsonError['errorMessage']);
      }
      return APIException(APIException.BAD_REQUEST, error: apiError);
    case 401:
      return APIException(APIException.UNAUTHORIZED);
    case 403:
      return APIException(APIException.FORBIDDEN);
    case 404:
      return APIException(APIException.NOT_FOUND);
    case 500:
      return APIException(APIException.INTERNAL_SERVER_ERROR);
    case 444:
      var downloadUrl = response.headers["location"];
      return APIException(APIException.UPGRADE_REQUIRED, arguments: downloadUrl);
    default:
      return APIException(APIException.OTHER);
  }
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  ApiClient._internal();

  factory ApiClient() => _instance;

  Future<U> postJsonForObject<T, U>(FactoryConstructor<U> factoryConstructor, String url, T jsonObject,
      {String? token, Map<String, dynamic>? queryParameters, Map<String, String>? headers, int retryTimes = 0}) async {
    var _headers = {'Accept': 'application/json'};
    if (headers != null && headers.isNotEmpty) {
      _headers.addAll(headers);
    }
    if (!kReleaseMode) {
      print("Url:$url");
      print("body:$jsonObject");
    }
    var response = await postJsonForResponse(url, jsonObject, token: token, queryParameters: queryParameters, headers: _headers, retryTimes: retryTimes);
    try {
      if (!kReleaseMode) {
        print("res121:" + response.body);
        print("res121:" + response.statusCode.toString());
      }
      var jsonData = jsonDecode(response.body);

      return factoryConstructor(jsonData);
    } catch (ex) {
      print(ex);
      print("exception121:" + ex.toString());
      throw APIException(APIException.BAD_RESPONSE_FORMAT, arguments: ex);
    }
  }

  Future<Response> postJsonForResponse<T>(String url, T jsonObject, {String? token, Map<String, dynamic>? queryParameters, Map<String, String>? headers, int retryTimes = 0}) async {
    String? requestBody;
    if (jsonObject != null) {
      requestBody = jsonEncode(jsonObject);
      if (headers == null) {
        headers = {'Content-Type': 'application/json'};
      } else {
        headers['Content-Type'] = 'application/json';
      }
    }

    return await _postForResponse(url, requestBody, token: token, queryParameters: queryParameters, headers: headers, retryTimes: retryTimes);
  }

  Future<Response> _postForResponse(
      String url,
      requestBody, {
        String? token,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
        int retryTimes = 0,
      }) async {
    try {
      var _headers = <String, String>{};
      if (token != null) {
        _headers['Authorization'] = 'Bearer $token';
      }

      if (headers != null && headers.isNotEmpty) {
        _headers.addAll(headers);
      }

      if (queryParameters != null) {
        var queryString = new Uri(queryParameters: queryParameters).query;
        url = url + '?' + queryString;
      }

      var response;

      response = await _post(Uri.parse(url), body: requestBody, headers: _headers).timeout(Duration(seconds: 100));

      if (!kReleaseMode) {
        print("Url:$url");
        print("body:$requestBody");
        print("res: " + response.body);
      }
      if (response.statusCode >= 200 && response.statusCode < 500) {
        var jsonData = jsonDecode(response.body);
        if (jsonData["StatusMessage"] != null && jsonData["StatusMessage"] == "Unauthorized user attempt to access API") {

          return await _postForResponse(url, requestBody, token: token, queryParameters: queryParameters, headers: headers, retryTimes: retryTimes);
        }

        return response;
      } else {
        throw _throwAPIException(response);
      }
    } on SocketException catch (e) {
      if (retryTimes > 0) {
        print('will retry after 3 seconds...');
        await Future.delayed(Duration(seconds: 3));
        return await _postForResponse(url, requestBody, token: token, queryParameters: queryParameters, headers: headers, retryTimes: retryTimes - 1);
      } else {
        throw APIException(APIException.OTHER, arguments: e);
      }
    } on HttpException catch (e) {
      if (retryTimes > 0) {
        print('will retry after 3 seconds...');
        await Future.delayed(Duration(seconds: 3));
        return await _postForResponse(url, requestBody, token: token, queryParameters: queryParameters, headers: headers, retryTimes: retryTimes - 1);
      } else {
        throw APIException(APIException.OTHER, arguments: e);
      }
    } on TimeoutException catch (e) {
      throw APIException(APIException.TIMEOUT, arguments: e);
    } on ClientException catch (e) {
      if (retryTimes > 0) {
        print('will retry after 3 seconds...');
        await Future.delayed(Duration(seconds: 3));
        return await _postForResponse(url, requestBody, token: token, queryParameters: queryParameters, headers: headers, retryTimes: retryTimes - 1);
      } else {
        throw APIException(APIException.OTHER, arguments: e);
      }
    } catch (ex) {
      print("exception1:" + ex.toString());
      throw APIException(APIException.BAD_RESPONSE_FORMAT, arguments: ex);
    }
  }

  bool _certificateCheck(X509Certificate cert, String host, int port) => true;

  Future<T> _withClient<T>(Future<T> Function(Client) fn) async {
    var httpClient = HttpClient()..badCertificateCallback = _certificateCheck;
    var client = IOClient(httpClient);
    try {
      return await fn(client);
    } finally {
      client.close();
    }
  }

  Future<Response> _post(url, {Map<String, String>? headers, body, Encoding? encoding}) => _withClient((client) => client.post(url, headers: headers, body: body, encoding: encoding));

  Future<U> getJsonForObject<T, U>(FactoryConstructor<U> factoryConstructor, String url,
      {String? token, Map<String, dynamic>? queryParameters, Map<String, String>? headers, int retryTimes = 0}) async {
    var _headers = {'Accept': 'application/json'};
    if (headers != null && headers.isNotEmpty) {
      _headers.addAll(headers);
    }
    var response = await getJsonForResponse(url, token: token, queryParameters: queryParameters, headers: _headers, retryTimes: retryTimes);
    try {
      if (!kReleaseMode) {
        print("res:" + response.body);
      }
      var jsonData = jsonDecode(response.body);
      return factoryConstructor(jsonData);
    } catch (ex) {
      print("exception:" + response.body);
      throw APIException(APIException.BAD_RESPONSE_FORMAT, arguments: ex);
    }
  }

  Future<Response> getJsonForResponse<T>(String url, {String? token, Map<String, dynamic>? queryParameters, Map<String, String>? headers, int retryTimes = 0}) async {
    if (headers == null) {
      headers = {'Content-Type': 'application/json'};
    } else {
      headers['Content-Type'] = 'application/json';
    }
    return await _getForResponse(url, token: token, queryParameters: queryParameters, headers: headers, retryTimes: retryTimes);
  }

  Future<Response> _getForResponse(String url, {String? token, Map<String, dynamic>? queryParameters, Map<String, String>? headers, int retryTimes = 0}) async {
    try {
      var _headers = <String, String>{};
      if (token != null) {
        _headers['Authorization'] = 'Bearer $token';
      }

      if (headers != null && headers.isNotEmpty) {
        _headers.addAll(headers);
      }
      if (queryParameters != null) {
        String queryString = new Uri(queryParameters: queryParameters).query;
        if (!url.contains(queryString.toString())) {
          url = url + '?' + queryString.toString();
        }
        // if (isFirstCall) url = url + '?' + queryString.toString();
      }

      if (!kReleaseMode) {
        print("Url:$url");
        print("queryParameters:$queryParameters");
      }
      var response = await _get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: 60));
      if (!kReleaseMode) {
        print("res: " + response.body.toString());
      }
      if (response.statusCode >= 200 && response.statusCode < 500) {
        var jsonData = jsonDecode(response.body);
        if (jsonData["StatusMessage"] != null && jsonData["StatusMessage"] == "Unauthorized user attempt to access API") {
          return await _getForResponse(url, token: token, queryParameters: queryParameters, headers: headers, retryTimes: retryTimes);
        }
        return response;
      } else {
        throw _throwAPIException(response);
      }
    } on SocketException catch (e) {
      if (retryTimes > 0) {
        print('will retry after 3 seconds...');
        await Future.delayed(Duration(seconds: 3));
        return await _getForResponse(url, token: token, queryParameters: queryParameters, headers: headers, retryTimes: retryTimes - 1);
      } else {
        throw APIException(APIException.OTHER, arguments: e);
      }
    } on HttpException catch (e) {
      if (retryTimes > 0) {
        print('will retry after 3 seconds...');
        await Future.delayed(Duration(seconds: 3));
        return await _getForResponse(url, token: token, queryParameters: queryParameters, headers: headers, retryTimes: retryTimes - 1);
      } else {
        throw APIException(APIException.OTHER, arguments: e);
      }
    } on TimeoutException catch (e) {
      throw APIException(APIException.TIMEOUT, arguments: e);
    } on ClientException catch (e) {
      if (retryTimes > 0) {
        await Future.delayed(Duration(seconds: 3));
        return await _getForResponse(url, token: token, queryParameters: queryParameters, headers: headers, retryTimes: retryTimes - 1);
      } else {
        throw APIException(APIException.OTHER, arguments: e);
      }
    } catch (e) {
      throw APIException(APIException.OTHER, arguments: e);
    }
  }

  Future<Response> _get(url, {Map<String, String>? headers}) => _withClient((client) => client.get(url, headers: headers));
}
