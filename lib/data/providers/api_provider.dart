import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../../core/constants/app_endpoints.dart';
import '../../core/utils/logger.dart';
import '../services/storage_service.dart';

class ApiProvider {
  late Dio _dio;
  final StorageService _storageService = getx.Get.find();

  ApiProvider() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to headers
          final token = _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          AppLogger.info('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info('Response: ${response.statusCode} ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error(
            'Error: ${error.response?.statusCode} ${error.message}',
            error,
            error.stackTrace,
          );
          return handler.next(error);
        },
      ),
    );
  }

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Upload with FormData (for images)
  Future<Response> upload(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Download file (Excel/PDF)
  Future<Response> download(
    String path, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final options = Options(
        responseType: ResponseType.bytes,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }
}
