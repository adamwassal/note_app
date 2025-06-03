import 'package:flutter/material.dart';

class FullScreenLoader {
  static bool _isShowing = false;

  static void show(BuildContext context) {
    if (_isShowing) return;

    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5), // خلفية شفافة داكنة
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    if (!_isShowing) return;

    _isShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }
}
