import 'employee_model.dart';
import '../../core/utils/logger.dart';

/// Paginated response model for users API
class PaginatedUsersResponse {
  final int currentPage;
  final List<EmployeeModel> data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link> links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  PaginatedUsersResponse({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory PaginatedUsersResponse.fromJson(Map<String, dynamic> json) {
    AppLogger.info('PaginatedUsersResponse: Parsing response');

    // Handle different response structures
    List<dynamic> dataList = [];

    if (json['data'] is List) {
      // Standard Laravel pagination response
      dataList = json['data'] as List<dynamic>;
      AppLogger.info(
        'PaginatedUsersResponse: Found ${dataList.length} users in data array',
      );
    } else if (json['data'] is Map) {
      // Data might be wrapped or error response
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap.containsKey('users')) {
        dataList = dataMap['users'] as List<dynamic>? ?? [];
      } else {
        AppLogger.warning(
          'PaginatedUsersResponse: data is a Map, not a List. Keys: ${dataMap.keys.toList()}',
        );
      }
    } else if (json['users'] is List) {
      // Alternative structure
      dataList = json['users'] as List<dynamic>;
      AppLogger.info(
        'PaginatedUsersResponse: Found ${dataList.length} users in users array',
      );
    } else {
      AppLogger.warning(
        'PaginatedUsersResponse: No data array found. Response keys: ${json.keys.toList()}',
      );
    }

    final users = <EmployeeModel>[];
    for (final item in dataList) {
      if (item is Map<String, dynamic>) {
        try {
          final employee = EmployeeModel.fromJson(item);
          // Filter: only include karyawan role, exclude admin
          if (employee.role == null || employee.role == 'karyawan') {
            users.add(employee);
          }
        } catch (e) {
          AppLogger.error(
            'PaginatedUsersResponse: Error parsing employee item',
            e,
          );
        }
      }
    }

    return PaginatedUsersResponse(
      currentPage: json['current_page'] as int? ?? 1,
      data: users,
      firstPageUrl: json['first_page_url'] as String?,
      from: json['from'] as int?,
      lastPage: json['last_page'] as int?,
      lastPageUrl: json['last_page_url'] as String?,
      links: _parseLinks(json['links']),
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String?,
      perPage: json['per_page'] as int?,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int?,
      total: json['total'] as int? ?? users.length,
    );
  }

  static List<Link> _parseLinks(dynamic linksData) {
    if (linksData is List<dynamic>) {
      return linksData
          .map(
            (item) => item is Map<String, dynamic> ? Link.fromJson(item) : null,
          )
          .whereType<Link>()
          .toList();
    }
    return [];
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;
}

class Link {
  final String? url;
  final String? label;
  final int? page;
  final bool? active;

  Link({this.url, this.label, this.page, this.active});

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'] as String?,
      label: json['label'] as String?,
      page: json['page'] as int?,
      active: json['active'] as bool?,
    );
  }
}
