import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

// --- 1. الموديل (Pet Model) ---
class Pet {
  String name, type, breed, gender, age, weight, color;
  String? imagePath;

  Pet({
    required this.name,
    required this.type,
    required this.breed,
    required this.gender,
    required this.age,
    required this.weight,
    required this.color,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'breed': breed,
      'gender': gender,
      'age': age,
      'weight': weight,
      'color': color,
      'imagePath': imagePath,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      breed: map['breed'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? '',
      weight: map['weight'] ?? '',
      color: map['color'] ?? '',
      imagePath: map['imagePath'],
    );
  }
}

class MyPetPage extends StatefulWidget {
  const MyPetPage({super.key});

  @override
  State<MyPetPage> createState() => _MyPetPageState();
}

class _MyPetPageState extends State<MyPetPage> {
  final Color primaryGreen = const Color(0xFF5B9D8E);
  final Color bgCream = const Color(0xFFF9F8F4);

  List<Pet> myPets = [];
  bool _isLoading = true;
  Box? myBox; // جعلناه Nullable للحماية

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      // التأكد من فتح الصندوق بشكل صحيح
      myBox = await Hive.openBox('myBox');
      final List<dynamic>? storedData = myBox?.get('pets');

      if (storedData != null) {
        setState(() {
          try {
            myPets = storedData
                .map((item) => Pet.fromMap(Map<String, dynamic>.from(item)))
                .toList();
          } catch (e) {
            debugPrint("خطأ في تنسيق البيانات القديمة: $e");
            myPets = [];
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("فشل فتح Hive: $e");
      setState(() => _isLoading = false); // إيقاف التحميل حتى لو فشل Hive
    }
  }

  void _savePets() {
    if (myBox != null && myBox!.isOpen) {
      final data = myPets.map((p) => p.toMap()).toList();
      myBox!.put('pets', data);
    }
  }

  void _showAddPetSheet() {
    final nameController = TextEditingController();
    final breedController = TextEditingController();
    final ageController = TextEditingController();
    final weightController = TextEditingController();
    final colorController = TextEditingController();
    String selectedType = 'Dog';
    String selectedGender = 'Male';
    String? imagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add New Pet",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF634732),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputLabel("Pet Name"),
                _buildTextField(nameController, "Name"),
                _buildInputLabel("Type"),
                _buildDropdown(
                  ['Dog', 'Cat', 'Bird'],
                  selectedType,
                  (val) => setSheetState(() => selectedType = val!),
                ),
                _buildInputLabel("Breed"),
                _buildTextField(breedController, "Breed"),
                _buildInputLabel("Gender"),
                _buildDropdown(
                  ['Male', 'Female'],
                  selectedGender,
                  (val) => setSheetState(() => selectedGender = val!),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel("Age"),
                          _buildTextField(ageController, "0"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel("Weight (kg)"),
                          _buildTextField(weightController, "0"),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildInputLabel("Color"),
                _buildTextField(colorController, "Color"),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final img = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (img != null) setSheetState(() => imagePath = img.path);
                  },
                  icon: const Icon(Icons.upload, color: Colors.white),
                  label: const Text(
                    "Upload Photo",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        setState(() {
                          myPets.add(
                            Pet(
                              name: nameController.text,
                              type: selectedType,
                              breed: breedController.text,
                              gender: selectedGender,
                              age: ageController.text,
                              weight: weightController.text,
                              color: colorController.text,
                              imagePath: imagePath,
                            ),
                          );
                          _savePets();
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Add Pet",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        title: const Text(
          "My Pets",
          style: TextStyle(
            color: Color(0xFF634732),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _showAddPetSheet,
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
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: myPets.isEmpty
                      ? const Center(
                          child: Text(
                            "No pets found. Click 'Add Pet' to start!",
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: myPets.length,
                          itemBuilder: (context, index) =>
                              _buildPetCard(myPets[index], index),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPetCard(Pet pet, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: pet.imagePath != null
                    ? Image.file(
                        File(pet.imagePath!),
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: const Icon(Icons.pets, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pet.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            myPets.removeAt(index);
                            _savePets();
                          }),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      pet.breed,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTag("${pet.age} Years"),
                          _buildTag(pet.type),
                          _buildTag(pet.color),
                          _buildTag("${pet.weight} kg"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code, size: 16),
                  label: const Text("QR Tag"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text("Edit"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) => Container(
    margin: const EdgeInsets.only(right: 5),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4F3),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF5B9D8E),
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 5),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _buildTextField(TextEditingController controller, String hint) =>
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF0F4F3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _buildDropdown(
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4F3),
      borderRadius: BorderRadius.circular(10),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}
