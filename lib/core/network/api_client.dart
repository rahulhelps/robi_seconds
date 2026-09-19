import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants.dart';

class ApiClient {
  ApiClient._();

  static late final Dio dio;

  static void initialize() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('[ApiClient] ${options.method} ${options.uri}');
        if (options.data != null) {
          debugPrint('[ApiClient] Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[ApiClient] ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('[ApiClient] Error ${error.response?.statusCode} ${error.requestOptions.uri}: ${error.message}');
        return handler.next(error);
      },
    ));
  }
}