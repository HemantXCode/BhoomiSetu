class DocumentModel {
  final String documentId;
  final String visitId;
  final String parcelId;
  final String fileName;
  final String fileType; // PDF, JPG, PNG, DOC, DOCX
  final int fileSizeBytes;
  final String localFilePath;
  final String uploadStatus; // PENDING_UPLOAD, UPLOADING, UPLOADED, FAILED
  final String syncStatus;

  DocumentModel({
    required this.documentId,
    required this.visitId,
    required this.parcelId,
    required this.fileName,
    required this.fileType,
    required this.fileSizeBytes,
    required this.localFilePath,
    this.uploadStatus = 'PENDING_UPLOAD',
    this.syncStatus = 'PENDING',
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      documentId: json['documentId'] as String? ?? json['document_id'] as String? ?? '',
      visitId: json['visitId'] as String? ?? json['visit_id'] as String? ?? '',
      parcelId: json['parcelId'] as String? ?? json['parcel_id'] as String? ?? '',
      fileName: json['fileName'] as String? ?? json['file_name'] as String? ?? '',
      fileType: json['fileType'] as String? ?? json['file_type'] as String? ?? 'PDF',
      fileSizeBytes: json['fileSizeBytes'] as int? ?? json['file_size_bytes'] as int? ?? 0,
      localFilePath: json['localFilePath'] as String? ?? json['local_file_path'] as String? ?? '',
      uploadStatus: json['uploadStatus'] as String? ?? json['upload_status'] as String? ?? 'PENDING_UPLOAD',
      syncStatus: json['syncStatus'] as String? ?? json['sync_status'] as String? ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'visitId': visitId,
      'parcelId': parcelId,
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
