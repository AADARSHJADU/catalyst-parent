import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:dio/dio.dart';

class CompetitionService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Map<String, dynamic>>> getCompetitions() async {
    try {
      final response = await _dio.get(ApiConstants.competitions);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMyRegistrations() async {
    try {
      final response = await _dio.get(ApiConstants.myRegistrations);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> getSchedule(int competitionId) async {
    try {
      final response =
          await _dio.get(ApiConstants.competitionSchedule(competitionId));
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<Map<String, dynamic>>> getPastResults() async {
    try {
      final response = await _dio.get(ApiConstants.pastResults);
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
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

  Future<Map<String, dynamic>> getRegistrationFee() async {
    try {
      final response = await _dio.get(ApiConstants.registrationFee,
          queryParameters: {'classType': 'competition'});
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> payCompetition(int id, {
    required String paymentMethod,
    int? studentId,
  }) async {
    try {
      final body = <String, dynamic>{'paymentMethod': paymentMethod};
      if (studentId != null) body['studentId'] = studentId;
      final response = await _dio.post(
          ApiConstants.competitionPayment(id), data: body);
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
