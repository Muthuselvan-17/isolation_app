import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rabis_abc_center/core/network/api_service.dart';
import 'package:rabis_abc_center/features/dashboard/data/models/dog_model.dart';
import 'package:rabis_abc_center/features/dashboard/data/repositories/dog_repository_impl.dart';
import 'package:rabis_abc_center/features/dashboard/domain/repositories/dog_repository.dart';

class DashboardState {
  final List<DogModel> dogs;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.dogs = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    List<DogModel>? dogs,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      dogs: dogs ?? this.dogs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DogRepository _repository;

  DashboardNotifier(this._repository) : super(DashboardState());

  Future<void> loadDogs({String? ephemeralId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dogs = await _repository.getDogs(ephemeralId: ephemeralId);
      state = state.copyWith(dogs: dogs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dogRepositoryProvider = Provider<DogRepository>((ref) {
  return DogRepositoryImpl(apiServiceProvider);
});

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dogRepositoryProvider);
  return DashboardNotifier(repository);
});
