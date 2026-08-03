import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:dio/dio.dart';

class PrivateBookingService {
  final Dio _dio = ApiClient.instance.dio;

  /// GET /parent/private-booking/instructors
  Future<List<Map<String, dynamic>>> getInstructors() async {
    try {
      final response =
          await _dio.get(ApiConstants.privateBookingInstructors);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/private-booking/dance-styles
  Future<List<Map<String, dynamic>>> getDanceStyles() async {
    try {
      final response =
          await _dio.get(ApiConstants.privateBookingDanceStyles);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/private-booking/instructors/:id/availability?date=YYYY-MM-DD
  Future<List<String>> getAvailability(int instructorId, String date) async {
    try {
      final response = await _dio.get(
        ApiConstants.privateBookingAvailability(instructorId),
        queryParameters: {'date': date},
      );
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        final slots = data['availableSlots'];
        if (slots is List) return List<String>.from(slots);
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /parent/private-booking/calculate-price
  Future<Map<String, dynamic>> calculatePrice({
    required int instructorId,
    required int duration,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.privateBookingCalculatePrice,
        data: {'instructorId': instructorId, 'duration': duration},
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /parent/private-booking/request-class
  Future<Map<String, dynamic>> requestClass({
    required int studentId,
    required int instructorId,
    required String date,
    required String startTime,
    required int duration,
    String? focusArea,
    String? studentGoal,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'studentId': studentId,
        'instructorId': instructorId,
        'date': date,
        'startTime': startTime,
        'duration': duration,
      };
      if (focusArea != null && focusArea.isNotEmpty) {
        body['focusArea'] = focusArea;
      }
      if (studentGoal != null && studentGoal.isNotEmpty) {
        body['studentGoal'] = studentGoal;
      }
      if (notes != null && notes.isNotEmpty) body['notes'] = notes;

      final response = await _dio.post(
        ApiConstants.privateBookingRequestClass,
        data: body,
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/private-booking/my-bookings
  Future<List<Map<String, dynamic>>> getMyBookings() async {
    try {
      final response =
          await _dio.get(ApiConstants.privateBookingMyBookings);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/private-booking/history
  Future<Map<String, dynamic>> getHistory({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (status != null && status.isNotEmpty) params['status'] = status;

      final response = await _dio.get(
        ApiConstants.privateBookingHistory,
        queryParameters: params,
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/students
  Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final response = await _dio.get(ApiConstants.parentStudents);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /parent/private-booking/:lessonId/checkout
  Future<Map<String, dynamic>> lessonCheckout(int lessonId,
      {String paymentMethod = 'stripe'}) async {
    try {
      final response = await _dio.post(
        ApiConstants.privateBookingLessonCheckout(lessonId),
        data: {'paymentMethod': paymentMethod, 'platform': 'mobile'},
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /parent/private-booking/:lessonId/capture
  Future<Map<String, dynamic>> lessonCapture(int lessonId, {
    required String gatewayOrderId,
    String paymentMethod = 'stripe',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.privateBookingLessonCapture(lessonId),
        data: {
          'gatewayOrderId': gatewayOrderId,
          'paymentMethod': paymentMethod,
        },
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
