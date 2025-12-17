import 'package:flutter/material.dart';
import 'package:layout_x1/pages/chatbot.dart';
import 'package:layout_x1/pages/login_page.dart';
import 'package:layout_x1/pages/pantaupage.dart';
import 'package:layout_x1/pages/products/productspage.dart';
import 'package:layout_x1/pages/register_page.dart';
import 'package:layout_x1/pages/main_scaffold.dart';
import 'package:layout_x1/pages/detection/body_detectionpage.dart';
import 'package:layout_x1/pages/detection/face_detectionpage.dart';
import 'package:layout_x1/pages/reminder.dart';
import 'package:layout_x1/pages/favoritepage.dart';
import 'package:layout_x1/pages/products/productdetailpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
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
        '/pantaukulit': (context) => const PantauKulitPage(),
        '/deteksikulittubuh': (context) => const BodyDetectionpage(),
        '/deteksikulitwajah': (context) => const FaceDetectionpage(),
        // '/products' : (context) => const ProductsPage(),
        '/reminder' : (context) => const ReminderSkincare(),
        '/chatbot' : (context) => const ChatbotPage(),
        '/favorite' : (context) => const FavoritePage(),
      },
    );
  }
}
