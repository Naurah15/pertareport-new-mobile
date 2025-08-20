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

class LaporanInputScreen extends StatefulWidget {
  const LaporanInputScreen({Key? key}) : super(key: key);

  @override
  State<LaporanInputScreen> createState() => _LaporanInputScreenState();
}

class _LaporanInputScreenState extends State<LaporanInputScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _teamSupportController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _kegiatanOtherController = TextEditingController();

  // State variables
  List<JenisKegiatan> _jenisKegiatanList = [];
  JenisKegiatan? _selectedKegiatan;
  List<File> _selectedImages = []; // mobile/desktop
  List<Uint8List> _webSelectedImages = []; // khusus web

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

  Future<void> _pickImages() async {
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
          _webSelectedImages = bytesImages;
        });
      } else {
        // MOBILE/DESKTOP → simpan sebagai File
        setState(() {
          _selectedImages = images.map((xfile) => File(xfile.path)).toList();
        });
      }
    } catch (e) {
      _showErrorDialog('Gagal memilih gambar. Detail: $e');
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      if (kIsWeb) {
        _webSelectedImages.removeAt(index);
      } else {
        _selectedImages.removeAt(index);
      }
    });
  }

  Future<void> _submitLaporan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedKegiatan == null) {
      _showErrorDialog('Please select a jenis kegiatan');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Create laporan
      final createResponse = await ApiService.createLaporan(
        lokasi: _lokasiController.text,
        namaTeamSupport: _teamSupportController.text,
        remark: _remarkController.text,
        kegiatanId: _selectedKegiatan!.id,
        kegiatanOther: _selectedKegiatan!.nama.toLowerCase() == 'other' 
            ? _kegiatanOtherController.text 
            : null,
      );

      // Step 2: Upload images if any
      if (kIsWeb && _webSelectedImages.isNotEmpty) {
        // Handle web image upload here if your API supports it
        // You might need to modify ApiService to handle Uint8List for web
      } else if (_selectedImages.isNotEmpty) {
        await ApiService.uploadImages(
          laporanId: createResponse.laporanId,
          images: _selectedImages,
        );
      }

      // Success
      _showSuccessDialog(
        'Laporan berhasil dibuat!\n'
        'No. Dokumen: ${createResponse.noDocument}'
      );

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
    _remarkController.clear();
    _kegiatanOtherController.clear();
    setState(() {
      _selectedKegiatan = null;
      _selectedImages.clear();
      _webSelectedImages.clear();
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
                                        'INPUT LAPORAN',
                                        style: TextStyle(
                                          fontSize: 12,
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
                                                  'Form Laporan Kegiatan',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                    color: textPrimary,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Lengkapi semua data dengan benar',
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
                                    const SizedBox(height: 20),

                                    // Jenis Kegiatan Dropdown
                                    _buildDropdown(),
                                    const SizedBox(height: 20),

                                    // Other Kegiatan Field (only show if "Other" is selected)
                                    if (_selectedKegiatan?.nama.toLowerCase() == 'other') ...[
                                      _buildTextField(
                                        controller: _kegiatanOtherController,
                                        label: 'Kegiatan Lainnya',
                                        icon: Icons.edit_note_rounded,
                                        color: pertaminaOrange,
                                        validator: (value) => _selectedKegiatan?.nama.toLowerCase() == 'other' && 
                                                           (value == null || value.isEmpty)
                                            ? "Kegiatan lainnya wajib diisi" 
                                            : null,
                                      ),
                                      const SizedBox(height: 20),
                                    ],

                                    // Remark Field
                                    _buildTextField(
                                      controller: _remarkController,
                                      label: 'Remark',
                                      icon: Icons.note_alt_outlined,
                                      color: pertaminaRed,
                                      maxLines: 3,
                                      validator: (value) =>
                                          value == null || value.isEmpty ? "Remark wajib diisi" : null,
                                    ),
                                    const SizedBox(height: 20),

                                    // Image Selection Card
                                    _buildImageCard(),
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

  Widget _buildDropdown() {
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
      child: DropdownButtonFormField<JenisKegiatan>(
        value: _selectedKegiatan,
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
              color: pertaminaBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.work_outline_rounded,
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
          errorStyle: TextStyle(
            color: pertaminaRed,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _selectedKegiatan = value;
          });
        },
        validator: (value) =>
            value == null ? "Jenis kegiatan wajib dipilih" : null,
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: pertaminaOrange.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: pertaminaOrange.withOpacity(0.1),
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
                  color: pertaminaOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  color: pertaminaOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Foto Kegiatan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${kIsWeb ? _webSelectedImages.length : _selectedImages.length} foto',
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [pertaminaOrange, Colors.orange[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: pertaminaOrange.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_a_photo_rounded, size: 18),
              label: const Text('Pilih Foto', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if ((kIsWeb ? _webSelectedImages : _selectedImages).isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: kIsWeb ? _webSelectedImages.length : _selectedImages.length,
                itemBuilder: (context, index) {
                  final imageWidget = kIsWeb
                      ? Image.memory(
                          _webSelectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );

                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageWidget,
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: pertaminaRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 14,
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
                      Icons.save_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Simpan Laporan',
                    style: TextStyle(
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
          'Report Management System',
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
    _remarkController.dispose();
    _kegiatanOtherController.dispose();
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