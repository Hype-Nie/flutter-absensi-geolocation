import 'package:get/get.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/logger.dart';

class SplashController extends GetxController {
  StorageService? _storageService;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('SplashController: onInit() called');
    _initializeAndNavigate();
  }

  @override
  void onReady() {
    super.onReady();
    AppLogger.info('SplashController: onReady() called');
  }

  Future<void> _initializeAndNavigate() async {
    try {
      AppLogger.info('SplashController: Initializing...');

      // Get StorageService instance safely
      try {
        _storageService = Get.find<StorageService>();
        AppLogger.info('SplashController: StorageService found');
      } catch (e) {
        AppLogger.error(
          'SplashController: StorageService not found, creating new instance',
          e,
          null,
        );
        final storageService = StorageService();
        _storageService = storageService;
        Get.put(storageService);
      }

      // Wait for 2 seconds for better UX
      await Future.delayed(const Duration(seconds: 2));

      await _checkLoginStatus();
    } catch (e, stackTrace) {
      AppLogger.error(
        'SplashController: Error during initialization',
        e,
        stackTrace,
      );
      // If error occurs, navigate to login as fallback
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _checkLoginStatus() async {
    try {
      AppLogger.info('SplashController: Checking login status...');

      if (_storageService == null) {
        AppLogger.error('SplashController: StorageService is null', null, null);
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      // Check if user is logged in
      final isLoggedIn = _storageService!.isLoggedIn();
      final userData = _storageService!.getUser();

      AppLogger.info(
        'SplashController: isLoggedIn=$isLoggedIn, userData=$userData',
      );

      if (isLoggedIn && userData != null) {
        // Navigate based on user role
        final role = userData['role'];
        AppLogger.info('SplashController: User role=$role, navigating...');

        if (role == 'admin') {
          AppLogger.info('SplashController: Navigating to admin dashboard');
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else {
          AppLogger.info('SplashController: Navigating to employee dashboard');
          Get.offAllNamed(AppRoutes.employeeDashboard);
        }
      } else {
        // Navigate to login
        AppLogger.info(
          'SplashController: Not logged in, navigating to login...',
        );
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'SplashController: Error checking login status',
        e,
        stackTrace,
      );
      // Navigate to login as fallback
      AppLogger.info('SplashController: Fallback - Navigating to login');
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
