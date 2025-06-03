import 'package:flutter/material.dart';
import 'package:note_app/core/theme/colors.dart';

class Btn extends StatelessWidget {
  const Btn({super.key, this.text, this.function, this.enabled});
  final String? text;
  final VoidCallback? function;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: 400,
      child: ElevatedButton(
        
        onPressed: function,
        style: ButtonStyle(
          backgroundColor: enabled!? MaterialStateProperty.all<Color>(AppColors.primary) : MaterialStateProperty.all<Color>(AppColors.disabledColor),
          foregroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 255, 255, 255)),
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(20)),
          
          
        ),
        
        child: Text(text!, style: TextStyle(fontSize: 20),),
      ),
    );
  }
}
