import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rabis_abc_center/features/dog_details/presentation/providers/dog_details_notifier.dart';
import 'package:rabis_abc_center/common/widgets/custom_text_field.dart';
import 'package:rabis_abc_center/features/dog_details/presentation/screens/widgets/feeding_section.dart';
import 'package:rabis_abc_center/features/dog_details/presentation/screens/widgets/death_section.dart';

class DogDetailsScreen extends ConsumerStatefulWidget {
  final String? dogId;

  const DogDetailsScreen({super.key, this.dogId});

  @override
  ConsumerState<DogDetailsScreen> createState() => _DogDetailsScreenState();
}

class _DogDetailsScreenState extends ConsumerState<DogDetailsScreen> {
  late final TextEditingController _microchipController;
  late final TextEditingController _symptomsController;
  late final TextEditingController _vaccinationDateController;
  late final TextEditingController _sterilizationDateController;

  @override
  void initState() {
    super.initState();
    _microchipController = TextEditingController();
    _symptomsController = TextEditingController();
    _vaccinationDateController = TextEditingController();
    _sterilizationDateController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.dogId != null) {
        ref.read(dogDetailsProvider.notifier).loadDog(widget.dogId!).then((_) {
          final dog = ref.read(dogDetailsProvider).dog;
          if (dog != null) {
            _microchipController.text = dog.microchipId ?? '';
            _symptomsController.text = dog.identification ?? '';
            // Using empty or mapping existing fields
            _vaccinationDateController.text = ''; 
            _sterilizationDateController.text = dog.isSterilized ? 'Sterilized' : '';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _microchipController.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dogId != null ? 'Dog Details: ${widget.dogId}' : 'Manual Entry'),
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
                      const Text('Dog Identification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _microchipController,
                        label: 'Microchip ID (Optional)',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _symptomsController,
                        label: 'Symptoms on Receiving (Identification)',
                        maxLines: 3,
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
                      if (state.dog?.isActive == true)
                        ElevatedButton(
                          onPressed: () => ref.read(dogDetailsProvider.notifier).discharge(),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                          child: const Text('Discharge Dog'),
                        ),
                      if (state.dog?.isActive == false)
                        const Center(
                          child: Chip(
                            label: Text('Already Discharged'),
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}
