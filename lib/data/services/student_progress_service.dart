import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/student_attendance_model.dart';
import 'package:catalyst/data/models/student_evaluation_model.dart';
import 'package:catalyst/data/models/student_feedback_model.dart';
import 'package:dio/dio.dart';

class StudentProgressService {
  final Dio _dio = ApiClient.instance.dio;

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

  /// GET /parent/progress/student/:studentId/evaluations
  Future<List<StudentEvaluationModel>> getEvaluations(
    int studentId, {
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.studentEvaluations(studentId),
        queryParameters: {'limit': limit},
      );
      final data = response.data['data'];
      if (data is List) {
        return data
            .map((e) =>
                StudentEvaluationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/progress/student/:studentId/feedback
  Future<List<StudentFeedbackModel>> getFeedback(
    int studentId, {
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.studentFeedback(studentId),
        queryParameters: {'limit': limit},
      );
      final data = response.data['data'];
      if (data is List) {
        return data
            .map((e) =>
                StudentFeedbackModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/attendance/student/:studentId
  Future<List<StudentAttendanceModel>> getAttendance(
    int studentId, {
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.studentAttendance(studentId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data['data'];
      // Response wraps items in a nested object with pagination
      if (data is Map<String, dynamic>) {
        final items = data['items'];
        if (items is List) {
          return items
              .map((e) => StudentAttendanceModel.fromJson(
                  e as Map<String, dynamic>))
              .toList();
        }
      }
      // Fallback if data is a direct list
      if (data is List) {
        return data
            .map((e) => StudentAttendanceModel.fromJson(
                e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
