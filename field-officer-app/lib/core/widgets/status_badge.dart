import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (label, bgColor, fgColor, icon) = _getStyle(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fgColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: fgColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: fgColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, Color, IconData) _getStyle(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return ('PENDING', AppColors.warningBg, AppColors.warning, Icons.access_time_filled);
      case 'IN_PROGRESS':
        return ('IN PROGRESS', AppColors.infoBg, AppColors.info, Icons.autorenew);
      case 'PENDING_VERIFICATION':
        return ('PENDING VERIFICATION', const Color(0xFFF3E8FF), const Color(0xFF7E22CE), Icons.hourglass_top);
      case 'VERIFIED':
        return ('VERIFIED', AppColors.successBg, AppColors.success, Icons.check_circle);
      case 'REJECTED':
        return ('REJECTED', AppColors.dangerBg, AppColors.danger, Icons.cancel);
      case 'SYNC_PENDING':
      case 'PENDING_SYNC':
        return ('SYNC PENDING', const Color(0xFFF1F5F9), const Color(0xFF475569), Icons.cloud_upload);
      case 'SYNCED':
        return ('SYNCED', AppColors.successBg, AppColors.success, Icons.cloud_done);
      default:
        return (status.toUpperCase(), const Color(0xFFF1F5F9), const Color(0xFF475569), Icons.info);
    }
  }
}
