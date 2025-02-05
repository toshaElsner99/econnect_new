import 'dart:convert';
import 'dart:io';
import 'package:e_connect/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../common/common_widgets.dart';
import '../logger/logger.dart';
import '../network_connectivity/network_connectivity.dart';
import 'api_string_constants.dart';

enum Method { POST, GET, DELETE, PUT, PATCH, MULTIPART }

class ApiService {
  ApiService._privateConstructor();
  static final ApiService instance = ApiService._privateConstructor();

  final _networkStatusService = NetworkStatusService();

  Future<dynamic> request({
    required String endPoint,
    required Method method,
    var reqBody,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    if (!_networkStatusService.connectionValue) {
      commonShowToast("No Internet Connection");
      return;
    }

    Uri uri = Uri.parse(ApiString.baseUrl + endPoint).replace(queryParameters: queryParams);
    http.Response? response;
    _logRequest('$uri', method, reqBody, headers);

    try {
      startLoading();
      response = await _makeRequest(method, uri, reqBody, headers);
      _logResponse(response);

      final responseData = json.decode(response.body);
      _handleToastMessage(responseData);

      if (response.statusCode == 200 || response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 403) {
        return json.decode(response.body);
      } else if (response.statusCode == 500) {
        throw Exception("Server Error");
      } else {
        throw Exception("Something Went Wrong");
      }
    } on SocketException {
      commonShowToast("No Internet Connection", Colors.red);
      throw Exception("No Internet Connection");
    } on FormatException {
      commonShowToast("Bad Response Format!", Colors.red);
      throw Exception("Bad Response Format!");
    } catch (e) {
      commonShowToast("Something Went Wrong $e", Colors.red);
      throw Exception("Something Went Wrong ${e.toString()}");
    } finally {
      stopLoading();
    }
  }

  Future<http.Response> _makeRequest(
      Method method, Uri uri, dynamic reqBody, Map<String, String>? headers) async {
    if (method == Method.MULTIPART && reqBody is Map<String, dynamic>) {
      var request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers ?? {})
        ..fields.addAll({for (var e in reqBody.entries) if (e.value is! File) e.key: e.value.toString()})
        ..files.addAll([
          for (var e in reqBody.entries.where((e) => e.value is File))
            http.MultipartFile.fromBytes(
              e.key,
              (e.value as File).readAsBytesSync(),
              filename: (e.value as File).path.split('/').last,
              contentType: MediaType.parse(lookupMimeType((e.value as File).path) ?? 'application/octet-stream'),
            )
        ]);
      return http.Response.fromStream(await request.send());
    }
    switch (method) {
      case Method.POST:
        FocusScope.of(navigatorKey.currentState!.context).unfocus();
        return await http.post(uri, body: reqBody, headers: headers);
      case Method.DELETE:
        return await http.delete(uri, body: jsonEncode(reqBody), headers: headers);
      case Method.PATCH:
        return await http.patch(uri, body: jsonEncode(reqBody), headers: headers);
      default:
        return await http.get(uri, headers: headers);
    }
  }

  void _logRequest(String url, Method method, dynamic params, Map<String, String>? headers) {
    logger.log("✈️ REQUEST[$method] => PATH: $url \n Headers: ${headers ?? {}} \n DATA: ${jsonEncode(params)}",
        printFullText: true);
  }

  void _logResponse(http.Response response) {
    logger.log("✅ RESPONSE[${response.statusCode}] => PATH: ${response.request!.url} \n DATA: ${jsonDecode(response.body)}",
        printFullText: true);
  }

