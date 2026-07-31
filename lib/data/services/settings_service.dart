import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/parent_profile_model.dart';
import 'package:dio/dio.dart';

/// API service for all Settings-related endpoints.
class SettingsService {
  final Dio _dio = ApiClient.instance.dio;

  // ── Get Relationships ───────────────────────────────────────────────────
  Future<List<LookupItem>> getRelationships() async {
    try {
      final response = await _dio.get(ApiConstants.relationships);
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => LookupItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Get Languages ───────────────────────────────────────────────────────
  Future<List<LookupItem>> getLanguages() async {
    try {
      final response = await _dio.get(ApiConstants.languages);
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => LookupItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Get Parent Profile ──────────────────────────────────────────────────
  Future<ParentProfileModel> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.parentProfile);
      final data = response.data['data'] as Map<String, dynamic>;
      return ParentProfileModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Update Parent Profile (JSON — for notifications/text fields) ────────
  Future<ParentProfileModel> updateProfile(Map<String, dynamic> body) async {
    try {
      final response = await _dio.put(
        ApiConstants.parentProfile,
        data: body,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ParentProfileModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Update Parent Profile with FormData (for file uploads) ──────────────
  Future<ParentProfileModel> updateProfileWithFormData(
      FormData formData) async {
    try {
      final response = await _dio.put(
        ApiConstants.parentProfile,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ParentProfileModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Change Password ─────────────────────────────────────────────────────
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      return response.data['message'] as String? ??
          'Password changed successfully';
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
