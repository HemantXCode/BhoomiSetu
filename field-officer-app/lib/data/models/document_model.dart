class DocumentModel {
  final String documentId;
  final String visitId;
  final String ulpin;
  final String fileName;
  final String fileType; // PDF, JPG, PNG, DOC, DOCX
  final int fileSizeBytes;
  final String localFilePath;
  final String uploadStatus; // PENDING_UPLOAD, UPLOADING, UPLOADED, FAILED
  final String syncStatus;

  DocumentModel({
    required this.documentId,
    required this.visitId,
    String? ulpin,
    String? parcelId,
    required this.fileName,
    required this.fileType,
    required this.fileSizeBytes,
    required this.localFilePath,
    this.uploadStatus = 'PENDING_UPLOAD',
    this.syncStatus = 'PENDING',
  }) : ulpin = ulpin ?? parcelId ?? '';

  String get parcelId => ulpin;
  String get filePath => localFilePath;
  String get title => fileName;

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      documentId: (json['documentId'] ?? json['document_id'] ?? json['id'])?.toString() ?? '',
      visitId: (json['visitId'] ?? json['visit_id'])?.toString() ?? '',
      ulpin: (json['ulpin'] ?? json['parcelId'] ?? json['parcel_id'])?.toString() ?? '',
      fileName: (json['fileName'] ?? json['file_name'] ?? json['title']) as String? ?? '',
      fileType: (json['fileType'] ?? json['file_type']) as String? ?? 'PDF',
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? (json['file_size_bytes'] as num?)?.toInt() ?? 0,
      localFilePath: (json['localFilePath'] ?? json['local_file_path'] ?? json['file_path'] ?? json['filePath'])?.toString() ?? '',
      uploadStatus: (json['uploadStatus'] ?? json['upload_status']) as String? ?? 'PENDING_UPLOAD',
      syncStatus: (json['syncStatus'] ?? json['sync_status']) as String? ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'visitId': visitId,
      'ulpin': ulpin,
      'parcelId': ulpin,
      'fileName': fileName,
      'fileType': fileType,
      'fileSizeBytes': fileSizeBytes,
      'localFilePath': localFilePath,
      'uploadStatus': uploadStatus,
      'syncStatus': syncStatus,
    };
  }

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
