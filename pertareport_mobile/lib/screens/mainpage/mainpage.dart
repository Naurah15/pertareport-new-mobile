//import 'package:pertareport_mobile/models/report/laporan.dart';//
import 'package:pertareport_mobile/screens/user_profile/profile_detail.dart';
import 'package:pertareport_mobile/screens/history/history_page.dart';
//import 'package:pertareport_mobile/screens/report/laporan_list.dart';//
import 'package:pertareport_mobile/screens/report/laporan_input_screen.dart';
import 'package:pertareport_mobile/widgets/mainpage/meal_list_view.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MyDiaryScreen extends StatefulWidget {
  const MyDiaryScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _MyDiaryScreenState createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  // Pertamina Corporate Colors
  static const Color pertaminaBlue = Color(0xFF0E4A6B);
  static const Color pertaminaGreen = Color(0xFF1B5E20);
  static const Color lightBlue = Color(0xFF1565C0);
  static const Color backgroundGray = Color(0xFFF5F7FA);
  static const Color softBlue = Color(0xFFE8EDF5);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF34495E);

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    
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

    addAllListData();

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  void addAllListData() {
    const int count = 4;

    // Inside Pertareport Title (moved to top)
    listViews.add(
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Inside Pertareport",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your corporate reporting dashboard",
              style: TextStyle(
                fontSize: 16,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    // Meals List View (after Inside Pertareport title)
    listViews.add(
      MealsListView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: const Interval((1 / count) * 1, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController,
      ),
    );

    // Reporting Form Card
    listViews.add(
      AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value * 0.3),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
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
                          Icons.assignment_turned_in_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Report',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'Submit your work progress today',
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LaporanInputScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_document,
                            color: pertaminaBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Start Reporting',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: pertaminaBlue,
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
        },
      ),
    );

    // Review Reports Card
    listViews.add(
      AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_floatingAnimation.value * 0.2),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [pertaminaGreen, Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: pertaminaGreen.withOpacity(0.3),
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
                          Icons.rate_review_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Review Reports',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'Review and approve team reports',
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryPage()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            color: pertaminaGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Review Now',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: pertaminaGreen,
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
        },
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundGray,
            softBlue,
            Color(0xFFDCE7F0),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricPatternPainter(),
            ),
          ),
          
          // Brand accent overlays
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
                        colors: [
                          pertaminaBlue.withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Positioned(
            bottom: -100,
            left: -100,
            child: AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-_floatingAnimation.value * 0.3, -_floatingAnimation.value),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          pertaminaGreen.withOpacity(0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: <Widget>[
                getMainListViewUI(),
                getAppBarUI(),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: pertaminaBlue.withOpacity(0.15 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 15.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Pertamina Logo
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [pertaminaBlue, lightBlue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.local_gas_station_rounded,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'PERTAMINA',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Pertareport',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 0.5,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: pertaminaBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.bookmark_rounded,
                                      color: pertaminaBlue,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ProfileDetail()),
                                      );
                                    },
                                    child: Text(
                                      'Profile',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        letterSpacing: 0.2,
                                        color: textPrimary,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
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

    // Create subtle hexagonal pattern
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