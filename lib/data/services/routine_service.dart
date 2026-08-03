import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:dio/dio.dart';

class RoutineService {
  final Dio _dio = ApiClient.instance.dio;

  /// GET /parent/enrollment/my-enrollments → extract routines
  Future<List<Map<String, dynamic>>> getMyRoutines() async {
    try {
      final response = await _dio.get(ApiConstants.myEnrollments);
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final routines = data['routines'] as List? ?? [];
      return List<Map<String, dynamic>>.from(routines);
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

  /// GET /parent/settings/registration-fee?classType=routine
  Future<Map<String, dynamic>> getRegistrationFee() async {
    try {
      final response = await _dio.get(ApiConstants.registrationFee,
          queryParameters: {'classType': 'routine'});
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/settings/payment-methods
  Future<List<String>> getPaymentMethods() async {
    try {
      final response = await _dio.get(ApiConstants.paymentMethods);
      final data = response.data['data'];
      if (data is List) return List<String>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /parent/payments/routine/:id/pay
  Future<Map<String, dynamic>> payRoutine(int paymentId,
      {required String paymentMethod}) async {
    try {
      final response = await _dio.post(
        ApiConstants.routinePayment(paymentId),
        data: {'paymentMethod': paymentMethod, 'platform': 'mobile'},
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /parent/payments/capture
  Future<Map<String, dynamic>> capturePayment({
    required String orderId,
    required int paymentId,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.paymentsCapture, data: {
        'orderId': orderId,
        'paymentType': 'routine',
        'paymentId': paymentId,
      });
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
