import 'package:flutter/material.dart';
import 'package:field_officer_app/core/theme/app_colors.dart';
import 'package:field_officer_app/core/widgets/bhoomi_button.dart';
import 'package:field_officer_app/core/routing/app_router.dart';
import 'package:field_officer_app/data/models/land_parcel_model.dart';
import 'package:field_officer_app/data/models/field_task_model.dart';
import 'package:field_officer_app/data/models/project_corridor_model.dart';

class ParcelDetailsBottomSheet extends StatelessWidget {
  final LandParcelModel parcel;
  final List<FieldTaskModel> tasks;
  final VoidCallback onClose;

  const ParcelDetailsBottomSheet({
    super.key,
    required this.parcel,
    required this.tasks,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final statusEnum = AcquisitionStatus.fromString(parcel.status);

    final matchingTask = tasks.firstWhere(
      (t) => t.ulpin == parcel.ulpin || t.parcelId == parcel.ulpin,
      orElse: () => FieldTaskModel(
        id: 'TSK-${parcel.ulpin}',
        ulpin: parcel.ulpin,
        project: parcel.projectName,
        village: parcel.village,
        district: parcel.district,
        state: parcel.state,
        surveyNumber: parcel.surveyNumber,
        landAreaSqM: parcel.landAreaSqM,
        taskType: 'Cadastral Verification',
        assignedDate: '2026-09-01',
        dueDate: '2026-09-10',
        status: parcel.status,
        latitude: parcel.latitude,
        longitude: parcel.longitude,
        instructions: 'Ground verification of corridor alignment, cadastral boundary demarcation, and asset inventory.',
      ),
    );

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

              // Header: ULPIN & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              parcel.ulpin,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.secondary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${parcel.surveyNumber} • ${parcel.village} (${parcel.district})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusEnum.backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusEnum.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusEnum.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusEnum.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusEnum.color,
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

              // Project-Affected RoW Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFF7ED),
                      Colors.orange.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDBA74)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA580C),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'PROJECT-AFFECTED LAND: YES',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Flexible(
                          child: Text(
                            'Prototype RoW • 70m',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC2410C),
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.alt_route, size: 14, color: Color(0xFF9A3412)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '${parcel.rowStatus} • ${parcel.projectName}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF9A3412),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Detailed Parcel Attributes Grid
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildInfoItem('Primary Owner', parcel.ownerName)),
                        Expanded(child: _buildInfoItem('Land Classification', parcel.classification)),
                      ],
                    ),
                    const Divider(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'Parcel Area',
                            '${parcel.areaHectares.toStringAsFixed(2)} Ha (${parcel.landAreaSqM.toStringAsFixed(0)} sq.m)',
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            'Centroid GPS',
                            '${parcel.latitude.toStringAsFixed(4)}, ${parcel.longitude.toStringAsFixed(4)}',
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildInfoItem('Verification Status', parcel.verificationStatus)),
                        Expanded(child: _buildInfoItem('Taluka / District', 'Haveli / ${parcel.district}')),
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
                      text: 'OPEN TASK',
                      icon: Icons.assignment_outlined,
                      height: 40,
                      type: ButtonType.outline,
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.taskDetails,
                          arguments: matchingTask,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BhoomiButton(
                      text: 'START VISIT',
                      icon: Icons.directions_walk,
                      height: 40,
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.startVisit,
                          arguments: matchingTask,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.textMuted,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isNotEmpty ? value : 'N/A',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}
