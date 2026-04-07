import 'package:rabis_abc_center/features/dashboard/data/models/dog_model.dart';

abstract class DogRepository {
  Future<List<DogModel>> getDogs({String? ephemeralId});
  Future<void> updateDogStatus(String dogId, String status);
}
