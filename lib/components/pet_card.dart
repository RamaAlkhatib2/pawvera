// lib/componants/pet_card.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pawvera/model/pet_model.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const PetCard({
    super.key,
    required this.pet,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                backgroundImage: pet.imagePath != null
                    ? FileImage(File(pet.imagePath!)) as ImageProvider
                    : null,
                child: pet.imagePath == null
                    ? const Icon(Icons.pets, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pet.breed,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close, color: Colors.red, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tagItem(pet.age),
              _tagItem(pet.type),
              _tagItem(pet.color),
              _tagItem(pet.weight),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _actionButton("QR Tag", Icons.qr_code, () {
                  // يمكنك إضافة أكشن الـ QR هنا لاحقاً
                }),
              ),
              const SizedBox(width: 10),
              // التعديل هنا: ربط زر Edit Info بدالة onEdit
              Expanded(
                child: _actionButton(
                  "Edit Info",
                  Icons.edit,
                  onEdit, // تمرير الدالة هنا
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tagItem(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );

  // تحديث الـ Widget المساعد ليقبل onTap
  Widget _actionButton(String label, IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap, // إضافة استجابة اللمس
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.blueGrey),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      );
}
