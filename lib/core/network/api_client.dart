import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/data/services/storage_service.dart';
import 'package:dio/dio.dart';

/// Central Dio instance used by all services.
/// Adds the auth token automatically to every request.
class ApiClient {
  ApiClient._();

  static ApiClient? _instance;
  static ApiClient get instance => _instance ??= ApiClient._();

  late final Dio _dio;

  void init(StorageService storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth interceptor — injects Bearer token when available
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // 401 → token expired, could trigger logout here
          return handler.next(error);
        },
      ),
    );

    // Log interceptor (only in debug)
    assert(() {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => print('[API] $o'),
        ),
      );
      return true;
    }());
  }

  Dio get dio => _dio;

  // ── Convenience methods (used by MessageRepository) ────────────────────────
  Future<Response> get(String path,
          {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> postForm(String path, {dynamic data}) =>
      _dio.post(path,
          data: data,
          options: Options(contentType: 'multipart/form-data'));

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path, {dynamic data}) =>
      _dio.delete(path, data: data);
}
