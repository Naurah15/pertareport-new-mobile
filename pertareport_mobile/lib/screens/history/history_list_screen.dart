// screens/history/history_list_screen.dart
//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pertareport_mobile/services/api_service.dart';
import 'package:pertareport_mobile/models/history/history_laporan.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;

class HistoryListScreen extends StatefulWidget {
  const HistoryListScreen({Key? key}) : super(key: key);

  @override
  State<HistoryListScreen> createState() => _HistoryListScreenState();
}

class _HistoryListScreenState extends State<HistoryListScreen>
    with TickerProviderStateMixin {
  List<HistoryLaporan> _historyList = [];
  List<HistoryLaporan> _filteredList = [];
  bool _isLoading = true;
  bool _isDownloading = false;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  // Animation controllers
  late AnimationController _floatingController;
  late AnimationController _fadeController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _fadeAnimation;

  // Pertamina Corporate Colors
  static const Color pertaminaBlue = Color(0xFF0E4A6B);
  static const Color pertaminaGreen = Color(0xFF1B5E20);
  static const Color pertaminaRed = Color(0xFFD32F2F);
  static const Color pertaminaOrange = Color(0xFFFF7043);
  //static const Color lightBlue = Color(0xFF1565C0);
  static const Color backgroundGray = Color(0xFFF5F7FA);
  static const Color softBlue = Color(0xFFE8EDF5);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF34495E);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadHistoryList();
  }

  void _setupAnimations() {
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(
      begin: -8,
      end: 8,
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

  Future<void> _loadHistoryList() async {
    try {
      // Note: You'll need to implement this in your ApiService
      final historyList = await ApiService.getHistoryList();
      setState(() {
        _historyList = historyList;
        _filteredList = historyList;
        _isLoading = false;
      });
    } catch (e) {
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
    await _loadHistoryList();
  }

  void _filterHistory() {
    setState(() {
      _filteredList = _historyList.where((laporan) {
        bool matchesSearch = _searchQuery.isEmpty ||
            laporan.noDocument.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            laporan.lokasi.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            laporan.namaTeamSupport.toLowerCase().contains(_searchQuery.toLowerCase());

        bool matchesFilter = _selectedFilter == 'all' ||
            (_selectedFilter == 'recent' && 
             DateTime.now().difference(laporan.tanggalProses).inDays <= 7) ||
            (_selectedFilter == 'high_activity' && laporan.kegiatanList.length >= 3) ||
            (_selectedFilter == 'with_photos' && laporan.totalPhotos > 0);

        return matchesSearch && matchesFilter;
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
        // Web download - open URL in new tab
        final url = type == 'excel' 
            ? 'your-api-base-url/history/download/excel/$laporanId/'
            : 'your-api-base-url/history/download/pdf/$laporanId/';
        
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      } else {
        // Mobile download - you'll need to implement file download and saving
        //final bytes = await ApiService.downloadLaporanFile(laporanId, type);
        // Save to device storage and show success message
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
      'Date: ${laporan.formattedDate}\n'
      'Activities: ${laporan.kegiatanList.length}\n'
      'Photos: ${laporan.totalPhotos}',
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

  Widget _buildDetailModal(HistoryLaporan laporan) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: pertaminaBlue.withOpacity(0.15),
                blurRadius: 20,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            laporan.noDocument,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: pertaminaBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded, color: pertaminaBlue),
                            onSelected: (value) {
                              switch (value) {
                                case 'share':
                                  _shareReport(laporan);
                                  break;
                                case 'location':
                                  _openLocationInMaps(laporan.lokasi);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'share',
                                child: Row(
                                  children: [
                                    Icon(Icons.share_rounded, size: 18, color: pertaminaGreen),
                                    SizedBox(width: 12),
                                    Text('Share Report'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'location',
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 18, color: pertaminaRed),
                                    SizedBox(width: 12),
                                    Text('Open Location'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Download buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildDownloadButton(
                            laporan.id,
                            'excel',
                            'Excel',
                            Icons.table_chart_rounded,
                            pertaminaGreen,
                            '${laporan.noDocument}.xlsx',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildDownloadButton(
                            laporan.id,
                            'pdf',
                            'PDF',
                            Icons.picture_as_pdf_rounded,
                            pertaminaRed,
                            '${laporan.noDocument}.pdf',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    Divider(color: borderColor),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildInfoSection(laporan),
                    SizedBox(height: 20),
                    _buildActivitiesSection(laporan),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadButton(int laporanId, String type, String label, 
      IconData icon, Color color, String filename) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isDownloading 
            ? null 
            : () => _downloadFile(laporanId, type, filename),
        icon: _isDownloading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(HistoryLaporan laporan) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: softBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pertaminaBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoRow('Location', laporan.lokasi, Icons.location_on_rounded),
          _buildInfoRow('Team Support', laporan.namaTeamSupport, Icons.people_rounded),
          _buildInfoRow('Date', laporan.formattedDate, Icons.schedule_rounded),
          _buildInfoRow('Activities', '${laporan.kegiatanList.length} activities', Icons.work_rounded),
          _buildInfoRow('Photos', '${laporan.totalPhotos} photos', Icons.photo_camera_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: pertaminaBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: pertaminaBlue),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection(HistoryLaporan laporan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activities Detail',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 12),
        ...laporan.kegiatanList.asMap().entries.map((entry) {
          final index = entry.key;
          final kegiatan = entry.value;
          final colors = [pertaminaBlue, pertaminaGreen, pertaminaRed, pertaminaOrange];
          final color = colors[index % colors.length];

          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.task_alt_rounded, color: color, size: 16),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        kegiatan.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  kegiatan.remark,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
                if (kegiatan.foto != null || kegiatan.fotoList.isNotEmpty) ...[
                  SizedBox(height: 12),
                  _buildPhotoSection(kegiatan, color),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPhotoSection(dynamic kegiatan, Color color) {
    List<String> allPhotos = [];
    if (kegiatan.foto != null) allPhotos.add(kegiatan.foto!);
    allPhotos.addAll(kegiatan.fotoList.map((foto) => foto.foto).toList());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_camera_outlined, color: color, size: 16),
            SizedBox(width: 8),
            Text(
              'Photos (${allPhotos.length})',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allPhotos.length,
            itemBuilder: (context, photoIndex) {
              return Container(
                margin: EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    allPhotos[photoIndex],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: Icon(Icons.error, size: 20),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        _filterHistory();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? pertaminaBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? pertaminaBlue : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? pertaminaBlue : Colors.black).withOpacity(0.1),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(HistoryLaporan laporan, int index) {
    final colors = [pertaminaBlue, pertaminaGreen, pertaminaRed, pertaminaOrange];
    final color = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        onTap: () => _showHistoryDetail(laporan),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          laporan.noDocument,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          laporan.formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => _showHistoryDetail(laporan),
                      icon: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Location with clickable map link
              GestureDetector(
                onTap: () => _openLocationInMaps(laporan.lokasi),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: softBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: pertaminaBlue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: pertaminaRed, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          laporan.lokasi,
                          style: TextStyle(
                            fontSize: 12,
                            color: textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(Icons.open_in_new_rounded, color: pertaminaBlue, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Team info
              Row(
                children: [
                  Icon(Icons.people_rounded, color: color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Team: ${laporan.namaTeamSupport}',
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats and actions
              Row(
                children: [
                  _buildStatChip('${laporan.kegiatanList.length}', 'Activities', Icons.work_rounded, pertaminaGreen),
                  const SizedBox(width: 8),
                  _buildStatChip('${laporan.totalPhotos}', 'Photos', Icons.photo_camera_rounded, pertaminaBlue),
                  const Spacer(),
                  Row(
                    children: [
                      _buildQuickActionButton(
                        () => _downloadFile(laporan.id, 'excel', '${laporan.noDocument}.xlsx'),
                        Icons.table_chart_rounded,
                        pertaminaGreen,
                        'Excel',
                      ),
                      const SizedBox(width: 8),
                      _buildQuickActionButton(
                        () => _downloadFile(laporan.id, 'pdf', '${laporan.noDocument}.pdf'),
                        Icons.picture_as_pdf_rounded,
                        pertaminaRed,
                        'PDF',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(VoidCallback onPressed, IconData icon, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: IconButton(
          onPressed: _isDownloading ? null : onPressed,
          icon: _isDownloading
              ? SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
                )
              : Icon(icon, color: color, size: 16),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
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
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: pertaminaRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.error_outline, color: pertaminaRed, size: 24),
            ),
            SizedBox(width: 12),
            Text('Error', style: TextStyle(color: pertaminaRed, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(message, style: TextStyle(color: textSecondary, fontSize: 14)),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [pertaminaRed, Colors.red[400]!]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: pertaminaGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.check_circle_outline, color: pertaminaGreen, size: 24),
            ),
            SizedBox(width: 12),
            Text('Success', style: TextStyle(color: pertaminaGreen, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(message, style: TextStyle(color: textSecondary, fontSize: 14)),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [pertaminaGreen, Colors.green[400]!]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundGray, softBlue, Color(0xFFDCE7F0)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(painter: GeometricPatternPainter()),
            ),

            // Background overlays
            Positioned(
              top: -50,
              right: -50,
              child: AnimatedBuilder(
                animation: _floatingAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_floatingAnimation.value * 0.5, _floatingAnimation.value),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [pertaminaBlue.withOpacity(0.08), Colors.transparent],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
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
                              icon: Icon(Icons.arrow_back_ios_rounded, color: pertaminaBlue, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: pertaminaBlue.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [pertaminaBlue, pertaminaGreen],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.history_rounded, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'HISTORY REPORTS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: pertaminaBlue,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search and Filter Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Search Bar
                          Container(
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
                          const SizedBox(height: 16),

                          // Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('all', 'All Reports', Icons.list_rounded),
                                const SizedBox(width: 8),
                                _buildFilterChip('recent', 'Recent', Icons.schedule_rounded),
                                const SizedBox(width: 8),
                                _buildFilterChip('high_activity', 'High Activity', Icons.trending_up_rounded),
                                const SizedBox(width: 8),
                                _buildFilterChip('with_photos', 'With Photos', Icons.photo_camera_rounded),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Content
                    Expanded(
                      child: _isLoading
                          ? Center(
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
                                        color: textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _filteredList.isEmpty
                              ? Center(
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
                                            gradient: LinearGradient(
                                              colors: [pertaminaBlue.withOpacity(0.1), softBlue],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            Icons.folder_open_rounded,
                                            size: 60,
                                            color: pertaminaBlue.withOpacity(0.6),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          _searchQuery.isNotEmpty || _selectedFilter != 'all'
                                              ? 'No reports match your criteria'
                                              : 'No history reports yet',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _searchQuery.isNotEmpty || _selectedFilter != 'all'
                                              ? 'Try adjusting your search or filters'
                                              : 'Your submitted reports will appear here',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _refreshData,
                                  color: pertaminaBlue,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 100),
                                    itemCount: _filteredList.length,
                                    itemBuilder: (context, index) {
                                      final laporan = _filteredList[index];
                                      return _buildHistoryCard(laporan, index);
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for background pattern
class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0E4A6B).withOpacity(0.02)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Create subtle hexagonal pattern
    for (double x = 0; x < size.width; x += 60) {
      for (double y = 0; y < size.height; y += 60) {
        final hexPath = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60.0) * (math.pi / 180.0);
          final dx = x + 20 * math.cos(angle);
          final dy = y + 20 * math.sin(angle);
          if (i == 0) {
            hexPath.moveTo(dx, dy);
          } else {
            hexPath.lineTo(dx, dy);
          }
        }
        hexPath.close();
        canvas.drawPath(hexPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}