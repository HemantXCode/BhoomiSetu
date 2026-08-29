import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/field_task_model.dart';
import '../../data/models/field_visit_model.dart';
import '../../data/models/evidence_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/utils/date_formatter.dart';
import '../field_visit/field_visit_controller.dart';

class EvidenceGalleryScreen extends ConsumerStatefulWidget {
  final FieldTaskModel task;
  final FieldVisitModel visit;

  const EvidenceGalleryScreen({super.key, required this.task, required this.visit});

  @override
  ConsumerState<EvidenceGalleryScreen> createState() => _EvidenceGalleryScreenState();
}

class _EvidenceGalleryScreenState extends ConsumerState<EvidenceGalleryScreen> {
  String _selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(fieldVisitControllerProvider);
    final allEvidence = visitState.visit?.evidence ?? [];

    final filtered = _selectedCategory == 'ALL'
        ? allEvidence
        : allEvidence.where((e) => e.category == _selectedCategory).toList();

    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Evidence Gallery',
        subtitle: 'Parcel ${widget.task.parcelId} • ${allEvidence.length} Photos',
        showBack: true,
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 48,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _buildFilterChip('ALL', 'All Photos'),
                _buildFilterChip('Parcel Boundary', 'Boundary'),
                _buildFilterChip('Land Condition', 'Land Condition'),
                _buildFilterChip('Existing Structure', 'Structures'),
                _buildFilterChip('Ownership Evidence', 'Ownership'),
                _buildFilterChip('Road / Access', 'Road Access'),
                _buildFilterChip('Other', 'Other'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: filtered.isEmpty
                ? const EmptyStateView(
                    title: 'No Evidence Photos',
                    message: 'Capture field photos using the camera capture screen.',
                    icon: Icons.photo_library_outlined,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ev = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Preview
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.file(
                                  File(ev.localFilePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFFE2E8F0),
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 48, color: AppColors.textMuted),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Details & Actions
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContainer,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          ev.category,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                                        tooltip: 'Delete Photo',
                                        onPressed: () => _confirmDelete(ev),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    ev.description ?? 'Field photograph',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.gps_fixed, size: 12, color: AppColors.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        'GPS: ${ev.latitude?.toStringAsFixed(5) ?? '--'}, ${ev.longitude?.toStringAsFixed(5) ?? '--'} (±${ev.gpsAccuracy?.toStringAsFixed(1) ?? '4.5'}m)',
                                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Captured: ${DateFormatter.formatDateTime(ev.timestamp)}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String categoryKey, String label) {
    final isSelected = _selectedCategory == categoryKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategory = categoryKey),
        backgroundColor: const Color(0xFFF1F5F9),
        selectedColor: AppColors.primaryContainer,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }

  void _confirmDelete(EvidenceModel ev) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo Evidence?'),
        content: const Text('This action will delete the photo and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(fieldVisitControllerProvider.notifier).removePhotoEvidence(ev.photoId, ev.localFilePath);
            },
            child: const Text('DELETE', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
