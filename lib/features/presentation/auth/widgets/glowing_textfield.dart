import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pscmate/core/utils/color_config.dart';

class GlowingTextField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator; // <-- added

  const GlowingTextField({
    super.key,
    required this.icon,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.validator, // <-- added
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textFaded.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        // <-- changed from TextField
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: AppColors.textLight),
        validator: validator, // <-- added
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textFaded),
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textFaded.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
