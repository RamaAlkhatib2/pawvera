import 'package:flutter/material.dart';

import 'package:pawvera/components/add_pet_button.dart';
import 'package:pawvera/components/edit_pet_sheet.dart';
import 'package:pawvera/components/pet_card.dart';
import 'package:pawvera/model/pet_model.dart';

class MyPetPage extends StatefulWidget {
  const MyPetPage({super.key});

  @override
  State<MyPetPage> createState() => _MyPetPageState();
}

class _MyPetPageState extends State<MyPetPage> {
  // قائمة الحيوانات الأليفة
  List<Pet> myPets = [
    Pet(
      name: "Buddy",
      breed: "Golden Retriever",
      age: "3 years",
      type: "Dog",
      color: "Golden",
      weight: "30kg",
    ),
  ];

  // دالة الحذف
  void deletePet(int index) {
    setState(() {
      myPets.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pet deleted successfully"),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // دالة الإضافة
  void addNewPet(Pet newPet) {
    setState(() {
      myPets.add(newPet);
    });
  }

  // دالة التعديل (تحديث البيانات في القائمة)
  void updatePet(int index, Pet updatedPet) {
    setState(() {
      myPets[index] = updatedPet;
    });
  }

  final Color primaryGreen = const Color(0xFF5B9D8E);
  final Color backgroundColor = const Color(0xFFF0F4F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "My Pets",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // زر الإضافة
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AddPetSheet(onPetAdded: addNewPet),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Add Pet",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // عرض القائمة
              Expanded(
                child: myPets.isEmpty
                    ? const Center(child: Text("No pets added yet."))
                    : ListView.builder(
                        itemCount: myPets.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: PetCard(
                              pet: myPets[index],
                              onDelete: () => deletePet(index),
                              // تفعيل زر التعديل لفتح صفحة التعديل
                              onEdit: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => EditPetSheet(
                                    pet: myPets[index],
                                    onPetUpdated: (newPetData) =>
                                        updatePet(index, newPetData),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
