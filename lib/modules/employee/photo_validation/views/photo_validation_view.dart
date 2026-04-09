import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../controllers/photo_validation_controller.dart';

class PhotoValidationView extends GetView<PhotoValidationController> {
  const PhotoValidationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildPhotoArea()),
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
                  Text(
                    controller.isClockOut.value
                        ? 'Absensi Keluar'
                        : 'Validasi Foto',
                    style: const TextStyle(
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

  Widget _buildPhotoArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(flex: 2, child: _buildPhotoContainer()),
          const SizedBox(height: 24),
          _buildCaptureButton(),
          const SizedBox(height: 16),
          _buildErrorMessage(),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPhotoContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Photo or Placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Obx(() {
              final imageFile = controller.capturedImage.value;
              if (imageFile != null) {
                return Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              }
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 120, color: AppColors.grey400),
                    const SizedBox(height: 16),
                    Text(
                      'Ambil foto selfie',
                      style: TextStyle(color: AppColors.grey500, fontSize: 16),
                    ),
                  ],
                ),
              );
            }),
          ),
          // Face frame overlay
          Center(
            child: Container(
              width: 200,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textPrimary.withValues(alpha: 0.8),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Corner brackets
          const Positioned(
            top: 50,
            left: 50,
            child: PhotoCornerBracket(isTop: true, isLeft: true),
          ),
          const Positioned(
            top: 50,
            right: 50,
            child: PhotoCornerBracket(isTop: true, isLeft: false),
          ),
          const Positioned(
            bottom: 50,
            left: 50,
            child: PhotoCornerBracket(isTop: false, isLeft: true),
          ),
          const Positioned(
            bottom: 50,
            right: 50,
            child: PhotoCornerBracket(isTop: false, isLeft: false),
          ),
          // Loading overlay
          Obx(
            () => controller.isLoading.value
                ? Container(
                    color: AppColors.textPrimary.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.textWhite,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.takePhoto,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.grey800,
          foregroundColor: AppColors.textWhite,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Ambil Foto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Obx(() {
      // Show warning if cannot clock out yet
      if (controller.isClockOut.value && !controller.canSubmit.value) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warning),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.timeUntilCanSubmit.value,
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Show photo validation error
      if (!controller.isPhotoValid.value) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warning),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.errorMessage.value.isNotEmpty
                      ? controller.errorMessage.value
                      : 'Foto Selfie tidak jelas',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textWhite,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Validasi Lokasi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(
            () => ElevatedButton(
              onPressed:
                  controller.capturedImage.value != null &&
                      !controller.isLoading.value &&
                      controller.canSubmit.value
                  ? controller.submitAttendance
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: AppColors.grey400,
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textWhite,
                      ),
                    )
                  : Text(
                      controller.isClockOut.value
                          ? 'Clock Out'
                          : 'Kirim Absensi',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class PhotoCornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const PhotoCornerBracket({
    super.key,
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _CornerBracketPainter(isTop: isTop, isLeft: isLeft),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  const _CornerBracketPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = ui.Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
