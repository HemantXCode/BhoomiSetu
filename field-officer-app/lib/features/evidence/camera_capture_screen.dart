import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/field_task_model.dart';
import '../../data/models/field_visit_model.dart';
import '../../data/models/evidence_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/providers/app_providers.dart';
import '../../core/routing/app_router.dart';
import '../field_visit/field_visit_controller.dart';
import '../auth/auth_controller.dart';

class CameraCaptureScreen extends ConsumerStatefulWidget {
  final FieldTaskModel task;
  final FieldVisitModel visit;

  const CameraCaptureScreen({super.key, required this.task, required this.visit});

  @override
  ConsumerState<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  File? _capturedImage;
  String _selectedCategory = 'Parcel Boundary';
  final _descriptionController = TextEditingController();
  bool _isProcessing = false;

  final List<String> _categories = [
    'Parcel Boundary',
    'Land Condition',
    'Existing Structure',
    'Ownership Evidence',
    'Road / Access',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    setState(() => _isProcessing = true);
    final file = await ref.read(cameraServiceProvider).takePhoto();
    setState(() {
      _capturedImage = file;
      _isProcessing = false;
    });
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isProcessing = true);
    final file = await ref.read(cameraServiceProvider).pickFromGallery();
    setState(() {
      _capturedImage = file;
      _isProcessing = false;
    });
  }

  Future<void> _saveEvidence() async {
    if (_capturedImage == null) return;

    final visitState = ref.read(fieldVisitControllerProvider);
    final officer = ref.read(authControllerProvider).user;

    final evidence = EvidenceModel(
      photoId: 'PHO-${const Uuid().v4().substring(0, 8).toUpperCase()}',
      visitId: widget.visit.visitId,
      parcelId: widget.task.parcelId,
      officerId: officer?.officerId ?? 'FO-MH-PUN-0842',
      timestamp: DateTime.now(),
      latitude: visitState.currentGps?.latitude ?? widget.task.latitude,
      longitude: visitState.currentGps?.longitude ?? widget.task.longitude,
      gpsAccuracy: visitState.currentGps?.accuracy ?? 4.5,
      category: _selectedCategory,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Photographic evidence captured on site.',
      localFilePath: _capturedImage!.path,
      syncStatus: 'PENDING',
    );

    await ref.read(fieldVisitControllerProvider.notifier).addPhotoEvidence(evidence);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo evidence saved successfully.')),
      );

      setState(() {
        _capturedImage = null;
        _descriptionController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(fieldVisitControllerProvider);
    final evidenceList = visitState.visit?.evidence ?? [];

    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Evidence Capture',
        subtitle: 'Parcel ${widget.task.parcelId}',
        showBack: true,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.photo_library, color: Colors.white, size: 18),
            label: Text(
              'Gallery (${evidenceList.length})',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.evidenceGallery,
                arguments: {'task': widget.task, 'visit': widget.visit},
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview & Viewfinder Box
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: _capturedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_capturedImage!, fit: BoxFit.cover),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                onPressed: () => setState(() => _capturedImage = null),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'GPS: ${widget.task.latitude.toStringAsFixed(4)}, ${widget.task.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 11, color: Colors.white, fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white10,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 48, color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Capture Clear On-Site Photograph',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Corner stones, boundary markers, or structures',
                            style: TextStyle(fontSize: 12, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Capture Trigger Buttons
            Row(
              children: [
                Expanded(
                  child: BhoomiButton(
                    text: 'OPEN CAMERA',
                    icon: Icons.camera_alt,
                    isLoading: _isProcessing,
                    onPressed: _takePhoto,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BhoomiButton(
                    text: 'CHOOSE PHOTO',
                    type: ButtonType.outline,
                    icon: Icons.photo_library_outlined,
                    onPressed: _pickFromGallery,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Evidence Metadata Tagging Form
            if (_capturedImage != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Evidence Tagging & Classification', style: AppTextStyles.h3),
                      const SizedBox(height: 12),
                      const Text('Photo Category *', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val ?? _selectedCategory),
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                      ),
                      const SizedBox(height: 12),
                      const Text('Description / Marker Notes', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'e.g. North-west corner survey stone #48/2A',
                        ),
                      ),
                      const SizedBox(height: 16),
                      BhoomiButton(
                        text: 'ATTACH PHOTO TO REPORT',
                        icon: Icons.add_photo_alternate,
                        onPressed: _saveEvidence,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Current Evidence List Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Captured Evidence (${evidenceList.length})', style: AppTextStyles.h3),
                        if (evidenceList.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.evidenceGallery,
                                arguments: {'task': widget.task, 'visit': widget.visit},
                              );
                            },
                            child: const Text('Manage All', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                    const Divider(height: 16),
                    if (evidenceList.isEmpty)
                      const Text(
                        'No photos captured yet. Take at least 1 boundary photo.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      )
                    else
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: evidenceList.length,
                          itemBuilder: (context, index) {
                            final ev = evidenceList[index];
                            return Container(
                              width: 90,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(ev.localFilePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.image, color: AppColors.textMuted),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Next CTA: Documents Upload
            BhoomiButton(
              text: 'PROCEED TO DOCUMENT UPLOAD',
              icon: Icons.description_outlined,
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.documentUpload,
                  arguments: {'task': widget.task, 'visit': widget.visit},
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
