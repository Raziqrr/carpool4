/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-07-29 18:34:54
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-07-31 00:52:13
/// @FilePath: lib/widgets/CustomTextField.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;
  final void Function(String) onChanged;
  final String hintText;
  final String errorText;
  TextInputType keyboardType;
  final bool obsureText;
  final Widget? suffix;

  CustomTextField(
      {super.key,
      required this.controller,
      required this.onChanged,
      required this.hintText,
      required this.errorText,
      this.keyboardType = TextInputType.name,
      this.obsureText = false,
      this.inputFormatters = const [],
      this.maxLines = 1,
      this.suffix = null});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obsureText,
      keyboardType: keyboardType,
      controller: controller,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        suffixIcon: suffix,
        border: OutlineInputBorder(
            gapPadding: 0.0,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        hintText: hintText,
        errorText: errorText == "" ? null : errorText,
      ),
    );
  }
}
