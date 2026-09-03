import 'package:flutter/material.dart';
import 'package:field_officer_app/core/theme/app_colors.dart';
import 'package:field_officer_app/data/models/project_corridor_model.dart';

class MobileGisKpiCard extends StatefulWidget {
  final ProjectCorridorModel corridor;
  final VoidCallback? onExpand;

  const MobileGisKpiCard({
    super.key,
    required this.corridor,
    this.onExpand,
  });

  @override
  State<MobileGisKpiCard> createState() => _MobileGisKpiCardState();
}

class _MobileGisKpiCardState extends State<MobileGisKpiCard> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.corridor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Name + Progress + Collapse toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          c.name.replaceAll(' Express Corridor (Phase-I)', '').replaceAll(' Semi-High Speed', ''),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    c.formattedAcquisitionProgress,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => setState(() => _isCollapsed = !_isCollapsed),
                  child: Icon(
                    _isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),

            if (!_isCollapsed) ...[
              const SizedBox(height: 4),
              // Compact 3-part progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 4,
                  child: Row(
                    children: [
                      if (c.acquiredLand > 0)
                        Expanded(
                          flex: (c.acquiredLand * 100).toInt(),
                          child: Container(color: AppColors.success),
                        ),
                      if (c.inProgressLand > 0)
                        Expanded(
                          flex: (c.inProgressLand * 100).toInt(),
                          child: Container(color: AppColors.warning),
                        ),
                      if (c.pendingLand > 0)
                        Expanded(
                          flex: (c.pendingLand * 100).toInt(),
                          child: Container(color: AppColors.danger),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // KPI stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat('Parcels', '${c.totalParcels} Total', AppColors.textPrimary),
                  _buildMiniStat('Acquired', '${c.acquiredParcels} (🟢)', AppColors.success),
                  _buildMiniStat('In Progress', '${c.inProgressParcels} (🟠)', AppColors.warning),
                  _buildMiniStat('Pending', '${c.pendingParcels} (🔴)', AppColors.danger),
                  _buildMiniStat('Land', '${c.totalLandRequired} Ha', AppColors.secondary),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
