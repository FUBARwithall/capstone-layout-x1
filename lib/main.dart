import 'package:flutter/material.dart';
import 'package:layout_x1/pages/login_page.dart';
import 'package:layout_x1/pages/register_page.dart';
import 'package:layout_x1/pages/main_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinCare AI',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/homepage': (context) => const MainScaffold(),
        '/pantaukulit': (context) => const MainScaffold(),
      },
    );
  }
}
