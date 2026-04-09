import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../models/employee_model.dart';
import '../models/paginated_users_response.dart';
import '../providers/api_provider.dart';
import '../../core/utils/logger.dart';

/// Result type for employee operations
class EmployeeResult<T> {
  final T? data;
  final String? error;

  EmployeeResult.success(this.data) : error = null;
  EmployeeResult.failure(this.error) : data = null;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

/// Service for handling employee business logic
/// Responsibilities:
/// - API calls for employee operations
/// - Data transformation and validation
/// - Error handling
class EmployeeService extends getx.GetxService {
  final ApiProvider _apiProvider = getx.Get.find<ApiProvider>();

  // Pagination settings
  static const int _perPage = 10;

  // State for reactive UI
  final getx.RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  final getx.RxBool isLoading = false.obs;
  final getx.RxBool isLoadingMore = false.obs;
  final getx.RxBool hasReachedMax = false.obs;
  final getx.RxInt currentPage = 1.obs;
  final getx.RxInt lastPage = 1.obs;
  final getx.RxInt total = 0.obs;

  /// Fetch all employees from API (initial load)
  /// Returns EmployeeResult with list of employees or error message
  Future<EmployeeResult<List<EmployeeModel>>> fetchAllEmployees() async {
    if (isLoading.value) {
      return EmployeeResult.failure('Already loading');
    }

    isLoading.value = true;
    hasReachedMax.value = false;

    try {
      AppLogger.info('EmployeeService: Fetching employees page 1');

      final response = await _apiProvider.get(
        '/users',
        queryParameters: {'page': 1, 'per_page': _perPage},
      );

      if (response.statusCode == 200) {
        return _handlePaginatedResponse(response, isFirstPage: true);
      }

      final errorMessage = _parseErrorMessage(response);
      AppLogger.error(
        'EmployeeService: Failed to fetch employees: $errorMessage',
      );
      return EmployeeResult.failure(errorMessage);
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error(
        'EmployeeService: DioException during fetch',
        e,
        e.stackTrace,
      );
      return EmployeeResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'EmployeeService: Unexpected error during fetch',
        e,
        stackTrace,
      );
      return EmployeeResult.failure('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more employees (pagination)
  /// Returns EmployeeResult with new employees or error message
  Future<EmployeeResult<List<EmployeeModel>>> loadMoreEmployees() async {
    // Don't load if already loading or reached max
    if (isLoadingMore.value || hasReachedMax.value) {
      return EmployeeResult.failure('No more data');
    }

    // Don't load if we're already on the last page
    if (currentPage.value >= lastPage.value) {
      hasReachedMax.value = true;
      return EmployeeResult.failure('No more data');
    }

    isLoadingMore.value = true;

    try {
      final nextPage = currentPage.value + 1;
      AppLogger.info('EmployeeService: Loading employees page $nextPage');

      final response = await _apiProvider.get(
        '/users',
        queryParameters: {'page': nextPage, 'per_page': _perPage},
      );

      if (response.statusCode == 200) {
        return _handlePaginatedResponse(response, isFirstPage: false);
      }

      final errorMessage = _parseErrorMessage(response);
      AppLogger.error(
        'EmployeeService: Failed to load more employees: $errorMessage',
      );
      return EmployeeResult.failure(errorMessage);
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error(
        'EmployeeService: DioException during load more',
        e,
        e.stackTrace,
      );
      return EmployeeResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'EmployeeService: Unexpected error during load more',
        e,
        stackTrace,
      );
      return EmployeeResult.failure('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Handle paginated response from API
  EmployeeResult<List<EmployeeModel>> _handlePaginatedResponse(
    Response response, {
    required bool isFirstPage,
  }) {
    AppLogger.info(
      'EmployeeService: Response data type: ${response.data.runtimeType}',
    );

    if (response.data is List) {
      // Direct array response (not paginated)
      final dataList = response.data as List<dynamic>;
      final newEmployees = dataList
          .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
          .where(
            (emp) => emp.role == null || emp.role == 'karyawan',
          ) // Filter out admin
          .toList();

      if (isFirstPage) {
        employees.value = newEmployees;
        currentPage.value = 1;
      } else {
        employees.addAll(newEmployees);
      }

      total.value = newEmployees.length;
      lastPage.value = 1;
      hasReachedMax.value = true;

      AppLogger.info(
        'EmployeeService: Found ${newEmployees.length} employees (direct array)',
      );
      return EmployeeResult.success(newEmployees);
    }

    if (response.data is! Map<String, dynamic>) {
      AppLogger.error('EmployeeService: Response data is not a Map');
      return EmployeeResult.failure('Invalid response format from server');
    }

    final data = response.data as Map<String, dynamic>;

    // Check for wrapped response with success flag
    if (data.containsKey('success') && data['success'] == false) {
      final message = data['message'] ?? 'Gagal memuat data';
      AppLogger.error('EmployeeService: API returned success=false: $message');
      return EmployeeResult.failure(message);
    }

    // Check for nested data structure
    var dataToParse = data;
    if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
      final nestedData = data['data'] as Map<String, dynamic>;
      if (nestedData.containsKey('data')) {
        dataToParse = nestedData;
      }
    }

    final paginatedResponse = PaginatedUsersResponse.fromJson(dataToParse);
    final newEmployees = paginatedResponse.data;

    if (isFirstPage) {
      employees.value = newEmployees;
    } else {
      employees.addAll(newEmployees);
    }

    currentPage.value = paginatedResponse.currentPage;
    lastPage.value = paginatedResponse.lastPage ?? 1;
    total.value = paginatedResponse.total ?? 0;
    hasReachedMax.value = currentPage.value >= lastPage.value;

    AppLogger.info(
      'EmployeeService: Successfully fetched ${newEmployees.length} employees '
      '(page ${paginatedResponse.currentPage}/${paginatedResponse.lastPage})',
    );

    return EmployeeResult.success(newEmployees);
  }

  /// Create a new employee via register API
  /// Returns EmployeeResult with created employee or error message
  Future<EmployeeResult<EmployeeModel>> createEmployee({
    required String npk,
    required String name,
    required String password,
    required String confirmPassword,
    String role = 'karyawan',
  }) async {
    try {
      AppLogger.info('EmployeeService: Creating employee with NPK: $npk');

      final body = {
        'npk': npk.trim(),
        'nama': name.trim(),
        'password': password.trim(),
        'password_confirmation': confirmPassword.trim(),
        'role': role,
      };

      final response = await _apiProvider.post('/register', data: body);

      AppLogger.info(
        'EmployeeService: Create response status: ${response.statusCode}',
      );
      AppLogger.info('EmployeeService: Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        // Handle different response formats
        Map<String, dynamic>? user;

        // Format 1: { "success": true, "user": {...} }
        if (data['success'] == true && data['user'] != null) {
          user = data['user'] as Map<String, dynamic>;
        }
        // Format 2: { "data": {...} } or direct user data
        else if (data['data'] != null) {
          user = data['data'] as Map<String, dynamic>;
        }
        // Format 3: { "message": "...", "id": ..., "npk": ... } - direct user fields
        else if (data['id'] != null || data['npk'] != null) {
          user = data;
        }

        if (user != null) {
          final employee = EmployeeModel.fromJson(user);
          // Only add to local state if role is karyawan (not admin)
          if (employee.role == null || employee.role == 'karyawan') {
            employees.insert(0, employee);
            total.value = total.value + 1;
          }

          AppLogger.info(
            'EmployeeService: Successfully created employee: ${employee.name}',
          );
          return EmployeeResult.success(employee);
        }
      }

      final errorMessage = _parseErrorMessage(response);
      AppLogger.error(
        'EmployeeService: Failed to create employee: $errorMessage',
      );
      return EmployeeResult.failure(errorMessage);
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error(
        'EmployeeService: DioException during create',
        e,
        e.stackTrace,
      );
      return EmployeeResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'EmployeeService: Unexpected error during create',
        e,
        stackTrace,
      );
      return EmployeeResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Update an existing employee via API
  /// PUT /users/{id}
  /// Returns EmployeeResult with updated employee or error message
  Future<EmployeeResult<EmployeeModel>> updateEmployee({
    required String id,
    required String npk,
    required String name,
    String role = 'karyawan',
  }) async {
    try {
      AppLogger.info('EmployeeService: Updating employee ID: $id');

      final body = {'npk': npk.trim(), 'nama': name.trim(), 'role': role};

      final response = await _apiProvider.put('/users/$id', data: body);

      AppLogger.info(
        'EmployeeService: Update response status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        // Check if response indicates success via message
        final message = data['message'] as String?;
        final isSuccessMessage =
            message != null &&
            (message.toLowerCase().contains('updated successfully') ||
                message.toLowerCase().contains('berhasil'));

        // Handle different response formats
        EmployeeModel? updatedEmployee;
        if (data['success'] == true || isSuccessMessage) {
          final user = data['user'] as Map<String, dynamic>?;
          if (user != null) {
            updatedEmployee = EmployeeModel.fromJson(user);
          } else if (data.containsKey('data')) {
            final userData = data['data'] as Map<String, dynamic>?;
            if (userData != null) {
              updatedEmployee = EmployeeModel.fromJson(userData);
            }
          } else {
            // If no user data, create from request body
            updatedEmployee = EmployeeModel(
              id: id,
              npk: npk.trim(),
              name: name.trim(),
              position: 'Staff',
              department: '-',
              role: role,
            );
          }
        } else if (data.containsKey('id')) {
          // Direct response
          updatedEmployee = EmployeeModel.fromJson(data);
        }

        if (updatedEmployee != null) {
          // Update in local state only if role is karyawan
          final index = employees.indexWhere((emp) => emp.id == id);
          if (updatedEmployee.role == null ||
              updatedEmployee.role == 'karyawan') {
            if (index != -1) {
              employees[index] = updatedEmployee;
            } else {
              // Employee wasn't in list before, add it
              employees.insert(0, updatedEmployee);
            }
          } else {
            // Role changed to admin, remove from employee list
            if (index != -1) {
              employees.removeAt(index);
            }
          }

          AppLogger.info(
            'EmployeeService: Successfully updated employee: ${updatedEmployee.name}',
          );
          return EmployeeResult.success(updatedEmployee);
        }
      }

      final errorMessage = _parseErrorMessage(response);
      AppLogger.error(
        'EmployeeService: Failed to update employee: $errorMessage',
      );
      return EmployeeResult.failure(errorMessage);
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error(
        'EmployeeService: DioException during update',
        e,
        e.stackTrace,
      );
      return EmployeeResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'EmployeeService: Unexpected error during update',
        e,
        stackTrace,
      );
      return EmployeeResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Delete an employee by ID
  /// DELETE /users/{id}
  /// Returns EmployeeResult with success or error message
  Future<EmployeeResult<void>> deleteEmployee(String id) async {
    try {
      AppLogger.info('EmployeeService: Deleting employee with ID: $id');

      final response = await _apiProvider.delete('/users/$id');

      AppLogger.info(
        'EmployeeService: Delete response status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from local state
        employees.removeWhere((emp) => emp.id == id);
        total.value = total.value > 0 ? total.value - 1 : 0;

        AppLogger.info('EmployeeService: Successfully deleted employee: $id');
        return EmployeeResult.success(null);
      }

      final errorMessage = _parseErrorMessage(response);
      AppLogger.error(
        'EmployeeService: Failed to delete employee: $errorMessage',
      );
      return EmployeeResult.failure(errorMessage);
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error(
        'EmployeeService: DioException during delete',
        e,
        e.stackTrace,
      );
      return EmployeeResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'EmployeeService: Unexpected error during delete',
        e,
        stackTrace,
      );
      return EmployeeResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Search employees by name or NPK (local filtering)
  List<EmployeeModel> searchEmployees(String query) {
    if (query.isEmpty) {
      return employees.toList();
    }
    final lowerQuery = query.toLowerCase();
    return employees.where((emp) {
      return emp.name.toLowerCase().contains(lowerQuery) ||
          emp.npk.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Refresh employee data from API
  Future<EmployeeResult<List<EmployeeModel>>> refreshEmployees() {
    currentPage.value = 1;
    hasReachedMax.value = false;
    return fetchAllEmployees();
  }

  String _parseErrorMessage(dynamic response) {
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      return data['message'] ?? 'Terjadi kesalahan';
    }
    return 'Terjadi kesalahan';
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] ?? 'Request failed';
      }
      if (e.response?.statusCode == 404) {
        return 'Data tidak ditemukan';
      }
      if (e.response?.statusCode == 401) {
        return 'Unauthorized - silakan login kembali';
      }
      if (e.response?.statusCode == 422) {
        return 'Validasi gagal: ${e.response?.data['message'] ?? 'Input tidak valid'}';
      }
      if (e.response?.statusCode == 500) {
        return 'Server error - coba lagi nanti';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout - periksa koneksi internet Anda';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak ada koneksi internet';
    }
    return 'Terjadi kesalahan: ${e.message ?? "Unknown error"}';
  }
}
