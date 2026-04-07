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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Post-Mortem Report'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: detailsController,
                    label: 'PM Details',
                    maxLines: 2,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: kitController,
                    label: 'LFA Test Kit No',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: result,
                    decoration: const InputDecoration(labelText: 'Result'),
                    items: ['Positive', 'Negative'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => result = val!),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Sample Collected'),
                    value: sampleCollected,
                    onChanged: (val) => setState(() => sampleCollected = val),
                  ),
                  CustomTextField(
                    controller: sampleSentController,
                    label: 'Sample Sent To',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                notifier.toggleDeathStatus(false);
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final report = DeathReportModel(
                    daysQuarantined: int.tryParse(daysController.text) ?? 0,
                    dateOfDeath: dateController.text,
                    pmDetails: detailsController.text,
                    lfaTestKitNo: kitController.text,
                    result: result,
                    sampleCollected: sampleCollected,
                    sampleSentTo: sampleSentController.text,
                  );
                  notifier.setDeathReport(report);
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit Report'),
            ),
          ],
        ),
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
          onChanged: (val) {
            notifier.toggleDeathStatus(val ?? false);
            if (val == true) {
              _showPMReportDialog(context, ref);
            }
          },
        ),
        if (state.deathReport != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PM Report Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Date of Death: ${state.deathReport!.dateOfDeath}'),
                    Text('Result: ${state.deathReport!.result}'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
