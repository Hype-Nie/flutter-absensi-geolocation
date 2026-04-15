import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ntp/ntp.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import '../utils/logger.dart';

/// Multi-layer security service for anti-spoofing
/// Prevents fake GPS, time manipulation, and device tampering
class SecurityService {
  static SecurityService? _instance;
  static SecurityService get instance => _instance ??= SecurityService._();

  SecurityService._();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // ========== TIME PROTECTION (NTP) ==========

  DateTime? _cachedNetworkTime;
  DateTime? _lastSyncTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Get accurate network time using NTP
  /// Independent of device time - prevents time spoofing
  Future<DateTime> getAccurateTime() async {
    try {
      // Return cached time if still valid
      if (_cachedNetworkTime != null &&
          _lastSyncTime != null &&
          DateTime.now().difference(_lastSyncTime!) < _cacheDuration) {
        AppLogger.info('SecurityService: Using cached NTP time');
        return _cachedNetworkTime!;
      }

      AppLogger.info('SecurityService: Fetching NTP time...');
      // Outer timeout in case the NTP library's own timeout doesn't fire
      // (e.g. DNS hangs, socket never opens in release mode)
      final ntpTime = await NTP.now(
        lookUpAddress: 'pool.ntp.org',
        timeout: const Duration(seconds: 5),
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          AppLogger.warning('SecurityService: NTP outer timeout, using device time');
          return DateTime.now();
        },
      );

      _cachedNetworkTime = ntpTime;
      _lastSyncTime = DateTime.now();
      AppLogger.info('SecurityService: NTP time synced successfully');
      return ntpTime;
    } catch (e) {
      AppLogger.error('SecurityService: NTP failed, using device time', e);
      // Fallback to device time but log the failure
      return DateTime.now();
    }
  }

  /// Check if device time has been manipulated
  /// Compares device time with NTP time
  Future<TimeCheckResult> checkDeviceTime() async {
    try {
      final deviceTime = DateTime.now();
      final networkTime = await getAccurateTime();

      final difference = deviceTime.difference(networkTime).abs();

      // If difference is more than 5 minutes, likely manipulated
      const threshold = Duration(minutes: 5);

      if (difference > threshold) {
        AppLogger.warning(
          'SecurityService: Device time manipulated! Diff: ${difference.inMinutes} minutes',
        );
        return TimeCheckResult(
          isManipulated: true,
          deviceTime: deviceTime,
          networkTime: networkTime,
          difference: difference,
        );
      }

      return TimeCheckResult(
        isManipulated: false,
        deviceTime: deviceTime,
        networkTime: networkTime,
        difference: difference,
      );
    } catch (e) {
      AppLogger.error('SecurityService: Time check failed', e);
      return TimeCheckResult(
        isManipulated: false, // Assume OK if check fails
        deviceTime: DateTime.now(),
        networkTime: DateTime.now(),
        difference: Duration.zero,
      );
    }
  }

  // ========== EMULATOR DETECTION ==========

  /// Check if app is running on an emulator
  Future<bool> isEmulator() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        final isPhysical = androidInfo.isPhysicalDevice;

        // Additional checks for common emulator indicators
        final model = androidInfo.model.toLowerCase();
        final manufacturer = androidInfo.manufacturer.toLowerCase();
        final hardware = androidInfo.hardware.toLowerCase();
        final board = androidInfo.board.toLowerCase();

        final emulatorIndicators = [
          'sdk', 'emu', 'goldfish', 'ranchu', 'vbox', 'genymotion',
          'google_sdk', 'sdk_gphone', 'simulator'
        ];

        final hasEmulatorIndicator = emulatorIndicators.any((indicator) =>
          model.contains(indicator) ||
          manufacturer.contains(indicator) ||
          hardware.contains(indicator) ||
          board.contains(indicator)
        );

        if (!isPhysical || hasEmulatorIndicator) {
          AppLogger.warning('SecurityService: Emulator detected');
          return true;
        }
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final isPhysical = iosInfo.isPhysicalDevice;

        if (!isPhysical) {
          AppLogger.warning('SecurityService: iOS Simulator detected');
          return true;
        }
      }

      return false;
    } catch (e) {
      AppLogger.error('SecurityService: Emulator check failed', e);
      return false; // Assume physical device if check fails
    }
  }

  // ========== ROOT/JAILBREAK DETECTION ==========

  /// Check if device is rooted (Android) or jailbroken (iOS)
  Future<bool> isRootedOrJailbroken() async {
    try {
      // Wrap in a timeout — the jailbreak_root_detection plugin can
      // hang indefinitely on some devices in release mode after R8
      // minification strips reflection-based code.
      final result = await Future.wait([
        JailbreakRootDetection.instance.isJailBroken.timeout(
          const Duration(seconds: 3),
          onTimeout: () => false,
        ),
        JailbreakRootDetection.instance.isNotTrust.timeout(
          const Duration(seconds: 3),
          onTimeout: () => false,
        ),
        JailbreakRootDetection.instance.isRealDevice.timeout(
          const Duration(seconds: 3),
          onTimeout: () => true, // assume real device on timeout
        ),
      ]);

      final isJailBroken = result[0];
      final isNotTrust = result[1];
      final isRealDevice = result[2];

      final isDetected = !isRealDevice || isJailBroken || isNotTrust;

      if (isDetected) {
        AppLogger.warning('SecurityService: Rooted/Jailbroken device detected');
      }

      return isDetected;
    } catch (e) {
      AppLogger.error('SecurityService: Root check failed', e);
      return false; // Assume safe if check fails
    }
  }

  // ========== DEBUG MODE DETECTION ==========

  /// Check if app is running in debug mode
  /// In production, running in debug mode should be blocked
  bool get isDebugMode {
    bool inDebug = false;
    assert(inDebug = true);
    return inDebug;
  }

  /// Check if we should block based on debug mode
  /// Only blocks in release builds if debug mode is somehow detected
  bool shouldBlockDebugMode() {
    // In production (release mode), debug should not be possible
    // This is a safety check
    if (kReleaseMode && isDebugMode) {
      AppLogger.warning('SecurityService: Debug mode detected in release build!');
      return true;
    }
    return false;
  }

  // ========== MOCK LOCATION DETECTION ==========

  /// Check if location is mocked
  bool isMockLocation(Position position) {
    final isMocked = position.isMocked == true;

    if (isMocked) {
      AppLogger.warning('SecurityService: Mock location detected');
    }

    return isMocked;
  }

  // ========== IMPOSSIBLE MOVEMENT DETECTION ==========

  /// Store last known position for movement validation
  Position? _lastKnownPosition;
  DateTime? _lastPositionTime;

  /// Store current position for next validation
  void storeLastPosition(Position position) {
    _lastKnownPosition = position;
    _lastPositionTime = DateTime.now();
  }

  /// Check if movement is physically impossible
  /// Returns true if movement is suspicious
  Future<bool> isImpossibleMovement(Position newPosition) async {
    if (_lastKnownPosition == null || _lastPositionTime == null) {
      // First position, can't validate
      return false;
    }

    try {
      // Calculate distance
      final distance = Geolocator.distanceBetween(
        _lastKnownPosition!.latitude,
        _lastKnownPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );

      // Calculate time difference
      final timeDiff = DateTime.now().difference(_lastPositionTime!);

      if (timeDiff.inSeconds <= 0) {
        return true; // Suspicious: same timestamp or time reversed
      }

      // Calculate speed (m/s)
      final speed = distance / timeDiff.inSeconds;

      // More than 50 m/s (~180 km/h) is suspicious for office attendance
      const maxSpeed = 50.0; // m/s

      if (speed > maxSpeed) {
        AppLogger.warning(
          'SecurityService: Impossible movement detected! '
          'Speed: ${speed.toStringAsFixed(1)} m/s (${(speed * 3.6).toStringAsFixed(1)} km/h), '
          'Distance: ${distance.toStringAsFixed(0)}m, '
          'Time: ${timeDiff.inSeconds}s',
        );
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.error('SecurityService: Movement check failed', e);
      return false;
    }
  }

  // ========== COMPREHENSIVE SECURITY CHECK ==========

  /// Perform all security checks before allowing attendance
  /// Returns detailed security report
  Future<SecurityReport> performSecurityCheck(Position position) async {
    AppLogger.info('SecurityService: Performing comprehensive security check...');

    final results = <SecurityCheckType, bool>{};
    final warnings = <String>[];

    // 1. Emulator check
    final isEmulatorResult = await isEmulator();
    results[SecurityCheckType.emulator] = !isEmulatorResult;
    if (isEmulatorResult) {
      warnings.add('Perangkat adalah emulator/simulator');
    }

    // 2. Root/Jailbreak check
    final isRootedResult = await isRootedOrJailbroken();
    results[SecurityCheckType.rooted] = !isRootedResult;
    if (isRootedResult) {
      warnings.add('Perangkat di-root/jailbreak');
    }

    // 3. Mock location check
    final isMockedResult = isMockLocation(position);
    results[SecurityCheckType.mockLocation] = !isMockedResult;
    if (isMockedResult) {
      warnings.add('Lokasi palsu terdeteksi (mock location)');
    }

    // 4. Time manipulation check
    final timeCheck = await checkDeviceTime();
    results[SecurityCheckType.timeManipulation] = !timeCheck.isManipulated;
    if (timeCheck.isManipulated) {
      warnings.add(
        'Waktu perangkat dimanipulasi (selisih ${timeCheck.difference.inMinutes} menit)'
      );
    }

    // 5. Impossible movement check
    final isImpossibleResult = await isImpossibleMovement(position);
    results[SecurityCheckType.impossibleMovement] = !isImpossibleResult;
    if (isImpossibleResult) {
      warnings.add('Pergerakan mencurigakan terdeteksi');
    }

    // 6. Debug mode check (only in production)
    final isDebugBlocked = shouldBlockDebugMode();
    results[SecurityCheckType.debugMode] = !isDebugBlocked;
    if (isDebugBlocked) {
      warnings.add('Aplikasi berjalan dalam mode debug (tidak aman)');
    }

    // Store current position for next check
    storeLastPosition(position);

    // Calculate overall security score
    final passedChecks = results.values.where((passed) => passed).length;
    final totalChecks = results.length;
    final securityScore = (passedChecks / totalChecks * 100).round();

    final isSecure = warnings.isEmpty;

    AppLogger.info(
      'SecurityService: Check complete - Score: $securityScore%, '
      'Passed: $passedChecks/$totalChecks, Warnings: ${warnings.length}',
    );

    return SecurityReport(
      isSecure: isSecure,
      securityScore: securityScore,
      results: results,
      warnings: warnings,
      accurateTime: timeCheck.networkTime,
    );
  }

  /// Clear stored position data
  void clearStoredPosition() {
    _lastKnownPosition = null;
    _lastPositionTime = null;
    AppLogger.info('SecurityService: Stored position cleared');
  }

  /// Clear cached NTP time
  void clearCachedTime() {
    _cachedNetworkTime = null;
    _lastSyncTime = null;
    AppLogger.info('SecurityService: Cached time cleared');
  }
}

