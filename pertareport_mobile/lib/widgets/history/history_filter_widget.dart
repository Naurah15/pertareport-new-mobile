// lib/screens/history/widgets/history_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:pertareport_mobile/models/history/history_filter.dart';

class HistoryFilterWidget extends StatelessWidget {
  final HistoryFilter filter;
  final Function(HistoryFilter) onFilterChanged;

  const HistoryFilterWidget({
    Key? key,
    required this.filter,
    required this.onFilterChanged,
  }) : super(key: key);

  static const Color pertaminaBlue = Color(0xFF003876);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: pertaminaBlue),
              const SizedBox(width: 8),
              const Text(
                'Filter & Pencarian Laporan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pertaminaBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal Mulai',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectStartDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFF8FAFC),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20, color: pertaminaBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                filter.startDate != null
                                    ? _formatDate(filter.startDate!)
                                    : 'Pilih tanggal mulai',
                                style: TextStyle(
                                  color: filter.startDate != null ? Colors.black : Colors.grey,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal Selesai',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectEndDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFF8FAFC),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20, color: pertaminaBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                filter.endDate != null
                                    ? _formatDate(filter.endDate!)
                                    : 'Pilih tanggal selesai',
                                style: TextStyle(
                                  color: filter.endDate != null ? Colors.black : Colors.grey,
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
              const SizedBox(width: 12),
              Column(
                children: [
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => onFilterChanged(filter),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pertaminaBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list, size: 16),
                        SizedBox(width: 4),
                        Text('Filter'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Clear filters button
          if (filter.hasDateFilter) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => onFilterChanged(
                filter.copyWith(clearStartDate: true, clearEndDate: true),
              ),
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Hapus Filter Tanggal'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: filter.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: pertaminaBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onFilterChanged(filter.copyWith(startDate: picked));
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: filter.endDate ?? DateTime.now(),
      firstDate: filter.startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: pertaminaBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onFilterChanged(filter.copyWith(endDate: picked));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}