// lib/screens/history/widgets/history_item_widget.dart
import 'package:flutter/material.dart';
import 'package:pertareport_mobile/models/history/history_laporan.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pertareport_mobile/services/history_api_service.dart';

class HistoryItemWidget extends StatelessWidget {
  final HistoryLaporan laporan;
  final VoidCallback? onTap;

  const HistoryItemWidget({
    Key? key,
    required this.laporan,
    this.onTap,
  }) : super(key: key);

  static const Color pertaminaRed = Color(0xFFE31E24);
  static const Color pertaminaBlue = Color(0xFF003876);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with document number
              Text(
                laporan.noDocument,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: pertaminaBlue,
                ),
              ),

              const SizedBox(height: 12),

              // Location with clickable link
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final url = HistoryApiService.getGoogleMapsUrl(laporan.lokasi);
                        launchUrl(Uri.parse(url));
                      },
                      child: Text(
                        laporan.lokasi,
                        style: const TextStyle(
                          color: pertaminaBlue,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Team Support
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Team Support: ${laporan.namaTeamSupport}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Date
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Tanggal Proses: ${_formatDateTime(laporan.tanggalProses)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              if (laporan.kegiatanList.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Kegiatan preview
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment, size: 16, color: pertaminaBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Kegiatan (${laporan.kegiatanList.length}):',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: pertaminaBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...laporan.kegiatanList.take(2).map((kegiatan) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            const Text('• ', style: TextStyle(color: pertaminaBlue)),
                            Expanded(
                              child: Text(
                                kegiatan.displayName,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (laporan.kegiatanList.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(left: 24, top: 4),
                        child: Text(
                          'dan ${laporan.kegiatanList.length - 2} kegiatan lainnya...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.assignment_outlined, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Tidak ada kegiatan yang tercatat',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],

              // Tap to view more indicator
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tap untuk melihat detail',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey[600],
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}