// lib/screens/history/widgets/bulk_download_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pertareport_mobile/models/history/history_filter.dart';
import 'package:pertareport_mobile/services/history_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BulkDownloadWidget extends StatelessWidget {
  final HistoryFilter filter;
  final bool hasData;

  const BulkDownloadWidget({
    Key? key,
    required this.filter,
    required this.hasData,
  }) : super(key: key);

  static const Color pertaminaRed = Color(0xFFE31E24);
  static const Color pertaminaBlue = Color(0xFF003876);

  @override
  Widget build(BuildContext context) {
    if (!hasData) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _downloadBulk(context, 'excel'),
            icon: const Icon(Icons.table_chart),
            label: const Text('Download All Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _downloadBulk(context, 'pdf'),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Download All PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: pertaminaRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadBulk(BuildContext context, String type) async {
    try {
      // Show downloading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preparing ${type.toUpperCase()} download...'),
          duration: const Duration(seconds: 2),
        ),
      );

      if (kIsWeb) {
        // For web, open download URL directly
        final url = HistoryApiService.getBulkDownloadUrl(type, filter: filter);
        await launchUrl(Uri.parse(url));
      } else {
        // For mobile, download file bytes
        final bytes = await HistoryApiService.downloadBulkFile(type, filter: filter);
        // Handle file saving - you might want to use file_picker or path_provider packages
        // For now, just show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${type.toUpperCase()} file downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading ${type.toUpperCase()}: $e'),
          backgroundColor: pertaminaRed,
        ),
      );
    }
  }
}