import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.loadReports,
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeSelector(controller),
                  const SizedBox(height: 16),
                  _buildQuickFilters(controller),
                  const SizedBox(height: 12),
                  _buildSummaryCards(controller),
                  const SizedBox(height: 16),
                  _buildSearchAndFilter(controller),
                  const SizedBox(height: 16),
                  _buildReportTable(controller),
                ],
              ),
            ),
          ),
        ),
        _buildExportButton(controller),
      ],
    );
  }

  Widget _buildDateRangeSelector(AdminDashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: AppColors.grey600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Periode',
                  style: TextStyle(fontSize: 12, color: AppColors.grey500),
                ),
                Obx(
                  () => Text(
                    controller.dateRangeText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) => TextButton.icon(
              onPressed: () => controller.selectCustomDateRange(context),
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Ubah'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(AdminDashboardController controller) {
    return Obx(
      () {
        final quickType = controller.quickFilterType.value;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickFilterChip(
                label: 'Hari Ini',
                isSelected: quickType == 'today',
                onTap: () => controller.setQuickFilter('today'),
              ),
              const SizedBox(width: 8),
              _buildQuickFilterChip(
                label: 'Kemarin',
                isSelected: quickType == 'yesterday',
                onTap: () => controller.setQuickFilter('yesterday'),
              ),
              const SizedBox(width: 8),
              _buildQuickFilterChip(
                label: '7 Hari Terakhir',
                isSelected: quickType == 'last_7_days',
                onTap: () => controller.setQuickFilter('last_7_days'),
              ),
              const SizedBox(width: 8),
              _buildQuickFilterChip(
                label: 'Bulan Ini',
                isSelected: quickType == 'this_month',
                onTap: () => controller.setQuickFilter('this_month'),
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (context) => _buildQuickFilterChip(
                  label: 'Custom',
                  isSelected: quickType == 'custom',
                  onTap: () => controller.selectCustomDateRange(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.grey700,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(AdminDashboardController controller) {
    return Obx(() {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildReportSummaryCard(
                  title: 'Total Hadir',
                  value: controller.reportTotalHadir.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReportSummaryCard(
                  title: 'Terlambat',
                  value: controller.reportTotalTerlambat.toString(),
                  icon: Icons.access_time,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReportSummaryCard(
                  title: 'Total Izin',
                  value: controller.reportTotalIzin.toString(),
                  icon: Icons.event_note_outlined,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReportSummaryCard(
                  title: 'Total Sakit',
                  value: controller.reportTotalSakit.toString(),
                  icon: Icons.medical_services_outlined,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildReportSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
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
            style: const TextStyle(fontSize: 10, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(AdminDashboardController controller) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Obx(
              () => TextField(
                onChanged: controller.onSearchReport,
                controller: TextEditingController(text: controller.searchQuery.value)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.searchQuery.value.length),
                  ),
                decoration: InputDecoration(
                  hintText: 'Cari berdasarkan nama atau NPK...',
                  hintStyle: const TextStyle(color: AppColors.grey400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.grey400),
                          onPressed: () => controller.onSearchReport(''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.statusFilter.value.isEmpty ? null : controller.statusFilter.value,
                  hint: const Text('Status', style: TextStyle(color: AppColors.grey600)),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey600),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Semua')),
                    DropdownMenuItem(value: 'hadir', child: Text('Hadir')),
                    DropdownMenuItem(value: 'terlambat', child: Text('Terlambat')),
                    DropdownMenuItem(value: 'izin', child: Text('Izin')),
                    DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                  ],
                  onChanged: (value) {
                    controller.onStatusFilterChanged(value);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportTable(AdminDashboardController controller) {
    return Obx(
      () {
        final attendanceData = controller.filteredReportList;

        if (attendanceData.isEmpty) {
          return _buildEmptyReportState();
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.05),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Absensi (${attendanceData.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.grey100),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Nama',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'NPK',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Tanggal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Jam Masuk',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Jam Keluar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: attendanceData.map((attendance) {
                    final nama = attendance.user?.name ?? '-';
                    final npk = attendance.user?.npk ?? '-';
                    // Use toLocal() for display to show date in user's timezone
                    final tanggal = DateFormat('dd/MM/yyyy', 'id_ID').format(attendance.tanggal.toLocal());
                    final jamMasuk = attendance.clockIn.isNotEmpty
                        ? attendance.clockIn.substring(0, attendance.clockIn.length >= 5 ? 5 : attendance.clockIn.length)
                        : '-';
                    final jamKeluar = attendance.clockOut?.isNotEmpty == true
                        ? attendance.clockOut!.substring(0, attendance.clockOut!.length >= 5 ? 5 : attendance.clockOut!.length)
                        : '-';
                    final status = _formatStatusDisplay(attendance.status);
                    final statusColor = _getStatusColor(attendance.status);

                    return DataRow(
                      cells: [
                        DataCell(Text(nama)),
                        DataCell(Text(npk, style: const TextStyle(fontFamily: 'monospace'))),
                        DataCell(Text(tanggal)),
                        DataCell(Text(jamMasuk)),
                        DataCell(Text(jamKeluar)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return 'Hadir';
      case 'terlambat':
        return 'Terlambat';
      case 'izin':
      case 'ijin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return AppColors.success;
      case 'terlambat':
        return AppColors.warning;
      case 'izin':
      case 'ijin':
        return AppColors.orange;
      case 'sakit':
        return AppColors.error;
      default:
        return AppColors.grey600;
    }
  }

  Widget _buildEmptyReportState() {
    return Obx(
      () {
        final controller = Get.find<AdminDashboardController>();
        final hasFilter = controller.statusFilter.value.isNotEmpty || controller.searchQuery.value.isNotEmpty;
        final noResults = hasFilter && controller.filteredReportList.isEmpty;

        return Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.05),
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
                child: Icon(
                  noResults ? Icons.search_off : Icons.assessment_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                noResults ? 'Tidak Ada Hasil' : 'Belum Ada Data Laporan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                noResults
                    ? 'Tidak ada data yang sesuai dengan filter atau pencarian Anda.'
                    : 'Data laporan untuk ${controller.dateRangeText} belum tersedia.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.grey500,
                ),
                textAlign: TextAlign.center,
              ),
              if (noResults)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton.icon(
                    onPressed: () {
                      controller.onSearchReport('');
                      controller.onStatusFilterChanged('');
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Filter'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportButton(AdminDashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(
        () => ElevatedButton.icon(
          onPressed: controller.isLoadingReports.value
              ? null
              : controller.exportReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.textWhite,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: controller.isLoadingReports.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.textWhite,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.download),
          label: Text(
            controller.isLoadingReports.value
                ? 'Mengexport...'
                : 'Export Laporan',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
