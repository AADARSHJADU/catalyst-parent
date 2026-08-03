import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:dio/dio.dart';

class RegularClassService {
  final Dio _dio = ApiClient.instance.dio;

  /// GET /parent/class-booking/classes
  Future<List<Map<String, dynamic>>> getClasses() async {
    try {
      final response = await _dio.get(ApiConstants.regularClasses);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/class-booking/my-bookings
  Future<List<Map<String, dynamic>>> getMyBookings() async {
    try {
      final response = await _dio.get(ApiConstants.regularClassMyBookings);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/class-booking/details/:classId
  Future<Map<String, dynamic>> getClassDetail(int classId) async {
    try {
      final response =
          await _dio.get(ApiConstants.regularClassDetail(classId));
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

  /// GET /parent/settings/payment-methods
  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await _dio.get(ApiConstants.paymentMethods);
      final data = response.data['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is List) {
        return {
          'stripeEnabled': data.contains('stripe'),
          'paypalEnabled': data.contains('paypal'),
          'cashEnabled': data.contains('cash'),
        };
      }
      return {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /parent/class-booking/checkout
  Future<Map<String, dynamic>> checkout({
    required int studentId,
    required int classId,
    required String paymentMethod,
    required String joiningDate,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.regularClassCheckout,
        data: {
          'studentId': studentId,
          'classId': classId,
          'paymentMethod': paymentMethod,
          'joiningDate': joiningDate,
          'platform': 'mobile',
        },
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /parent/class-booking/capture
  Future<Map<String, dynamic>> capture({
    required int paymentId,
    required String paymentMethod,
    required String gatewayOrderId,
    required String joiningDate,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.regularClassCapture,
        data: {
          'paymentId': paymentId,
          'paymentMethod': paymentMethod,
          'gatewayOrderId': gatewayOrderId,
          'joiningDate': joiningDate,
        },
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /parent/class-booking/pay-later
  Future<Map<String, dynamic>> payLater({
    required int studentId,
    required int classId,
    required String joiningDate,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.regularClassPayLater,
        data: {
          'studentId': studentId,
          'classId': classId,
          'paymentMethod': 'cash',
          'joiningDate': joiningDate,
        },
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// DELETE /parent/enrollment/regular/:id
  Future<void> dropEnrollment(int enrollmentId) async {
    try {
      await _dio.delete(ApiConstants.dropEnrollment(enrollmentId));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /parent/payments/class/:id/pay
  Future<Map<String, dynamic>> payClassInvoice(int paymentId,
      {String paymentMethod = 'stripe'}) async {
    try {
      final response = await _dio.post(
        ApiConstants.payClassInvoice(paymentId),
        data: {'paymentMethod': paymentMethod},
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /parent/settings/registration-fee?classType=class
  Future<Map<String, dynamic>> getRegistrationFee() async {
    try {
      final response = await _dio.get(ApiConstants.registrationFee,
          queryParameters: {'classType': 'class'});
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
