/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-07-30 22:19:21
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-07-31 00:52:43
/// @FilePath: lib/widgets/PrimaryButton.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Primarybutton extends StatelessWidget {
  Primarybutton({super.key, required this.buttonText, required this.onPressed});
  final void Function()? onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: CupertinoColors.activeGreen),
    );
  }
}
