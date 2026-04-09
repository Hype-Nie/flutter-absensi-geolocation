import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/attendance_history_model.dart';
import '../models/user_stats_model.dart';
import '../providers/api_provider.dart';
import '../../core/utils/logger.dart';

/// Service for managing attendance data
class AttendanceService {
  final ApiProvider _apiProvider;

  AttendanceService(this._apiProvider);

  /// Clock in attendance with multipart/form-data
  /// POST /absensi/clock-in
  Future<ClockInResult> clockIn({
    required String userId,
    required DateTime tanggal,
    required File clockInImage,
    required double clockInLat,
    required double clockInLong,
    String? status,
  }) async {
    try {
      AppLogger.info('AttendanceService: Clock in for user ID: $userId');

      // Verify image file exists
      if (!await clockInImage.exists()) {
        AppLogger.error(
          'Clock-in image file does not exist: ${clockInImage.path}',
        );
        return ClockInResult.failure('File foto tidak ditemukan');
      }

      // Check file size
      final fileSize = await clockInImage.length();
      final fileSizeInMB = fileSize / (1024 * 1024);

      AppLogger.info(
        'AttendanceService: Image size: ${fileSizeInMB.toStringAsFixed(2)} MB',
      );

      // Validate file size (max 2MB)
      if (fileSizeInMB > 2.0) {
        AppLogger.error(
          'Clock-in image too large: ${fileSizeInMB.toStringAsFixed(2)} MB',
        );
        return ClockInResult.failure(
          'Ukuran foto terlalu besar (${fileSizeInMB.toStringAsFixed(2)} MB). Maksimal 2MB.',
        );
      }

      // Format tanggal as YYYY-MM-DD
      final formattedDate = DateFormat('yyyy-MM-dd').format(tanggal);

      // Create multipart form data
      final formDataMap = <String, dynamic>{
        'user_id': userId,
        'tanggal': formattedDate,
        'clock_in_image': await MultipartFile.fromFile(
          clockInImage.path,
          filename: 'clock_in_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'clock_in_lat': clockInLat.toString(),
        'clock_in_long': clockInLong.toString(),
      };

      if (status != null && status.isNotEmpty) {
        formDataMap['status'] = status;
      }

      final formData = FormData.fromMap(formDataMap);

      final imageSize = await clockInImage.length();
      AppLogger.info('AttendanceService: Sending clock-in request');
      AppLogger.info('  - user_id: $userId');
      AppLogger.info('  - tanggal: $formattedDate');
      AppLogger.info('  - clock_in_lat: $clockInLat');
      AppLogger.info('  - clock_in_long: $clockInLong');
      AppLogger.info('  - image: ${clockInImage.path}');
      AppLogger.info(
        '  - image size: ${(imageSize / 1024).toStringAsFixed(2)} KB',
      );

      final response = await _apiProvider.upload(
        '/absensi/clock-in',
        formData: formData,
      );

      AppLogger.info(
        'AttendanceService: Clock-in response status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final attendanceData = data['data'] as Map<String, dynamic>;
          final attendance = AttendanceHistoryModel.fromJson(attendanceData);

          AppLogger.info(
            'AttendanceService: Clock-in successful. Status: ${attendance.status}',
          );

          return ClockInResult.success(attendance);
        }

        final message = data['message'] ?? 'Clock in gagal';
        AppLogger.error('AttendanceService: Clock-in failed: $message');
        return ClockInResult.failure(message);
      }

      return ClockInResult.failure('Clock in gagal');
    } on DioException catch (e) {
      // Log detailed error information
      AppLogger.error('AttendanceService: Clock-in DioException', e);

      if (e.response != null) {
        AppLogger.error('Response status: ${e.response?.statusCode}');
        AppLogger.error('Response data: ${e.response?.data}');
      }

      final errorMessage = _handleClockInException(e);
      return ClockInResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'AttendanceService: Clock-in unexpected error',
        e,
        stackTrace,
      );
      return ClockInResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Clock out attendance with multipart/form-data
  /// POST /absensi/clock-out/{attendanceId}
  Future<ClockInResult> clockOut({
    required int attendanceId,
    required File clockOutImage,
    required double clockOutLat,
    required double clockOutLong,
  }) async {
    try {
      AppLogger.info(
        'AttendanceService: Clock out for attendance ID: $attendanceId',
      );

      // Verify image file exists
      if (!await clockOutImage.exists()) {
        AppLogger.error(
          'Clock-out image file does not exist: ${clockOutImage.path}',
        );
        return ClockInResult.failure('File foto tidak ditemukan');
      }

      // Check file size
      final fileSize = await clockOutImage.length();
      final fileSizeInMB = fileSize / (1024 * 1024);

      AppLogger.info(
        'AttendanceService: Image size: ${fileSizeInMB.toStringAsFixed(2)} MB',
      );

      // Validate file size (max 2MB)
      if (fileSizeInMB > 2.0) {
        AppLogger.error(
          'Clock-out image too large: ${fileSizeInMB.toStringAsFixed(2)} MB',
        );
        return ClockInResult.failure(
          'Ukuran foto terlalu besar (${fileSizeInMB.toStringAsFixed(2)} MB). Maksimal 2MB.',
        );
      }

      // Create multipart form data
      final formData = FormData.fromMap({
        'clock_out_image': await MultipartFile.fromFile(
          clockOutImage.path,
          filename: 'clock_out_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'clock_out_lat': clockOutLat.toString(),
        'clock_out_long': clockOutLong.toString(),
      });

      final imageSize = await clockOutImage.length();
      AppLogger.info('AttendanceService: Sending clock-out request');
      AppLogger.info('  - attendance_id: $attendanceId');
      AppLogger.info('  - clock_out_lat: $clockOutLat');
      AppLogger.info('  - clock_out_long: $clockOutLong');
      AppLogger.info('  - image: ${clockOutImage.path}');
      AppLogger.info(
        '  - image size: ${(imageSize / 1024).toStringAsFixed(2)} KB',
      );

      final response = await _apiProvider.upload(
        '/absensi/clock-out/$attendanceId',
        formData: formData,
      );

      AppLogger.info(
        'AttendanceService: Clock-out response status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final attendanceData = data['data'] as Map<String, dynamic>;
          final attendance = AttendanceHistoryModel.fromJson(attendanceData);

          AppLogger.info(
            'AttendanceService: Clock-out successful. Status: ${attendance.status}',
          );

          return ClockInResult.success(attendance);
        }

        final message = data['message'] ?? 'Clock out gagal';
        AppLogger.error('AttendanceService: Clock-out failed: $message');
        return ClockInResult.failure(message);
      }

      return ClockInResult.failure('Clock out gagal');
    } on DioException catch (e) {
      AppLogger.error('AttendanceService: Clock-out DioException', e);

      if (e.response != null) {
        AppLogger.error('Response status: ${e.response?.statusCode}');
        AppLogger.error('Response data: ${e.response?.data}');
      }

      final errorMessage = _handleClockInException(e);
      return ClockInResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'AttendanceService: Clock-out unexpected error',
        e,
        stackTrace,
      );
      return ClockInResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Update attendance status (admin only)
  /// PUT /absensi/{id}
  Future<ClockInResult> updateStatus({
    required int id,
    required String status,
    required int lateDuration,
  }) async {
    try {
      AppLogger.info(
        'AttendanceService: Updating status for attendance ID: $id to $status',
      );

      final body = {'status': status, 'late_duration': lateDuration};

      final response = await _apiProvider.put('/absensi/$id', data: body);

      AppLogger.info(
        'AttendanceService: Update status response: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final attendanceData = data['data'] as Map<String, dynamic>;
          final attendance = AttendanceHistoryModel.fromJson(attendanceData);

          AppLogger.info(
            'AttendanceService: Status updated successfully to ${attendance.status}',
          );

          return ClockInResult.success(attendance);
        }

        final message = data['message'] ?? 'Gagal mengubah status';
        AppLogger.error('AttendanceService: Update status failed: $message');
        return ClockInResult.failure(message);
      }

      return ClockInResult.failure('Gagal mengubah status');
    } on DioException catch (e) {
      AppLogger.error('AttendanceService: Update status DioException', e);

      if (e.response != null) {
        AppLogger.error('Response status: ${e.response?.statusCode}');
        AppLogger.error('Response data: ${e.response?.data}');
      }

      final errorMessage = _handleClockInException(e);
      return ClockInResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'AttendanceService: Update status unexpected error',
        e,
        stackTrace,
      );
      return ClockInResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Get attendance history by user ID with pagination
  /// GET /absensi?user_id={userId}&page={page}
  Future<AttendanceResult> getAttendanceById(
    String userId, {
    int? page,
    int perPage = 10,
  }) async {
    try {
      // Build query parameters using /absensi endpoint with user_id filter
      final queryParams = <String, dynamic>{
        'user_id': userId,
        'order_by': 'tanggal',
        'order_dir': 'desc',
      };

      if (page != null) {
        queryParams['page'] = page.toString();
        queryParams['per_page'] = perPage.toString();
      }

      // Build query string
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      final endpoint = '/absensi?$queryString';

      AppLogger.info(
        'AttendanceService: Fetching attendance for user ID: $userId${page != null ? " (page $page)" : ""}',
      );

      final response = await _apiProvider.get(endpoint);

      AppLogger.info(
        'AttendanceService: Response status: ${response.statusCode}',
      );
      AppLogger.info(
        'AttendanceService: Response data type: ${response.data.runtimeType}',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final attendanceData = data['data'];

          // Handle paginated response (data contains pagination info)
          if (attendanceData is Map<String, dynamic> &&
              attendanceData.containsKey('data')) {
            final items = attendanceData['data'] as List;
            final attendanceList = items
                .map(
                  (item) => AttendanceHistoryModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();

            AppLogger.info(
              'AttendanceService: Found ${attendanceList.length} attendance records (paginated)',
            );
            return AttendanceResult.success(attendanceList);
          }
          // Handle direct list response
          else if (attendanceData is List) {
            final attendanceList = attendanceData
                .map(
                  (item) => AttendanceHistoryModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();

            AppLogger.info(
              'AttendanceService: Found ${attendanceList.length} attendance records',
            );
            return AttendanceResult.success(attendanceList);
          }
          // Handle single record
          else if (attendanceData is Map<String, dynamic>) {
            final attendance = AttendanceHistoryModel.fromJson(attendanceData);
            AppLogger.info('AttendanceService: Found 1 attendance record');
            return AttendanceResult.success([attendance]);
          }
        }

        final message = data['message'] ?? 'Gagal memuat data absensi';
        AppLogger.error(
          'AttendanceService: API returned success=false: $message',
        );
        return AttendanceResult.failure(message);
      }

      return AttendanceResult.failure('Gagal memuat data absensi');
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error('AttendanceService: DioException', e, e.stackTrace);
      return AttendanceResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error('AttendanceService: Unexpected error', e, stackTrace);
      return AttendanceResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  String _handleClockInException(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;

      // Try to parse detailed validation errors
      if (data is Map) {
        if (data.containsKey('message')) {
          final message = data['message'];

          // Check for validation errors
          if (data.containsKey('errors') && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            final errorMessages = <String>[];

            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorMessages.add('$key: ${value.first}');
              } else if (value is String) {
                errorMessages.add('$key: $value');
              }
            });

            if (errorMessages.isNotEmpty) {
              return '$message\n${errorMessages.join('\n')}';
            }
          }

          return message ?? 'Clock in gagal';
        }
      }

      if (e.response?.statusCode == 422) {
        return 'Validasi gagal. Periksa data yang dikirim';
      }
      if (e.response?.statusCode == 404) {
        return 'Endpoint tidak ditemukan';
      }
      if (e.response?.statusCode == 401) {
        return 'Unauthorized - silakan login kembali';
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

  /// Get a single attendance record by ID
  /// GET /absensi/{id}
  Future<AttendanceResult> getSingleAttendance(int id) async {
    try {
      AppLogger.info('AttendanceService: Fetching single attendance ID: $id');

      final response = await _apiProvider.get('/absensi/$id');

      AppLogger.info(
        'AttendanceService: Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final attendanceData = data['data'];

          if (attendanceData is Map<String, dynamic>) {
            final attendance = AttendanceHistoryModel.fromJson(attendanceData);
            AppLogger.info(
              'AttendanceService: Found attendance ID: ${attendance.id}, user: ${attendance.user?.name}',
            );
            return AttendanceResult.success([attendance]);
          }
        }

        final message = data['message'] ?? 'Data absensi tidak ditemukan';
        return AttendanceResult.failure(message);
      }

      return AttendanceResult.failure('Data absensi tidak ditemukan');
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error(
        'AttendanceService: getSingleAttendance DioException',
        e,
        e.stackTrace,
      );
      return AttendanceResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'AttendanceService: getSingleAttendance unexpected error',
        e,
        stackTrace,
      );
      return AttendanceResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Get user attendance statistics
  /// GET /absensi/user/{id}/stats
  Future<StatsResult> getUserStats(String userId) async {
    try {
      AppLogger.info('AttendanceService: Fetching stats for user ID: $userId');

      final response = await _apiProvider.get('/absensi/user/$userId/stats');

      AppLogger.info(
        'AttendanceService: Stats response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final statsData = data['data'] as Map<String, dynamic>;
          final stats = UserStatsModel.fromJson(statsData);

          AppLogger.info(
            'AttendanceService: Stats loaded - Hadir: ${stats.stats.totalHadir}, Terlambat: ${stats.stats.totalTerlambat}',
          );
          return StatsResult.success(stats);
        }

        final message = data['message'] ?? 'Gagal memuat statistik';
        AppLogger.error(
          'AttendanceService: API returned success=false: $message',
        );
        return StatsResult.failure(message);
      }

      return StatsResult.failure('Gagal memuat statistik');
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error('AttendanceService: Stats DioException', e, e.stackTrace);
      return StatsResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'AttendanceService: Stats unexpected error',
        e,
        stackTrace,
      );
      return StatsResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Get all attendance for a specific date (for admin dashboard)
  /// GET /absensi?tanggal={YYYY-MM-DD}&order_by=tanggal&order_dir=desc
  /// If fetchAll is true, will fetch all pages to get complete data
  Future<AttendanceResult> getAttendanceByDate({
    required String tanggal,
    String? status,
    String? search,
    int? page,
    int perPage = 100,
    bool fetchAll = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'tanggal': tanggal,
        'order_by': 'clock_in',
        'order_dir': 'asc',
        'per_page': perPage.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (page != null) {
        queryParams['page'] = page.toString();
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      final endpoint = '/absensi?$queryString';

      AppLogger.info(
        'AttendanceService: Fetching attendance for date: $tanggal',
      );

      final response = await _apiProvider.get(endpoint);

      AppLogger.info(
        'AttendanceService: Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final attendanceData = data['data'];
          List<AttendanceHistoryModel> allAttendees = [];

          if (attendanceData is Map<String, dynamic> &&
              attendanceData.containsKey('data')) {
            final items = attendanceData['data'] as List;
            final attendanceList = items
                .map(
                  (item) => AttendanceHistoryModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
            allAttendees.addAll(attendanceList);

            // Fetch all pages if requested
            if (fetchAll) {
              final meta = attendanceData['meta'] as Map<String, dynamic>?;
              if (meta != null) {
                final lastPage = meta['last_page'] as int? ?? 1;
                final currentPage = meta['current_page'] as int? ?? 1;

                // Fetch remaining pages
                for (int p = currentPage + 1; p <= lastPage; p++) {
                  final pageResult = await getAttendanceByDate(
                    tanggal: tanggal,
                    status: status,
                    search: search,
                    page: p,
                    perPage: perPage,
                    fetchAll: false, // Prevent infinite recursion
                  );
                  if (pageResult.isSuccess && pageResult.data != null) {
                    allAttendees.addAll(pageResult.data!);
                  }
                }
              }
            }

            AppLogger.info(
              'AttendanceService: Found ${allAttendees.length} total attendance records for $tanggal',
            );
            return AttendanceResult.success(allAttendees);
          } else if (attendanceData is List) {
            final attendanceList = attendanceData
                .map(
                  (item) => AttendanceHistoryModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
            allAttendees.addAll(attendanceList);

            AppLogger.info(
              'AttendanceService: Found ${allAttendees.length} attendance records for $tanggal',
            );
            return AttendanceResult.success(allAttendees);
          }
        }

        final message = data['message'] ?? 'Gagal memuat data absensi';
        return AttendanceResult.failure(message);
      }

      return AttendanceResult.failure('Gagal memuat data absensi');
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error('AttendanceService: DioException', e, e.stackTrace);
      return AttendanceResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error('AttendanceService: Unexpected error', e, stackTrace);
      return AttendanceResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Get attendance by month and year
  /// GET /absensi?month={month}&year={year}
  Future<AttendanceResult> getAttendanceByMonthYear({
    required int month,
    required int year,
    int perPage = 100,
    bool fetchAll = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'month': month.toString(),
        'year': year.toString(),
        'order_by': 'tanggal',
        'order_dir': 'desc',
        'per_page': perPage.toString(),
      };

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      final endpoint = '/absensi?$queryString';

      AppLogger.info(
        'AttendanceService: Fetching attendance for month: $month, year: $year',
      );

      final response = await _apiProvider.get(endpoint);

      AppLogger.info(
        'AttendanceService: Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final attendanceData = data['data'];
          List<AttendanceHistoryModel> allAttendees = [];

          if (attendanceData is Map<String, dynamic> &&
              attendanceData.containsKey('data')) {
            final items = attendanceData['data'] as List;
            final attendanceList = items
                .map(
                  (item) => AttendanceHistoryModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
            allAttendees.addAll(attendanceList);

            // Fetch all pages if requested
            if (fetchAll) {
              final meta = attendanceData['meta'] as Map<String, dynamic>?;
              if (meta != null) {
                final lastPage = meta['last_page'] as int? ?? 1;
                final currentPage = meta['current_page'] as int? ?? 1;

                for (int p = currentPage + 1; p <= lastPage; p++) {
                  final pageResult = await getAttendanceByDate(
                    tanggal: '${year}-${month.toString().padLeft(2, '0')}-01',
                    page: p,
                    perPage: perPage,
                    fetchAll: false,
                  );
                  if (pageResult.isSuccess && pageResult.data != null) {
                    allAttendees.addAll(pageResult.data!);
                  }
                }
              }
            }

            AppLogger.info(
              'AttendanceService: Found ${allAttendees.length} attendance records for $month/$year',
            );
            return AttendanceResult.success(allAttendees);
          } else if (attendanceData is List) {
            final attendanceList = attendanceData
                .map(
                  (item) => AttendanceHistoryModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
            allAttendees.addAll(attendanceList);

            AppLogger.info(
              'AttendanceService: Found ${allAttendees.length} attendance records for $month/$year',
            );
            return AttendanceResult.success(allAttendees);
          }
        }

        final message = data['message'] ?? 'Gagal memuat data absensi';
        return AttendanceResult.failure(message);
      }

      return AttendanceResult.failure('Gagal memuat data absensi');
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error('AttendanceService: DioException', e, e.stackTrace);
      return AttendanceResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error('AttendanceService: Unexpected error', e, stackTrace);
      return AttendanceResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Get attendance by date range
  /// GET /absensi?start_date={YYYY-MM-DD}&end_date={YYYY-MM-DD}
  Future<AttendanceResult> getAttendanceByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int perPage = 100,
    bool fetchAll = true,
  }) async {
    try {
      // Format start date as-is
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      // Add 1 day to end date for API (API uses < comparison, not <=)
      // This ensures records on the end date are included
      final endStr = DateFormat(
        'yyyy-MM-dd',
      ).format(endDate.add(const Duration(days: 1)));

      final queryParams = <String, dynamic>{
        'start_date': startStr,
        'end_date': endStr,
        'order_by': 'tanggal',
        'order_dir': 'desc',
        'per_page': perPage.toString(),
      };

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');

      final endpoint = '/absensi?$queryString';

      AppLogger.info(
        'AttendanceService: Fetching attendance from $startStr to $endStr',
      );

      final response = await _apiProvider.get(endpoint);

      AppLogger.info(
        'AttendanceService: Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final attendanceData = data['data'];
          List<AttendanceHistoryModel> allAttendees = [];

          if (attendanceData is Map<String, dynamic> &&
              attendanceData.containsKey('data')) {
            final items = attendanceData['data'] as List;
            final attendanceList = items
                .map(
                  (item) => AttendanceHistoryModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
            allAttendees.addAll(attendanceList);

            // Fetch all pages if requested
            if (fetchAll) {
              final meta = attendanceData['meta'] as Map<String, dynamic>?;
              if (meta != null) {
                final lastPage = meta['last_page'] as int? ?? 1;
                final currentPage = meta['current_page'] as int? ?? 1;

                for (int p = currentPage + 1; p <= lastPage; p++) {
                  // For date range, we need to fetch all pages
                  // Using the same endpoint with page parameter
                  final pageEndpoint = '$queryString&page=$p';
                  final pageResponse = await _apiProvider.get(
                    '/absensi?$pageEndpoint',
                  );

                  if (pageResponse.statusCode == 200) {
                    final pageData = pageResponse.data as Map<String, dynamic>;
                    if (pageData['success'] == true) {
                      final pageAttendanceData = pageData['data'];
                      if (pageAttendanceData is Map<String, dynamic> &&
                          pageAttendanceData.containsKey('data')) {
                        final pageItems = pageAttendanceData['data'] as List;
                        final pageList = pageItems
                            .map(
                              (item) => AttendanceHistoryModel.fromJson(
                                item as Map<String, dynamic>,
                              ),
                            )
                            .toList();
                        allAttendees.addAll(pageList);
                      }
                    }
                  }
                }
              }
            }

            AppLogger.info(
              'AttendanceService: Found ${allAttendees.length} attendance records',
            );
            return AttendanceResult.success(allAttendees);
          } else if (attendanceData is List) {
            final attendanceList = attendanceData
                .map(
                  (item) => AttendanceHistoryModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
            allAttendees.addAll(attendanceList);

            AppLogger.info(
              'AttendanceService: Found ${allAttendees.length} attendance records',
            );
            return AttendanceResult.success(allAttendees);
          }
        }

        final message = data['message'] ?? 'Gagal memuat data absensi';
        return AttendanceResult.failure(message);
      }

      return AttendanceResult.failure('Gagal memuat data absensi');
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error('AttendanceService: DioException', e, e.stackTrace);
      return AttendanceResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error('AttendanceService: Unexpected error', e, stackTrace);
      return AttendanceResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Get today's attendance for user
  /// Returns the attendance record if exists, null if not found
  Future<AttendanceHistoryModel?> getTodayAttendance(String userId) async {
    try {
      AppLogger.info(
        'AttendanceService: Fetching today attendance for user ID: $userId',
      );

      final result = await getAttendanceById(userId, page: 1);

      if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
        // Check if first record (most recent) is from today
        final latestAttendance = result.data!.first;

        // Convert UTC date to local date for comparison
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // attendance.tanggal is UTC, convert to local date
        final localAttendanceDate = latestAttendance.tanggal.toLocal();
        final attendanceDate = DateTime(
          localAttendanceDate.year,
          localAttendanceDate.month,
          localAttendanceDate.day,
        );

        if (attendanceDate == today) {
          AppLogger.info(
            'AttendanceService: Found today attendance - ID: ${latestAttendance.id}, Clock Out: ${latestAttendance.clockOut ?? "not yet"}',
          );
          return latestAttendance;
        }
      }

      AppLogger.info('AttendanceService: No attendance found for today');
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'AttendanceService: Error fetching today attendance',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Export attendance data to CSV
  /// GET /absensi/export/excel (returns CSV format)
  Future<ExportResult> exportCsv({
    String? userId,
    String? status,
    String? tanggal,
    String? startDate,
    String? endDate,
    int? month,
    int? year,
    String? search,
    String orderBy = 'tanggal',
    String orderDir = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'order_by': orderBy,
        'order_dir': orderDir,
      };

      if (userId != null && userId.isNotEmpty) {
        queryParams['user_id'] = userId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (tanggal != null && tanggal.isNotEmpty) {
        queryParams['tanggal'] = tanggal;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }
      if (month != null) {
        queryParams['month'] = month.toString();
      }
      if (year != null) {
        queryParams['year'] = year.toString();
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      AppLogger.info(
        'AttendanceService: Exporting CSV with params: $queryParams',
      );

      final response = await _apiProvider.download(
        '/absensi/export/excel',
        queryParameters: queryParams,
      );

      AppLogger.info(
        'AttendanceService: Export CSV response status: ${response.statusCode}',
      );
      AppLogger.info(
        'AttendanceService: Response data type: ${response.data.runtimeType}',
      );

      // Check if response is JSON error (API returned error instead of file)
      if (response.data is Map) {
        final errorData = response.data as Map;
        final message = errorData['message'] ?? 'Gagal mengekspor CSV';
        AppLogger.error(
          'AttendanceService: API returned JSON error: $errorData',
        );
        return ExportResult.failure('API Error: $message');
      }

      if (response.statusCode == 200) {
        // Response is bytes (CSV text)
        final bytes = response.data is List<int>
            ? response.data as List<int>
            : (response.data as String).codeUnits;
        AppLogger.info(
          'AttendanceService: Export CSV successful. Size: ${bytes.length} bytes',
        );

        // Validate CSV content (should start with ID,NPK or similar CSV header)
        if (bytes.length >= 3) {
          final header =
              String.fromCharCode(bytes[0]) +
              String.fromCharCode(bytes[1]) +
              String.fromCharCode(bytes[2]);
          AppLogger.info('AttendanceService: CSV header starts with: $header');
        }

        return ExportResult.success(bytes, 'csv');
      }

      return ExportResult.failure(
        'Gagal mengekspor CSV. Status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error(
        'AttendanceService: Export CSV DioException',
        e,
        e.stackTrace,
      );
      return ExportResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'AttendanceService: Export CSV unexpected error',
        e,
        stackTrace,
      );
      return ExportResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Export attendance data to PDF
  /// GET /absensi/export/pdf
  Future<ExportResult> exportPdf({
    String? userId,
    String? status,
    String? tanggal,
    String? startDate,
    String? endDate,
    int? month,
    int? year,
    String? search,
    String orderBy = 'tanggal',
    String orderDir = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'order_by': orderBy,
        'order_dir': orderDir,
      };

      if (userId != null && userId.isNotEmpty) {
        queryParams['user_id'] = userId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (tanggal != null && tanggal.isNotEmpty) {
        queryParams['tanggal'] = tanggal;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }
      if (month != null) {
        queryParams['month'] = month.toString();
      }
      if (year != null) {
        queryParams['year'] = year.toString();
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      AppLogger.info(
        'AttendanceService: Exporting PDF with params: $queryParams',
      );

      final response = await _apiProvider.download(
        '/absensi/export/pdf',
        queryParameters: queryParams,
      );

      AppLogger.info(
        'AttendanceService: Export PDF response status: ${response.statusCode}',
      );
      AppLogger.info(
        'AttendanceService: Response data type: ${response.data.runtimeType}',
      );

      // Check if response is JSON error (API returned error instead of file)
      if (response.data is Map) {
        final errorData = response.data as Map;
        final message = errorData['message'] ?? 'Gagal mengekspor PDF';
        AppLogger.error(
          'AttendanceService: API returned JSON error: $errorData',
        );
        return ExportResult.failure('API Error: $message');
      }

      if (response.statusCode == 200) {
        final bytes = response.data as List<int>;
        AppLogger.info(
          'AttendanceService: Export PDF successful. Size: ${bytes.length} bytes',
        );

        // Validate PDF file signature (PDF files start with %PDF)
        if (bytes.length >= 4) {
          final signature =
              String.fromCharCode(bytes[0]) +
              String.fromCharCode(bytes[1]) +
              String.fromCharCode(bytes[2]) +
              String.fromCharCode(bytes[3]);
          if (signature != '%PDF') {
            AppLogger.error(
              'AttendanceService: Invalid PDF file signature: $signature',
            );
            return ExportResult.failure(
              'File tidak valid. Server mungkin mengembalikan error.',
            );
          }
        }

        return ExportResult.success(bytes, 'pdf');
      }

      return ExportResult.failure(
        'Gagal mengekspor PDF. Status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error(
        'AttendanceService: Export PDF DioException',
        e,
        e.stackTrace,
      );
      return ExportResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error(
        'AttendanceService: Export PDF unexpected error',
        e,
        stackTrace,
      );
      return ExportResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }
}

/// Result wrapper for attendance operations
class AttendanceResult {
  final List<AttendanceHistoryModel>? data;
  final String? error;
  final bool isSuccess;

  AttendanceResult._({this.data, this.error, required this.isSuccess});

  factory AttendanceResult.success(List<AttendanceHistoryModel> data) {
    return AttendanceResult._(data: data, isSuccess: true);
  }

  factory AttendanceResult.failure(String error) {
    return AttendanceResult._(error: error, isSuccess: false);
  }
}

/// Result wrapper for clock-in operations
class ClockInResult {
  final AttendanceHistoryModel? data;
  final String? error;
  final bool isSuccess;

  ClockInResult._({this.data, this.error, required this.isSuccess});

  factory ClockInResult.success(AttendanceHistoryModel data) {
    return ClockInResult._(data: data, isSuccess: true);
  }

  factory ClockInResult.failure(String error) {
    return ClockInResult._(error: error, isSuccess: false);
  }
}

/// Result wrapper for stats operations
class StatsResult {
  final UserStatsModel? data;
  final String? error;
  final bool isSuccess;

  StatsResult._({this.data, this.error, required this.isSuccess});

  factory StatsResult.success(UserStatsModel data) {
    return StatsResult._(data: data, isSuccess: true);
  }

  factory StatsResult.failure(String error) {
    return StatsResult._(error: error, isSuccess: false);
  }
}

/// Result wrapper for export operations
class ExportResult {
  final List<int>? data;
  final String? error;
  final bool isSuccess;
  final String? extension;

  ExportResult._({
    this.data,
    this.error,
    required this.isSuccess,
    this.extension,
  });

  factory ExportResult.success(List<int> data, String extension) {
    return ExportResult._(data: data, isSuccess: true, extension: extension);
  }

  factory ExportResult.failure(String error) {
    return ExportResult._(error: error, isSuccess: false);
  }
}
