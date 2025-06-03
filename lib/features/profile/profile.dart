import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_app/core/theme/colors.dart';
import 'package:note_app/core/widgets/btn.dart';
import 'package:note_app/core/widgets/field.dart';
import 'package:note_app/core/widgets/full_screen_loader.dart';
import 'package:note_app/features/login/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> _changePassword() async {
    String currentPassword = currentPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is currently signed in')));
      return;
    }

    setState(() => isLoading = true);
    FullScreenLoader.show(context);

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')));
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      String message = 'Failed to change password';
      if (error.code == 'wrong-password') {
        message = 'Current password is incorrect';
      } else if (error.code == 'requires-recent-login') {
        message = 'Please login again and try changing password';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      FullScreenLoader.hide(context);
      setState(() => isLoading = false);
    }
  }

  void _showChangePasswordDialog() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Field(
                labelText: 'Current Password',
                obscureText: true,
                controller: currentPasswordController,
              ),
              const SizedBox(height: 10),
              Field(
                labelText: 'New Password',
                obscureText: true,
                controller: newPasswordController,
              ),
              const SizedBox(height: 10),
              Field(
                labelText: 'Confirm New Password',
                obscureText: true,
                controller: confirmPasswordController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : _changePassword,
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Icon(Icons.person, size: 50, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                email.isNotEmpty
                    ? 'Hello, ${email.split("@").first}'
                    : 'Not signed in',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 40),
              Btn(
                text: 'Change Password',
                function: _showChangePasswordDialog,
                enabled: !isLoading,
              ),
              const SizedBox(height: 20),
              Btn(
                text: 'Sign Out',
                function: _signOut,
                enabled: !isLoading,
              
              ),
            ],
          ),
        ),
      ),
    );
  }
}
