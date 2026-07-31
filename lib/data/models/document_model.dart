/// Model representing a document from the API.
class ApiDocumentModel {
  const ApiDocumentModel({
    required this.id,
    required this.title,
    this.description,
    this.category = 'Downloads',
    this.filePath,
    this.fileType,
    this.fileSize,
    this.fileUrl,
    this.isActive = true,
    this.studioId,
    this.studioName,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String? description;
  final String category;
  final String? filePath;
  final String? fileType;
  final int? fileSize;
  final String? fileUrl;
  final bool isActive;
  final int? studioId;
  final String? studioName;
  final String? createdAt;
  final String? updatedAt;

  String get fileSizeFormatted {
    if (fileSize == null) return '';
    if (fileSize! >= 1048576) {
      return '${(fileSize! / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(fileSize! / 1024).toStringAsFixed(0)} KB';
  }

  String get fileTypeUpper => (fileType ?? 'PDF').toUpperCase();

  factory ApiDocumentModel.fromJson(Map<String, dynamic> json) {
    final studio = json['studio'] as Map<String, dynamic>?;
    return ApiDocumentModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'Downloads',
      filePath: json['filePath'] as String?,
      fileType: json['fileType'] as String?,
      fileSize: json['fileSize'] as int?,
      fileUrl: json['fileUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      studioId: json['studioId'] as int?,
      studioName: studio?['name'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
    );
  }
}

/// Stats summary for documents.
class DocumentStats {
  const DocumentStats({
    this.total = 0,
    this.waivers = 0,
    this.policies = 0,
    this.medicalForms = 0,
    this.downloads = 0,
  });

  final int total;
  final int waivers;
  final int policies;
  final int medicalForms;
  final int downloads;

  factory DocumentStats.fromJson(Map<String, dynamic> json) {
    return DocumentStats(
      total: json['total'] as int? ?? 0,
      waivers: json['waivers'] as int? ?? 0,
      policies: json['policies'] as int? ?? 0,
      medicalForms: json['medicalForms'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
    );
  }
}

/// Response wrapper with pagination and stats.
class DocumentsResponse {
  const DocumentsResponse({
    required this.documents,
    required this.stats,
    this.totalItems = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.limit = 10,
  });

  final List<ApiDocumentModel> documents;
  final DocumentStats stats;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int limit;

  factory DocumentsResponse.fromJson(Map<String, dynamic> json) {
    final docsList = json['documents'] as List<dynamic>? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    final statsJson = json['stats'] as Map<String, dynamic>? ?? {};

    return DocumentsResponse(
      documents: docsList
          .map((e) => ApiDocumentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: DocumentStats.fromJson(statsJson),
      totalItems: pagination['totalItems'] as int? ?? docsList.length,
      totalPages: pagination['totalPages'] as int? ?? 1,
      currentPage: pagination['currentPage'] as int? ?? 1,
      limit: pagination['limit'] as int? ?? 10,
    );
  }
}
