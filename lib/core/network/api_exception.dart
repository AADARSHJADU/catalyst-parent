import 'package:dio/dio.dart';

/// Wraps Dio errors into friendly, user-facing messages.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      // Try to extract server message
      final serverMsg = (data is Map) ? data['message'] as String? : null;
      return ApiException(
        serverMsg ?? _statusMessage(e.response!.statusCode),
        statusCode: e.response!.statusCode,
      );
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
            'Connection timed out. Please check your internet.');
      case DioExceptionType.connectionError:
        return const ApiException(
            'No internet connection. Please try again.');
      default:
        return const ApiException('Something went wrong. Please try again.');
    }
  }

  static String _statusMessage(int? code) {
    switch (code) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Invalid credentials. Please try again.';
      case 403:
        return 'You do not have permission to do this.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong (code: $code).';
    }
  }

  @override
  String toString() => message;
}
