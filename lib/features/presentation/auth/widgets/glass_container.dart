import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pscmate/core/utils/color_config.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final List<Color> glowColors;

  const GlassContainer({
    super.key,
    required this.child,
    required this.glowColors,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure the theme is dark for these colors to look right
    return Theme(
      data: ThemeData.dark(),
      child: Container(
        //  margin: const EdgeInsets.all(20), // Margin around the card
        decoration: BoxDecoration(
          color: AppColors.cardDark.withOpacity(0.8),
          borderRadius: BorderRadius.circular(30),
          // border: Border.all(
          //   color: glowColors.first.withOpacity(0.5),
          //   width: 1.5,
          // ),
          boxShadow: [
            // Outer glow
            BoxShadow(
              color: glowColors.last.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
            // Inner border glow effect
            BoxShadow(
              color: glowColors.first.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            // The blur effect behind the card
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 36.0,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
