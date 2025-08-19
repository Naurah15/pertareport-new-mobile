// screens/laporan_input_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pertareport_mobile/services/api_service.dart';
import 'package:pertareport_mobile/models/report/jenis_kegiatan.dart';

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
  List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isLoadingJenisKegiatan = true;

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

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      setState(() {
        _selectedImages = images.map((xfile) => File(xfile.path)).toList();
      });
    } catch (e) {
      _showErrorDialog('Error picking images: $e');
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      _selectedImages.removeAt(index);
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
      if (_selectedImages.isNotEmpty) {
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
                    // Lokasi Field
                    TextFormField(
                      controller: _lokasiController,
                      decoration: const InputDecoration(
                        labelText: "Lokasi",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Lokasi wajib diisi" : null,
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
                            if (_selectedImages.isNotEmpty)
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.file(
                                              _selectedImages[index],
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
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