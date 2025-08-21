// screens/laporan_input_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pertareport_mobile/services/api_service.dart';
import 'package:pertareport_mobile/models/report/jenis_kegiatan.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class ActivityEntry {
  JenisKegiatan? jenisKegiatan;
  String kegiatanOther;
  String remark;
  List<File> images; // mobile/desktop
  List<Uint8List> webImages; // khusus web

  ActivityEntry({
    this.jenisKegiatan,
    this.kegiatanOther = '',
    this.remark = '',
    List<File>? images,
    List<Uint8List>? webImages,
  }) : images = images ?? [], 
       webImages = webImages ?? [];

  bool get isValid {
    return jenisKegiatan != null && 
           remark.isNotEmpty &&
           (jenisKegiatan!.nama.toLowerCase() != 'other' || kegiatanOther.isNotEmpty);
  }
}

class LaporanInputScreen extends StatefulWidget {
  const LaporanInputScreen({Key? key}) : super(key: key);

  @override
  State<LaporanInputScreen> createState() => _LaporanInputScreenState();
}

class _LaporanInputScreenState extends State<LaporanInputScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers for location and team
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _teamSupportController = TextEditingController();

  // State variables
  List<JenisKegiatan> _jenisKegiatanList = [];
  List<ActivityEntry> _activityEntries = [ActivityEntry()]; // Start with one activity
  List<TextEditingController> _remarkControllers = [TextEditingController()];
  List<TextEditingController> _kegiatanOtherControllers = [TextEditingController()];

  bool _isLoading = false;
  bool _isLoadingJenisKegiatan = true;
  bool _isLoadingLocation = false;
  String _locationStatus = "Tekan tombol untuk mendapatkan lokasi";

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
  static const Color lightBlue = Color(0xFF1565C0);
  static const Color backgroundGray = Color(0xFFF5F7FA);
  static const Color softBlue = Color(0xFFE8EDF5);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF34495E);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadJenisKegiatan();
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

  Future<void> _loadJenisKegiatan() async {
    try {
      final jenisKegiatanList = await ApiService.getJenisKegiatan();
      setState(() {
        _jenisKegiatanList = jenisKegiatanList;
        _isLoadingJenisKegiatan = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingJenisKegiatan = false;
      });
      _showErrorDialog('Error loading jenis kegiatan: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = "Mendapatkan lokasi...";
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _locationStatus = "Layanan lokasi tidak aktif";
        });
        _showErrorDialog('Layanan lokasi tidak aktif. Silakan aktifkan GPS.');
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _locationStatus = "Izin lokasi ditolak";
          });
          _showErrorDialog('Izin akses lokasi ditolak.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _locationStatus = "Izin lokasi ditolak permanen";
        });
        _showErrorDialog('Izin akses lokasi ditolak permanen. Silakan aktifkan di pengaturan aplikasi.');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double lat = position.latitude;
      double lon = position.longitude;
      
      // Format coordinates to 6 decimal places
      String coordinates = "${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}";
      
      setState(() {
        _lokasiController.text = coordinates;
        _isLoadingLocation = false;
        _locationStatus = "Lokasi berhasil didapatkan";
      });

    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationStatus = "Gagal mendapatkan lokasi";
      });
      _showErrorDialog('Gagal mendapatkan lokasi: $e');
    }
  }

  void _addActivityEntry() {
    setState(() {
      _activityEntries.add(ActivityEntry());
      _remarkControllers.add(TextEditingController());
      _kegiatanOtherControllers.add(TextEditingController());
    });
  }

  void _removeActivityEntry(int index) {
    if (_activityEntries.length > 1) {
      setState(() {
        _remarkControllers[index].dispose();
        _kegiatanOtherControllers[index].dispose();
        _activityEntries.removeAt(index);
        _remarkControllers.removeAt(index);
        _kegiatanOtherControllers.removeAt(index);
      });
    }
  }

  Future<void> _pickImagesForActivity(int activityIndex) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1080,
      );

      if (images.isEmpty) return;

      if (kIsWeb) {
        // WEB → simpan sebagai bytes
        List<Uint8List> bytesImages = [];
        for (var img in images) {
          bytesImages.add(await img.readAsBytes());
        }
        setState(() {
          _activityEntries[activityIndex].webImages.addAll(bytesImages);
        });
      } else {
        // MOBILE/DESKTOP → simpan sebagai File
        setState(() {
          _activityEntries[activityIndex].images.addAll(
            images.map((xfile) => File(xfile.path)).toList()
          );
        });
      }
    } catch (e) {
      _showErrorDialog('Gagal memilih gambar. Detail: $e');
    }
  }

  Future<void> _removeImageFromActivity(int activityIndex, int imageIndex) async {
    setState(() {
      if (kIsWeb) {
        _activityEntries[activityIndex].webImages.removeAt(imageIndex);
      } else {
        _activityEntries[activityIndex].images.removeAt(imageIndex);
      }
    });
  }

  Future<void> _submitLaporan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate all activity entries
    for (int i = 0; i < _activityEntries.length; i++) {
      final activity = _activityEntries[i];
      activity.remark = _remarkControllers[i].text;
      activity.kegiatanOther = _kegiatanOtherControllers[i].text;

      if (!activity.isValid) {
        _showErrorDialog('Kegiatan ke-${i + 1} tidak lengkap. Pastikan semua field terisi dengan benar.');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      int laporanId;
      String noDocument;
      List<int> kegiatanLaporanIds = [];

      // Step 1: Create main laporan with first activity
      final firstActivity = _activityEntries[0];
      final createResponse = await ApiService.createLaporan(
        lokasi: _lokasiController.text,
        namaTeamSupport: _teamSupportController.text,
        remark: firstActivity.remark,
        kegiatanId: firstActivity.jenisKegiatan!.id,
        kegiatanOther: firstActivity.jenisKegiatan!.nama.toLowerCase() == 'other' 
            ? firstActivity.kegiatanOther 
            : null,
      );

      laporanId = createResponse.laporanId;
      noDocument = createResponse.noDocument;
      kegiatanLaporanIds.add(createResponse.kegiatanLaporanId);

      // Step 2: Add remaining activities to the same laporan
      for (int i = 1; i < _activityEntries.length; i++) {
        final activity = _activityEntries[i];
        
        final addKegiatanResponse = await ApiService.addKegiatanToLaporan(
          laporanId: laporanId,
          remark: activity.remark,
          kegiatanId: activity.jenisKegiatan!.id,
          kegiatanOther: activity.jenisKegiatan!.nama.toLowerCase() == 'other' 
              ? activity.kegiatanOther 
              : null,
        );

        kegiatanLaporanIds.add(addKegiatanResponse.kegiatanLaporanId);
      }

      // Step 3: Upload images for each kegiatan separately
      for (int i = 0; i < _activityEntries.length; i++) {
        final activity = _activityEntries[i];
        final kegiatanLaporanId = kegiatanLaporanIds[i];
        
        if (!kIsWeb && activity.images.isNotEmpty) {
          await ApiService.uploadImagesForKegiatan(
            kegiatanLaporanId: kegiatanLaporanId,
            images: activity.images,
          );
        } else if (kIsWeb && activity.webImages.isNotEmpty) {
          // Handle web images if needed
          print('Web images detected for kegiatan ${i + 1} but upload method needs implementation');
        }
      }

      // Calculate total images
      int totalImages = 0;
      for (var activity in _activityEntries) {
        totalImages += kIsWeb ? activity.webImages.length : activity.images.length;
      }

      // Success message
      String successMessage = 'Laporan Multi-Kegiatan berhasil dibuat!\n\n';
      successMessage += 'Nomor Dokumen: $noDocument\n';
      successMessage += 'Total Kegiatan: ${_activityEntries.length}\n';
      successMessage += 'Total Foto: $totalImages\n\n';
      successMessage += 'Kegiatan yang dibuat:\n';
      for (int i = 0; i < _activityEntries.length; i++) {
        final activity = _activityEntries[i];
        String kegiatanName = activity.jenisKegiatan!.nama.toLowerCase() == 'other' 
            ? activity.kegiatanOther 
            : activity.jenisKegiatan!.nama;
        successMessage += '${i + 1}. $kegiatanName\n';
      }

      _showSuccessDialog(successMessage);

      // Reset form
      _resetForm();

    } catch (e) {
      _showErrorDialog('Error creating laporan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    _lokasiController.clear();
    _teamSupportController.clear();
    
    // Dispose existing controllers
    for (var controller in _remarkControllers) {
      controller.dispose();
    }
    for (var controller in _kegiatanOtherControllers) {
      controller.dispose();
    }
    
    setState(() {
      _activityEntries = [ActivityEntry()];
      _remarkControllers = [TextEditingController()];
      _kegiatanOtherControllers = [TextEditingController()];
      _locationStatus = "Tekan tombol untuk mendapatkan lokasi";
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
            Text(
              'Error',
              style: TextStyle(
                color: pertaminaRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [pertaminaRed, Colors.red[400]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: pertaminaGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.check_circle_outline, color: pertaminaGreen, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Success',
              style: TextStyle(
                color: pertaminaGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [pertaminaGreen, Colors.green[400]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: GeometricPatternPainter(),
              ),
            ),
            
            // Brand accent overlays
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
                          colors: [
                            pertaminaBlue.withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            Positioned(
              bottom: -100,
              left: -100,
              child: AnimatedBuilder(
                animation: _floatingAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(-_floatingAnimation.value * 0.3, -_floatingAnimation.value),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            pertaminaGreen.withOpacity(0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main Content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _isLoadingJenisKegiatan
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
                              CircularProgressIndicator(
                                color: pertaminaBlue,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Loading Data...',
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
                    : Column(
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
                                    icon: Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: pertaminaBlue,
                                      size: 20,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                const Spacer(),
                                // Page Title with Icon
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
                                        child: const Icon(
                                          Icons.assignment_add,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'SATU LAPORAN (${_activityEntries.length} KEGIATAN)',
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

                          // Form Content
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Animated floating header
                                    AnimatedBuilder(
                                      animation: _floatingAnimation,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(0, _floatingAnimation.value * 0.5),
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            margin: const EdgeInsets.only(bottom: 30),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(25),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: pertaminaBlue.withOpacity(0.12),
                                                  blurRadius: 30,
                                                  offset: const Offset(0, 15),
                                                  spreadRadius: -5,
                                                ),
                                              ],
                                              border: Border.all(
                                                color: pertaminaBlue.withOpacity(0.1),
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [pertaminaBlue, pertaminaGreen, pertaminaRed],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  child: const Icon(
                                                    Icons.description_rounded,
                                                    size: 40,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Laporan Multi Kegiatan',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                    color: textPrimary,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Satu nomor laporan dengan beberapa kegiatan',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textSecondary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    // Location Field with GPS button
                                    _buildLocationCard(),
                                    const SizedBox(height: 20),

                                    // Team Support Field
                                    _buildTextField(
                                      controller: _teamSupportController,
                                      label: 'Nama Team Support',
                                      icon: Icons.people_outline_rounded,
                                      color: pertaminaGreen,
                                      validator: (value) =>
                                          value == null || value.isEmpty ? "Nama team wajib diisi" : null,
                                    ),
                                    const SizedBox(height: 30),

                                    // Activities Header
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [pertaminaBlue.withOpacity(0.1), softBlue],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: pertaminaBlue.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: pertaminaBlue,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.work_history_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Daftar Kegiatan (${_activityEntries.length} item)',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: textPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  'Satu laporan dengan beberapa kegiatan berbeda',
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
                                              gradient: LinearGradient(
                                                colors: [pertaminaGreen, Colors.green[400]!],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: pertaminaGreen.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: IconButton(
                                              onPressed: _addActivityEntry,
                                              icon: const Icon(Icons.add_rounded, color: Colors.white),
                                              tooltip: 'Tambah Kegiatan',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Activity Entries List
                                    ...List.generate(_activityEntries.length, (index) {
                                      return _buildActivityCard(index);
                                    }),

                                    const SizedBox(height: 30),

                                    // Submit Button
                                    _buildSubmitButton(),
                                    const SizedBox(height: 40),

                                    // Footer
                                    _buildFooter(),
                                    const SizedBox(height: 30),
                                  ],
                                ),
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

  Widget _buildActivityCard(int index) {
    final activity = _activityEntries[index];
    final colors = [pertaminaBlue, pertaminaGreen, pertaminaRed, pertaminaOrange];
    final color = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
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
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kegiatan ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              if (_activityEntries.length > 1)
                Container(
                  decoration: BoxDecoration(
                    color: pertaminaRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _removeActivityEntry(index),
                    icon: Icon(Icons.delete_outline_rounded, color: pertaminaRed, size: 18),
                    tooltip: 'Hapus Kegiatan',
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Jenis Kegiatan Dropdown
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<JenisKegiatan>(
              value: activity.jenisKegiatan,
              items: _jenisKegiatanList.map((JenisKegiatan kegiatan) {
                return DropdownMenuItem<JenisKegiatan>(
                  value: kegiatan,
                  child: Text(
                    kegiatan.nama,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: "Jenis Kegiatan",
                labelStyle: TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.work_outline_rounded,
                    color: color,
                    size: 18,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: borderColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: color,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: pertaminaRed,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: pertaminaRed,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: backgroundGray,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                errorStyle: TextStyle(
                  color: pertaminaRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  activity.jenisKegiatan = value;
                });
              },
              validator: (value) =>
                  value == null ? "Jenis kegiatan wajib dipilih" : null,
            ),
          ),
          const SizedBox(height: 16),

          // Other Kegiatan Field (only show if "Other" is selected)
          if (activity.jenisKegiatan?.nama.toLowerCase() == 'other') ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _kegiatanOtherControllers[index],
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: "Kegiatan Lainnya",
                  labelStyle: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: pertaminaOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: pertaminaOrange,
                      size: 18,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: pertaminaOrange,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: pertaminaRed,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: pertaminaRed,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: backgroundGray,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  errorStyle: TextStyle(
                    color: pertaminaRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                validator: (value) => activity.jenisKegiatan?.nama.toLowerCase() == 'other' && 
                                   (value == null || value.isEmpty)
                    ? "Kegiatan lainnya wajib diisi" 
                    : null,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Remark Field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: _remarkControllers[index],
              maxLines: 3,
              style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: "Detail",
                labelStyle: TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.note_alt_outlined,
                    color: color,
                    size: 18,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: borderColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: color,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: pertaminaRed,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: pertaminaRed,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: backgroundGray,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                errorStyle: TextStyle(
                  color: pertaminaRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? "Remark wajib diisi" : null,
            ),
          ),
          const SizedBox(height: 16),

          // Image Selection for this activity
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Foto Kegiatan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${kIsWeb ? activity.webImages.length : activity.images.length} foto',
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImagesForActivity(index),
                    icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                    label: const Text('Pilih Foto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                if ((kIsWeb ? activity.webImages : activity.images).isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: kIsWeb ? activity.webImages.length : activity.images.length,
                      itemBuilder: (context, imageIndex) {
                        final imageWidget = kIsWeb
                            ? Image.memory(
                                activity.webImages[imageIndex],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                activity.images[imageIndex],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              );

                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageWidget,
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImageFromActivity(index, imageIndex),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: pertaminaRed,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: color,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: pertaminaRed,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: pertaminaRed,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: backgroundGray,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorStyle: TextStyle(
            color: pertaminaRed,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: pertaminaBlue.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: pertaminaBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: pertaminaBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: pertaminaBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Lokasi Kegiatan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _lokasiController,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: "Koordinat Lokasi",
                      labelStyle: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      hintText: "Latitude, Longitude",
                      hintStyle: TextStyle(
                        color: textSecondary.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: pertaminaBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.my_location_rounded,
                          color: pertaminaBlue,
                          size: 18,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: borderColor,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: pertaminaBlue,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: pertaminaRed,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: pertaminaRed,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: backgroundGray,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Lokasi wajib diisi" : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [pertaminaGreen, Colors.green[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: pertaminaGreen.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.gps_fixed_rounded, size: 18),
                  label: const Text('GPS', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _locationStatus.contains("berhasil") 
                    ? Icons.check_circle_rounded 
                    : _locationStatus.contains("Gagal") || _locationStatus.contains("ditolak")
                        ? Icons.error_rounded 
                        : Icons.info_rounded,
                size: 16,
                color: _locationStatus.contains("berhasil") 
                    ? pertaminaGreen 
                    : _locationStatus.contains("Gagal") || _locationStatus.contains("ditolak")
                        ? pertaminaRed 
                        : pertaminaBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _locationStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _locationStatus.contains("berhasil") 
                        ? pertaminaGreen 
                        : _locationStatus.contains("Gagal") || _locationStatus.contains("ditolak")
                            ? pertaminaRed 
                            : textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [pertaminaBlue, lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: pertaminaBlue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitLaporan,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Kirim Laporan (${_activityEntries.length} Kegiatan)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Powered by Pertamina Retail',
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF7F8C8D),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Single Report Multi-Activity System',
          style: TextStyle(
            fontSize: 9,
            color: const Color(0xFFBDC3C7),
            fontWeight: FontWeight.w300,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _fadeController.dispose();
    _lokasiController.dispose();
    _teamSupportController.dispose();
    
    // Dispose all controllers
    for (var controller in _remarkControllers) {
      controller.dispose();
    }
    for (var controller in _kegiatanOtherControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }
}

// Custom painter matching design pattern
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