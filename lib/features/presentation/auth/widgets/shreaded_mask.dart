import 'package:flutter/material.dart';
import 'package:pscmate/core/utils/color_config.dart';

ShaderMask shreadMaskWidget({
  required String textContent,
  required double size,
  required Color color1,
  required Color color2,
}) {
  return ShaderMask(
    blendMode: BlendMode
        .srcIn, // 1. Ensures the gradient replaces the text color strictly
    shaderCallback: (bounds) => LinearGradient(
      colors: [color1, color2],
      begin: Alignment.centerLeft, // Optional: makes gradient horizontal
      end: Alignment.centerRight,
    ).createShader(bounds),
    child: Text(
      textContent,
      style: TextStyle(
        fontSize: size, // Adjust size as needed
        fontWeight: FontWeight.bold,
        color: Colors
            .white, // 2. CRITICAL: This must be white (or opaque) for the mask to work
      ),
    ),
  );
}
