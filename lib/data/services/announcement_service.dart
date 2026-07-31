import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/announcement_model.dart';
import 'package:dio/dio.dart';

/// API service for Announcement endpoints.
class AnnouncementService {
  final Dio _dio = ApiClient.instance.dio;

  /// Fetch all published announcements.
  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final response = await _dio.get(
        ApiConstants.announcements,
        queryParameters: {'status': 'published'},
      );

      final responseData = response.data;

      // Handle different response structures
      List<dynamic> list;

      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];
        if (data is List) {
          // Direct array: { "data": [...] }
          list = data;
        } else if (data is Map<String, dynamic>) {
          // Paginated: { "data": { "announcements": [...] } } or { "data": { "rows": [...] } }
          list = data['announcements'] as List<dynamic>? ??
              data['rows'] as List<dynamic>? ??
              [];
        } else {
          list = [];
        }
      } else if (responseData is List) {
        list = responseData;
      } else {
        list = [];
      }

      return list
          .map((e) =>
              AnnouncementModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
