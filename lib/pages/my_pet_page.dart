import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pawvera/services/database_service.dart';

class MyPetPage extends StatefulWidget {
  const MyPetPage({super.key});

  @override
  State<MyPetPage> createState() => _MyPetPageState();
}

class _MyPetPageState extends State<MyPetPage> {
  final Color primaryGreen = const Color(0xFF5B9D8E);
  final Color bgCream = const Color(0xFFEAF5F1);
  final DatabaseService _db = DatabaseService();
  final List<String> _ageUnits = const ['Weeks', 'Months', 'Years'];

  // --- 1. ميثود الإضافة (Add Pet) - Integrated with Firestore ---
  void _showAddPetSheet() {
    final nameCtrl = TextEditingController();
    final breedCtrl = TextEditingController();
    final ageValueCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    String selectedType = 'Dog';
    String selectedGender = 'Male';
    String selectedAgeUnit = 'Years';
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
                  ['Dog', 'Cat', 'Bird', 'Rabbit', 'Fish'],
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
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        ageValueCtrl,
                        "Age number",
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdown(
                        _ageUnits,
                        selectedAgeUnit,
                        (v) => setSheetState(() => selectedAgeUnit = v!),
                      ),
                    ),
                  ],
                ),
                _buildLabel("Color"),
                _buildTextField(colorCtrl, "Color"),

                const SizedBox(height: 15),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      final img = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (img != null) {
                        setSheetState(() => imagePath = img.path);
                      }
                    },
                    icon: Icon(Icons.image, color: primaryGreen),
                    label: Text(
                      imagePath == null ? "Add Photo" : "Photo Added ✅",
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryGreen,
                          side: BorderSide(
                            color: primaryGreen.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameCtrl.text.isNotEmpty) {
                              final ageValue = ageValueCtrl.text.trim();
                              final newPet = {
                                'name': nameCtrl.text,
                                'type': selectedType,
                                'breed': breedCtrl.text,
                                'gender': selectedGender,
                                'age': ageValue.isEmpty
                                    ? ''
                                    : '$ageValue $selectedAgeUnit',
                                'ageValue': ageValue,
                                'ageUnit': selectedAgeUnit,
                                'weight': weightCtrl.text,
                                'color': colorCtrl.text,
                                'imagePath':
                                    imagePath, // Note: Should ideally be uploaded to Firebase Storage
                                'ownerName': '',
                                'ownerPhone': '',
                                'ownerEmail': '',
                                'medicalInfo': '',
                                'allergies': '',
                              };

                              await _db.addPet(newPet);
                              if (context.mounted) Navigator.pop(context);
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

  // --- 2. نافذة QR حسب تصميم Figma الجديد ---
  void _showQRCodeDialog(Map pet, String petId) {
    bool isCodeActive = true;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final ownerName = pet['ownerName'] as String? ?? '';
          final ownerPhone = pet['ownerPhone'] as String? ?? '';
          final ownerEmail = pet['ownerEmail'] as String? ?? '';
          final medicalInfo = pet['medicalInfo'] as String? ?? 'None';
          final allergies = pet['allergies'] as String? ?? 'None';
          return Dialog(
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
                      Text(
                        "Pet QR Tag - ${pet['name'] ?? ''}",
                        style: const TextStyle(
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
                  const SizedBox(height: 8),
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
                          activeThumbColor: primaryGreen,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  QrImageView(data: _buildPetQrData(pet), size: 180),
                  const SizedBox(height: 10),
                  const Text(
                    "Scan this QR code to view your pet's information",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const Divider(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Owner Name: ${ownerName.isNotEmpty ? ownerName : 'Not set'}\n"
                      "Phone: ${ownerPhone.isNotEmpty ? ownerPhone : 'No phone'}\n"
                      "Email: ${ownerEmail.isNotEmpty ? ownerEmail : 'No email'}",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Medical Info: ${medicalInfo.isNotEmpty ? medicalInfo : 'None'}\n"
                      "Allergies: ${allergies.isNotEmpty ? allergies : 'None'}",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Future.delayed(
                              Duration.zero,
                              () => _showQRCodeEditDialog(pet, petId),
                            );
                          },
                          child: const Text(
                            "Edit Info",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _printPetQrTag(pet),
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
          );
        },
      ),
    );
  }

  // --- 3. نافذة Edit حسب تصميم Figma الجديد ---
  void _showQRCodeEditDialog(Map pet, String petId) {
    final ownerNameCtrl = TextEditingController(text: pet['ownerName']);
    final ownerPhoneCtrl = TextEditingController(text: pet['ownerPhone']);
    final ownerEmailCtrl = TextEditingController(text: pet['ownerEmail']);
    final medicalInfoCtrl = TextEditingController(text: pet['medicalInfo']);
    final allergiesCtrl = TextEditingController(text: pet['allergies']);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  Text(
                    "Pet QR Tag - ${pet['name'] ?? ''}",
                    style: const TextStyle(
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
              const SizedBox(height: 8),
              const Text(
                "Scan or edit your pet's QR tag information",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildLabel("Owner Name"),
              _buildTextField(ownerNameCtrl, "Your name"),
              _buildLabel("Owner Phone"),
              _buildTextField(ownerPhoneCtrl, "(+) 1 555 000-0000"),
              _buildLabel("Owner Email"),
              _buildTextField(ownerEmailCtrl, "your@email.com"),
              _buildLabel("Medical Information"),
              _buildTextField(
                medicalInfoCtrl,
                "Vaccinations, medications, conditions...",
              ),
              _buildLabel("Allergies"),
              _buildTextField(
                allergiesCtrl,
                "Any allergies or sensitivities...",
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: BorderSide(color: primaryGreen.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _db.updatePet(petId, {
                          'ownerName': ownerNameCtrl.text,
                          'ownerPhone': ownerPhoneCtrl.text,
                          'ownerEmail': ownerEmailCtrl.text,
                          'medicalInfo': medicalInfoCtrl.text,
                          'allergies': allergiesCtrl.text,
                        });
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }

  void _showEditPetDialog(Map pet, String petId) {
    final nameCtrl = TextEditingController(text: pet['name']);
    final breedCtrl = TextEditingController(text: pet['breed']);
    final ageValueCtrl = TextEditingController(text: _extractAgeValue(pet));
    final weightCtrl = TextEditingController(text: pet['weight']);
    final colorCtrl = TextEditingController(text: pet['color']);
    String selectedType = pet['type'] as String? ?? 'Dog';
    String selectedGender = pet['gender'] as String? ?? 'Male';
    String selectedAgeUnit = _extractAgeUnit(pet);
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
                const SizedBox(height: 8),
                const Text(
                  "Make changes to your pet's details.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final img = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          if (img != null) {
                            setDialogState(() => newImg = img.path);
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: newImg != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(newImg!),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.cloud_upload,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Upload Photo',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Pet Photo",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF634732),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel("Pet Name"),
                _buildEditField(nameCtrl),
                _buildLabel("Type"),
                _buildDropdown(
                  ['Dog', 'Cat', 'Bird', 'Rabbit', 'Fish'],
                  selectedType,
                  (value) => setDialogState(() => selectedType = value!),
                ),
                _buildLabel("Breed"),
                _buildEditField(breedCtrl),
                _buildLabel("Gender"),
                _buildDropdown(
                  ['Male', 'Female'],
                  selectedGender,
                  (value) => setDialogState(() => selectedGender = value!),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Age"),
                          Row(
                            children: [
                              Expanded(
                                child: _buildEditField(
                                  ageValueCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildEditDropdown(
                                  _ageUnits,
                                  selectedAgeUnit,
                                  (value) => setDialogState(
                                    () => selectedAgeUnit = value!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Weight (kg)"),
                          _buildEditField(weightCtrl),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildLabel("Color"),
                _buildEditField(colorCtrl),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryGreen,
                          side: BorderSide(
                            color: primaryGreen.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final ageValue = ageValueCtrl.text.trim();
                          await _db.updatePet(petId, {
                            'name': nameCtrl.text,
                            'type': selectedType,
                            'breed': breedCtrl.text,
                            'gender': selectedGender,
                            'age': ageValue.isEmpty
                                ? ''
                                : '$ageValue $selectedAgeUnit',
                            'ageValue': ageValue,
                            'ageUnit': selectedAgeUnit,
                            'weight': weightCtrl.text,
                            'color': colorCtrl.text,
                            'imagePath': newImg,
                          });
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "My Pets",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6F4A3F),
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: _showAddPetSheet,
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text(
                        "Add Pet",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D9E8F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.userPets,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List pets = snapshot.data?.docs ?? [];

                  if (pets.isEmpty) {
                    return const Center(
                      child: Text(
                        "No pets yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final petDoc = pets[index];
                      final petData = petDoc.data() as Map<String, dynamic>;
                      return _buildPetCard(petData, petDoc.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetCard(Map pet, String petId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF9FC8C0), width: 1),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF9FC8C0), width: 1),
                  color: Colors.grey[100],
                ),
                child: ClipOval(
                  child: pet['imagePath'] != null
                      ? Image.file(
                          File(pet['imagePath']),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.pets, size: 24, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF6F4A3F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pet['breed'] ?? '',
                      style: const TextStyle(
                        color: Color(0xFF7D7D7D),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildTag(_formatAgeLabel(pet)),
                        _buildTag(pet['type']),
                        _buildTag(pet['color']),
                        _buildTag("${pet['weight']}kg"),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  await _db.deletePet(petId);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4F4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFF1DBDB)),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFFD36A6A),
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showQRCodeDialog(pet, petId),
                  icon: const Icon(Icons.qr_code_2, size: 12),
                  label: const Text("QR Tag"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F5F5),
                    foregroundColor: const Color(0xFF6C5A45),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: const BorderSide(color: Color(0xFFB9D7D2)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showEditPetDialog(pet, petId),
                  icon: const Icon(Icons.edit_outlined, size: 12),
                  label: const Text("Edit Info"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F5F5),
                    foregroundColor: const Color(0xFF6C5A45),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: const BorderSide(color: Color(0xFFB9D7D2)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
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
  Widget _buildTextField(
    TextEditingController c,
    String h, {
    TextInputType? keyboardType,
  }) => TextField(
    controller: c,
    keyboardType: keyboardType,
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
  Widget _buildEditField(
    TextEditingController c, {
    TextInputType? keyboardType,
  }) => TextField(
    controller: c,
    keyboardType: keyboardType,
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
  Widget _buildEditDropdown(
    List<String> items,
    String val,
    Function(String?) onCh,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(10),
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
      color: const Color(0xFFF8FAFA),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFFD3E3E0)),
    ),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 8,
        color: Color(0xFF6C5A45),
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  String _extractAgeValue(Map pet) {
    final storedAgeValue = (pet['ageValue'] as String?)?.trim() ?? '';
    if (storedAgeValue.isNotEmpty) return storedAgeValue;

    final ageText = (pet['age'] as String?)?.trim() ?? '';
    if (ageText.isEmpty) return '';
    final match = RegExp(r'\d+').firstMatch(ageText);
    return match?.group(0) ?? ageText;
  }

  String _extractAgeUnit(Map pet) {
    final storedUnit = (pet['ageUnit'] as String?)?.trim() ?? '';
    if (_ageUnits.contains(storedUnit)) return storedUnit;

    final ageText = (pet['age'] as String?)?.toLowerCase() ?? '';
    if (ageText.contains('week')) return 'Weeks';
    if (ageText.contains('month')) return 'Months';
    return 'Years';
  }

  String _formatAgeLabel(Map pet) {
    final value = _extractAgeValue(pet);
    if (value.isEmpty) return 'Age N/A';
    return '$value ${_extractAgeUnit(pet)}';
  }

  String _buildPetQrData(Map pet) {
    return [
      'Pet: ${pet['name'] ?? ''}',
      'Type: ${pet['type'] ?? ''}',
      'Breed: ${pet['breed'] ?? ''}',
      'Age: ${_formatAgeLabel(pet)}',
      'Owner: ${pet['ownerName'] ?? ''}',
      'Phone: ${pet['ownerPhone'] ?? ''}',
      'Medical Info: ${pet['medicalInfo'] ?? ''}',
      'Allergies: ${pet['allergies'] ?? ''}',
    ].join('\n');
  }

  Future<void> _printPetQrTag(Map pet) async {
    try {
      final doc = pw.Document();
      final qrData = _buildPetQrData(pet);

      doc.addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'Pet QR Tag - ${pet['name'] ?? ''}',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrData,
                  width: 200,
                  height: 200,
                ),
                pw.SizedBox(height: 16),
                pw.Text('Scan this code to view pet details.'),
              ],
            ),
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => doc.save());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to print QR tag right now.')),
      );
    }
  }
}
