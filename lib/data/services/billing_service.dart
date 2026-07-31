import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/billing_model.dart';
import 'package:dio/dio.dart';

/// API service for Billing-related endpoints.
class BillingService {
  final Dio _dio = ApiClient.instance.dio;

  /// Fetch billing overview with optional category and search filters.
  Future<BillingResponse> getBilling({
    String? category,
    String? search,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (category != null && category.isNotEmpty) {
        params['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }

      final response = await _dio.get(
        ApiConstants.parentBilling,
        queryParameters: params.isNotEmpty ? params : null,
      );
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return BillingResponse.fromJson(data);
      }
      return const BillingResponse(
        summary: BillingSummary(),
        transactions: [],
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
