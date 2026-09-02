import 'package:flutter/material.dart';
import 'package:field_officer_app/core/theme/app_colors.dart';

class CorridorLegendWidget extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const CorridorLegendWidget({
    super.key,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ACQUISITION STATUS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              if (onToggleCollapse != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onToggleCollapse,
                  child: Icon(
                    isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
          if (!isCollapsed) ...[
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusDot(AppColors.success, 'Acquired'),
                const SizedBox(width: 8),
                _buildStatusDot(AppColors.warning, 'In Progress'),
                const SizedBox(width: 8),
                _buildStatusDot(AppColors.danger, 'Pending'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusDot(const Color(0xFF10B981), 'Officer GPS', isIcon: true, icon: Icons.person_pin_circle),
                const SizedBox(width: 8),
                _buildStatusDot(AppColors.secondary, 'Corridor Path', isIcon: true, icon: Icons.linear_scale),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusDot(Color color, String label, {bool isIcon = false, IconData? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isIcon && icon != null)
          Icon(icon, size: 12, color: color)
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
