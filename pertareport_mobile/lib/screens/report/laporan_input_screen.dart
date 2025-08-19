import 'package:flutter/material.dart';

class LaporanInputScreen extends StatefulWidget {
  const LaporanInputScreen({Key? key}) : super(key: key);

  @override
  State<LaporanInputScreen> createState() => _LaporanInputScreenState();
}

class _LaporanInputScreenState extends State<LaporanInputScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _teamSupportController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  String? _selectedKegiatan;
  final List<String> _kegiatanOptions = [
    "Maintenance",
    "Inspection",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Input Laporan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                  labelText: "Lokasi",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Lokasi wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teamSupportController,
                decoration: const InputDecoration(
                  labelText: "Nama Team Support",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nama team wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedKegiatan,
                items: _kegiatanOptions.map((String kegiatan) {
                  return DropdownMenuItem<String>(
                    value: kegiatan,
                    child: Text(kegiatan),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: "Jenis Kegiatan",
                  border: OutlineInputBorder(),
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
              TextFormField(
                controller: _remarkController,
                decoration: const InputDecoration(
                  labelText: "Remark",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: kirim ke API Django
                    final data = {
                      "lokasi": _lokasiController.text,
                      "team_support": _teamSupportController.text,
                      "kegiatan": _selectedKegiatan,
                      "remark": _remarkController.text,
                    };
                    print("Data laporan: $data");

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Laporan berhasil disimpan (dummy)!")),
                    );
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
