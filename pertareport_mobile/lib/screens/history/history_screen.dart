// lib/screens/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pertareport_mobile/models/history/history_laporan.dart';
import 'package:pertareport_mobile/models/history/history_filter.dart';
import 'package:pertareport_mobile/services/history_api_service.dart';
import 'package:pertareport_mobile/widgets/history/history_filter_widget.dart';
import 'package:pertareport_mobile/widgets/history/history_item_widget.dart';
import 'package:pertareport_mobile/widgets/history/bulk_download_widget.dart';
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

  // Pertamina brand colors
  static const Color pertaminaRed = Color(0xFFE31E24);
  static const Color pertaminaBlue = Color(0xFF003876);
  static const Color pertaminaLightGray = Color(0xFFF8FAFC);

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
      backgroundColor: pertaminaLightGray,
      appBar: AppBar(
        title: const Text(
          'Daftar Laporan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: pertaminaBlue,
        elevation: 0,
        actions: [
          if (_filter.hasFilters)
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.white),
              onPressed: _clearFilters,
              tooltip: 'Clear Filters',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nomor dokumen, lokasi, atau nama team support...',
                      prefixIcon: const Icon(Icons.search, color: pertaminaBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: pertaminaBlue, width: 2),
                      ),
                      filled: true,
                      fillColor: pertaminaLightGray,
                    ),
                  ),
                ),

                // Date Filter
                HistoryFilterWidget(
                  filter: _filter,
                  onFilterChanged: _onFilterChanged,
                ),

                const Divider(height: 1),
              ],
            ),
          ),

          // Results Section
          if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(pertaminaBlue),
                    ),
                    SizedBox(height: 16),
                    Text('Memuat data...'),
                  ],
                ),
              ),
            )
          else if (_error.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: pertaminaRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $_error',
                      style: const TextStyle(color: pertaminaRed),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadHistory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pertaminaBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredLaporanList.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inbox,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _filter.hasFilters
                          ? 'Tidak ada laporan yang sesuai dengan filter'
                          : 'Belum ada laporan yang tersedia',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_filter.hasFilters) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Hapus Filter'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  // Results Count & Bulk Actions
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Results Count
                        Row(
                          children: [
                            const Icon(Icons.list_alt, color: pertaminaBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Menampilkan ${_filteredLaporanList.length} laporan' +
                                (_filter.dateRangeText.isNotEmpty 
                                    ? ' ${_filter.dateRangeText.toLowerCase()}'
                                    : ''),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: pertaminaBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Bulk Download Actions
                        BulkDownloadWidget(
                          filter: _filter,
                          hasData: _filteredLaporanList.isNotEmpty,
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Laporan List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredLaporanList.length,
                      itemBuilder: (context, index) {
                        final laporan = _filteredLaporanList[index];
                        return HistoryItemWidget(
                          laporan: laporan,
                          onTap: () => _showLaporanDetails(laporan),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          laporan.noDocument,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: pertaminaBlue,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
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

                        // Download Actions
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _downloadFile(laporan.id, 'excel'),
                                icon: const Icon(Icons.table_chart),
                                label: const Text('Excel'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _downloadFile(laporan.id, 'pdf'),
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('PDF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pertaminaRed,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Kegiatan List
                        const Text(
                          'Daftar Kegiatan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: pertaminaBlue,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (laporan.kegiatanList.isEmpty)
                          const Text(
                            'Tidak ada kegiatan yang tercatat',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: isClickable && onTap != null
                ? GestureDetector(
                    onTap: onTap,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: pertaminaBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }

  // Updated _buildKegiatanCard method for history_screen.dart
  Widget _buildKegiatanCard(HistoryKegiatan kegiatan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kegiatan.displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: pertaminaBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              kegiatan.remark,
              style: const TextStyle(color: Colors.grey),
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
      ),
    );
  }

  // Helper method to build photo container with error handling
  Widget _buildPhotoContainer(String photoUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
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
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $photoUrl, Error: $error');
            return Container(
              alignment: Alignment.center,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                    size: 30,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gagal memuat',
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

  Future<void> _downloadFile(int laporanId, String type) async {
    try {
      if (kIsWeb) {
        // For web, open download URL
        final url = HistoryApiService.getDownloadUrl(laporanId, type);
        await launchUrl(Uri.parse(url));
      } else {
        // For mobile, download file bytes and save
        final bytes = await HistoryApiService.downloadLaporanFile(laporanId, type);
        // Handle file saving based on your file handling implementation
        // You might want to use file_picker or path_provider packages
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading file: $e'),
          backgroundColor: pertaminaRed,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}