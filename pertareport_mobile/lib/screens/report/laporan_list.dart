import 'package:flutter/material.dart';
import 'package:pertareport_mobile/models/report/laporan.dart';


class LaporanListScreen extends StatelessWidget {
  final List<Laporan> laporanList;

  const LaporanListScreen({Key? key, required this.laporanList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Laporan")),
      body: ListView.builder(
        itemCount: laporanList.length,
        itemBuilder: (context, index) {
          final laporan = laporanList[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(laporan.noDocument),
              subtitle: Text("${laporan.lokasi} • ${laporan.namaTeamSupport}"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LaporanDetailScreen(laporan: laporan),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class LaporanDetailScreen extends StatelessWidget {
  final Laporan laporan;

  const LaporanDetailScreen({Key? key, required this.laporan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail ${laporan.noDocument}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lokasi: ${laporan.lokasi}"),
            Text("Team: ${laporan.namaTeamSupport}"),
            Text("Tanggal: ${laporan.tanggalProses}"),
            const SizedBox(height: 16),
            const Text("Kegiatan:", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: laporan.kegiatanList.length,
                itemBuilder: (context, index) {
                  final kegiatan = laporan.kegiatanList[index];
                  return ListTile(
                    title: Text(kegiatan.kegiatanOther ?? kegiatan.kegiatan.nama),
                    subtitle: Text(kegiatan.remark),
                    leading: Image.network(kegiatan.foto, width: 50, height: 50, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
