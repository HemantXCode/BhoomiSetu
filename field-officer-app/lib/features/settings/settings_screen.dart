import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/network/api_config.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _urlController = TextEditingController(text: ApiConfig.baseUrl);
  DataMode _currentMode = ApiConfig.dataMode;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ApiConfig.setBaseUrl(_urlController.text.trim());
    ApiConfig.setDataMode(_currentMode);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BhoomiAppBar(
        title: 'System Settings',
        subtitle: 'Gateway & Repository Configuration',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Repository Data Mode Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Data Mode / Repository Layer', style: AppTextStyles.h3),
                    const SizedBox(height: 6),
                    const Text(
                      'Switch between Standalone Mock Repository and Aditya\'s Live API Gateway.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const Divider(height: 20),
                    RadioListTile<DataMode>(
                      value: DataMode.mock,
                      groupValue: _currentMode,
                      title: const Text('Mock Repository (Standalone SIH Demo)', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Uses realistic local Pune Ring Road dataset. No backend required.'),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _currentMode = val ?? DataMode.mock),
                    ),
                    const Divider(height: 8),
                    RadioListTile<DataMode>(
                      value: DataMode.api,
                      groupValue: _currentMode,
                      title: const Text('API Repository (Aditya\'s Backend Gateway)', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Connects to live REST API Gateway /api/v1 endpoints.'),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _currentMode = val ?? DataMode.api),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // API Base URL Configuration Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('API Gateway Base URL', style: AppTextStyles.h3),
                    const SizedBox(height: 6),
                    const Text(
                      'Configurable server address for Aditya\'s FastAPI / API Gateway.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.link, size: 20),
                        hintText: 'https://api.bhoomisetu.gov.in',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App Build Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Application Environment', style: AppTextStyles.h3),
                    const Divider(height: 16),
                    _buildInfoRow('Application Name', AppConstants.appName),
                    _buildInfoRow('Full Build Version', AppConstants.appVersion),
                    _buildInfoRow('Target Framework', 'Flutter 3.47.2 / Dart 3.13.2'),
                    _buildInfoRow('Local SQLite Schema', 'v1.0 (7 Tables Encrypted)'),
                    _buildInfoRow('Ministry', AppConstants.ministry),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Settings CTA
            BhoomiButton(
              text: 'SAVE CONFIGURATION',
              icon: Icons.save_outlined,
              onPressed: _saveSettings,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
