class InspectionModel {
  final String visitId;
  final String parcelMatchesRecord; // YES / NO / NOT_APPLICABLE
  final String boundaryIdentified;
  final String boundaryMarkersAvailable;
  final String boundaryMatchesCadastral;
  final String landUseVerified;
  final String physicalConditionVerified;
  final String encroachmentChecked;
  final String ownershipChecked;
  final String documentsReviewed;
  final String objectionReceived;
  final String disputeObserved;
  final String encroachmentObserved;
  final String otherIssues;
  final String? remarks;
  final String? additionalObservations;
  final String syncStatus;

  InspectionModel({
    required this.visitId,
    this.parcelMatchesRecord = 'YES',
    this.boundaryIdentified = 'YES',
    this.boundaryMarkersAvailable = 'YES',
    this.boundaryMatchesCadastral = 'YES',
    this.landUseVerified = 'YES',
    this.physicalConditionVerified = 'YES',
    this.encroachmentChecked = 'YES',
    this.ownershipChecked = 'YES',
    this.documentsReviewed = 'YES',
    this.objectionReceived = 'NO',
    this.disputeObserved = 'NO',
    this.encroachmentObserved = 'NO',
    this.otherIssues = 'NO',
    this.remarks,
    this.additionalObservations,
    this.syncStatus = 'PENDING',
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    return InspectionModel(
      visitId: json['visitId'] as String? ?? json['visit_id'] as String? ?? '',
      parcelMatchesRecord: json['parcelMatchesRecord'] as String? ?? 'YES',
      boundaryIdentified: json['boundaryIdentified'] as String? ?? 'YES',
      boundaryMarkersAvailable: json['boundaryMarkersAvailable'] as String? ?? 'YES',
      boundaryMatchesCadastral: json['boundaryMatchesCadastral'] as String? ?? 'YES',
      landUseVerified: json['landUseVerified'] as String? ?? 'YES',
      physicalConditionVerified: json['physicalConditionVerified'] as String? ?? 'YES',
      encroachmentChecked: json['encroachmentChecked'] as String? ?? 'YES',
      ownershipChecked: json['ownershipChecked'] as String? ?? 'YES',
      documentsReviewed: json['documentsReviewed'] as String? ?? 'YES',
      objectionReceived: json['objectionReceived'] as String? ?? 'NO',
      disputeObserved: json['disputeObserved'] as String? ?? 'NO',
      encroachmentObserved: json['encroachmentObserved'] as String? ?? 'NO',
      otherIssues: json['otherIssues'] as String? ?? 'NO',
      remarks: json['remarks'] as String?,
      additionalObservations: json['additionalObservations'] as String? ?? json['additional_observations'] as String?,
      syncStatus: json['syncStatus'] as String? ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitId': visitId,
      'parcelMatchesRecord': parcelMatchesRecord,
      'boundaryIdentified': boundaryIdentified,
      'boundaryMarkersAvailable': boundaryMarkersAvailable,
      'boundaryMatchesCadastral': boundaryMatchesCadastral,
      'landUseVerified': landUseVerified,
      'physicalConditionVerified': physicalConditionVerified,
      'encroachmentChecked': encroachmentChecked,
      'ownershipChecked': ownershipChecked,
      'documentsReviewed': documentsReviewed,
      'objectionReceived': objectionReceived,
      'disputeObserved': disputeObserved,
      'encroachmentObserved': encroachmentObserved,
      'otherIssues': otherIssues,
      'remarks': remarks,
      'additionalObservations': additionalObservations,
      'syncStatus': syncStatus,
    };
  }

  bool isComplete() {
    // Validates all critical items are checked and required remarks are entered
    return parcelMatchesRecord.isNotEmpty &&
        boundaryIdentified.isNotEmpty &&
        boundaryMatchesCadastral.isNotEmpty &&
        landUseVerified.isNotEmpty &&
        ownershipChecked.isNotEmpty;
  }
}