  void _handleToastMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
      final String message = responseData['message'];
      final bool isSuccess = (responseData['statusCode'] == 200 || responseData['status'] == 1);
      commonShowToast(message, isSuccess ? Colors.green : Colors.red);
    }
  }
}
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:mime/mime.dart';
//
// import '../common/common_widgets.dart';
// import '../logger/logger.dart';
// import '../network_connectivity/network_connectivity.dart';
// import 'api_string_constants.dart';
//
// enum Method { POST, GET, DELETE, PUT, PATCH, MULTIPART }
//
// // final NetworkStatusService _networkStatusService = NetworkStatusService();
//
// class ApiService {
//   ApiService._privateConstructor();
//
//   static final ApiService instance = ApiService._privateConstructor();
//   Future<dynamic> request({
//     required String endPoint,
//     required Method method,
//     var reqBody,
//     Map<String, dynamic>? queryParams,
//     Map<String, String>? headers,
//   }) async {
//     // if (_networkStatusService.connectionValue == false) {
//     //   commonShowToast("No Internet Connection");
//     //   return;
//     // }
//     http.Response? response;
//     try {
//       Uri uri = Uri.parse(ApiString.baseUrl + endPoint);
//       if (queryParams != null) {
//         uri = uri.replace(queryParameters: queryParams);
//       }
//
//       _logRequest('$uri', method, reqBody, headers);
//
//       if (method == Method.POST) {
//         response = await http.post(uri, body: jsonEncode(reqBody), headers: headers);
//       } else if (method == Method.DELETE) {
//         response = await http.delete(uri, body: jsonEncode(reqBody), headers: headers);
//       } else if (method == Method.PATCH) {
//         response = await http.patch(uri, body: jsonEncode(reqBody), headers: headers,);
//       } else if (method == Method.MULTIPART) {
//         if (reqBody != null && reqBody is Map<String, dynamic>) {
//           var request = http.MultipartRequest('POST', uri);
//           reqBody.forEach((key, value) {
//             if (value is File) {
//               String? mimeType = lookupMimeType(value.path);
//               var multipartFile = http.MultipartFile.fromBytes(
//                 key,
//                 value.readAsBytesSync(),
//                 filename: value.path.split('/').last,
//                 contentType: mimeType != null ? MediaType.parse(mimeType) : MediaType('application', 'octet-stream'),
//               );
//               request.files.add(multipartFile);
//             } else {
//               request.fields[key] = value.toString();
//             }
//           });
//           if (headers != null) {
//             request.headers.addAll(headers);
//           }
//           response = await http.Response.fromStream(await request.send());
//         } else {
//           throw Exception("Invalid multipart request body");
//         }
//       } else {
//         response = await http.get(uri, headers: headers);
//       }
//
//       _logResponse(response);
//
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else if (response.statusCode == 401 || response.statusCode == 400) {
//         return json.decode(response.body);
//       } else if (response.statusCode == 500) {
//         throw Exception("Server Error");
//       } else {
//         throw Exception("Something Went Wrong");
//       }
//     } on SocketException catch (e) {
//       _logError(response);
//       throw Exception("No Internet Connection $e");
//     } on FormatException {
//       _logError(response);
//       throw Exception("Bad Response Format!");
//     } catch (e) {
//       _logError(response);
//       throw Exception("Something Went Wrong $e");
//     }
//   }
// }
//
// void _logRequest(String url, Method method, dynamic params, Map<String, String>? headers) {
//   logger.log(
//       "\n\n--------------------------------------------------------------------------------------------------------");
//   if (method == Method.GET) {
//     logger.log(
//         // "👨‍💻✔ NETWORK_CONNECTION[${_networkStatusService.connectionValue}] + CONNECTIVITY TYPE[${_networkStatusService.connectionStatus}]"
//             '\n'
//             "✈️ REQUEST[$method] => PATH: $url \n Headers: ${headers ?? {}} \n DATA: ${jsonEncode(params)}");
//   } else {
//     try {
//       logger.log(
//           "✈️ REQUEST[$method] => PATH: $url \n Headers: ${headers ?? {}} \n DATA: $params",
//           printFullText: true);
//     } catch (e) {
//       logger.log(
//           "✈️ REQUEST[$method] => PATH: $url \n Headers: ${headers ?? {}} \n DATA: $params",
//           printFullText: true);
//     }
//   }
// }
//
// void _logResponse(http.Response response) {
//   final statusCode = response.statusCode;
//   final uri = response.request!.url;
//   final data = jsonDecode(response.body);
//   logger.log("✅ RESPONSE[$statusCode] => PATH: $uri \n DATA: $data",
//       printFullText: true);
// }
//
// void _logError(dynamic error) {
//   if (error is http.Response) {
//     final statusCode = error.statusCode;
//     final uri = error.request!.url;
//     final data = jsonDecode(error.body);
//     logger.log(
//         // "👨‍💻✔ NETWORK_CONNECTION[${_networkStatusService.connectionValue}] + CONNECTIVITY TYPE[${_networkStatusService.connectionStatus}]"
//             '\n'
//             "⚠️ ERROR[$statusCode] => PATH: $uri\n DATA: $data",
//         printFullText: true);
//   } else {
//     logger.log("⚠️ ERROR: $error", printFullText: true);
//   }
// }

