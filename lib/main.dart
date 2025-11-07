import 'package:flutter/material.dart';
import 'package:layout_x1/pages/register_page.dart';
import 'package:layout_x1/pages/login_page.dart';
import 'package:layout_x1/pages/landing_page.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/landing': (context) => LandingPage(),
      },
    );
  }
}