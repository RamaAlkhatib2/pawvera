// lib/componants/edit_pet_sheet.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawvera/model/pet_model.dart';

class EditPetSheet extends StatefulWidget {
  final Pet pet; 
  final Function(Pet) onPetUpdated;

  const EditPetSheet({
    super.key,
    required this.pet,
    required this.onPetUpdated,
  });

  @override
  State<EditPetSheet> createState() => _EditPetSheetState();
}

class _EditPetSheetState extends State<EditPetSheet> {
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _colorController;

  String? selectedType;
  String? selectedGender;

  File? _selectedImage;

  // دالة اختيار الصورة من الاستوديو
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.pet.name);
    _breedController = TextEditingController(text: widget.pet.breed);
    _ageController = TextEditingController(
      text: widget.pet.age.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    _weightController = TextEditingController(
      text: widget.pet.weight.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    _colorController = TextEditingController(text: widget.pet.color);
    selectedType = widget.pet.type;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Edit Pet Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            
            const Text(
              "Pet Photo",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFB), // لون خلفية هادئ
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 35,
                            color: Color(0xFF5B9D8E),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Click to upload photo",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField("Pet Name", _nameController),
            _buildTextField("Breed", _breedController),
            Row(
              children: [
                Expanded(
                  child: _buildTextField("Age", _ageController, isNumber: true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    "Weight (kg)",
                    _weightController,
                    isNumber: true,
                  ),
                ),
              ],
            ),

            _buildTextField("Color", _colorController),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9D8E),
                    ),
                    onPressed: () {
                      final updatedPet = Pet(
                        name: _nameController.text,
                        breed: _breedController.text,
                        age: "${_ageController.text} years",
                        type: selectedType ?? widget.pet.type,
                        color: _colorController.text,
                        weight: "${_weightController.text}kg",
                      );
                      widget.onPetUpdated(updatedPet);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,

    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
