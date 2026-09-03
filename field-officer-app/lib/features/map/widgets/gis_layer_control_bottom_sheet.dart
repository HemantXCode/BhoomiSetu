import 'package:flutter/material.dart';
import 'package:field_officer_app/core/theme/app_colors.dart';

class GISLayerOptions {
  final bool showCorridors;
  final bool showParcels;
  final bool showAffectedOnly;
  final bool showAcquisitionColors;
  final bool showUlpinLabels;
  final bool showOfficerGps;

  const GISLayerOptions({
    this.showCorridors = true,
    this.showParcels = true,
    this.showAffectedOnly = false,
    this.showAcquisitionColors = true,
    this.showUlpinLabels = true,
    this.showOfficerGps = true,
  });

  GISLayerOptions copyWith({
    bool? showCorridors,
    bool? showParcels,
    bool? showAffectedOnly,
    bool? showAcquisitionColors,
    bool? showUlpinLabels,
    bool? showOfficerGps,
  }) {
    return GISLayerOptions(
      showCorridors: showCorridors ?? this.showCorridors,
      showParcels: showParcels ?? this.showParcels,
      showAffectedOnly: showAffectedOnly ?? this.showAffectedOnly,
      showAcquisitionColors: showAcquisitionColors ?? this.showAcquisitionColors,
      showUlpinLabels: showUlpinLabels ?? this.showUlpinLabels,
      showOfficerGps: showOfficerGps ?? this.showOfficerGps,
    );
  }
}

class GISLayerControlBottomSheet extends StatelessWidget {
  final GISLayerOptions options;
  final ValueChanged<GISLayerOptions> onChanged;

  const GISLayerControlBottomSheet({
    super.key,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
              const SizedBox(height: 12),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.layers, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'GIS Map Layers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Toggles
              _buildLayerToggle(
                title: 'Project Corridor & 70m RoW',
                subtitle: 'Highway multi-layer casing & 70m statutory buffer band',
                icon: Icons.add_road,
                iconColor: AppColors.secondary,
                value: options.showCorridors,
                onChanged: (val) => onChanged(options.copyWith(showCorridors: val)),
              ),
              _buildLayerToggle(
                title: 'Cadastral Parcel Polygons',
                subtitle: 'Surrounding land parcel boundaries & shapes',
                icon: Icons.crop_free,
                iconColor: const Color(0xFF0284C7),
                value: options.showParcels,
                onChanged: (val) => onChanged(options.copyWith(showParcels: val)),
              ),
              _buildLayerToggle(
                title: 'Show Affected Parcels Only',
                subtitle: 'Hide or mute unimpacted cadastral boundaries',
                icon: Icons.filter_alt,
                iconColor: AppColors.primary,
                value: options.showAffectedOnly,
                onChanged: (val) => onChanged(options.copyWith(showAffectedOnly: val)),
              ),
              _buildLayerToggle(
                title: 'Acquisition Status Colors',
                subtitle: 'Green (Acquired), Orange (In Progress), Red (Pending)',
                icon: Icons.palette,
                iconColor: AppColors.success,
                value: options.showAcquisitionColors,
                onChanged: (val) => onChanged(options.copyWith(showAcquisitionColors: val)),
              ),
              _buildLayerToggle(
                title: 'ULPIN & Area Centroid Labels',
                subtitle: 'Parcel identifier and area badges on parcel centroids',
                icon: Icons.label,
                iconColor: Colors.amber.shade800,
                value: options.showUlpinLabels,
                onChanged: (val) => onChanged(options.copyWith(showUlpinLabels: val)),
              ),
              _buildLayerToggle(
                title: 'Officer GPS Location',
                subtitle: 'Real-time device coordinates and accuracy halo',
                icon: Icons.person_pin_circle,
                iconColor: const Color(0xFF10B981),
                value: options.showOfficerGps,
                onChanged: (val) => onChanged(options.copyWith(showOfficerGps: val)),
              ),

              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'BhoomiSetu Mobile GIS Engine • Vector Layers',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayerToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        value: value,
        activeTrackColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}
