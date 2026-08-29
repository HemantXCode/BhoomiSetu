import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/routing/app_router.dart';
import '../auth/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      appBar: const BhoomiAppBar(
        title: 'Officer Profile',
        subtitle: 'BhoomiSetu Field Administration',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Officer Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.secondary,
                      child: Text(
                        (user?.name ?? 'RK').substring(0, 2).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? AppConstants.demoOfficerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.designation ?? AppConstants.demoDesignation,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ID: ${user?.officerId ?? AppConstants.demoOfficerId}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const Divider(height: 28),
                    _buildProfileRow(Icons.location_on_outlined, 'Jurisdiction', '${user?.district ?? "Pune"}, ${user?.state ?? "Maharashtra"}'),
                    _buildProfileRow(Icons.email_outlined, 'Official Email', user?.email ?? AppConstants.demoEmail),
                    _buildProfileRow(Icons.phone_outlined, 'Contact Phone', user?.phone ?? '+91 98230 45678'),
                    _buildProfileRow(Icons.verified_user_outlined, 'Authority Level', 'Field Verification Officer Grade-I'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Navigation Menu Options
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined, color: AppColors.secondary),
                    title: const Text('My Work Progress', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('View performance, verified parcels & metrics', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.myProgress),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_sync_outlined, color: AppColors.primary),
                    title: const Text('Offline Sync Center', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Manage pending uploads & sync queue', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.offlineSync),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: AppColors.secondary),
                    title: const Text('System Settings', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('API base URL, Data mode & Preferences', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            BhoomiButton(
              text: 'LOGOUT SESSION',
              type: ButtonType.outline,
              icon: Icons.logout,
              onPressed: () => _confirmLogout(context, ref),
            ),
            const SizedBox(height: 16),
            const Text(
              AppConstants.appVersion,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout Session?'),
        content: const Text('Ensure all field reports are synchronized before logging out.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
            child: const Text('LOGOUT', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
