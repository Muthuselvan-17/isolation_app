import 'dart:convert';
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

  DogDetailsState({
    this.dog,
    this.isMarkedAsDeath = false,
    this.deathReport,
    this.isLoading = false,
    this.error,
  });

  DogDetailsState copyWith({
    DogModel? dog,
    bool? isMarkedAsDeath,
    DeathReportModel? deathReport,
    bool? isLoading,
    String? error,
  }) {
    return DogDetailsState(
      dog: dog ?? this.dog,
      isMarkedAsDeath: isMarkedAsDeath ?? this.isMarkedAsDeath,
      deathReport: deathReport ?? this.deathReport,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DogDetailsNotifier extends StateNotifier<DogDetailsState> {
  final ApiService _apiService;

  DogDetailsNotifier(this._apiService) : super(DogDetailsState());

  Future<void> loadDog(String dogId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get('/api/v1/fauna/stray-dogs/$dogId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dog = DogModel.fromJson(data['data']);
        state = state.copyWith(dog: dog, isLoading: false);
      } else {
        throw 'Failed to load dog details: ${response.statusCode}';
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleDeathStatus(bool isDeath) {
    state = state.copyWith(isMarkedAsDeath: isDeath);
  }

  void setDeathReport(DeathReportModel report) {
    state = state.copyWith(deathReport: report);
  }

  Future<void> discharge() async {
    if (state.dog == null) return;
    state = state.copyWith(isLoading: true);
    try {
      await _apiService.post('/api/v1/fauna/stray-dogs/${state.dog!.id}/discharge', {});
      state = state.copyWith(
        dog: state.dog!.copyWith(isActive: false),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Discharge failed');
    }
  }
}

final dogDetailsProvider = StateNotifierProvider.autoDispose<DogDetailsNotifier, DogDetailsState>((ref) {
  return DogDetailsNotifier(apiServiceProvider);
});

// Feeding Behaviour Provider
class FeedingState {
  final List<FeedingModel> history;
  FeedingState({this.history = const []});
}

class FeedingNotifier extends StateNotifier<FeedingState> {
  FeedingNotifier() : super(FeedingState(history: [FeedingModel(day: 1)]));

  void addDay() {
    final newDay = state.history.length + 1;
    state = FeedingState(history: [...state.history, FeedingModel(day: newDay)]);
  }

  void updateFeeding(int day, bool? food, bool? water) {
    final newList = state.history.map((f) {
      if (f.day == day) return f.copyWith(food: food, water: water);
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

final feedingProvider = StateNotifierProvider.autoDispose<FeedingNotifier, FeedingState>((ref) {
  return FeedingNotifier();
});
