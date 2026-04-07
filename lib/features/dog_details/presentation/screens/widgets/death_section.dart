import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rabis_abc_center/features/dog_details/presentation/providers/dog_details_notifier.dart';
import 'package:rabis_abc_center/features/dog_details/data/models/death_report_model.dart';
import 'package:rabis_abc_center/common/widgets/custom_text_field.dart';

class DeathSection extends ConsumerWidget {
  const DeathSection({super.key});

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _showPMReportDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dogDetailsProvider.notifier);
    final formKey = GlobalKey<FormState>();

    final daysController = TextEditingController();
    final dateController = TextEditingController();
    final detailsController = TextEditingController();
    final kitController = TextEditingController();
    final sampleSentController = TextEditingController();
    String result = 'Negative';
    bool sampleCollected = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            ),
            child: const Row(
              children: [
                Icon(Icons.report_gmailerrorred_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('PM Report Entry', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('General Information', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: daysController,
                    label: 'No of Days Quarantined',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: dateController,
                    label: 'Date of Death',
                    hint: 'YYYY-MM-DD',
                    readOnly: true,
                    onTap: () => _selectDate(context, dateController),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const Divider(height: 32),
                  const Text('Test Results', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: kitController,
                    label: 'LFA Test Kit No',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: result,
                    decoration: InputDecoration(
                      labelText: 'Test Result',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['Positive', 'Negative'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => result = val!),
                  ),
                  const Divider(height: 32),
                  const Text('Lab Sample', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sample Collected'),
                    value: sampleCollected,
                    activeThumbColor: Colors.redAccent,
                    onChanged: (val) => setState(() => sampleCollected = val),
                  ),
                  if (sampleCollected)
                    CustomTextField(
                      controller: sampleSentController,
                      label: 'Sample Sent To',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  const Divider(height: 32),
                  const Text('Additional Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: detailsController,
                    label: 'Clinical Observation / PM Details',
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () {
                notifier.toggleDeathStatus(false);
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final report = DeathReportModel(
                    daysQuarantined: int.tryParse(daysController.text) ?? 0,
                    dateOfDeath: dateController.text,
                    pmDetails: detailsController.text,
                    lfaTestKitNo: kitController.text,
                    result: result,
                    sampleCollected: sampleCollected,
                    sampleSentTo: sampleCollected ? sampleSentController.text : 'N/A',
                  );

                  try {
                    await notifier.submitPMRecord(report);
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to Dashboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PM Record submitted successfully')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit PM Record'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? (value == 'Positive' ? Colors.red : Colors.green) : Colors.black87,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dogDetailsProvider);
    final notifier = ref.read(dogDetailsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Death Section', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        CheckboxListTile(
          title: const Text('Mark as Death'),
          value: state.isMarkedAsDeath,
          onChanged: state.deathReport != null ? null : (val) {
            notifier.toggleDeathStatus(val ?? false);
            if (val == true) {
              _showPMReportDialog(context, ref);
            }
          },
        ),
        if (state.deathReport != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment_turned_in_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text('PM Report Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent)),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildSummaryItem('Days Quarantined', '${state.deathReport!.daysQuarantined}'),
                  _buildSummaryItem('Date of Death', state.deathReport!.dateOfDeath),
                  _buildSummaryItem('Kit No', state.deathReport!.lfaTestKitNo),
                  _buildSummaryItem('Result', state.deathReport!.result, isBold: true),
                  _buildSummaryItem('Sample Collected', state.deathReport!.sampleCollected ? 'Yes' : 'No'),
                  if (state.deathReport!.sampleCollected)
                    _buildSummaryItem('Sample Sent To', state.deathReport!.sampleSentTo),
                  const SizedBox(height: 8),
                  const Text('Observations:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13)),
                  Text(state.deathReport!.pmDetails, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
