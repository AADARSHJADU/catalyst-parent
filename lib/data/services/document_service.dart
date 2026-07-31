import 'package:catalyst/core/constants/api_constants.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/network/api_exception.dart';
import 'package:catalyst/data/models/document_model.dart';
import 'package:dio/dio.dart';

/// API service for Document-related endpoints.
class DocumentService {
  final Dio _dio = ApiClient.instance.dio;

  /// Fetch documents with optional pagination, search, and category filter.
  Future<DocumentsResponse> getDocuments({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (category != null && category != 'All') params['category'] = category;

      final response = await _dio.get(
        ApiConstants.parentDocuments,
        queryParameters: params,
      );
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return DocumentsResponse.fromJson(data);
      }
      // If data is a list directly (fallback)
      if (data is List) {
        final docs = data
            .map((e) => ApiDocumentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return DocumentsResponse(
          documents: docs,
          stats: const DocumentStats(),
          totalItems: docs.length,
        );
      }
      return const DocumentsResponse(
          documents: [], stats: DocumentStats());
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
