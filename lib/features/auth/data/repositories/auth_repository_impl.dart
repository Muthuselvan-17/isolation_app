import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rabis_abc_center/core/network/api_service.dart';
import 'package:rabis_abc_center/features/auth/domain/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  static const String _userKey = 'user_session';

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
        await _saveUser(user);
        return user;
      } else {
        throw data['message'] ?? 'Login failed';
      }
    } else {
      throw 'Failed to login: ${response.statusCode}';
    }
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      final user = UserModel.fromJson(jsonDecode(userStr));
      _apiService.updateToken(user.session);
      return user;
    }
    return null;
  }

  @override
  Future<void> clearStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<void> logout() async {
    _apiService.updateToken('');
    await clearStoredUser();
  }
}
