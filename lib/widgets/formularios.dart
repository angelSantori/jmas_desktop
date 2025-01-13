import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFieldAzul extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onVisibilityToggle;
  final IconData prefixIcon;

  const CustomTextFieldAzul({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.isPassword = false,
    this.isVisible = false,
    this.onVisibilityToggle,
    this.prefixIcon = Icons.text_fields,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.blue.shade900),
          prefixIcon: Icon(prefixIcon, color: Colors.blue.shade900),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.blue.shade900,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          filled: true,
          fillColor: Colors.blue.shade50,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
        style: const TextStyle(fontSize: 18, color: Colors.black),
        validator: validator,
        obscureText: isPassword && !isVisible,
        inputFormatters: isPassword
            ? null
            : [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      ),
    );
  }
}
