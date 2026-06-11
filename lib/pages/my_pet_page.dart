import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pawvera/services/database_service.dart';
import '../services/breed_service.dart';

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
    Future<String>? petUploadFuture;
    List<BreedInfo> fetchedBreeds = [];
    bool loadingBreeds = false;
    BreedInfo? selectedBreedInfo;
    bool breedsInit = false;

    Future<void> loadBreeds(String type, StateSetter ss) async {
      if (type != 'Dog' && type != 'Cat') {
        ss(() { fetchedBreeds = []; selectedBreedInfo = null; });
        return;
      }
      ss(() => loadingBreeds = true);
      final result = await BreedService.fetchBreeds(type);
      ss(() {
        fetchedBreeds = result;
        loadingBreeds = false;
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
        if (!breedsInit) {
          breedsInit = true;
          Future.microtask(() => loadBreeds(selectedType, setSheetState));
        }
        return Container(
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
                  (v) {
                    setSheetState(() {
                      selectedType = v!;
                      selectedBreedInfo = null;
                      breedCtrl.clear();
                    });
                    loadBreeds(v!, setSheetState);
                  },
                ),
                _buildLabel("Breed"),
                if (loadingBreeds)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: fetchedBreeds.isEmpty
                        ? null
                        : () async {
                            final selected = await _showBreedSearchDialog(
                              context,
                              fetchedBreeds,
                            );
                            if (selected != null) {
                              breedCtrl.text = selected;
                              final info = fetchedBreeds.firstWhere(
                                (b) => b.name == selected,
                                orElse: () => BreedInfo(name: selected),
                              );
                              setSheetState(() => selectedBreedInfo = info);
                            }
                          },
                    child: AbsorbPointer(
                      absorbing: fetchedBreeds.isNotEmpty,
                      child: _buildTextField(
                        breedCtrl,
                        fetchedBreeds.isNotEmpty
                            ? 'Tap to select breed'
                            : 'Breed',
                      ),
                    ),
                  ),
                if (selectedBreedInfo != null &&
                    selectedBreedInfo!.temperament.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B9D8E).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF5B9D8E).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🐾 ${selectedBreedInfo!.temperament}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                        ),
                        if (selectedBreedInfo!.lifeSpan.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              '⏳ Life span: ${selectedBreedInfo!.lifeSpan}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                            ),
                          ),
                        if (selectedBreedInfo!.origin.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              '🌍 Origin: ${selectedBreedInfo!.origin}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                            ),
                          ),
                      ],
                    ),
                  ),

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
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 80,
                      );
                      if (img != null) {
                        setSheetState(() => imagePath = img.path);
                        final uid = FirebaseAuth.instance.currentUser!.uid;
                        petUploadFuture = img.readAsBytes().then(
                          (bytes) => _db.uploadPetImage(
                            uid: uid,
                            bytes: bytes,
                            fileName: img.name,
                          ),
                        );
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
                            if (nameCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please enter your pet's name.",
                                  ),
                                ),
                              );
                              return;
                            }
                            try {
                              String? uploadedUrl;
                              if (petUploadFuture != null) {
                                uploadedUrl = await petUploadFuture;
                              }
                              final ageValue = ageValueCtrl.text.trim();
                              final newPet = {
                                'name': nameCtrl.text.trim(),
                                'type': selectedType,
                                'breed': breedCtrl.text.trim(),
                                'gender': selectedGender,
                                'age': ageValue.isEmpty
                                    ? ''
                                    : '$ageValue $selectedAgeUnit',
                                'ageValue': ageValue,
                                'ageUnit': selectedAgeUnit,
                                'weight': weightCtrl.text.trim(),
                                'color': colorCtrl.text.trim(),
                                'imagePath': uploadedUrl,
                                'ownerName': '',
                                'ownerPhone': '',
                                'ownerEmail': '',
                                'medicalInfo': '',
                                'allergies': '',
                              };
                              await _db.addPet(newPet);
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Failed to add pet: ${e.toString()}",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
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
        );
        },
      ),
    );
  }

  void _showQRCodeDialog(Map pet, String petId) {
    bool isCodeActive = pet['qrActive'] != false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final ownerUid = FirebaseAuth.instance.currentUser?.uid ?? '';
          final qrUrl = _buildPetQrUrl(ownerUid, petId);
          final ownerName = pet['ownerName'] as String? ?? '';
          final ownerPhone = pet['ownerPhone'] as String? ?? '';
          final ownerEmail = pet['ownerEmail'] as String? ?? '';
          final medicalInfo = pet['medicalInfo'] as String? ?? 'None';
          final allergies = pet['allergies'] as String? ?? 'None';
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
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
                                    : "Inactive - Code is disabled",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isCodeActive
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isCodeActive,
                          onChanged: (v) {
                            setDialogState(() => isCodeActive = v);
                            _db.updatePet(petId, {'qrActive': v});
                          },
                          activeThumbColor: primaryGreen,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (isCodeActive)
                    QrImageView(
                      data: qrUrl,
                      size: 240,
                      errorCorrectionLevel: QrErrorCorrectLevel.L,
                      padding: const EdgeInsets.all(8),
                    )
                  else
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "QR Code Inactive",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    isCodeActive
                        ? "Scan this QR code to view your pet's information"
                        : "Enable the toggle above to activate the QR code",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    textAlign: TextAlign.center,
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
                          onPressed: isCodeActive
                              ? () => _printPetQrTag(qrUrl, pet)
                              : null,
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
    bool saving = false;
    Future<String>? uploadFuture;

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
                            maxWidth: 800,
                            maxHeight: 800,
                            imageQuality: 80,
                          );
                          if (img != null) {
                            setDialogState(() => newImg = img.path);
                            // Start upload immediately in background
                            final uid =
                                FirebaseAuth.instance.currentUser!.uid;
                            uploadFuture = img.readAsBytes().then(
                              (bytes) => _db.uploadPetImage(
                                uid: uid,
                                bytes: bytes,
                                fileName: img.name,
                              ),
                            );
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
                                  child: kIsWeb
                                      ? Image.network(
                                          newImg!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
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
                        onPressed: saving
                            ? null
                            : () async {
                                setDialogState(() => saving = true);
                                try {
                                  String? uploadedUrl = newImg;
                                  if (uploadFuture != null) {
                                    uploadedUrl = await uploadFuture;
                                  }
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
                                    'imagePath': uploadedUrl,
                                  });
                                  if (context.mounted) Navigator.pop(context);
                                } catch (e) {
                                  if (context.mounted) {
                                    setDialogState(() => saving = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Save failed: $e')),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
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

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Error loading pets:\n${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }

                  final List pets = snapshot.data?.docs ?? [];

                  if (pets.isEmpty) {
                    return const Center(
                      child: Text(
                        "No pets yet. Tap 'Add Pet' to get started.",
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
                  child: _petImage(
                    pet['imagePath'] as String?,
                    size: 48,
                    placeholder: const Icon(Icons.pets, size: 24, color: Colors.grey),
                  ),
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
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await _db.deletePet(petId);
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text("Failed to delete pet: ${e.toString()}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
  static Future<String?> _showBreedSearchDialog(
    BuildContext context,
    List<BreedInfo> breeds,
  ) {
    final searchCtrl = TextEditingController();
    var filtered = List<BreedInfo>.from(breeds);
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text(
            'Select Breed',
            style: TextStyle(fontSize: 16, color: Color(0xFF634732)),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 360,
            child: Column(
              children: [
                TextField(
                  controller: searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search breed...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF0F4F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                  ),
                  onChanged: (q) => setD(() {
                    filtered = q.isEmpty
                        ? List<BreedInfo>.from(breeds)
                        : breeds
                            .where((b) => b.name
                                .toLowerCase()
                                .contains(q.toLowerCase()))
                            .toList();
                  }),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => ListTile(
                      dense: true,
                      title: Text(
                        filtered[i].name,
                        style: const TextStyle(fontSize: 13),
                      ),
                      onTap: () => Navigator.pop(ctx, filtered[i].name),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _petImage(
    String? path, {
    required double size,
    required Widget placeholder,
  }) {
    if (path == null || path.isEmpty) return placeholder;
    if (path.startsWith('data:')) {
      try {
        final bytes = base64Decode(path.substring(path.indexOf(',') + 1));
        return Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (ctx, e, st) => placeholder,
        );
      } catch (_) {
        return placeholder;
      }
    }
    return Image.network(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (ctx, e, st) => placeholder,
    );
  }

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

  // Encodes a URL so any phone camera opens the pet's public profile in the browser.
  String _buildPetQrUrl(String ownerUid, String petId) {
    return 'https://pawvera-3578f.web.app/#/pet/$ownerUid/$petId';
  }

  Future<void> _printPetQrTag(String qrUrl, Map pet) async {
    try {
      final doc = pw.Document();
      final qrData = qrUrl;

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
                  barcode: pw.Barcode.qrCode(
                    errorCorrectLevel: pw.BarcodeQRCorrectionLevel.low,
                  ),
                  data: qrData,
                  width: 250,
                  height: 250,
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
