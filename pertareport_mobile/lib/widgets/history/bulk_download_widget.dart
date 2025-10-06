// lib/widgets/history/bulk_download_widget.dart
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
  Widget build(BuildContext context) {
    if (!hasData) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_download_rounded,
            color: textSecondary,
            size: 18,
          ),
          const SizedBox(width: 8),
          const Text(
            'Download:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          
          // Excel button
          _buildCompactButton(
            context: context,
            icon: Icons.table_chart_rounded,
            label: 'Excel',
            color: pertaminaGreen,
            onPressed: () => _downloadBulk(context, 'excel'),
          ),
          
          const SizedBox(width: 8),
          
          // PDF button
          _buildCompactButton(
            context: context,
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF',
            color: pertaminaRed,
            onPressed: () => _downloadBulk(context, 'pdf'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFilterSummary() {
    List<String> filters = [];
    
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      filters.add('pencarian');
    }
    
    if (filter.startDate != null || filter.endDate != null) {
      filters.add('tanggal');
    }
    
    return filters.join(', ');
  }

  Future<void> _downloadBulk(BuildContext context, String type) async {
    try {
      // Show downloading indicator with better styling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text('Menyiapkan download ${type.toUpperCase()}...'),
            ],
          ),
          backgroundColor: pertaminaBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      if (kIsWeb) {
        // For web, open download URL directly
        final url = await HistoryApiService.getBulkDownloadUrl(
          type: type,
          filter: filter,
        );
        await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
        
        // Show success message for web
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Download ${type.toUpperCase()} dimulai'),
                ],
              ),
              backgroundColor: pertaminaGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        // For mobile, download file bytes
        final bytes = await HistoryApiService.downloadBulkFile(
          type,
          filter: filter,
        );
        
        // Handle file saving - you might want to use file_picker or path_provider packages
        // For now, just show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('File ${type.toUpperCase()} berhasil didownload (${bytes.length} bytes)'),
                ],
              ),
              backgroundColor: pertaminaGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error download ${type.toUpperCase()}: $e'),
                ),
              ],
            ),
            backgroundColor: pertaminaRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}