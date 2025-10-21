// lib/screens/history/widgets/history_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:pertareport_mobile/models/history/history_filter.dart';

class HistoryFilterWidget extends StatefulWidget {
  final HistoryFilter filter;
  final Function(HistoryFilter) onFilterChanged;

  const HistoryFilterWidget({
    Key? key,
    required this.filter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<HistoryFilterWidget> createState() => _HistoryFilterWidgetState();
}

class _HistoryFilterWidgetState extends State<HistoryFilterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  // Pertamina Corporate Colors
  static const Color pertaminaBlue = Color(0xFF0E4A6B);
  static const Color lightBlue = Color(0xFF1565C0);
  static const Color softBlue = Color(0xFFE8EDF5);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF34495E);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: pertaminaBlue.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Collapsible Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: pertaminaBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.filter_list_rounded,
                        color: pertaminaBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filter Laporan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          if (widget.filter.hasFilters)
                            Text(
                              _getActiveFiltersText(),
                              style: TextStyle(
                                fontSize: 12,
                                color: lightBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else
                            Text(
                              'Tap untuk mengatur filter',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Filter indicator badges
                    if (widget.filter.hasDateFilter)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: lightBlue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: lightBlue.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.date_range, size: 12, color: lightBlue),
                            const SizedBox(width: 4),
                            Text(
                              'Tanggal',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Expand/collapse icon
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expandable content
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Container(
                      decoration: BoxDecoration(
                        color: softBlue.withOpacity(0.3),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Divider(height: 1, color: borderColor),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildFilterContent(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Range Section
        const Text(
          'Rentang Tanggal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Date pickers row
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                label: 'Tanggal Mulai',
                date: widget.filter.startDate,
                onDateSelected: (date) {
                  widget.onFilterChanged(widget.filter.copyWith(startDate: date));
                },
                icon: Icons.calendar_today_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDatePicker(
                label: 'Tanggal Selesai',
                date: widget.filter.endDate,
                onDateSelected: (date) {
                  widget.onFilterChanged(widget.filter.copyWith(endDate: date));
                },
                icon: Icons.event_rounded,
                firstDate: widget.filter.startDate,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            if (widget.filter.hasDateFilter) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    widget.onFilterChanged(
                      widget.filter.copyWith(
                        clearStartDate: true, 
                        clearEndDate: true
                      ),
                    );
                  },
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: const Text('Hapus Filter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textSecondary,
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onFilterChanged(widget.filter);
                  _toggleExpanded(); // Auto collapse after applying
                },
                icon: const Icon(Icons.search_rounded, size: 16),
                label: const Text('Terapkan Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pertaminaBlue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required Function(DateTime) onDateSelected,
    required IconData icon,
    DateTime? firstDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectDate(
              onDateSelected,
              initialDate: date,
              firstDate: firstDate,
            ),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: date != null ? pertaminaBlue : borderColor,
                  width: date != null ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  if (date != null)
                    BoxShadow(
                      color: pertaminaBlue.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: date != null ? pertaminaBlue : textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      date != null ? _formatDate(date) : 'Pilih tanggal',
                      style: TextStyle(
                        fontSize: 13,
                        color: date != null ? textPrimary : textSecondary.withOpacity(0.7),
                        fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (date != null)
                    GestureDetector(
                      onTap: () {
                        if (label.contains('Mulai')) {
                          widget.onFilterChanged(
                            widget.filter.copyWith(clearStartDate: true),
                          );
                        } else {
                          widget.onFilterChanged(
                            widget.filter.copyWith(clearEndDate: true),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    Function(DateTime) onDateSelected, {
    DateTime? initialDate,
    DateTime? firstDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: pertaminaBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textPrimary,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _getActiveFiltersText() {
    List<String> filters = [];
    
    if (widget.filter.startDate != null || widget.filter.endDate != null) {
      if (widget.filter.startDate != null && widget.filter.endDate != null) {
        filters.add('${_formatDate(widget.filter.startDate!)} - ${_formatDate(widget.filter.endDate!)}');
      } else if (widget.filter.startDate != null) {
        filters.add('Mulai: ${_formatDate(widget.filter.startDate!)}');
      } else {
        filters.add('Sampai: ${_formatDate(widget.filter.endDate!)}');
      }
    }
    
    return filters.join(' • ');
  }
}