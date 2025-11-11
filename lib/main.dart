import 'package:flutter/material.dart';
import 'package:layout_x1/pages/login_page.dart';
import 'package:layout_x1/pages/productspage.dart';
import 'package:layout_x1/pages/register_page.dart';
import 'package:layout_x1/pages/main_scaffold.dart';
import 'package:layout_x1/pages/body_detectionpage.dart';
import 'package:layout_x1/pages/face_detectionpage.dart';


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
        '/deteksikulittubuh': (context) => const BodyDetectionpage(),
        '/deteksikulitwajah': (context) => const FaceDetectionpage(),
        '/products' : (context) => const ProductsPage()
      },
    );
  }
}
