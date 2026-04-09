import 'dart:math' as math;
import 'package:intl/intl.dart';

class Helpers {
  // Date & Time Formatting
  static String formatDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format, 'id_ID').format(date);
  }

  static String formatTime(DateTime time, {String format = 'HH:mm'}) {
    return DateFormat(format, 'id_ID').format(time);
  }

  static String formatDateTime(DateTime dateTime,
      {String format = 'dd MMM yyyy HH:mm'}) {
    return DateFormat(format, 'id_ID').format(dateTime);
  }

  // Get greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  // Check if late (after 8 AM)
  static bool isLate(DateTime checkInTime) {
    final standardTime = DateTime(
      checkInTime.year,
      checkInTime.month,
      checkInTime.day,
      8,
      0,
    );
    return checkInTime.isAfter(standardTime);
  }

  // Calculate distance between two coordinates (in meters)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // in meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (dLat / 2) * (dLat / 2) +
        _toRadians(lat1) * _toRadians(lat2) * (dLon / 2) * (dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  // Format distance
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  // Validate password
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
