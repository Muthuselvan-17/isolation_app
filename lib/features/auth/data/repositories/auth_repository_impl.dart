import 'dart:convert';
import 'package:rabis_abc_center/core/network/api_service.dart';
import 'package:rabis_abc_center/features/auth/domain/repositories/auth_repository.dart';
import 'package:rabis_abc_center/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await _apiService.post('/api/v1/iam/login', {
      'username': email,
      'password': password,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final user = UserModel.fromJson(data['data']);
        _apiService.updateToken(user.session);
        return user;
      } else {
        throw data['message'] ?? 'Login failed';
      }
    } else {
      throw 'Failed to login: ${response.statusCode}';
    }
  }

  @override
  Future<void> logout() async {
    _apiService.updateToken('');
  }
}
