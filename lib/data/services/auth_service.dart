import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/api_provider.dart';
import '../../core/constants/app_endpoints.dart';
import '../../core/utils/logger.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() {
    if (_storageService.isLoggedIn()) {
      final userData = _storageService.getUser();
      if (userData != null) {
        currentUser.value = UserModel.fromJson(userData);
        isLoggedIn.value = true;
      }
    }
  }

  /// Login with NPK and password
  /// Returns the UserModel on success
  /// Throws [DioException] on API errors
  Future<UserModel> login(String npk, String password) async {
    try {
      AppLogger.info('AuthService: Login attempt for NPK: $npk');

      final response = await _apiProvider.post(
        AppEndpoints.login,
        data: {
          'npk': npk,
          'password': password,
        },
      );

      AppLogger.info('AuthService: Login response: ${response.data}');

      // Parse response
      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      final bool success = response.data['success'] ?? false;
      final String message = response.data['message'] ?? 'Login failed';

      if (!success) {
        throw Exception(message);
      }

      final data = response.data['data'];
      if (data == null) {
        throw Exception('No data in response');
      }

      // Extract user data and token
      final userJson = data['user'] as Map<String, dynamic>;
      final token = data['token'] as String;

      // Create UserModel
      final user = UserModel.fromJson(userJson);

      // Save to Storage
      await _storageService.saveUser(userJson);
      await _storageService.saveUserId(user.id);
      await _storageService.saveToken(token);
      await _storageService.setLoggedIn(true);

      // Update State
      currentUser.value = user;
      isLoggedIn.value = true;

      AppLogger.info('AuthService: Login successful for user: ${user.nama} (${user.role})');

      return user;
    } on DioException catch (e) {
      AppLogger.error('AuthService: DioException during login', e, e.stackTrace);

      String errorMessage = 'Login failed';
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'] ?? errorMessage;
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'Invalid NPK or password';
        } else if (e.response?.statusCode == 422) {
          errorMessage = 'Validation error: ${e.response?.data['message'] ?? 'Invalid input'}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection.';
      }

      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error('AuthService: Unexpected error during login', e, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.info('AuthService: Logging out user: ${currentUser.value?.nama}');

      // Call logout API if needed
      final token = _storageService.getToken();
      if (token != null) {
        try {
          await _apiProvider.post(AppEndpoints.logout);
        } catch (e) {
          AppLogger.warning('AuthService: Logout API call failed: $e');
          // Continue with local logout even if API call fails
        }
      }
    } catch (e) {
      AppLogger.error('AuthService: Error during logout API call', e);
    } finally {
      // Clear local storage regardless of API call result
      await _storageService.clearAll();
      currentUser.value = null;
      isLoggedIn.value = false;
    }
  }

  /// Get the current token
  String? get token => _storageService.getToken();

  /// Get the current user ID
  String? get userId => _storageService.getUserId();
}
