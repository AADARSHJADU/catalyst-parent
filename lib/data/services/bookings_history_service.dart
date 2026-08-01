import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:dio/dio.dart';

/// API service for Booking History endpoints.
class BookingsHistoryService {
  final Dio _dio = ApiClient.instance.dio;

  /// GET /parent/class-booking/history
  /// Used for Classes, Wellness, Routines tabs (use `type` query param)
  Future<Map<String, dynamic>> getClassHistory({
    int page = 1,
    int limit = 10,
    String? search,
    String? paymentStatus,
    String? type,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (paymentStatus != null && paymentStatus != 'All') {
        params['paymentStatus'] = paymentStatus;
      }
      if (type != null && type.isNotEmpty) params['type'] = type;

      final response = await _dio.get(
        ApiConstants.classBookingHistory,
        queryParameters: params,
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/choreography-booking/history
  Future<Map<String, dynamic>> getChoreographyHistory({
    int page = 1,
    int limit = 10,
    String? search,
    String? paymentStatus,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (paymentStatus != null && paymentStatus != 'All') {
        params['paymentStatus'] = paymentStatus;
      }

      final response = await _dio.get(
        ApiConstants.choreographyBookingHistory,
        queryParameters: params,
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/private-booking/history
  Future<Map<String, dynamic>> getPrivateHistory({
    int page = 1,
    int limit = 10,
    String? search,
    String? paymentStatus,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (paymentStatus != null && paymentStatus != 'All') {
        params['paymentStatus'] = paymentStatus;
      }

      final response = await _dio.get(
        ApiConstants.privateBookingHistoryEndpoint,
        queryParameters: params,
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