// ========== DATA MODELS ==========

/// Result of time manipulation check
class TimeCheckResult {
  final bool isManipulated;
  final DateTime deviceTime;
  final DateTime networkTime;
  final Duration difference;

  TimeCheckResult({
    required this.isManipulated,
    required this.deviceTime,
    required this.networkTime,
    required this.difference,
  });

  @override
  String toString() {
    return 'TimeCheckResult{isManipulated: $isManipulated, difference: ${difference.inMinutes}min}';
  }
}

/// Types of security checks
enum SecurityCheckType {
  emulator,
  rooted,
  mockLocation,
  timeManipulation,
  impossibleMovement,
  debugMode,
}

/// Comprehensive security report
class SecurityReport {
  final bool isSecure;
  final int securityScore; // 0-100
  final Map<SecurityCheckType, bool> results;
  final List<String> warnings;
  final DateTime accurateTime;

  SecurityReport({
    required this.isSecure,
    required this.securityScore,
    required this.results,
    required this.warnings,
    required this.accurateTime,
  });

  /// Get warning message for user display
  String getWarningMessage() {
    if (warnings.isEmpty) return '';
    return warnings.join('\n');
  }

  /// Check if specific security check passed
  bool checkPassed(SecurityCheckType type) {
    return results[type] ?? false;
  }

  @override
  String toString() {
    return 'SecurityReport{isSecure: $isSecure, score: $securityScore%, warnings: ${warnings.length}}';
  }
}
