class DashboardStatsModel {
  final int assigned;
  final int inProgress;
  final int completed;
  final int verified;
  final int pending;
  final int rejected;
  final int syncPending;

  DashboardStatsModel({
    required this.assigned,
    required this.inProgress,
    required this.completed,
    required this.verified,
    required this.pending,
    required this.rejected,
    required this.syncPending,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      assigned: json['assigned'] as int? ?? 0,
      inProgress: json['inProgress'] as int? ?? json['in_progress'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      verified: json['verified'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
      syncPending: json['syncPending'] as int? ?? json['sync_pending'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assigned': assigned,
      'inProgress': inProgress,
      'completed': completed,
      'verified': verified,
      'pending': pending,
      'rejected': rejected,
      'syncPending': syncPending,
    };
  }

  factory DashboardStatsModel.empty() {
    return DashboardStatsModel(
      assigned: 0,
      inProgress: 0,
      completed: 0,
      verified: 0,
      pending: 0,
      rejected: 0,
      syncPending: 0,
    );
  }
}
