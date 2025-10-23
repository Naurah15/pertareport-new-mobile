import 'package:flutter/material.dart';
import 'package:pertareport_mobile/screens/history/history_screen.dart';
import 'package:pertareport_mobile/screens/report/laporan_input_screen.dart';
import 'package:pertareport_mobile/widgets/mainpage/bottom_bar_view.dart';
import 'package:pertareport_mobile/utils/mainpage_theme.dart';
import 'package:pertareport_mobile/screens/mainpage/mainpage.dart';

class FitnessAppHomeScreen extends StatefulWidget {
  @override
  _FitnessAppHomeScreenState createState() => _FitnessAppHomeScreenState();
}

class _FitnessAppHomeScreenState extends State<FitnessAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  Widget tabBody = Container(
    color: FitnessAppTheme.background,
  );

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = MyDiaryScreen(animationController: animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                  bottomBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          addClick: () {},
          changeIndex: (int index) {
            // index 0 = Report (FAB tengah)
            // index 1 = Home (kiri)
            // index 2 = History (kanan)

            if (index == 1) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) return;
                setState(() {
                  tabBody =
                      MyDiaryScreen(animationController: animationController);
                });
              });
            } else if (index == 0) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) return;
                setState(() {
                  tabBody = const LaporanInputScreen();
                });
              });
            } else if (index == 2) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) return;
                setState(() {
                  tabBody = const HistoryScreen();
                });
              });
            }
          },
        ),
      ],
    );
  }
}
