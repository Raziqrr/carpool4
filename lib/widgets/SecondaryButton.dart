/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-07-30 22:22:58
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-07-30 22:40:49
/// @FilePath: lib/widgets/SecondaryButton.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:flutter/material.dart';

class Secondarybutton extends StatelessWidget {
  Secondarybutton(
      {super.key, required this.onPressed, required this.buttonText});
  final void Function() onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(buttonText),
      style: OutlinedButton.styleFrom(),
    );
  }
}
