class SyncQueueItemModel {
  final String localId;
  final String clientEventId; // Idempotency key
  final String entityType; // FIELD_VISIT, EVIDENCE, DOCUMENT, INSPECTION
  final String entityId;
  final String operation; // CREATE, UPDATE, SUBMIT
  final String payload; // JSON string
  final String createdAt;
  final String updatedAt;
  final int retryCount;
  final String syncStatus; // PENDING, SYNCING, SYNCED, FAILED
  final String? lastError;

  SyncQueueItemModel({
    required this.localId,
    required this.clientEventId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
    this.retryCount = 0,
    this.syncStatus = 'PENDING',
    this.lastError,
  });

  factory SyncQueueItemModel.fromJson(Map<String, dynamic> json) {
    return SyncQueueItemModel(
      localId: json['localId'] as String? ?? json['local_id'] as String? ?? '',
      clientEventId: json['clientEventId'] as String? ?? json['client_event_id'] as String? ?? '',
      entityType: json['entityType'] as String? ?? json['entity_type'] as String? ?? '',
      entityId: json['entityId'] as String? ?? json['entity_id'] as String? ?? '',
      operation: json['operation'] as String? ?? 'CREATE',
      payload: json['payload'] as String? ?? '{}',
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String? ?? '',
      retryCount: json['retryCount'] as int? ?? json['retry_count'] as int? ?? 0,
      syncStatus: json['syncStatus'] as String? ?? json['sync_status'] as String? ?? 'PENDING',
      lastError: json['lastError'] as String? ?? json['last_error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'clientEventId': clientEventId,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation,
      'payload': payload,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'retryCount': retryCount,
      'syncStatus': syncStatus,
      'lastError': lastError,
    };
  }

  SyncQueueItemModel copyWith({
    int? retryCount,
    String? syncStatus,
    String? lastError,
    String? updatedAt,
  }) {
    return SyncQueueItemModel(
      localId: localId,
      clientEventId: clientEventId,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      retryCount: retryCount ?? this.retryCount,
      syncStatus: syncStatus ?? this.syncStatus,
      lastError: lastError ?? this.lastError,
    );
  }
}
