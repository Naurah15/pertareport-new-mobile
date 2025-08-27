// screens/history/history_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pertareport_mobile/services/api_service.dart';
import 'package:pertareport_mobile/models/history/history_summary.dart';
import 'package:pertareport_mobile/screens/history/history_list_screen.dart';
import 'dart:math' as math;

class HistoryDashboardScreen extends StatefulWidget {
  const HistoryDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HistoryDashboardScreen> createState() => _HistoryDashboardScreenState();
}

class _HistoryDashboardScreenState extends State<HistoryDashboardScreen>
    with TickerProviderStateMixin {
  HistorySummary? _summary;
  bool _isLoading = true;
  
  // Animation controllers
  late AnimationController _floatingController;
  late AnimationController _fadeController;
  late AnimationController _countController;
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

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSummary();
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

    _countController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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

  Future<void> _loadSummary() async {
    try {
      // Create instance of ApiService and call the method
      final summary = await ApiService.getHistorySummary();
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
      _countController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading dashboard: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    _countController.reset();
    await _loadSummary();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: pertaminaRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.error_outline, color: pertaminaRed, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Error', style: TextStyle(color: pertaminaRed, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: textSecondary, fontSize: 14)),
        actions: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [pertaminaRed, Colors.red[400]!]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
            colors: [backgroundGray, softBlue, Color(0xFFDCE7F0)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(painter: GeometricPatternPainter()),
            ),

            // Background overlays
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
                          colors: [pertaminaBlue.withOpacity(0.08), Colors.transparent],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Header Section
                    Container(
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
                              icon: const Icon(Icons.arrow_back_ios_rounded, color: pertaminaBlue, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const Spacer(),
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
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [pertaminaBlue, pertaminaGreen],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                  ),
                                  child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'DASHBOARD',
                                  style: TextStyle(
                                    fontSize: 11,
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

                    // Content
                    Flexible(
                      flex: 1,
                      child: _isLoading
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
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(color: pertaminaBlue, strokeWidth: 3),
                                    SizedBox(height: 20),
                                    Text(
                                      'Loading Dashboard...',
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
                          : RefreshIndicator(
                              onRefresh: _refreshData,
                              color: pertaminaBlue,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: [
                                    _buildWelcomeCard(),
                                    const SizedBox(height: 20),
                                    _buildStatsGrid(),
                                    const SizedBox(height: 20),
                                    _buildActivityChart(),
                                    const SizedBox(height: 20),
                                    _buildQuickActions(),
                                    const SizedBox(height: 100),
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

  Widget _buildWelcomeCard() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 0.3),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [pertaminaBlue, lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: pertaminaBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.dashboard_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'History Dashboard',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _summary?.lastReportFormatted ?? 'Loading...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_summary != null)
                    Row(
                      children: [
                        _buildQuickStat(
                          '${_summary!.totalReports}',
                          'Total Reports',
                          Icons.description_rounded,
                        ),
                        const SizedBox(width: 20),
                        _buildQuickStat(
                          '${_summary!.totalActivities}',
                          'Activities',
                          Icons.work_rounded,
                        ),
                        const SizedBox(width: 20),
                        _buildQuickStat(
                          '${_summary!.totalPhotos}',
                          'Photos',
                          Icons.photo_camera_rounded,
                        ),
                      ],
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Flexible(
      flex: 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _countController,
              builder: (context, child) {
                final animatedValue = (int.parse(value) * _countController.value).round();
                return Text(
                  '$animatedValue',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                );
              },
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_summary == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: _buildStatCard(
                'Average Activities',
                _summary!.averageActivitiesPerReport.toStringAsFixed(1),
                Icons.trending_up_rounded,
                pertaminaGreen,
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              flex: 1,
              child: _buildStatCard(
                'Average Photos',
                _summary!.averagePhotosPerReport.toStringAsFixed(1),
                Icons.photo_library_rounded,
                pertaminaOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLocationCard(),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _countController,
            builder: (context, child) {
              final animatedValue = (double.parse(value) * _countController.value);
              return Text(
                animatedValue.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    if (_summary == null || _summary!.mostActiveLocation.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: pertaminaRed.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: pertaminaRed.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: pertaminaRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_rounded, color: pertaminaRed, size: 24),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Most Active Location',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _summary!.mostActiveLocation,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    if (_summary == null || _summary!.activityTypeCount.isEmpty) {
      return const SizedBox.shrink();
    }

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Types',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ..._summary!.activityTypeCount.entries.take(5).map((entry) {
            final colors = [pertaminaBlue, pertaminaGreen, pertaminaRed, pertaminaOrange, lightBlue];
            final color = colors[_summary!.activityTypeCount.keys.toList().indexOf(entry.key) % colors.length];
            final maxValue = _summary!.activityTypeCount.values.reduce(math.max);
            final percentage = entry.value / maxValue;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: _buildActionCard(
                'View All Reports',
                'Browse your history',
                Icons.list_rounded,
                pertaminaBlue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryListScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              flex: 1,
              child: _buildActionCard(
                'Export Data',
                'Download reports',
                Icons.download_rounded,
                pertaminaGreen,
                () {
                  // Implement bulk export
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bulk export feature coming soon!'),
                      backgroundColor: pertaminaGreen,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _fadeController.dispose();
    _countController.dispose();
    super.dispose();
  }
}

// Custom painter for background pattern
class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0E4A6B).withOpacity(0.02)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

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