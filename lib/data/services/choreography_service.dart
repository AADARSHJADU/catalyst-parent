import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:dio/dio.dart';

class ChoreographyService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Map<String, dynamic>>> getMyChoreographies() async {
    try {
      final response = await _dio.get(ApiConstants.choreographyList);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> checkout({
    required int choreographyId,
    required int studentId,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.choreographyCheckout, data: {
        'choreographyId': choreographyId,
        'studentId': studentId,
        'paymentMethod': paymentMethod,
      });
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> capture({
    required int paymentId,
    required String gatewayOrderId,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.choreographyCapture, data: {
        'paymentId': paymentId,
        'gatewayOrderId': gatewayOrderId,
        'paymentMethod': paymentMethod,
      });
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> payLater({
    required int choreographyId,
    required int studentId,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.choreographyPayLater, data: {
        'choreographyId': choreographyId,
        'studentId': studentId,
      });
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

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
}
