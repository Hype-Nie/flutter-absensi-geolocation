import 'package:get_storage/get_storage.dart';

class StorageService {
  late final GetStorage _storage;

  StorageService() {
    _storage = GetStorage();
  }

  // Keys
  static const String keyToken = 'token';
  static const String keyUserId = 'user_id';
  static const String keyUser = 'user';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyRememberMe = 'remember_me';

  // Token
  Future<void> saveToken(String token) async {
    await _storage.write(keyToken, token);
  }

  String? getToken() {
    return _storage.read(keyToken);
  }

  Future<void> removeToken() async {
    await _storage.remove(keyToken);
  }

  // User ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(keyUserId, userId);
  }

  String? getUserId() {
    return _storage.read(keyUserId);
  }

  Future<void> removeUserId() async {
    await _storage.remove(keyUserId);
  }

  // User Data
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(keyUser, user);
  }

  Map<String, dynamic>? getUser() {
    return _storage.read(keyUser);
  }

  Future<void> removeUser() async {
    await _storage.remove(keyUser);
  }

  // Login Status
  Future<void> setLoggedIn(bool value) async {
    await _storage.write(keyIsLoggedIn, value);
  }

  bool isLoggedIn() {
    return _storage.read(keyIsLoggedIn) ?? false;
  }

  // Remember Me
  Future<void> setRememberMe(bool value) async {
    await _storage.write(keyRememberMe, value);
  }

  bool getRememberMe() {
    return _storage.read(keyRememberMe) ?? false;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.erase();
  }
}
