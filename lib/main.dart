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
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('App: Initializing...');

  // Load .env file
  await dotenv.load(fileName: '.env');
  AppLogger.info('App: .env file loaded');

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID');
  AppLogger.info('App: Date formatting initialized');

  // Initialize GetStorage
  await GetStorage.init();
  AppLogger.info('App: GetStorage initialized');

  // Initialize services
  await _initServices();
  AppLogger.info('App: Services initialized');

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());

  // Configure EasyLoading
  _configureEasyLoading();
}

Future<void> _initServices() async {
  try {
    // Initialize core services
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

    AppLogger.info('App: Initializing SecurityService...');
    Get.put(SecurityService.instance);

    AppLogger.info('App: All services initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('App: Error initializing services', e, stackTrace);
    rethrow;
  }
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
