import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/logger.dart';

class SplashController extends GetxController {
  StorageService? _storageService;
  bool _hasNavigated = false;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('SplashController: onInit() called');

    // Absolute safety timeout — if for ANY reason the normal flow
    // takes longer than 10 seconds, force-navigate to login.
    // This prevents the app from being stuck forever in release mode.
    Future.delayed(const Duration(seconds: 10), () {
      if (!_hasNavigated) {
        debugPrint('SplashController: Safety timeout reached — forcing navigation to login');
        _navigateTo(AppRoutes.login);
      }
    });

    _initializeAndNavigate();
  }

  @override
  void onReady() {
    super.onReady();
    AppLogger.info('SplashController: onReady() called');
  }

  /// Safe navigation helper — ensures we only navigate once.
  void _navigateTo(String route) {
    if (_hasNavigated) return;
    _hasNavigated = true;
    AppLogger.info('SplashController: Navigating to $route');
    Get.offAllNamed(route);
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
      _navigateTo(AppRoutes.login);
    }
  }

  Future<void> _checkLoginStatus() async {
    try {
      AppLogger.info('SplashController: Checking login status...');

      if (_storageService == null) {
        AppLogger.error('SplashController: StorageService is null', null, null);
        _navigateTo(AppRoutes.login);
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
          _navigateTo(AppRoutes.adminDashboard);
        } else {
          _navigateTo(AppRoutes.employeeDashboard);
        }
      } else {
        _navigateTo(AppRoutes.login);
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'SplashController: Error checking login status',
        e,
        stackTrace,
      );
      _navigateTo(AppRoutes.login);
    }
  }
}
