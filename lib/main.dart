import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/utils/logger.dart';
import 'core/services/security_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/location_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/employee_service.dart';
import 'data/services/attendance_service.dart';
import 'data/providers/api_provider.dart';
import 'routes/app_pages.dart';

void main() async {
  // Wrap entire main in runZonedGuarded so uncaught async errors
  // don't silently kill the app in release mode.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ---- Safe initialization (each step wrapped in try-catch) ----

    // 1. Load .env file
    try {
      await dotenv.load(fileName: '.env');
      AppLogger.info('App: .env file loaded');
    } catch (e) {
      // In release mode the .env asset path can differ;
      // fall back so the app still boots with the hardcoded default URL.
      debugPrint('App: Failed to load .env – $e');
    }

    // 2. Initialize date formatting
    try {
      await initializeDateFormatting('id_ID');
    } catch (e) {
      debugPrint('App: Date formatting init failed – $e');
    }

    // 3. Initialize GetStorage
    try {
      await GetStorage.init();
    } catch (e) {
      debugPrint('App: GetStorage init failed – $e');
    }

    // 4. Initialize services
    try {
      await _initServices();
    } catch (e, stackTrace) {
      debugPrint('App: Service init failed – $e\n$stackTrace');
    }

    // 5. Set preferred orientations
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (_) {}

    // ---- Always run the app, even if init partially failed ----
    runApp(const MyApp());

    // Configure EasyLoading (post-frame)
    _configureEasyLoading();
  }, (error, stack) {
    // Global fallback – prevents silent crashes in release builds.
    debugPrint('App: Uncaught error – $error\n$stack');
  });
}

Future<void> _initServices() async {
  // Initialize core services – order matters (dependencies first)
  AppLogger.info('App: Initializing StorageService...');
  Get.put(StorageService());

  AppLogger.info('App: Initializing LocationService...');
  Get.put(LocationService());

  AppLogger.info('App: Initializing ApiProvider...');
  Get.put(ApiProvider());

  AppLogger.info('App: Initializing AuthService...');
  Get.put(AuthService());

  AppLogger.info('App: Initializing EmployeeService...');
  Get.put(EmployeeService());

  AppLogger.info('App: Initializing AttendanceService...');
  Get.put(AttendanceService(Get.find<ApiProvider>()));

  // SecurityService is deferred – it calls native code
  // (jailbreak_root_detection, device_info_plus) that can
  // crash / hang on some devices in release mode.
  // We register it lazily so it doesn't block startup.
  AppLogger.info('App: Registering SecurityService (lazy)...');
  Get.lazyPut(() => SecurityService.instance);

  AppLogger.info('App: All services initialised successfully');
}

void _configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..maskType = EasyLoadingMaskType.black
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      builder: EasyLoading.init(),
    );
  }
}
