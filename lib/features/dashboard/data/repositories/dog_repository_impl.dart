import 'dart:convert';
import 'package:rabis_abc_center/core/network/api_service.dart';
import 'package:rabis_abc_center/features/dashboard/domain/repositories/dog_repository.dart';
import 'package:rabis_abc_center/features/dashboard/data/models/dog_model.dart';

class DogRepositoryImpl implements DogRepository {
  final ApiService _apiService;

  DogRepositoryImpl(this._apiService);

  @override
  Future<List<DogModel>> getDogs({String? ephemeralId}) async {
    final queryParams = <String, String>{};
    if (ephemeralId != null && ephemeralId.isNotEmpty) {
      queryParams['ephemeralId'] = ephemeralId;

      // SEARCH Logic (Add button / Scanner)
      final response = await _apiService.get('/api/v1/fauna/stray-dogs', queryParams);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic>? list = data['data']?['data'];
          if (list == null) return [];
          return list.map((e) => DogModel.fromJson(e)).toList();
        } else {
          throw data['message'] ?? 'Search failed';
        }
      } else {
        throw 'Search failed: ${response.statusCode}';
      }
    } else {
      // MAIN DASHBOARD Logic (Ring Vaccination)
      final response = await _apiService.get('/api/v1/ring-vaccination/faunas/with-ring-vaccination', queryParams);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic>? list = data['data'];
          if (list == null) return [];
          return list
              .where((e) => e['fauna'] != null)
              .map((e) => DogModel.fromJson(e['fauna']))
              .toList();
        } else {
          throw data['message'] ?? 'Failed to fetch dashboard';
        }
      } else {
        throw 'Failed to fetch dashboard: ${response.statusCode}';
      }
    }
  }

  @override
  Future<void> updateDogStatus(String dogId, String status) async {
    await _apiService.post('/api/v1/fauna/update-status', {
      'dogId': dogId,
      'status': status,
    });
  }
}
