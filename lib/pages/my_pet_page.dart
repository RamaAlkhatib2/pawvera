import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pawvera/components/pet_card.dart';
import 'package:pawvera/model/pet_model.dart';

class MyPetPage extends StatefulWidget {
  const MyPetPage({super.key});

  @override
  State<MyPetPage> createState() => _MyPetPageState();
}

class _MyPetPageState extends State<MyPetPage> {
  final Color primaryGreen = const Color(0xFF5B9D8E);
  final Color backgroundColor = const Color(0xFFF0F4F3);

  // حالة الـ QR Code (تُعرف هنا لتكون قابلة للتغيير)
  bool isQRCodeActive = true;

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

  // 1. دالة إظهار الـ QR Code المحدثة تماماً حسب Figma
  void showPetQRCode(Pet pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        // للسماح بتحديث الـ Switch داخل الـ Sheet
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ),
                Text(
                  "Pet QR Tag - ${pet.name}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Scan or edit your pet's QR tag information",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 20),

                // قسم حالة الـ QR Code والـ Switch
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "QR Code Status",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isQRCodeActive
                                ? "Active - Code can be scanned"
                                : "Inactive - Code is disabled",
                            style: TextStyle(
                              color: isQRCodeActive
                                  ? primaryGreen
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: isQRCodeActive,
                        onChanged: (val) =>
                            setModalState(() => isQRCodeActive = val),
                        activeColor: primaryGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // الـ QR Code والوصف
                QrImageView(
                  data: "Pet Name: ${pet.name}, Breed: ${pet.breed}",
                  version: QrVersions.auto,
                  size: 180.0,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Scan this QR code to view ${pet.name}'s information",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 25),

                // معلومات التواصل والطبية
                _infoSection("Owner Contact:", "Not set - No phone"),
                const SizedBox(height: 12),
                _infoSection("Medical Info:", "None specified"),
                const SizedBox(height: 25),

                // أزرار التحكم السفلية
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.edit_note),
                        label: const Text("Edit Info"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryGreen,
                          side: BorderSide(color: primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.print_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Print QR Tag",
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
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoSection(String title, String value) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(value, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AddPetSheet(
                        onPetAdded: (newPet) {
                          setState(() => myPets.add(newPet));
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Add Pet",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: myPets.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: PetCard(
                        pet: myPets[index],
                        onDelete: () => setState(() => myPets.removeAt(index)),
                        onEdit: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AddPetSheet(
                              petToEdit: myPets[index],
                              onPetAdded: (updatedPet) {
                                setState(() => myPets[index] = updatedPet);
                              },
                            ),
                          );
                        },
                        onShowQR: () => showPetQRCode(myPets[index]),
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

// --- كلاس AddPetSheet (كما في الكود الخاص بكِ تماماً) ---
class AddPetSheet extends StatefulWidget {
  final Function(Pet) onPetAdded;
  final Pet? petToEdit;

  const AddPetSheet({super.key, required this.onPetAdded, this.petToEdit});

  @override
  State<AddPetSheet> createState() => _AddPetSheetState();
}

class _AddPetSheetState extends State<AddPetSheet> {
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _colorController;
  String? selectedType;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.petToEdit?.name ?? "");
    _breedController = TextEditingController(
      text: widget.petToEdit?.breed ?? "",
    );
    _ageController = TextEditingController(
      text: widget.petToEdit?.age.replaceAll(RegExp(r'[^0-9]'), '') ?? "",
    );
    _weightController = TextEditingController(
      text: widget.petToEdit?.weight.replaceAll(RegExp(r'[^0-9.]'), '') ?? "",
    );
    _colorController = TextEditingController(
      text: widget.petToEdit?.color ?? "",
    );
    selectedType = widget.petToEdit?.type;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 15,
        bottom: bottomInset + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                widget.petToEdit == null ? "Add New Pet" : "Edit Pet Info",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          color: Color(0xFF5B9D8E),
                          size: 30,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 15),
            _buildTextField("Pet Name", _nameController),
            _buildDropdownField("Type", [
              "Dog",
              "Cat",
              "Bird",
              "Other",
            ], (val) => setState(() => selectedType = val)),
            _buildTextField("Breed", _breedController),
            Row(
              children: [
                Expanded(
                  child: _buildTextField("Age", _ageController, isNumber: true),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTextField(
                    "Weight (kg)",
                    _weightController,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    final newPet = Pet(
                      name: _nameController.text,
                      breed: _breedController.text,
                      age: "${_ageController.text} years",
                      type: selectedType ?? "Dog",
                      color: _colorController.text,
                      weight: "${_weightController.text}kg",
                      imagePath:
                          _selectedImage?.path ?? widget.petToEdit?.imagePath,
                    );
                    widget.onPetAdded(newPet);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9D8E),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  widget.petToEdit == null ? "Add Pet" : "Save Changes",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
