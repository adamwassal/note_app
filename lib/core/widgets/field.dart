import 'package:flutter/material.dart';

class Field extends StatelessWidget {
  const Field({super.key, this.labelText, this.keyboardType, this.obscureText, this.controller});
  
  final String? labelText;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText ?? 'Enter text',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        keyboardType: keyboardType ?? TextInputType.text,
        obscureText: obscureText ?? false,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }
}