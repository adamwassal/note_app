import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:note_app/features/main_screen/main_screen.dart';
import 'package:note_app/features/login/login.dart';
import 'package:note_app/features/onboarding/onboarding.dart';
import 'package:note_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = FlutterSecureStorage();
  bool? isOnBoarded;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final onBoarded = await storage.read(key: 'isOnBoarded');

    setState(() {
      isOnBoarded = onBoarded == 'true';
    });
  }

  @override
  Widget build(BuildContext context) {
    // لو القيم مش جاهزة بعد
    if (isOnBoarded == null) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xFF787DFF),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
      ),
      home: isOnBoarded == true
          ? (FirebaseAuth.instance.currentUser != null
                ? const MainScreen()
                : const LoginScreen())
          : const OnBoardingScreen(),
    );
  }
}
