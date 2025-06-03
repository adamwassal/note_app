import 'package:flutter/material.dart';

Future<void> showWarningMsg(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // المستخدم لازم يضغط زر عشان يقفل الرسالة
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Warning', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // تقفل الديالوج
            },
          ),
        ],
      );
    },
  );
}
