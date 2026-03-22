import 'package:flutter/material.dart';

class RoleButton extends StatelessWidget {
  final bool isSelected;
  final String role;
  final VoidCallback onTap;

  const RoleButton({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5F2) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF5B9D8E) : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            role,
            style: TextStyle(
              color: isSelected ? const Color(0xFF5B9D8E) : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
