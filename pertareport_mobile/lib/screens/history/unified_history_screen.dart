// screens/history/unified_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pertareport_mobile/services/api_service.dart';
import 'package:pertareport_mobile/models/history/history_laporan.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class UnifiedHistoryScreen extends StatefulWidget {
  const UnifiedHistoryScreen({Key? key}) : super(key: key);

  @override
  State<UnifiedHistoryScreen> createState() => _UnifiedHistoryScreenState();
}

class _UnifiedHistoryScreenState extends State<UnifiedHistoryScreen>
    with TickerProviderStateMixin {
  List<HistoryLaporan> _historyList = [];
  List<HistoryLaporan> _filteredList = [];
  bool _isLoading = true;
  bool _isDownloading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Animation controllers
  late AnimationController _floatingController;
  late AnimationController _fadeController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _fadeAnimation;

  // Pertamina Corporate Colors
  static const Color pertaminaRed = Color(0xFFE31E24);
  static const Color pertaminaBlue = Color(0xFF003876);
  static const Color pertaminaDarkBlue = Color(0xFF002855);
  static const Color pertaminaGray = Color(0xFF6B7280);
  static const Color pertaminaLightGray = Color(0xFFF8FAFC);
  static const Color pertaminaDarkGray = Color(0xFF374151);
  static const Color backgroundGray = Color(0xFFF8FAFC);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadHistoryData();
  }

  void _setupAnimations() {
    _floatingController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
  }

  Future<void> _loadHistoryData() async {
      try {
        print('Starting to load history data...');
        final historyList = await ApiService.getHistoryList();
        print('Received ${historyList.length} history items');
        setState(() {
          _historyList = historyList;
          _filteredList = _historyList;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading history data: $e');
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Error loading history: $e');
      }
    }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadHistoryData();
  }

  void _filterHistory() {
    setState(() {
      _filteredList = _historyList.where((laporan) {
        return _searchQuery.isEmpty ||
            laporan.noDocument.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            laporan.lokasi.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            laporan.namaTeamSupport.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      // Sort by date (most recent first)
      _filteredList.sort((a, b) => b.tanggalProses.compareTo(a.tanggalProses));
    });
  }

  Future<void> _downloadFile(int laporanId, String type, String filename) async {
      setState(() {
        _isDownloading = true;
      });

      try {
        if (kIsWeb) {
          // Use the proper baseUrl reference from ApiService
          final url = type == 'excel' 
              ? '${ApiService.historyUrl}/history/download/excel/$laporanId/'
              : '${ApiService.historyUrl}/history/download/pdf/$laporanId/';
          
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          }
        } else {
          // Mobile download
          _showSuccessDialog('File downloaded successfully!');
        }
      } catch (e) {
        _showErrorDialog('Download failed: $e');
      } finally {
        setState(() {
          _isDownloading = false;
        });
      }
    }

  Future<void> _openLocationInMaps(String location) async {
    final url = 'https://www.google.com/maps?q=$location';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _shareReport(HistoryLaporan laporan) {
    Share.share(
      'Report: ${laporan.noDocument}\n'
      'Location: ${laporan.lokasi}\n'
      'Team: ${laporan.namaTeamSupport}\n'
      'Date: ${laporan.formattedDate}',
      subject: 'Pertamina Report - ${laporan.noDocument}',
    );
  }

  void _showHistoryDetail(HistoryLaporan laporan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailModal(laporan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundGray, const Color(0xFFE5E7EB)],
            stops: const [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating background elements
            _buildFloatingElements(),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Header Section
                    _buildHeader(),

                    // Search Section
                    _buildSearchSection(),

                    // Content
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Floating circles
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Positioned(
                top: 100 + _floatingAnimation.value,
                left: 50,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pertaminaRed.withOpacity(0.03),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Positioned(
                top: 300 - _floatingAnimation.value * 0.5,
                right: 80,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pertaminaBlue.withOpacity(0.03),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: pertaminaBlue.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: pertaminaBlue, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          Text(
            'Daftar Laporan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: pertaminaBlue,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: pertaminaBlue.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search reports...',
            hintStyle: TextStyle(color: pertaminaGray),
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: pertaminaBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.search_rounded, color: pertaminaBlue, size: 18),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: pertaminaRed),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                      _filterHistory();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
            _filterHistory();
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: pertaminaBlue.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: pertaminaBlue, strokeWidth: 3),
              const SizedBox(height: 20),
              Text(
                'Loading History...',
                style: TextStyle(
                  color: pertaminaDarkGray,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredList.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: pertaminaBlue.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: pertaminaLightGray,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.folder_open_rounded,
                  size: 60,
                  color: pertaminaGray,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No reports found'
                    : 'Tidak ada laporan yang tersedia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: pertaminaDarkGray,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try adjusting your search'
                    : 'Your submitted reports will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: pertaminaGray,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: pertaminaBlue,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100, left: 24, right: 24),
        itemCount: _filteredList.length,
        itemBuilder: (context, index) {
          final laporan = _filteredList[index];
          return _buildHistoryCard(laporan);
        },
      ),
    );
  }

  Widget _buildHistoryCard(HistoryLaporan laporan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        onTap: () => _showHistoryDetail(laporan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with document number and downloads
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          laporan.noDocument,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: pertaminaBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _openLocationInMaps(laporan.lokasi),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_rounded, color: pertaminaRed, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  laporan.lokasi,
                                  style: TextStyle(
                                    color: pertaminaBlue,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildDownloadButton(
                        () => _downloadFile(laporan.id, 'excel', '${laporan.noDocument}.xlsx'),
                        Icons.table_chart_rounded,
                        const Color(0xFF10B981),
                        'Excel',
                      ),
                      const SizedBox(width: 8),
                      _buildDownloadButton(
                        () => _downloadFile(laporan.id, 'pdf', '${laporan.noDocument}.pdf'),
                        Icons.picture_as_pdf_rounded,
                        pertaminaRed,
                        'PDF',
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Team and date info
              Text(
                'Nama Team Support: ${laporan.namaTeamSupport}',
                style: TextStyle(
                  color: pertaminaDarkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tanggal Proses: ${laporan.formattedDate}',
                style: TextStyle(
                  color: pertaminaGray,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),
              
              // Activities summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: pertaminaLightGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.work_rounded, color: pertaminaBlue, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${laporan.kegiatanList.length} Activities',
                      style: TextStyle(
                        color: pertaminaDarkGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded, color: pertaminaGray, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton(VoidCallback onPressed, IconData icon, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: _isDownloading ? null : onPressed,
          icon: _isDownloading
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
                )
              : Icon(icon, color: Colors.white, size: 16),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ),
    );
  }

  Widget _buildDetailModal(HistoryLaporan laporan) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.15),
                blurRadius: 20,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      laporan.noDocument,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: pertaminaBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${laporan.namaTeamSupport} • ${laporan.formattedDate}',
                      style: TextStyle(
                        color: pertaminaGray,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: borderColor),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildActivitiesTable(laporan),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivitiesTable(HistoryLaporan laporan) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [pertaminaBlue, pertaminaDarkBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Jenis Kegiatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                Expanded(flex: 3, child: Text('Detail / Remark', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
                Expanded(flex: 1, child: Text('Foto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
              ],
            ),
          ),
          // Table Body
          ...laporan.kegiatanList.asMap().entries.map((entry) {
            final index = entry.key;
            final kegiatan = entry.value;
            final isEven = index % 2 == 0;
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isEven ? pertaminaLightGray.withOpacity(0.5) : Colors.white,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      kegiatan.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: pertaminaDarkGray,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      kegiatan.remark,
                      style: TextStyle(
                        fontSize: 13,
                        color: pertaminaGray,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: kegiatan.foto != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              kegiatan.foto!,
                              width: 80,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error, size: 20),
                                );
                              },
                            ),
                          )
                        : Text(
                            'Tidak ada foto',
                            style: TextStyle(
                              fontSize: 12,
                              color: pertaminaGray,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: pertaminaRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.error_outline, color: pertaminaRed, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Error', style: TextStyle(color: pertaminaRed, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(message, style: TextStyle(color: pertaminaGray, fontSize: 14)),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [pertaminaRed, Colors.red.shade400]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Success', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(message, style: TextStyle(color: pertaminaGray, fontSize: 14)),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}