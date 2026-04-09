import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshData,
                color: AppColors.primary,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonthSelector(context),
                      const SizedBox(height: 16),
                      _buildSummaryCards(),
                      const SizedBox(height: 24),
                      _buildReportTable(),
                    ],
                  ),
                ),
              ),
            ),
            _buildExportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.goBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Laporan Absensi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Periode',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Obx(() => Text(
                      controller.monthYearText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => controller.selectMonth(context),
            icon: const Icon(Icons.edit_calendar),
            label: const Text('Ubah'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      int totalHadir = 0;
      int totalIzin = 0;
      int totalSakit = 0;
      
      for (var report in controller.reports) {
        totalHadir += (report['hadir'] as int?) ?? 0;
        totalIzin += (report['izin'] as int?) ?? 0;
        totalSakit += (report['sakit'] as int?) ?? 0;
      }

      return Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              title: 'Total Hadir',
              value: totalHadir.toString(),
              icon: Icons.check_circle_outline,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              title: 'Total Izin',
              value: totalIzin.toString(),
              icon: Icons.event_note_outlined,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              title: 'Total Sakit',
              value: totalSakit.toString(),
              icon: Icons.medical_services_outlined,
              color: Colors.red,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTable() {
    return Obx(() {
      final reportData = controller.reports;

      if (reportData.isEmpty) {
        return _buildEmptyReportState();
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Detail Absensi Karyawan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                columns: const [
                  DataColumn(label: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('NPK', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Hadir', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Izin', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Sakit', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: reportData.map((report) {
                  return DataRow(
                    cells: [
                      DataCell(Text(report['name'] ?? '-')),
                      DataCell(Text(report['npk'] ?? '-')),
                      DataCell(Text(
                        report['hadir'].toString(),
                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        report['izin'].toString(),
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                      )),
                      DataCell(Text(
                        report['sakit'].toString(),
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyReportState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assessment_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Data Laporan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data laporan untuk ${controller.monthYearText} belum tersedia.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() => ElevatedButton.icon(
            onPressed: controller.isLoading.value ? null : controller.exportReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.download),
            label: Text(
              controller.isLoading.value ? 'Mengexport...' : 'Export Laporan',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
    );
  }
}
