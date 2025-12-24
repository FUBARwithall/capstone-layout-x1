import 'package:flutter/material.dart';
import 'package:layout_x1/pages/chatbot.dart';
import 'package:layout_x1/pages/auth/login_page.dart';
import 'package:layout_x1/pages/pantaupage.dart';
import 'package:layout_x1/pages/auth/register_page.dart';
import 'package:layout_x1/pages/main_scaffold.dart';
import 'package:layout_x1/pages/detection/body_detectionpage.dart';
import 'package:layout_x1/pages/detection/face_detectionpage.dart';
import 'package:layout_x1/pages/reminder.dart';
import 'package:layout_x1/pages/favoritepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/secure_storage.dart';
import 'services/user_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinCare AI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(), // Check session first
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/homepage': (context) => const MainScaffold(),
        '/pantaukulit': (context) => const PantauKulitPage(),
        '/deteksikulittubuh': (context) => const BodyDetectionpage(),
        '/deteksikulitwajah': (context) => const FaceDetectionpage(),
        '/reminder': (context) => const ReminderSkincare(),
        '/chatbot': (context) => const ChatbotPage(),
        '/favorite': (context) => const FavoritePage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Check if user has a valid token and is logged in
    final token = await SecureStorage.getToken();
    final isLoggedIn = await UserPreferences.isLoggedIn();

    if (!mounted) return;

    // Wait a bit for splash effect (optional)
    await Future.delayed(const Duration(seconds: 1));

    if (token != null && isLoggedIn) {
      // User is logged in, go to homepage
      Navigator.pushReplacementNamed(context, '/homepage');
    } else {
      // User is not logged in, go to login page
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5DC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0066CC)),
            SizedBox(height: 16),
            Text(
              'SkinCare AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
