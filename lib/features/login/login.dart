import 'package:flutter/material.dart';
import 'package:note_app/core/helpers/warning_msg.dart';
import 'package:note_app/core/theme/colors.dart';
import 'package:note_app/core/widgets/field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_app/core/widgets/full_screen_loader.dart';
import 'package:note_app/features/main_screen/main_screen.dart';
import 'package:note_app/features/signup/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void loginBtn() async {
    if (isLoading) return; // عشان ما تكررش الضغط

    setState(() => isLoading = true);
    FullScreenLoader.show(context);

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      FullScreenLoader.hide(context);
      setState(() => isLoading = false);
      showWarningMsg(context, 'Please fill all fields!');
      return;
    }

    try {
      UserCredential value = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Login successful: ${value.user?.email}');
      FullScreenLoader.hide(context);
      setState(() => isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (error) {
      FullScreenLoader.hide(context);
      setState(() => isLoading = false);

      String errorCode = '';
      if (error is FirebaseAuthException) {
        errorCode = error.code;
      } else {
        errorCode = error.toString();
      }

      final Map<String, String> errorMessages = {
        'invalid-credential': 'Invalid email or password!',
        'invalid-email': 'Invalid email format!',
        'user-not-found': 'User not found!',
        'wrong-password': 'Wrong password!',
      };

      String message =
          errorMessages[errorCode] ?? 'Login failed! Please try again.';

      showWarningMsg(context, message);
      print("Login failed: $error");
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
                "Login Screen",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () async {
                  try {
                    // Step 1: Sign in with Google
                    final GoogleSignInAccount? googleUser = await GoogleSignIn()
                        .signIn();

                    if (googleUser == null) {
                      print('Google Sign-In cancelled');
                      return;
                    }

                    final GoogleSignInAuthentication googleAuth =
                        await googleUser.authentication;

                    // Step 2: Create a new credential
                    final AuthCredential credential =
                        GoogleAuthProvider.credential(
                          accessToken: googleAuth.accessToken,
                          idToken: googleAuth.idToken,
                        );

                    // Step 3: Sign in with Firebase
                    final UserCredential userCredential = await FirebaseAuth
                        .instance
                        .signInWithCredential(credential);

                    print(
                      'Google Sign-In successful: ${userCredential.user?.email}',
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
                        offset: Offset(0, 3),
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

              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  onPressed: isLoading ? null : loginBtn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.login, color: Colors.white),
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
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                child: Text(
                  'Don\'t have an account? Sign Up',
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
