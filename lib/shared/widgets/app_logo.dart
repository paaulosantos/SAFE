import 'package:flutter/material.dart';
import 'package:safe/core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool isSmall;

  const AppLogo({super.key, this.size = 60, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final fontSize = isSmall ? size * 0.8 : size;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.accentGradient,
      ),
      child: Center(
        child: Text(
          '🛡️',
          style: TextStyle(fontSize: fontSize),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
