import 'package:flutter/material.dart';

class MyTextfields extends StatelessWidget {
  final controller;
  final String hitnText;
  final bool obscureText;
  const MyTextfields({
    super.key,
    required this.controller,
    required this.hitnText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey),
          ),
          hintText: hitnText,
        ),
      ),
    );
  }
}
