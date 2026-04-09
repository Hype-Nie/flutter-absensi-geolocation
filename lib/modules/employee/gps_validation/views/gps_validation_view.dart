import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../controllers/gps_validation_controller.dart';

class GpsValidationView extends GetView<GpsValidationController> {
  const GpsValidationView({super.key});

  // Map controller for programmatic camera control
  static final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMapArea()),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Get.back(),
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Validasi GPS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (controller.isClockOut.value)
                    Text(
                      'Clock Out',
                      style: TextStyle(fontSize: 14, color: AppColors.grey600),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(flex: 2, child: _buildMapContainer()),
          const SizedBox(height: 24),
          _buildLocationInfo(),
          _buildCoordinates(),
          const SizedBox(height: 32),
          _buildValidateButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMapContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Stack(
        children: [
          // Flutter Map
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Obx(() {
              final currentPos = controller.currentPosition.value;

              // Move map to user location when available
              if (currentPos != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _mapController.move(
                    LatLng(currentPos.latitude, currentPos.longitude),
                    15.0,
                  );
                });
              }

              // Default center to first location point or user's location
              final center = currentPos != null
                  ? LatLng(currentPos.latitude, currentPos.longitude)
                  : controller.validationPoints.first.position;

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 15.0,
                  minZoom: 12.0,
                  maxZoom: 18.0,
                ),
                children: [
                  // Tile Layer - OpenStreetMap
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.perhutani.absensi',
                  ),

                  // Circle Layers - 200m radius for each point
                  CircleLayer(
                    circles: controller.validationPoints
                        .map(
                          (point) => CircleMarker(
                            point: point.position,
                            radius: controller.validationRadius,
                            useRadiusInMeter: true,
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderColor: AppColors.primary.withValues(
                              alpha: 0.5,
                            ),
                            borderStrokeWidth: 2,
                          ),
                        )
                        .toList(),
                  ),

                  // Marker Layer - Location points
                  MarkerLayer(
                    markers: controller.validationPoints
                        .map(
                          (point) => Marker(
                            point: point.position,
                            width: 80,
                            height: 80,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    point.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.location_on,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  // Current Position Marker
                  if (controller.currentPosition.value != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            controller.currentPosition.value!.latitude,
                            controller.currentPosition.value!.longitude,
                          ),
                          width: 60,
                          height: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer pulse circle
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                              // Inner dot
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              );
            }),
          ),

          // Loading indicator
          Obx(
            () => controller.isLoading.value
                ? Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink(),
          ),

          // Refresh button
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  controller.refreshLocation();
                  // Also center map on current location after refresh
                  final currentPos = controller.currentPosition.value;
                  if (currentPos != null) {
                    _mapController.move(
                      LatLng(currentPos.latitude, currentPos.longitude),
                      15.0,
                    );
                  }
                },
                tooltip: 'Refresh Lokasi',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Obx(() {
      final position = controller.currentPosition.value;
      final nearest = controller.nearestPoint.value;
      final distance = controller.distanceToNearest.value;

      if (position == null) {
        return const Text(
          'Menunggu lokasi GPS...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        );
      }

      if (nearest != null && distance > 0) {
        final isValid = distance <= controller.validationRadius;
        return Column(
          children: [
            Text(
              'Lokasi terdekat: ${nearest.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Jarak: ${distance.toStringAsFixed(0)}m dari ${controller.validationRadius.toStringAsFixed(0)}m',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isValid ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }

      return const Text(
        'Pastikan Anda berada di lokasi yang sesuai\nuntuk melakukan absensi',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      );
    });
  }

  Widget _buildCoordinates() {
    return Obx(() {
      final position = controller.currentPosition.value;
      if (position != null) {
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Lat: ${position.latitude.toStringAsFixed(6)}, '
            'Lng: ${position.longitude.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 12, color: AppColors.grey600),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildValidateButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value || controller.isSubmitting.value
              ? null
              : controller.validateLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textWhite,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: AppColors.grey400,
          ),
          child: controller.isLoading.value || controller.isSubmitting.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textWhite,
                      ),
                    ),
                    if (controller.isSubmitting.value) ...[
                      const SizedBox(width: 12),
                      const Text(
                        'Mengirim Absensi...',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                )
              : const Text(
                  'Validasi Lokasi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}

