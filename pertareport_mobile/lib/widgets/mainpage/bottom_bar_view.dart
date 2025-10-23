import 'dart:math' as math;
import 'package:flutter/material.dart';

class BottomBarView extends StatefulWidget {
  const BottomBarView({Key? key, this.changeIndex, this.addClick})
      : super(key: key);

  final Function(int index)? changeIndex;
  final Function()? addClick;

  @override
  _BottomBarViewState createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  int selectedIndex = 0;

  // Pertamina Corporate Colors
  static const Color pertaminaBlue = Color(0xFF0E4A6B);
  static const Color pertaminaRed = Color(0xFFD32F2F);
  static const Color lightBlue = Color(0xFF1565C0);
  static const Color softBlue = Color(0xFFE8EDF5);

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animationController?.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        AnimatedBuilder(
          animation: animationController!,
          builder: (BuildContext context, Widget? child) {
            return Transform(
              transform: Matrix4.translationValues(0.0, 0.0, 0.0),
              child: PhysicalShape(
                color: Colors.white,
                elevation: 20.0,
                clipper: TabClipper(
                    radius: Tween<double>(begin: 0.0, end: 1.0)
                            .animate(CurvedAnimation(
                                parent: animationController!,
                                curve: Curves.fastOutSlowIn))
                            .value *
                        38.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        softBlue.withOpacity(0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 62,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 8, right: 8, top: 4),
                          child: Row(
                            children: <Widget>[
                              // Tab kiri - Report (index 1)
                              Expanded(
                                child: TabIconWidget(
                                  icon: Icons.description_rounded,
                                  label: 'Report',
                                  isSelected: selectedIndex == 1,
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = 1;
                                    });
                                    widget.changeIndex!(1);
                                  },
                                ),
                              ),
                              // Space untuk FAB Home di tengah
                              SizedBox(
                                width: Tween<double>(begin: 0.0, end: 1.0)
                                        .animate(CurvedAnimation(
                                            parent: animationController!,
                                            curve: Curves.fastOutSlowIn))
                                        .value *
                                    64.0,
                              ),
                              // Tab kanan - History (index 2)
                              Expanded(
                                child: TabIconWidget(
                                  icon: Icons.history_rounded,
                                  label: 'History',
                                  isSelected: selectedIndex == 2,
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = 2;
                                    });
                                    widget.changeIndex!(2);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // FAB Home di tengah (index 0)
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: SizedBox(
            width: 38 * 2.0,
            height: 38 + 62.0,
            child: Container(
              alignment: Alignment.topCenter,
              color: Colors.transparent,
              child: SizedBox(
                width: 38 * 2.0,
                height: 38 * 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ScaleTransition(
                    alignment: Alignment.center,
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                            parent: animationController!,
                            curve: Curves.fastOutSlowIn)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            lightBlue,
                            pertaminaBlue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: pertaminaBlue.withOpacity(0.4),
                            offset: const Offset(0, 8.0),
                            blurRadius: 20.0,
                            spreadRadius: 2.0,
                          ),
                          BoxShadow(
                            color: lightBlue.withOpacity(0.3),
                            offset: const Offset(0, 4.0),
                            blurRadius: 12.0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.2),
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(60),
                          onTap: () {
                            setState(() {
                              selectedIndex = 0;
                            });
                            widget.changeIndex!(0);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.home_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TabIconWidget extends StatefulWidget {
  const TabIconWidget({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  _TabIconWidgetState createState() => _TabIconWidgetState();
}

class _TabIconWidgetState extends State<TabIconWidget>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  // Pertamina Corporate Colors
  static const Color pertaminaBlue = Color(0xFF0E4A6B);
  static const Color lightBlue = Color(0xFF1565C0);
  static const Color softBlue = Color(0xFFE8EDF5);

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TabIconWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      animationController?.forward(from: 0.0);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      animationController?.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: softBlue.withOpacity(0.3),
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Lebih flexible - gunakan constraint actual
            final maxHeight = constraints.maxHeight;
            final iconSize = (maxHeight * 0.45).clamp(18.0, 24.0);
            final fontSize = widget.isSelected ? 8.5 : 8.0;
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon - TIDAK pakai Flexible di Stack
                SizedBox(
                  height: iconSize + 10,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle saat selected
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: iconSize + 10,
                        height: iconSize + 10,
                        decoration: BoxDecoration(
                          color: widget.isSelected 
                              ? softBlue 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Icon
                      AnimatedScale(
                        scale: widget.isSelected ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        child: Icon(
                          widget.icon,
                          size: iconSize,
                          color: widget.isSelected
                              ? pertaminaBlue
                              : Colors.grey.shade400,
                        ),
                      ),
                      // Decorative pulse effect
                      if (widget.isSelected)
                        ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 1.15).animate(
                            CurvedAnimation(
                              parent: animationController!,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: Container(
                            width: iconSize + 10,
                            height: iconSize + 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: lightBlue.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Minimal spacing
                const SizedBox(height: 2),
                // Label text - fixed height
                SizedBox(
                  height: 11,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: widget.isSelected
                            ? pertaminaBlue
                            : Colors.grey.shade500,
                        letterSpacing: 0.1,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Active indicator dot - conditional
                SizedBox(
                  height: 4,
                  child: widget.isSelected
                      ? Center(
                          child: Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: pertaminaBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TabClipper extends CustomClipper<Path> {
  TabClipper({this.radius = 38.0});

  final double radius;

  @override
  Path getClip(Size size) {
    final Path path = Path();

    final double v = radius * 2;
    path.lineTo(0, 0);
    path.arcTo(Rect.fromLTWH(0, 0, radius, radius), degreeToRadians(180),
        degreeToRadians(90), false);
    path.arcTo(
        Rect.fromLTWH(
            ((size.width / 2) - v / 2) - radius + v * 0.04, 0, radius, radius),
        degreeToRadians(270),
        degreeToRadians(70),
        false);

    path.arcTo(Rect.fromLTWH((size.width / 2) - v / 2, -v / 2, v, v),
        degreeToRadians(160), degreeToRadians(-140), false);

    path.arcTo(
        Rect.fromLTWH((size.width - ((size.width / 2) - v / 2)) - v * 0.04, 0,
            radius, radius),
        degreeToRadians(200),
        degreeToRadians(70),
        false);
    path.arcTo(Rect.fromLTWH(size.width - radius, 0, radius, radius),
        degreeToRadians(270), degreeToRadians(90), false);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(TabClipper oldClipper) => true;

  double degreeToRadians(double degree) {
    final double redian = (math.pi / 180) * degree;
    return redian;
  }
}