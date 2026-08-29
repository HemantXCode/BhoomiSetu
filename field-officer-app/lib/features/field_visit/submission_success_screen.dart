import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/routing/app_router.dart';
import '../../core/utils/date_formatter.dart';

class SubmissionSuccessScreen extends StatelessWidget {
  final String visitId;
  final String parcelId;

  const SubmissionSuccessScreen({
    super.key,
    required this.visitId,
    required this.parcelId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Success Badge
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.success, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle, size: 54, color: AppColors.success),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Verification Submitted',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Field inspection report recorded and signed.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Ticket Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildTicketRow('Parcel Identifier', parcelId, isBold: true),
                        const Divider(height: 16),
                        _buildTicketRow('Visit Session ID', visitId),
                        const Divider(height: 16),
                        _buildTicketRow('Submission Time', DateFormatter.formatDateTime(DateTime.now())),
                        const Divider(height: 16),
                        _buildTicketRow('Local Storage', 'Saved Locally (Encrypted)'),
                        const Divider(height: 16),
                        _buildTicketRow('Sync Queue Status', 'SYNC PENDING', statusColor: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                // Actions
                BhoomiButton(
                  text: 'RETURN TO DASHBOARD',
                  icon: Icons.dashboard_outlined,
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.main,
                      (route) => false,
                      arguments: 0,
                    );
                  },
                ),
                const SizedBox(height: 10),
                BhoomiButton(
                  text: 'VIEW OFFLINE SYNC CENTER',
                  type: ButtonType.outline,
                  icon: Icons.sync,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.offlineSync);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value, {bool isBold = false, Color? statusColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold || statusColor != null ? FontWeight.w800 : FontWeight.w600,
            color: statusColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
