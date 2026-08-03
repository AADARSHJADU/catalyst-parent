import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:dio/dio.dart';

class ScheduleApiService {
  final Dio _dio = ApiClient.instance.dio;

  /// GET /parent/enrollment/my-enrollments
  Future<Map<String, dynamic>> getMyEnrollments() async {
    try {
      final response = await _dio.get(ApiConstants.myEnrollments);
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/schedule/wellness?limit=100&status=active
  Future<List<Map<String, dynamic>>> getWellnessSchedule() async {
    try {
      final response = await _dio.get(ApiConstants.wellnessSchedule,
          queryParameters: {'limit': 100, 'status': 'active'});
      final data = response.data['data'];
      if (data is Map && data['classes'] is List) {
        return List<Map<String, dynamic>>.from(data['classes']);
      }
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
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

  /// GET /admin/studios
  Future<List<Map<String, dynamic>>> getStudios() async {
    try {
      final response = await _dio.get(ApiConstants.studiosList);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/choreography-booking
  Future<List<Map<String, dynamic>>> getChoreographies() async {
    try {
      final response = await _dio.get(ApiConstants.choreographyList);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
