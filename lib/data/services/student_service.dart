import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/student_model.dart';
import 'package:dio/dio.dart';

/// API service for Student-related endpoints.
class StudentService {
  final Dio _dio = ApiClient.instance.dio;

  // ── Get Students ───────────────────────────────────────────────────────
  Future<List<StudentModel>> getStudents() async {
    try {
      final response = await _dio.get(ApiConstants.parentStudents);
      final data = response.data['data'];
      final List<dynamic> list = data is List ? data : [];
      return list
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Create Student ─────────────────────────────────────────────────────
  Future<StudentModel> createStudent(FormData formData) async {
    try {
      final response = await _dio.post(
        ApiConstants.parentStudents,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return StudentModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Update Student ─────────────────────────────────────────────────────
  Future<StudentModel> updateStudent(int id, FormData formData) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.parentStudents}/$id',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return StudentModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Get Age Groups ─────────────────────────────────────────────────────
  Future<List<StudentLookup>> getAgeGroups() async {
    try {
      final response = await _dio.get(ApiConstants.ageGroups);
      final data = response.data['data'];
      final List<dynamic> list = data is List ? data : [];
      return list
          .map((e) => StudentLookup.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Get Skill Levels ───────────────────────────────────────────────────
  Future<List<StudentLookup>> getSkillLevels() async {
    try {
      final response = await _dio.get(ApiConstants.skillLevels);
      final data = response.data['data'];
      final List<dynamic> list = data is List ? data : [];
      return list
          .map((e) => StudentLookup.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Get Dance Styles ───────────────────────────────────────────────────
  Future<List<StudentDanceStyle>> getDanceStyles() async {
    try {
      final response = await _dio.get(ApiConstants.danceStyles);
      final data = response.data['data'];
      final List<dynamic> list = data is List ? data : [];
      return list
          .map((e) => StudentDanceStyle.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Get Studios ────────────────────────────────────────────────────────
  Future<List<StudentStudio>> getStudios() async {
    try {
      final response = await _dio.get(ApiConstants.studios);
      final data = response.data['data'];
      final List<dynamic> list = data is List ? data : [];
      return list
          .map((e) => StudentStudio.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
