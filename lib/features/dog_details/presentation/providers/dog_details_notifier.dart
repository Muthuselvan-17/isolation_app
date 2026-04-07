import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rabis_abc_center/core/network/api_service.dart';
import 'package:rabis_abc_center/features/dashboard/data/models/dog_model.dart';
import 'package:rabis_abc_center/features/dog_details/data/models/feeding_model.dart';
import 'package:rabis_abc_center/features/dog_details/data/models/death_report_model.dart';

class DogDetailsState {
  final DogModel? dog;
  final bool isMarkedAsDeath;
  final DeathReportModel? deathReport;
  final bool isLoading;
  final String? error;
  final int? shelterId;

  DogDetailsState({
    this.dog,
    this.isMarkedAsDeath = false,
    this.deathReport,
    this.isLoading = false,
    this.error,
    this.shelterId,
  });

  DogDetailsState copyWith({
    DogModel? dog,
    bool? isMarkedAsDeath,
    DeathReportModel? deathReport,
    bool? isLoading,
    String? error,
    int? shelterId,
    bool clearDeathReport = false,
    bool clearError = false,
    bool clearShelterId = false,
  }) {
    return DogDetailsState(
      dog: dog ?? this.dog,
      isMarkedAsDeath: isMarkedAsDeath ?? this.isMarkedAsDeath,
      deathReport: clearDeathReport ? null : (deathReport ?? this.deathReport),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      shelterId: clearShelterId ? null : (shelterId ?? this.shelterId),
    );
  }
}

class DogDetailsNotifier extends StateNotifier<DogDetailsState> {
  final ApiService _apiService;
  final Ref _ref;

  DogDetailsNotifier(this._apiService, this._ref) : super(DogDetailsState());

  void setInitialDog(DogModel dog) {
    state = DogDetailsState(dog: dog);
    // Also reset feeding history for the new dog
    _ref.read(feedingProvider.notifier).setHistory([]);
  }

  String? _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return null;
    try {
      final dateTime = DateTime.parse(date.toString());
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }

