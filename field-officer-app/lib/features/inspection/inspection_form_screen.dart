import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/field_task_model.dart';
import '../../data/models/field_visit_model.dart';
import '../../data/models/inspection_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/routing/app_router.dart';
import '../field_visit/field_visit_controller.dart';

class InspectionFormScreen extends ConsumerStatefulWidget {
  final FieldTaskModel task;
  final FieldVisitModel visit;

  const InspectionFormScreen({super.key, required this.task, required this.visit});

  @override
  ConsumerState<InspectionFormScreen> createState() => _InspectionFormScreenState();
}

class _InspectionFormScreenState extends ConsumerState<InspectionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Section 1: Parcel Identification
  String _parcelMatches = 'YES';

  // Section 2: Boundary
  String _boundaryIdentified = 'YES';
  String _markersAvailable = 'YES';
  String _boundaryMatchesCadastral = 'YES';

  // Section 3: Land Condition
  String _landUseVerified = 'YES';
  String _physicalConditionVerified = 'YES';
  String _encroachmentChecked = 'YES';

  // Section 4: Ownership
  String _ownershipChecked = 'YES';
  String _documentsReviewed = 'YES';

  // Section 5: Issues
  String _objectionReceived = 'NO';
  String _disputeObserved = 'NO';
  String _encroachmentObserved = 'NO';
  String _otherIssues = 'NO';

  final _remarksController = TextEditingController(text: 'Physical site inspected. Boundaries clear and marked.');
  final _observationsController = TextEditingController(text: 'Ground condition suitable for corridor alignment.');

  @override
  void dispose() {
    _remarksController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveInspection() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all mandatory inspection remarks.')),
      );
      return;
    }

    final inspection = InspectionModel(
      visitId: widget.visit.visitId,
      parcelMatchesRecord: _parcelMatches,
      boundaryIdentified: _boundaryIdentified,
      boundaryMarkersAvailable: _markersAvailable,
      boundaryMatchesCadastral: _boundaryMatchesCadastral,
      landUseVerified: _landUseVerified,
      physicalConditionVerified: _physicalConditionVerified,
      encroachmentChecked: _encroachmentChecked,
      ownershipChecked: _ownershipChecked,
      documentsReviewed: _documentsReviewed,
      objectionReceived: _objectionReceived,
      disputeObserved: _disputeObserved,
      encroachmentObserved: _encroachmentObserved,
      otherIssues: _otherIssues,
      remarks: _remarksController.text.trim(),
      additionalObservations: _observationsController.text.trim(),
      syncStatus: 'PENDING',
    );

    await ref.read(fieldVisitControllerProvider.notifier).saveInspection(inspection);

    if (mounted) {
      Navigator.of(context).pushNamed(
        AppRoutes.cameraCapture,
        arguments: {'task': widget.task, 'visit': widget.visit},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Land Inspection Checklist',
        subtitle: 'ULPIN: ${widget.task.ulpin}',
        showBack: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.assignment_outlined, size: 20, color: AppColors.primaryDark),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Statutory Land Inspection Form under National Land Acquisition Act.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 1: Parcel Identification
              _buildSectionCard(
                'Section 1: Parcel Identification',
                Icons.fingerprint,
                [
                  _buildChecklistItem(
                    'Parcel matches assigned survey record',
                    _parcelMatches,
                    (val) => setState(() => _parcelMatches = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // SECTION 2: Boundary
              _buildSectionCard(
                'Section 2: Boundary & Demarcation',
                Icons.crop_square,
                [
                  _buildChecklistItem(
                    'Boundary identified on ground',
                    _boundaryIdentified,
                    (val) => setState(() => _boundaryIdentified = val),
                  ),
                  _buildChecklistItem(
                    'Boundary markers / stones available',
                    _markersAvailable,
                    (val) => setState(() => _markersAvailable = val),
                  ),
                  _buildChecklistItem(
                    'Boundary matches cadastral map',
                    _boundaryMatchesCadastral,
                    (val) => setState(() => _boundaryMatchesCadastral = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // SECTION 3: Land Condition
              _buildSectionCard(
                'Section 3: Land Condition & Use',
                Icons.landscape_outlined,
                [
                  _buildChecklistItem(
                    'Land use verified (Agricultural / NA)',
                    _landUseVerified,
                    (val) => setState(() => _landUseVerified = val),
                  ),
                  _buildChecklistItem(
                    'Physical condition verified',
                    _physicalConditionVerified,
                    (val) => setState(() => _physicalConditionVerified = val),
                  ),
                  _buildChecklistItem(
                    'Encroachment inspection completed',
                    _encroachmentChecked,
                    (val) => setState(() => _encroachmentChecked = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // SECTION 4: Ownership
              _buildSectionCard(
                'Section 4: Ownership & Legal Review',
                Icons.badge_outlined,
                [
                  _buildChecklistItem(
                    'Ownership information checked',
                    _ownershipChecked,
                    (val) => setState(() => _ownershipChecked = val),
                  ),
                  _buildChecklistItem(
                    'Required 7/12 extract / title reviewed',
                    _documentsReviewed,
                    (val) => setState(() => _documentsReviewed = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // SECTION 5: Issues & Disputes
              _buildSectionCard(
                'Section 5: Objections & Observations',
                Icons.report_problem_outlined,
                [
                  _buildChecklistItem(
                    'Any written objection received?',
                    _objectionReceived,
                    (val) => setState(() => _objectionReceived = val),
                    isIssue: true,
                  ),
                  _buildChecklistItem(
                    'Any boundary dispute observed?',
                    _disputeObserved,
                    (val) => setState(() => _disputeObserved = val),
                    isIssue: true,
                  ),
                  _buildChecklistItem(
                    'Any unauthorized encroachment observed?',
                    _encroachmentObserved,
                    (val) => setState(() => _encroachmentObserved = val),
                    isIssue: true,
                  ),
                  _buildChecklistItem(
                    'Any other legal or environmental issues?',
                    _otherIssues,
                    (val) => setState(() => _otherIssues = val),
                    isIssue: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Remarks & Observations
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Survey Remarks & Observations', style: AppTextStyles.h3),
                      const SizedBox(height: 12),
                      const Text('Field Remarks *', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 2,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Remarks are required' : null,
                        decoration: const InputDecoration(hintText: 'Enter specific field findings...'),
                      ),
                      const SizedBox(height: 12),
                      const Text('Additional Observations', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _observationsController,
                        maxLines: 2,
                        decoration: const InputDecoration(hintText: 'Enter any additional notes for CALA officer...'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // CTA Button
              BhoomiButton(
                text: 'SAVE & CAPTURE EVIDENCE',
                icon: Icons.camera_alt_outlined,
                onPressed: _handleSaveInspection,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.h3,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(
    String label,
    String currentValue,
    Function(String) onChanged, {
    bool isIssue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildChoiceChip('YES', currentValue == 'YES', () => onChanged('YES'), isPositive: !isIssue),
              const SizedBox(width: 8),
              _buildChoiceChip('NO', currentValue == 'NO', () => onChanged('NO'), isPositive: isIssue),
              const SizedBox(width: 8),
              _buildChoiceChip('N/A', currentValue == 'NOT_APPLICABLE', () => onChanged('NOT_APPLICABLE')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap, {bool isPositive = true}) {
    Color selectedColor = isPositive ? AppColors.primary : AppColors.secondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
