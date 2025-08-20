// screens/laporan_input_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pertareport_mobile/services/api_service.dart';
import 'package:pertareport_mobile/models/report/jenis_kegiatan.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'package:geolocator/geolocator.dart';

class LaporanInputScreen extends StatefulWidget {
  const LaporanInputScreen({Key? key}) : super(key: key);

  @override
  State<LaporanInputScreen> createState() => _LaporanInputScreenState();
}

class _LaporanInputScreenState extends State<LaporanInputScreen> {
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

  @override
  void initState() {
    super.initState();
    _loadJenisKegiatan();
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
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Input Laporan"),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: _isLoadingJenisKegiatan
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Location Field with GPS button
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _lokasiController,
                                    decoration: const InputDecoration(
                                      labelText: "Koordinat Lokasi",
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.location_on),
                                      hintText: "Latitude, Longitude",
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty ? "Lokasi wajib diisi" : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                                  icon: _isLoadingLocation 
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.gps_fixed),
                                  label: const Text('GPS'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  _locationStatus.contains("berhasil") 
                                      ? Icons.check_circle 
                                      : _locationStatus.contains("Gagal") || _locationStatus.contains("ditolak")
                                          ? Icons.error 
                                          : Icons.info,
                                  size: 16,
                                  color: _locationStatus.contains("berhasil") 
                                      ? Colors.green 
                                      : _locationStatus.contains("Gagal") || _locationStatus.contains("ditolak")
                                          ? Colors.red 
                                          : Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _locationStatus,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _locationStatus.contains("berhasil") 
                                        ? Colors.green 
                                        : _locationStatus.contains("Gagal") || _locationStatus.contains("ditolak")
                                            ? Colors.red 
                                            : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Team Support Field
                    TextFormField(
                      controller: _teamSupportController,
                      decoration: const InputDecoration(
                        labelText: "Nama Team Support",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Nama team wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Jenis Kegiatan Dropdown
                    DropdownButtonFormField<JenisKegiatan>(
                      value: _selectedKegiatan,
                      items: _jenisKegiatanList.map((JenisKegiatan kegiatan) {
                        return DropdownMenuItem<JenisKegiatan>(
                          value: kegiatan,
                          child: Text(kegiatan.nama),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: "Jenis Kegiatan",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedKegiatan = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? "Jenis kegiatan wajib dipilih" : null,
                    ),
                    const SizedBox(height: 16),

                    // Other Kegiatan Field (only show if "Other" is selected)
                    if (_selectedKegiatan?.nama.toLowerCase() == 'other') ...[
                      TextFormField(
                        controller: _kegiatanOtherController,
                        decoration: const InputDecoration(
                          labelText: "Kegiatan Lainnya",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit),
                        ),
                        validator: (value) => _selectedKegiatan?.nama.toLowerCase() == 'other' && 
                                           (value == null || value.isEmpty)
                            ? "Kegiatan lainnya wajib diisi" 
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Remark Field
                    TextFormField(
                      controller: _remarkController,
                      decoration: const InputDecoration(
                        labelText: "Remark",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Remark wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Image Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Foto Kegiatan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _pickImages,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Pilih Foto'),
                            ),
                            const SizedBox(height: 8),
                            if ((kIsWeb ? _webSelectedImages : _selectedImages).isNotEmpty)
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
                                      margin: const EdgeInsets.only(right: 8),
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
                                              onTap: () => _removeImage(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitLaporan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Simpan Laporan",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    _teamSupportController.dispose();
    _remarkController.dispose();
    _kegiatanOtherController.dispose();
    super.dispose();
  }
}