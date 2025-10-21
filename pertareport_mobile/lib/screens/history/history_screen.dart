// lib/screens/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pertareport_mobile/models/history/history_laporan.dart';
import 'package:pertareport_mobile/models/history/history_filter.dart';
import 'package:pertareport_mobile/services/history_api_service.dart';
import 'package:pertareport_mobile/widgets/history/history_filter_widget.dart';
import 'package:pertareport_mobile/widgets/history/history_item_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryLaporan> _laporanList = [];
  List<HistoryLaporan> _filteredLaporanList = [];
  bool _isLoading = false;
  String _error = '';
  HistoryFilter _filter = HistoryFilter();
  final TextEditingController _searchController = TextEditingController();

  // Pertamina Corporate Colors (matching MyDiaryScreen)
  static const Color pertaminaBlue = Color(0xFF0E4A6B);
  static const Color pertaminaRed = Color(0xFFD32F2F);
  static const Color lightBlue = Color(0xFF1565C0);
  static const Color backgroundGray = Color(0xFFF5F7FA);
  static const Color softBlue = Color(0xFFE8EDF5);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF34495E);

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filter = _filter.copyWith(searchQuery: _searchController.text);
      _applyFilters();
    });
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final laporanList = await HistoryApiService.getHistoryList(filter: _filter);
      setState(() {
        _laporanList = laporanList;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredLaporanList = _laporanList;

    // Apply search filter
    if (_filter.searchQuery != null && _filter.searchQuery!.isNotEmpty) {
      final query = _filter.searchQuery!.toLowerCase();
      _filteredLaporanList = _filteredLaporanList.where((laporan) {
        return laporan.noDocument.toLowerCase().contains(query) ||
              laporan.lokasi.toLowerCase().contains(query) ||
              laporan.namaTeamSupport.toLowerCase().contains(query);
      }).toList();
    }

    // Apply date range filter
    if (_filter.startDate != null) {
      _filteredLaporanList = _filteredLaporanList.where((laporan) {
        final laporanDate = DateTime(
          laporan.tanggalProses.year,
          laporan.tanggalProses.month,
          laporan.tanggalProses.day,
        );
        final filterStartDate = DateTime(
          _filter.startDate!.year,
          _filter.startDate!.month,
          _filter.startDate!.day,
        );
        return laporanDate.isAtSameMomentAs(filterStartDate) || 
              laporanDate.isAfter(filterStartDate);
      }).toList();
    }

    if (_filter.endDate != null) {
      _filteredLaporanList = _filteredLaporanList.where((laporan) {
        final laporanDate = DateTime(
          laporan.tanggalProses.year,
          laporan.tanggalProses.month,
          laporan.tanggalProses.day,
        );
        final filterEndDate = DateTime(
          _filter.endDate!.year,
          _filter.endDate!.month,
          _filter.endDate!.day,
        );
        return laporanDate.isAtSameMomentAs(filterEndDate) || 
              laporanDate.isBefore(filterEndDate);
      }).toList();
    }
  }

  void _onFilterChanged(HistoryFilter newFilter) {
    setState(() {
      _filter = newFilter;
    });
    _loadHistory();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _filter = HistoryFilter();
    });
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundGray,
              softBlue,
              Color(0xFFDCE7F0),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: pertaminaBlue.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: pertaminaBlue,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Daftar Laporan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (_filter.hasFilters)
                      GestureDetector(
                        onTap: _clearFilters,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: pertaminaRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.clear_all_rounded,
                            color: pertaminaRed,
                            size: 18,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _loadHistory,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: pertaminaBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: pertaminaBlue,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search and Filter Section
              Flexible(
                flex: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: pertaminaBlue.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: softBlue,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: lightBlue.withOpacity(0.2)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari laporan...',
                            hintStyle: TextStyle(color: textSecondary.withOpacity(0.6)),
                            prefixIcon: Icon(Icons.search_rounded, color: lightBlue, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: TextStyle(color: textPrimary),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Date Filter
                      HistoryFilterWidget(
                        filter: _filter,
                        onFilterChanged: _onFilterChanged,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Content Section
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(pertaminaBlue),
                      strokeWidth: 3,
                    ),
                  ),
                )
              else if (_error.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: pertaminaRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 40,
                              color: pertaminaRed,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi Kesalahan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error,
                            style: TextStyle(color: textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _loadHistory,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [pertaminaBlue, lightBlue],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Coba Lagi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_filteredLaporanList.isEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: textSecondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.inbox_rounded,
                                size: 40,
                                color: textSecondary.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _filter.hasFilters ? 'Tidak Ada Hasil' : 'Belum Ada Laporan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _filter.hasFilters
                                  ? 'Tidak ada laporan yang sesuai dengan filter'
                                  : 'Belum ada laporan yang tersedia',
                              style: TextStyle(color: textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            if (_filter.hasFilters) ...[
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: _clearFilters,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: lightBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: lightBlue.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    'Hapus Filter',
                                    style: TextStyle(
                                      color: lightBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      // Results Summary
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: pertaminaBlue.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: lightBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.list_alt_rounded,
                                color: lightBlue,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_filteredLaporanList.length} laporan ditemukan' +
                                (_filter.dateRangeText.isNotEmpty 
                                    ? ' ${_filter.dateRangeText.toLowerCase()}'
                                    : ''),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Laporan List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredLaporanList.length,
                          itemBuilder: (context, index) {
                            final laporan = _filteredLaporanList[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: HistoryItemWidget(
                                laporan: laporan,
                                onTap: () => _showLaporanDetails(laporan),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLaporanDetails(HistoryLaporan laporan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          laporan.noDocument,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: pertaminaBlue,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close_rounded, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: Colors.grey[200]),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Info
                        _buildDetailRow('Lokasi', laporan.lokasi, isClickable: true, onTap: () {
                          final url = HistoryApiService.getGoogleMapsUrl(laporan.lokasi);
                          launchUrl(Uri.parse(url));
                        }),
                        _buildDetailRow('Team Support', laporan.namaTeamSupport),
                        _buildDetailRow('Tanggal Proses', _formatDateTime(laporan.tanggalProses)),

                        const SizedBox(height: 24),

                        // Kegiatan List
                        Text(
                          'Daftar Kegiatan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: pertaminaBlue,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (laporan.kegiatanList.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Tidak ada kegiatan yang tercatat',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          )
                        else
                          ...laporan.kegiatanList.map((kegiatan) => _buildKegiatanCard(kegiatan)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isClickable = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: isClickable && onTap != null
                ? GestureDetector(
                    onTap: onTap,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: pertaminaBlue,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKegiatanCard(HistoryKegiatan kegiatan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: softBlue.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: pertaminaBlue.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kegiatan.displayName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: pertaminaBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            kegiatan.remark,
            style: TextStyle(color: textSecondary),
          ),
          if (kegiatan.foto != null || kegiatan.fotoList.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (kegiatan.foto != null)
                    _buildPhotoContainer(kegiatan.foto!),
                  ...kegiatan.fotoList.map((foto) => _buildPhotoContainer(foto.foto)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoContainer(String photoUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: softBlue.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: const AlwaysStoppedAnimation<Color>(pertaminaBlue),
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              alignment: Alignment.center,
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_rounded,
                    color: Colors.grey[400],
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gagal dimuat',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}