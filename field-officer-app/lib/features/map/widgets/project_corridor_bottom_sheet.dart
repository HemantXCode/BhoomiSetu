import 'package:flutter/material.dart';
import 'package:field_officer_app/core/theme/app_colors.dart';
import 'package:field_officer_app/core/widgets/bhoomi_button.dart';
import 'package:field_officer_app/core/widgets/status_badge.dart';
import 'package:field_officer_app/data/models/project_corridor_model.dart';

class ProjectCorridorBottomSheet extends StatelessWidget {
  final ProjectCorridorModel corridor;
  final VoidCallback onViewParcels;
  final VoidCallback onClose;

  const ProjectCorridorBottomSheet({
    super.key,
    required this.corridor,
    required this.onViewParcels,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isRail = corridor.type.toLowerCase().contains('rail');
    final parcelPct = corridor.parcelCompletionPercentage;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Header: Project Name, Type Icon, Status, Close
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isRail ? Icons.train : Icons.add_road,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                corridor.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            StatusBadge(
                              status: corridor.status.toUpperCase(),
                              compact: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${corridor.type.toUpperCase()} • ${corridor.code} • ${corridor.lengthKm.toStringAsFixed(0)} KM',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Route: Point A -> Point B
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trip_origin, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        corridor.startPoint,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_forward, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    const Icon(Icons.location_on, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        corridor.endPoint,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Dynamic Acquisition Progress Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Land Acquisition Progress',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            corridor.formattedAcquisitionProgress,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Multi-Segment Progress Bar (Acquired, In Progress, Pending)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 8,
                        child: Row(
                          children: [
                            if (corridor.acquiredLand > 0)
                              Expanded(
                                flex: (corridor.acquiredLand * 100).toInt(),
                                child: Container(color: AppColors.success),
                              ),
                            if (corridor.inProgressLand > 0)
                              Expanded(
                                flex: (corridor.inProgressLand * 100).toInt(),
                                child: Container(color: AppColors.warning),
                              ),
                            if (corridor.pendingLand > 0)
                              Expanded(
                                flex: (corridor.pendingLand * 100).toInt(),
                                child: Container(color: AppColors.danger),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Land Area Stat Pills
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(
                            'Required',
                            '${corridor.totalLandRequired.toStringAsFixed(1)} Ha',
                            AppColors.secondary,
                          ),
                        ),
                        Expanded(
                          child: _buildStatBox(
                            'Acquired',
                            '${corridor.acquiredLand.toStringAsFixed(2)} Ha',
                            AppColors.success,
                          ),
                        ),
                        Expanded(
                          child: _buildStatBox(
                            'In Progress',
                            '${corridor.inProgressLand.toStringAsFixed(2)} Ha',
                            AppColors.warning,
                          ),
                        ),
                        Expanded(
                          child: _buildStatBox(
                            'Pending',
                            '${corridor.pendingLand.toStringAsFixed(2)} Ha',
                            AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Parcel Breakdown Stats
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PARCEL COMPLETION',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${corridor.acquiredParcels} of ${corridor.totalParcels} Acquired (${parcelPct.toStringAsFixed(1)}%)',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniBadge('${corridor.acquiredParcels} Acquired', AppColors.success, AppColors.successBg),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildMiniBadge('${corridor.inProgressParcels} In Progress', AppColors.warning, AppColors.warningBg),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildMiniBadge('${corridor.pendingParcels} Pending', AppColors.danger, AppColors.dangerBg),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: BhoomiButton(
                      text: 'VIEW PROJECT PARCELS',
                      icon: Icons.layers,
                      height: 44,
                      onPressed: onViewParcels,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Disclaimer
              const Center(
                child: Text(
                  'DEMO DATA • FOR VERIFICATION & PLANNING CONTEXT ONLY',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
