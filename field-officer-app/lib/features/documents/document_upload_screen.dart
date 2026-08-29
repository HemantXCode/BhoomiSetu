import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/field_task_model.dart';
import '../../data/models/field_visit_model.dart';
import '../../data/models/document_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/routing/app_router.dart';
import '../field_visit/field_visit_controller.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  final FieldTaskModel task;
  final FieldVisitModel visit;

  const DocumentUploadScreen({super.key, required this.task, required this.visit});

  @override
  ConsumerState<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  bool _isPicking = false;

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.isNotEmpty) {
        final picked = result.first;
        final doc = DocumentModel(
          documentId: 'DOC-${const Uuid().v4().substring(0, 8).toUpperCase()}',
          visitId: widget.visit.visitId,
          parcelId: widget.task.parcelId,
          fileName: picked.name,
          fileType: picked.name.split('.').last.toUpperCase(),
          fileSizeBytes: 102400,
          localFilePath: picked.path ?? 'mock_path/${picked.name}',
          uploadStatus: 'PENDING_UPLOAD',
          syncStatus: 'PENDING',
        );

        await ref.read(fieldVisitControllerProvider.notifier).addDocument(doc);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Document "${picked.name}" attached.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File selection note: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  void _addSampleCadastralDocument() async {
    final doc = DocumentModel(
      documentId: 'DOC-${const Uuid().v4().substring(0, 8).toUpperCase()}',
      visitId: widget.visit.visitId,
      parcelId: widget.task.parcelId,
      fileName: '7-12_Extract_Survey_${widget.task.surveyNumber.replaceAll('/', '_')}.pdf',
      fileType: 'PDF',
      fileSizeBytes: 245000,
      localFilePath: 'internal_docs/7_12_extract.pdf',
      uploadStatus: 'PENDING_UPLOAD',
      syncStatus: 'PENDING',
    );
    await ref.read(fieldVisitControllerProvider.notifier).addDocument(doc);
  }

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(fieldVisitControllerProvider);
    final documents = visitState.visit?.documents ?? [];

    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Document Upload',
        subtitle: 'Parcel ${widget.task.parcelId}',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Prompt Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.upload_file, size: 28, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Attach Survey & Legal Records', style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    const Text(
                      'Attach 7/12 land records, Aadhaar consent, mutation entries, or objections.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: BhoomiButton(
                            text: 'CHOOSE DOCUMENT',
                            icon: Icons.attach_file,
                            isLoading: _isPicking,
                            onPressed: _pickFile,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _addSampleCadastralDocument,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text('Add 7/12', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Attached Documents List
            Text('Attached Documents (${documents.length})', style: AppTextStyles.h3),
            const SizedBox(height: 10),

            if (documents.isEmpty)
              const EmptyStateView(
                title: 'No Documents Attached',
                message: 'Supporting documents are optional but recommended for statutory verification.',
                icon: Icons.folder_open_outlined,
              )
            else
              ...documents.map((doc) => _buildDocumentCard(context, doc)),

            const SizedBox(height: 24),

            // Next CTA: Review & Submit
            BhoomiButton(
              text: 'PROCEED TO REVIEW & SUBMIT',
              icon: Icons.rate_review_outlined,
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.reviewSubmit,
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

  Widget _buildDocumentCard(BuildContext context, DocumentModel doc) {
    IconData icon = Icons.insert_drive_file;
    Color color = AppColors.secondary;

    if (doc.fileType == 'PDF') {
      icon = Icons.picture_as_pdf;
      color = Colors.red.shade700;
    } else if (doc.fileType == 'JPG' || doc.fileType == 'PNG') {
      icon = Icons.image;
      color = Colors.blue.shade700;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          doc.fileName,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${doc.fileType} • ${doc.formattedSize} • Status: ${doc.uploadStatus}',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
          onPressed: () {
            ref.read(fieldVisitControllerProvider.notifier).removeDocument(doc.documentId);
          },
        ),
      ),
    );
  }
}
