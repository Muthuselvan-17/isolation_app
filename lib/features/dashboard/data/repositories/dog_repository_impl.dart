import 'dart:convert';
import 'package:rabis_abc_center/core/network/api_service.dart';
import 'package:rabis_abc_center/features/dashboard/domain/repositories/dog_repository.dart';
import 'package:rabis_abc_center/features/dashboard/data/models/dog_model.dart';

class DogRepositoryImpl implements DogRepository {
  final ApiService _apiService;

  DogRepositoryImpl(this._apiService);

  @override
  Future<List<DogModel>> getDogs({String? ephemeralId}) async {
    final queryParams = {
      'page': '1',
      'limit': '10',
    };
    if (ephemeralId != null && ephemeralId.isNotEmpty) {
      queryParams['ephemeralId'] = ephemeralId;
    }

    final response = await _apiService.get('/api/v1/fauna/stray-dogs', queryParams);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> list = data['data']['data'];
        return list.map((e) => DogModel.fromJson(e)).toList();
      } else {
        throw data['message'] ?? 'Failed to fetch dogs';
      }
    } else {
      throw 'Failed to fetch dogs: ${response.statusCode}';
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
