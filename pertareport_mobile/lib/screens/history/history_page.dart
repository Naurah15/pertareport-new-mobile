// screens/history/history_page.dart
import 'package:flutter/material.dart';
import 'package:pertareport_mobile/screens/history/history_dashboard_screen.dart';
import 'package:pertareport_mobile/screens/history/history_list_screen.dart' as history;
import 'dart:math' as math;

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

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
  }

  void _setupAnimations() {
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
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
                                child: const Icon(Icons.history_rounded, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'HISTORY CENTER',
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

                  // Welcome Section
                  AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatingAnimation.value * 0.3),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
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
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.folder_shared_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Report History',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Access your submitted reports and analytics',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.9),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Main Options
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Dashboard Card
                          _buildOptionCard(
                            'Analytics Dashboard',
                            'View statistics and performance metrics',
                            Icons.analytics_rounded,
                            pertaminaGreen,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HistoryDashboardScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // History List Card
                          _buildOptionCard(
                            'All Reports',
                            'Browse and download your report history',
                            Icons.list_alt_rounded,
                            pertaminaRed,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const history.HistoryListScreen(),
                                ),
                              );

                            },
                          ),

                          const SizedBox(height: 20),

                          // Export Options Card
                          _buildOptionCard(
                            'Export Center',
                            'Bulk download and export options',
                            Icons.download_rounded,
                            pertaminaOrange,
                            () {
                              _showExportOptions(context);
                            },
                          ),

                          const Spacer(),

                          // Footer
                          _buildFooter(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 0.2),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: color.withOpacity(0.1), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 20),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: color,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: pertaminaBlue.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security_rounded, color: pertaminaBlue, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Secure & Confidential',
                style: TextStyle(
                  fontSize: 12,
                  color: pertaminaBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pertamina Retail History Center',
          style: TextStyle(
            fontSize: 11,
            color: textSecondary,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(14, 74, 107, 0.15),
                blurRadius: 20,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Export Options',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildExportOption(
                  'Export All Reports (Excel)',
                  'Download all your reports in Excel format',
                  Icons.table_chart_rounded,
                  pertaminaGreen,
                  () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Excel export will be available soon!'),
                        backgroundColor: pertaminaGreen,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildExportOption(
                  'Export All Reports (PDF)',
                  'Download all your reports in PDF format',
                  Icons.picture_as_pdf_rounded,
                  pertaminaRed,
                  () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF export will be available soon!'),
                        backgroundColor: pertaminaRed,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildExportOption(
                  'Custom Export',
                  'Select specific reports and date ranges',
                  Icons.tune_rounded,
                  pertaminaOrange,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const history.HistoryListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildExportOption(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
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