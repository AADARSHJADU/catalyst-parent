import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/api_user_model.dart';
import 'package:dio/dio.dart';

/// Raw API calls for all auth endpoints.
/// Returns typed models; throws [ApiException] on failure.
class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  // ── Register ─────────────────────────────────────────────────────────────
  /// [role] is always sent as "parent" — not exposed to the user.
  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'fullname': fullName,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'role': 'parent', // static — never changes
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Get Profile ───────────────────────────────────────────────────────────
  Future<ApiUserModel> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      final data = response.data['data'] as Map<String, dynamic>;
      return ApiUserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Update Profile ────────────────────────────────────────────────────────
  Future<ApiUserModel> updateProfile({
    String? name,
    String? address,
    String? city,
    String? postcode,
    String? country,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (address != null) body['address'] = address;
      if (city != null) body['city'] = city;
      if (postcode != null) body['postcode'] = postcode;
      if (country != null) body['country'] = country;

      final response = await _dio.put(ApiConstants.profile, data: body);
      final data = response.data['data'] as Map<String, dynamic>;
      return ApiUserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Forgot Password ───────────────────────────────────────────────────────
  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      return response.data['message'] as String? ??
          'OTP sent to your email successfully';
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  Future<void> verifyOtp({required String token}) async {
    try {
      await _dio.post(
        ApiConstants.verifyOtp,
        data: {'token': token},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Reset Password ────────────────────────────────────────────────────────
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await _dio.post(
        ApiConstants.resetPassword,
        data: {'token': token, 'password': password},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Update FCM Token ──────────────────────────────────────────────────────
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _dio.patch(
        ApiConstants.fcmToken,
        data: {'fcmToken': fcmToken},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
