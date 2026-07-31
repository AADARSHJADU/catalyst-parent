import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/api_notification_model.dart';
import 'package:dio/dio.dart';

/// API service for all Notification-related endpoints.
class NotificationApiService {
  final Dio _dio = ApiClient.instance.dio;

  // ── Get Notifications ──────────────────────────────────────────────────
  Future<List<ApiNotificationModel>> getNotifications({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.notifications,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data['data'];

      // API may return data as a List directly or as a Map with 'notifications' key
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic> &&
          data.containsKey('notifications')) {
        list = data['notifications'] as List<dynamic>;
      } else {
        list = [];
      }

      return list
          .map((e) =>
              ApiNotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Mark Single Notification as Read ───────────────────────────────────
  Future<void> markAsRead(int id) async {
    try {
      await _dio.put('${ApiConstants.notifications}/$id/read');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Mark All Notifications as Read ─────────────────────────────────────
  Future<int> markAllAsRead() async {
    try {
      final response =
          await _dio.put(ApiConstants.markAllNotificationsRead);
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return data['updatedCount'] as int? ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Delete Single Notification ─────────────────────────────────────────
  Future<void> deleteNotification(int id) async {
    try {
      await _dio.delete('${ApiConstants.notifications}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ── Bulk Delete Notifications ──────────────────────────────────────────
  Future<int> bulkDelete(List<int> ids) async {
    try {
      final response = await _dio.delete(
        ApiConstants.notifications,
        data: {'ids': ids},
      );
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return data['deletedCount'] as int? ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
