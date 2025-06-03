import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:note_app/core/theme/colors.dart';
import 'package:note_app/features/login/login.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Image.asset('assets/logo.png', width: 400, height: 400),
                Text(
                  'Note App',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: const Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your personal note-taking companion',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            Spacer(),
            ElevatedButton(
              onPressed: () async{
                await storage.write(key: 'isOnBoarded', value: 'true');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                padding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                'Get Started',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
