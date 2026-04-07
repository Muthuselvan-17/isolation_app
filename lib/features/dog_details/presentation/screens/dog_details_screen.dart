import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rabis_abc_center/features/dog_details/presentation/providers/dog_details_notifier.dart';
import 'package:rabis_abc_center/features/dashboard/data/models/dog_model.dart';
import 'package:rabis_abc_center/common/widgets/custom_text_field.dart';
import 'package:rabis_abc_center/features/dog_details/presentation/screens/widgets/feeding_section.dart';
import 'package:rabis_abc_center/features/dog_details/presentation/screens/widgets/death_section.dart';

class DogDetailsScreen extends ConsumerStatefulWidget {
  final DogModel dog;

  const DogDetailsScreen({super.key, required this.dog});

  @override
  ConsumerState<DogDetailsScreen> createState() => _DogDetailsScreenState();
}

class _DogDetailsScreenState extends ConsumerState<DogDetailsScreen> {
  late final TextEditingController _roomController;
  late final TextEditingController _microchipController;
  late final TextEditingController _identificationController;
  late final TextEditingController _symptomsController;
  late final TextEditingController _vaccinationDateController;
  late final TextEditingController _sterilizationDateController;

  @override
  void initState() {
    super.initState();
    _roomController = TextEditingController(text: widget.dog.roomNumber?.toString() ?? '');
    _microchipController = TextEditingController(text: widget.dog.microchipId ?? '');
    _identificationController = TextEditingController(text: widget.dog.identification ?? '');
    _symptomsController = TextEditingController(text: widget.dog.symptoms ?? '');
    _vaccinationDateController = TextEditingController(text: widget.dog.dateOfBirth ?? ''); // Assuming DOB for now
    _sterilizationDateController = TextEditingController(text: widget.dog.isSterilized ? 'Sterilized' : '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dogDetailsProvider.notifier).loadDog(widget.dog.id);
    });
  }

  @override
  void dispose() {
    _roomController.dispose();
    _microchipController.dispose();
    _identificationController.dispose();
    _symptomsController.dispose();
    _vaccinationDateController.dispose();
    _sterilizationDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dogDetailsProvider);

    ref.listen<DogDetailsState>(dogDetailsProvider, (previous, next) {
      if (next.dog != null && (previous?.isLoading == true && next.isLoading == false)) {
        final dog = next.dog!;
        _roomController.text = dog.roomNumber?.toString() ?? '';
        _microchipController.text = dog.microchipId ?? '';
        _identificationController.text = dog.identification ?? '';
        _symptomsController.text = dog.symptoms ?? '';
        _vaccinationDateController.text = dog.isolatedvaccinationDate ?? '';
        
        // Prioritize actual date, then fallback to boolean label
        if (dog.sterilizationDate != null && dog.sterilizationDate!.isNotEmpty) {
          _sterilizationDateController.text = dog.sterilizationDate!;
        } else {
          _sterilizationDateController.text = dog.isSterilized ? 'Sterilized' : '';
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Observation Details'),
        actions: [
          if (!state.isMarkedAsDeath && state.deathReport == null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                final feedingHistory = ref.read(feedingProvider).history;
                await ref.read(dogDetailsProvider.notifier).submitObservationRecord(
                      roomNumber: int.tryParse(_roomController.text),
                      microchipId: _microchipController.text,
                      identification: _identificationController.text,
                      symptoms: _symptomsController.text,
                      feedingHistory: feedingHistory,
                      vaccinationDate: _vaccinationDateController.text,
                      sterilizationDate: _sterilizationDateController.text,
                    );
                if (context.mounted && state.error == null) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Observation saved successfully')),
                  );
                }
              },
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _roomController,
                        label: 'Room Number',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _microchipController,
                        label: 'Microchip ID (Optional)',
                        readOnly: true,
                        fillColor: Colors.grey[100],
                      ),
                      const SizedBox(height: 16),
                      const Text('Symptoms on Receiving', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _symptomsController,
                        label: 'Symptoms details',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      const Text('Physical Identification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _identificationController,
                        label: 'Color, marks, etc.',
                        maxLines: 2,
                      ),
                      const Divider(height: 48),
                      const FeedingSection(),
                      const Divider(height: 48),
                      const DeathSection(),
                      const Divider(height: 48),
                      const Text('Additional Fields', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _vaccinationDateController,
                        label: 'Vaccination Date',
                        hint: 'YYYY-MM-DD',
                        readOnly: true,
                        onTap: () => _selectDate(context, _vaccinationDateController),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _sterilizationDateController,
                        label: 'Sterilization Status/Date',
                        hint: 'Sterilized / YYYY-MM-DD',
                        readOnly: true,
                        onTap: () => _selectDate(context, _sterilizationDateController),
                      ),
                      const SizedBox(height: 32),
                      if (!state.isMarkedAsDeath && state.deathReport == null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final feedingHistory = ref.read(feedingProvider).history;
                              await ref.read(dogDetailsProvider.notifier).submitObservationRecord(
                                    roomNumber: int.tryParse(_roomController.text),
                                    microchipId: _microchipController.text,
                                    identification: _identificationController.text,
                                    symptoms: _symptomsController.text,
                                    feedingHistory: feedingHistory,
                                    vaccinationDate: _vaccinationDateController.text,
                                    sterilizationDate: _sterilizationDateController.text,
                                  );
                              if (context.mounted && state.error == null) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      state.shelterId != null
                                          ? 'Observation updated successfully'
                                          : 'Observation saved successfully',
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              state.shelterId != null ? 'Update Observation Record' : 'Save Observation Record',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (state.dog?.isActive == true)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Discharge'),
                                    content: const Text('Are you sure you want to discharge this dog?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Discharge', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && context.mounted) {
                                  await ref.read(dogDetailsProvider.notifier).discharge();
                                  if (context.mounted && state.error == null) {
                                    Navigator.pop(context); // Go back to Dashboard after discharge
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Dog discharged successfully')),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Discharge Dog', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        if (state.dog?.isActive == false)
                          const Center(
                            child: Chip(
                              label: Text('Already Discharged'),
                              backgroundColor: Colors.grey,
                            ),
                          ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}
