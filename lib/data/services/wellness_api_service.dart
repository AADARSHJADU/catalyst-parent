import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:dio/dio.dart';

class WellnessApiService {
  final Dio _dio = ApiClient.instance.dio;

  // ── Browse Classes ─────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getClasses({
    String? search,
    String? category,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (category != null && category.isNotEmpty) params['category'] = category;
      final response = await _dio.get(ApiConstants.wellnessClasses,
          queryParameters: params.isNotEmpty ? params : null);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Book with Pass Credit ──────────────────────────────────────────────
  Future<Map<String, dynamic>> bookClass({
    required int classId,
    required List<String> sessionDates,
    String paymentType = 'pass',
  }) async {
    try {
      final response = await _dio.post(ApiConstants.wellnessBookClass, data: {
        'classId': classId,
        'sessionDates': sessionDates,
        'paymentType': paymentType,
      });
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Drop-in Checkout ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> dropinCheckout({
    required int classId,
    required List<String> sessionDates,
    String gateway = 'stripe',
  }) async {
    try {
      final response =
          await _dio.post(ApiConstants.wellnessDropinCheckout, data: {
        'classId': classId,
        'sessionDates': sessionDates,
        'gateway': gateway,
      });
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Drop-in Confirm ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> dropinConfirm({
    required int classId,
    required List<String> sessionDates,
    String gateway = 'stripe',
    double? dropInPrice,
    String? orderId,
  }) async {
    try {
      final response =
          await _dio.post(ApiConstants.wellnessDropinConfirm, data: {
        'classId': classId,
        'sessionDates': sessionDates,
        'gateway': gateway,
        if (dropInPrice != null) 'dropInPrice': dropInPrice,
        if (orderId != null) 'orderId': orderId,
      });
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Cancel Booking ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    try {
      final response =
          await _dio.post(ApiConstants.wellnessCancelBooking, data: {
        'bookingId': bookingId,
      });
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── My Bookings ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getMyBookings() async {
    try {
      final response = await _dio.get(ApiConstants.wellnessMyBookings);
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Pass Products ──────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _dio.get(ApiConstants.wellnessProducts);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Membership Checkout ────────────────────────────────────────────────
  Future<Map<String, dynamic>> membershipCheckout({
    required int productId,
    String paymentMethod = 'stripe',
  }) async {
    try {
      final response =
          await _dio.post(ApiConstants.wellnessMembershipCheckout, data: {
        'productId': productId,
        'paymentMethod': paymentMethod,
        'platform': 'mobile',
      });
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Membership Capture ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> membershipCapture({
    required int paymentId,
    String paymentMethod = 'stripe',
    String? gatewayOrderId,
  }) async {
    try {
      final response =
          await _dio.post(ApiConstants.wellnessMembershipCapture, data: {
        'paymentId': paymentId,
        'paymentMethod': paymentMethod,
        if (gatewayOrderId != null) 'gatewayOrderId': gatewayOrderId,
      });
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── My Memberships + Credits Ledger ────────────────────────────────────
  Future<Map<String, dynamic>> getMyMemberships() async {
    try {
      final response = await _dio.get(ApiConstants.wellnessMyMemberships);
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