  Future<void> loadDog(String dogId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get('/api/v1/fauna-shelter/$dogId');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final shelter = data['shelter'];
          final deathReportData = data['deathReport'];

          // Use fauna data from shelter or fallback to what we have
          final faunaData = shelter != null ? shelter['fauna'] : null;
          DogModel? dog;
          if (faunaData != null) {
            dog = DogModel.fromJson(faunaData);
          } else {
            dog = state.dog;
          }

          if (dog != null && shelter != null) {
            // Merge shelter data into dog model
            dog = dog.copyWith(
              id: dogId, // Keep original ID
              roomNumber: shelter['roomNumber'] as int?,
              identification: (shelter['identification']?.toString().isNotEmpty == true)
                  ? shelter['identification'].toString()
                  : dog.identification,
              symptoms: shelter['symptoms']?.toString(),
              microchipId: (shelter['microchipId']?.toString().isNotEmpty == true)
                  ? shelter['microchipId'].toString()
                  : dog.microchipId,
              isolatedvaccinationDate: _formatDate(shelter['isolatedvaccinationDate']),
              sterilizationDate: _formatDate(shelter['sterilizationDate']),
            );

            // Update Feeding History if available
            if (shelter['feedingHistory'] != null) {
              final List<dynamic> historyJson = shelter['feedingHistory'];
              final history = historyJson.map((e) => FeedingModel.fromJson(e)).toList();
              _ref.read(feedingProvider.notifier).setHistory(history);
            }
          }

          DeathReportModel? deathReport;
          if (deathReportData != null) {
            deathReport = DeathReportModel.fromJson(deathReportData);
          }

          state = state.copyWith(
            dog: dog,
            deathReport: deathReport,
            clearDeathReport: deathReport == null,
            isMarkedAsDeath: deathReport != null,
            isLoading: false,
            shelterId: shelter != null ? shelter['id'] as int? : null,
            clearShelterId: (shelter == null || shelter['id'] == null),
          );
          print('DogDetailsNotifier: Load complete. ShelterId: ${state.shelterId}');
        } else {
          throw responseData['message'] ?? 'Failed to load dog details';
        }
      } else {
        throw 'Failed to load dog details: ${response.statusCode}';
      }
    } catch (e) {
      print('DogDetailsNotifier: Load Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleDeathStatus(bool isDeath) {
    state = state.copyWith(isMarkedAsDeath: isDeath);
  }

  void setDeathReport(DeathReportModel report) {
    state = state.copyWith(deathReport: report);
  }

  Future<void> submitObservationRecord({
    required int? roomNumber,
    required String? microchipId,
    required String? identification,
    required String? symptoms,
    required List<FeedingModel> feedingHistory,
    required String? vaccinationDate,
    required String? sterilizationDate,
  }) async {
    if (state.dog == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payload = {
        "faunaId": state.dog!.id,
        "microchipId": microchipId,
        "identification": identification,
        "symptoms": symptoms,
        "feedingHistory": feedingHistory.map((e) => e.toJson()).toList(),
        "isolatedvaccinationDate": vaccinationDate,
        "sterilizationDate": sterilizationDate,
        "roomNumber": roomNumber,
      };

      print('DogDetailsNotifier: Submitting Payload: $payload');

      if (state.shelterId != null) {
        print('DogDetailsNotifier: Patching existing record ${state.shelterId}');
        await _apiService.patch('/api/v1/fauna-shelter/shelter/${state.shelterId}', payload);
      } else {
        print('DogDetailsNotifier: Saving new record');
        await _apiService.post('/api/v1/fauna-shelter/shelter', payload);
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('DogDetailsNotifier: Submit Error: $e');
      state = state.copyWith(isLoading: false, error: 'Observation submission failed');
    }
  }

  Future<void> submitPMRecord(DeathReportModel report) async {
    if (state.dog == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final faunaId = state.dog!.id;
      final payload = report.toJson();
      payload['faunaId'] = faunaId;

      // 1. Submit the death report to the shelter system
      await _apiService.post('/api/v1/fauna-shelter/death-report', payload);

      // 2. Update the fauna-tracker intake status
      await _apiService.post(
        '/api/v1/fauna-tracker/abc-intake/fauna/$faunaId',
        {},
        {'type': 'ABC_DESEASED'},
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'PM Record submission failed');
      rethrow;
    }
  }

  Future<void> discharge() async {
    if (state.dog == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final faunaId = state.dog!.id;

      // 1. Original Shelter Discharge
      await _apiService.post('/api/v1/fauna/stray-dogs/$faunaId/discharge', {});

      // 2. Intake Tracker Release Update
      await _apiService.post(
        '/api/v1/fauna-tracker/abc-intake/fauna/$faunaId',
        {},
        {'type': 'READY_TO_RELEASE'},
      );

      state = state.copyWith(
        dog: state.dog!.copyWith(isActive: false),
        isLoading: false,
      );
    } catch (e) {
      print('DogDetailsNotifier: Discharge Error: $e');
      state = state.copyWith(isLoading: false, error: 'Discharge failed');
    }
  }
}

final dogDetailsProvider = StateNotifierProvider<DogDetailsNotifier, DogDetailsState>((ref) {
  return DogDetailsNotifier(apiServiceProvider, ref);
});

// Feeding Behaviour Provider
class FeedingState {
  final List<FeedingModel> history;
  FeedingState({this.history = const []});
}

class FeedingNotifier extends StateNotifier<FeedingState> {
  FeedingNotifier() : super(FeedingState(history: [FeedingModel(day: 1)]));

  void setHistory(List<FeedingModel> history) {
    if (history.isEmpty) {
      state = FeedingState(history: [FeedingModel(day: 1)]);
    } else {
      state = FeedingState(history: history);
    }
  }

  void addDay() {
    final newDay = state.history.length + 1;
    state = FeedingState(history: [...state.history, FeedingModel(day: newDay)]);
  }

  void updateFeeding(int day, {bool? food, bool? water, String? status}) {
    final newList = state.history.map<FeedingModel>((f) {
      if (f.day == day) {
        return f.copyWith(
          food: food,
          water: water,
          status: status,
        );
      }
      return f;
    }).toList();
    state = FeedingState(history: newList);
  }

  void removeDay(int day) {
    final filtered = state.history.where((f) => f.day != day).toList();
    // Re-index days to maintain sequence Day 1, Day 2, etc.
    final updated = filtered.asMap().entries.map((entry) {
      final index = entry.key;
      final feeding = entry.value;
      return feeding.copyWith(day: index + 1);
    }).toList();
    state = FeedingState(history: updated);
  }
}

final feedingProvider = StateNotifierProvider<FeedingNotifier, FeedingState>((ref) {
  return FeedingNotifier();
});
