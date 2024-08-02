/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-07-31 01:10:36
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-07-31 01:29:28
/// @FilePath: lib/widgets/GenderCard.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Gendercard extends StatelessWidget {
  const Gendercard(
      {super.key,
      required this.value,
      required this.icon,
      required this.isSelected,
      this.onTap = null,
      required this.primary,
      required this.secondary});

  final String value;
  final IconData icon;
  final String isSelected;
  final void Function()? onTap;
  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: secondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
                strokeAlign: BorderSide.strokeAlignOutside,
                width: isSelected == value ? 8 : 0,
                color: primary)),
        elevation: isSelected == value ? 20 : 1,
        child: Container(
          width: (MediaQuery.sizeOf(context).width - 15) * 25 / 100,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: primary,
                  size: isSelected == value ? 50 : 40,
                ),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primary),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
