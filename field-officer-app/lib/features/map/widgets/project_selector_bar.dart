import 'package:flutter/material.dart';
import 'package:field_officer_app/core/theme/app_colors.dart';
import 'package:field_officer_app/data/models/project_corridor_model.dart';

class ProjectSelectorBar extends StatelessWidget {
  final List<ProjectCorridorModel> corridors;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;

  const ProjectSelectorBar({
    super.key,
    required this.corridors,
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // All Projects Filter
            _buildChip(
              label: 'All Projects',
              icon: Icons.alt_route,
              isSelected: selectedFilter == 'ALL',
              onTap: () => onSelectFilter('ALL'),
            ),
            const SizedBox(width: 6),
            // Individual Projects
            ...corridors.map((c) {
              final isSelected = selectedFilter == c.id;
              final icon = c.type.toLowerCase().contains('rail') ? Icons.train : Icons.add_road;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _buildChip(
                  label: c.name.replaceAll(' Corridor', ''),
                  icon: icon,
                  isSelected: isSelected,
                  onTap: () => onSelectFilter(c.id),
                ),
              );
            }),
            // Subtle Demo Data Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'DEMO DATA',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFFD580),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryLight : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
