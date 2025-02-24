import 'dart:convert';
import 'dart:io';
import 'package:e_connect/main.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../model/sign_in_model.dart';
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
    bool? needLoader = false,
  }) async {
    if (signInModel.data?.authToken != null) {
      SignInModel? loadedModel = await SignInModel.loadFromPrefs();
      if (loadedModel != null) {
        signInModel = loadedModel;
      }
    }
    final header = {
      'Authorization': "Bearer ${signInModel.data?.authToken}",};
    if (!_networkStatusService.connectionValue) {
      commonShowToast("No Internet Connection");
      return;
    }

    Uri uri = Uri.parse(ApiString.baseUrl + endPoint).replace(queryParameters: queryParams);
    http.Response? response;
    Map<String, String> requestHeaders = {};
    if (!endPoint.contains(AppString.signIN)) {
      requestHeaders.addAll(header);
    }

    _logRequest('$uri', method, reqBody, requestHeaders);

    try {
      if(needLoader == true) startLoading();
      if(endPoint == ApiString.closeConversation || endPoint == ApiString.sendMessage){
        print("IN close");
        requestHeaders.clear();
        requestHeaders.addAll({
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${signInModel.data!.authToken}"
        });
        reqBody = jsonEncode(reqBody);
      }
      response = await _makeRequest(method, uri, reqBody, requestHeaders);
      _logResponse(response);

      final responseData = json.decode(response.body);
      _handleToastMessage(responseData);

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 403) {
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
        return await http.post(uri, body: reqBody, headers: headers);
      case Method.DELETE:
        return await http.delete(uri, body: jsonEncode(reqBody), headers: headers);
      case Method.PATCH:
        return await http.patch(uri, body: jsonEncode(reqBody), headers: headers);
      case Method.PUT:
        return await http.put(uri, body: jsonEncode(reqBody), headers: headers);
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
      final String message = responseData['message'].toString();
      final bool isSuccess = (responseData['statusCode'] == 200 || responseData['statusCode'] == 201 || responseData['status'] == 1);
      commonShowToast(message, isSuccess ? Colors.green : Colors.red);
    }
  }
}

