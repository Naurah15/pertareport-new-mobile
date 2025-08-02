import 'package:flutter/material.dart';
import 'package:pertareport_mobile/firstpage.dart';
import 'package:pertareport_mobile/screens/auth/login.dart';
import 'package:pertareport_mobile/screens/auth/register.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  PageController controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3, // FirstPage, LoginPage, RegisterPage
        controller: controller,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const FirstPage(); // FirstPage sebagai halaman pertama
          } else if (index == 1) {
            return LoginPage(controller: controller); // LoginPage
          } else if (index == 2) {
            return RegisterPage(controller: controller); // RegisterPage
          }
          return null;
        },
      ),
    );
  }
}
