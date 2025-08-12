// lib/Core/Services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Constants/api_endpoins.dart';

class ApiClient {
  static final ApiClient _i = ApiClient._internal();
  factory ApiClient() => _i;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl, // e.g. http://59.94.176.2:8022/api
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          const storage = FlutterSecureStorage();
          final token = await storage.read(key: 'active_access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          // If you add refresh logic later, hook 401 here.
          handler.next(e);
        },
      ),
    );
  }
}
