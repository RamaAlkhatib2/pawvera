import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyPetPage extends StatefulWidget {
  const MyPetPage({super.key});

  @override
  State<MyPetPage> createState() => _MyPetPageState();
}

class _MyPetPageState extends State<MyPetPage> {
  final Color primaryGreen = const Color(0xFF5B9D8E);
  final Color bgCream = const Color(0xFFF9F8F4);
  final String boxName = 'myBox';

  // --- 1. ميثود الإضافة (Add Pet) - رجعت تشتغل كاملة ---
  void _showAddPetSheet() {
    final nameCtrl = TextEditingController();
    final breedCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Center(
                  child: Text(
                    "Add New Pet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF634732),
                    ),
                  ),
                ),

                _buildLabel("Pet Name"),
                _buildTextField(nameCtrl, "Name"),
                _buildLabel("Type"),
                _buildDropdown(
                  ['Dog', 'Cat', 'Bird', 'Rabbit'],
                  selectedType,
                  (v) => setSheetState(() => selectedType = v!),
                ),
                _buildLabel("Breed"),
                _buildTextField(breedCtrl, "Breed"),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Gender"),
                          _buildDropdown(
                            ['Male', 'Female'],
                            selectedGender,
                            (v) => setSheetState(() => selectedGender = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Weight (kg)"),
                          _buildTextField(weightCtrl, "0"),
                        ],
                      ),
                    ),
                  ],
                ),

                _buildLabel("Age"),
                _buildTextField(ageCtrl, "Age"),
                _buildLabel("Color"),
                _buildTextField(colorCtrl, "Color"),

                const SizedBox(height: 15),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      final img = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (img != null)
                        setSheetState(() => imagePath = img.path);
                    },
                    icon: Icon(Icons.image, color: primaryGreen),
                    label: Text(
                      imagePath == null ? "Add Photo" : "Photo Added ✅",
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.isNotEmpty) {
                        final newPet = {
                          'name': nameCtrl.text,
                          'type': selectedType,
                          'breed': breedCtrl.text,
                          'gender': selectedGender,
                          'age': ageCtrl.text,
                          'weight': weightCtrl.text,
                          'color': colorCtrl.text,
                          'imagePath': imagePath,
                        };

                        var box = Hive.box(boxName);
                        List currentList = List.from(
                          box.get('pets', defaultValue: []),
                        );
                        currentList.add(newPet);
                        await box.put('pets', currentList);
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

  // --- 2. نافذة QR حسب تصميم Figma الجديد ---
  void _showQRCodeDialog(Map pet) {
    bool isCodeActive = true;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 20),
                    const Text(
                      "Pet QR Tag",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF634732),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const Text(
                  "Scan or edit your pet's QR tag information",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "QR Code Status",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF634732),
                              ),
                            ),
                            Text(
                              isCodeActive
                                  ? "Active - Code can be scanned"
                                  : "Inactive",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isCodeActive,
                        onChanged: (v) =>
                            setDialogState(() => isCodeActive = v),
                        activeColor: primaryGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                QrImageView(
                  data: "Pet: ${pet['name']}, Info: ${pet['breed']}",
                  size: 180,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Scan this QR code to view your pet's information",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Divider(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Owner Contact:\nNot set • No phone",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text(
                          "Edit Info",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text(
                          "Print QR",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 3. نافذة Edit حسب تصميم Figma الجديد ---
  void _showEditPetDialog(Map pet, int index, List allPets) {
    final nameCtrl = TextEditingController(text: pet['name']);
    final breedCtrl = TextEditingController(text: pet['breed']);
    final ageCtrl = TextEditingController(text: pet['age']);
    final weightCtrl = TextEditingController(text: pet['weight']);
    final colorCtrl = TextEditingController(text: pet['color']);
    String? newImg = pet['imagePath'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 20),
                    const Text(
                      "Edit Pet Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF634732),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Center(
                  child: Text(
                    "Make changes to your pet's details.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "Pet Photo",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF634732),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final img = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          if (img != null)
                            setDialogState(() => newImg = img.path);
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            shape: BoxShape.circle,
                          ),
                          child: newImg != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.file(
                                    File(newImg!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.upload, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildLabel("Pet Name"),
                _buildEditField(nameCtrl),
                _buildLabel("Breed"),
                _buildEditField(breedCtrl),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Age"),
                          _buildEditField(ageCtrl),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Weight"),
                          _buildEditField(weightCtrl),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildLabel("Color"),
                _buildEditField(colorCtrl),
                const SizedBox(height: 25),
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
                        onPressed: () {
                          List newList = List.from(allPets);
                          newList[index] = {
                            ...pet,
                            'name': nameCtrl.text,
                            'breed': breedCtrl.text,
                            'age': ageCtrl.text,
                            'weight': weightCtrl.text,
                            'color': colorCtrl.text,
                            'imagePath': newImg,
                          };
                          Hive.box(boxName).put('pets', newList);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                        ),
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box(boxName).listenable(),
              builder: (context, Box box, _) {
                final List pets = box.get('pets', defaultValue: []);
                if (pets.isEmpty)
                  return const Center(child: Text("No pets yet."));
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: pets.length,
                  itemBuilder: (context, index) => _buildPetCard(
                    Map<String, dynamic>.from(pets[index]),
                    index,
                    pets,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(Map pet, int index, List allPets) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: pet['imagePath'] != null
                    ? Image.file(
                        File(pet['imagePath']),
                        width: 65,
                        height: 65,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 65,
                        height: 65,
                        color: Colors.grey[200],
                        child: const Icon(Icons.pets),
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      pet['breed'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 5,
                      children: [
                        _buildTag("${pet['age']} yrs"),
                        _buildTag(pet['type']),
                        _buildTag(pet['color']),
                        _buildTag("${pet['weight']}kg"),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  List newList = List.from(allPets);
                  newList.removeAt(index);
                  Hive.box(boxName).put('pets', newList);
                },
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showQRCodeDialog(pet),
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
                  onPressed: () => _showEditPetDialog(pet, index, allPets),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit Info"),
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

  // Helpers
  Widget _buildLabel(String l) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 5),
    child: Text(
      l,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF5B9D8E),
      ),
    ),
  );
  Widget _buildTextField(TextEditingController c, String h) => TextField(
    controller: c,
    decoration: InputDecoration(
      hintText: h,
      filled: true,
      fillColor: const Color(0xFFF0F4F3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      isDense: true,
    ),
  );
  Widget _buildEditField(TextEditingController c) => TextField(
    controller: c,
    decoration: InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.all(10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
  Widget _buildDropdown(
    List<String> items,
    String val,
    Function(String?) onCh,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4F3),
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: val,
        isExpanded: true,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onCh,
      ),
    ),
  );
  Widget _buildTag(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(t, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  );
}
