import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_app/core/theme/colors.dart';
import 'package:note_app/core/widgets/field.dart';
import 'package:note_app/core/widgets/full_screen_loader.dart';
import 'package:note_app/core/helpers/warning_msg.dart'; // لو عندك دالة لإظهار رسالة تحذير
import 'package:note_app/features/main_screen/main_screen.dart';
import 'package:note_app/features/login/login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> signUpBtn() async {
    if (isLoading) return; // لمنع الضغط المتكرر

    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty) {
      showWarningMsg(context, 'Please enter your email.');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(email)) {
      showWarningMsg(context, 'Please enter a valid email.');
      return;
    }

    if (password.length < 6) {
      showWarningMsg(context, 'Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      showWarningMsg(context, 'Passwords do not match.');
      return;
    }

    try {
      setState(() => isLoading = true);
      FullScreenLoader.show(context);

      UserCredential value = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Account created: ${value.user?.email}');
      FullScreenLoader.hide(context);
      setState(() => isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      FullScreenLoader.hide(context);
      setState(() => isLoading = false);

      final errorMessages = {
        'email-already-in-use': 'This email is already in use.',
        'invalid-email': 'Invalid email format.',
        'operation-not-allowed': 'Operation not allowed.',
        'weak-password': 'The password is too weak.',
      };

      String message = errorMessages[error.code] ?? 'Sign Up failed! Please try again.';
      showWarningMsg(context, message);
      print("Sign Up failed: $error");
    } catch (error) {
      FullScreenLoader.hide(context);
      setState(() => isLoading = false);
      showWarningMsg(context, 'An unexpected error occurred.');
      print("Sign Up failed: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign Up Screen",
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  try {
                    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

                    if (googleUser == null) {
                      print('Google Sign-In cancelled');
                      return;
                    }

                    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

                    final AuthCredential credential = GoogleAuthProvider.credential(
                      accessToken: googleAuth.accessToken,
                      idToken: googleAuth.idToken,
                    );

                    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

                    print('Google Sign-In successful: ${userCredential.user?.email}');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  } catch (error) {
                    print("Google Sign-In failed: $error");
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/google_auth.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Field(
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
              ),
              Field(
                labelText: 'Password',
                obscureText: true,
                controller: passwordController,
              ),
              Field(
                labelText: 'Confirm password',
                obscureText: true,
                controller: confirmPasswordController,
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  onPressed: isLoading ? null : signUpBtn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.app_registration, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
