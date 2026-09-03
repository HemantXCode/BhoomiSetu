import 'package:flutter/material.dart';
import 'package:field_officer_app/core/theme/app_colors.dart';
import 'package:field_officer_app/data/models/land_parcel_model.dart';
import 'package:field_officer_app/data/models/project_corridor_model.dart';

class ULPINSearchModal extends StatefulWidget {
  final List<LandParcelModel> allParcels;
  final ValueChanged<LandParcelModel> onSelectParcel;

  const ULPINSearchModal({
    super.key,
    required this.allParcels,
    required this.onSelectParcel,
  });

  @override
  State<ULPINSearchModal> createState() => _ULPINSearchModalState();
}

class _ULPINSearchModalState extends State<ULPINSearchModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<LandParcelModel> _results = [];

  @override
  void initState() {
    super.initState();
    _results = widget.allParcels;
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() => _results = widget.allParcels);
      return;
    }
    final q = query.trim().toUpperCase();
    setState(() {
      _results = widget.allParcels.where((p) {
        return p.ulpin.toUpperCase().contains(q) ||
            p.surveyNumber.toUpperCase().contains(q) ||
            p.village.toUpperCase().contains(q) ||
            p.ownerName.toUpperCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Search Cadastral Parcels',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by ULPIN, Survey No, Village...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primary),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Quick Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickFilter('Urse'),
                  _buildQuickFilter('Hinjawadi'),
                  _buildQuickFilter('Lavale'),
                  _buildQuickFilter('Bhugaon'),
                  _buildQuickFilter('Dhayari'),
                  _buildQuickFilter('1024'),
                ],
              ),
            ),
          ),

          const Divider(height: 12),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_results.length} PARCELS FOUND',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const Text(
                  'Prototype GIS Dataset',
                  style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Text(
                      'No matching parcels found',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, idx) {
                      final p = _results[idx];
                      final statusEnum = AcquisitionStatus.fromString(p.status);

                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: statusEnum.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusEnum.color.withValues(alpha: 0.3)),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.location_on,
                              size: 20,
                              color: statusEnum.color,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              p.ulpin,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: statusEnum.backgroundColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusEnum.label,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: statusEnum.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${p.surveyNumber} • ${p.village} (${p.district}) • ${p.areaHectares.toStringAsFixed(2)} Ha',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onSelectParcel(p);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilter(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label),
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary),
        backgroundColor: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        onPressed: () {
          _searchCtrl.text = label;
          _onSearchChanged(label);
        },
      ),
    );
  }
}
