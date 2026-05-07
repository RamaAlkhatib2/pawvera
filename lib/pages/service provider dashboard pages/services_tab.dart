import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  static const Color primaryTeal = Color(0xFF2D6A64);

  // قائمة الخدمات
  List<Map<String, dynamic>> services = [
    {
      'name': 'Full Grooming Package',
      'description': 'Bath, haircut, nail trim, and ear cleaning',
      'price': '45.00',
      'duration': '2 hours',
      'isActive': true,
      'image': null,
    },
    {
      'name': 'Basic Bath & Brush',
      'description': 'Wash and brush service',
      'price': '30.00',
      'duration': '1 hour',
      'isActive': true,
      'image': null,
    },
  ];

  // متغيرات التحكم بالبحث
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // متحكمات واجهة الإضافة/التعديل
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  File? _selectedImage;

  // دالة البحث (تعيد القائمة المصفاة فقط)
  List<Map<String, dynamic>> get _filteredServices {
    if (_searchQuery.isEmpty) return services;
    return services
        .where(
          (service) => service['name'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  Future<void> _pickImage(StateSetter setModalState) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setModalState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _openServiceForm({
    Map<String, dynamic>? serviceToEdit,
    int? originalIndex,
  }) {
    if (serviceToEdit != null) {
      _nameController.text = serviceToEdit['name'];
      _descController.text = serviceToEdit['description'];
      _priceController.text = serviceToEdit['price'];
      _durationController.text = serviceToEdit['duration'];
      _selectedImage = serviceToEdit['image'];
    } else {
      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      _durationController.clear();
      _selectedImage = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => _buildServiceFormUI(
          setModalState,
          isEdit: serviceToEdit != null,
          index: originalIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredServices; // القائمة المصفاة بناءً على البحث

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الرأس: العنوان وزر الإضافة
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Manage Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _openServiceForm(),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text(
                "Add Service",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // --- شريط البحث الجديد ---
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: "Search services...",
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // قائمة الخدمات (المصفاة)
        displayList.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No services found."),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  // للحصول على الـ index الحقيقي في القائمة الأصلية عند التعديل
                  final service = displayList[index];
                  final originalIndex = services.indexOf(service);
                  return _buildServiceCard(service, originalIndex);
                },
              ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service['image'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  service['image'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                service['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              _buildActiveBadge(service['isActive']),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            service['description'],
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                "\$${service['price']}",
                style: const TextStyle(
                  color: primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 15),
              Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                service['duration'],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openServiceForm(
                    serviceToEdit: service,
                    originalIndex: index,
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(
                    () => services[index]['isActive'] =
                        !services[index]['isActive'],
                  ),
                  icon: Icon(
                    service['isActive']
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 16,
                  ),
                  label: Text(service['isActive'] ? "Deactivate" : "Activate"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // واجهة الـ Form (نفس السابقة بدون تغيير في التصميم)
  Widget _buildServiceFormUI(
    StateSetter setModalState, {
    required bool isEdit,
    int? index,
  }) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? "Edit Service" : "Add New Service",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildLabel("Service Photo *"),
            GestureDetector(
              onTap: () => _pickImage(setModalState),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _selectedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: GestureDetector(
                              onTap: () =>
                                  setModalState(() => _selectedImage = null),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_outlined, color: Colors.grey),
                          Text(
                            "Click to upload photo",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 15),
            _buildLabel("Service Name *"),
            _buildTextField(_nameController, "e.g., Full Grooming Package"),
            const SizedBox(height: 15),
            _buildLabel("Description *"),
            _buildTextField(
              _descController,
              "Describe the service...",
              maxLines: 3,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Price (\$) *"),
                      _buildTextField(_priceController, "0.00"),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Duration *"),
                      _buildTextField(_durationController, "e.g., 2 hours"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    setState(() {
                      final data = {
                        'name': _nameController.text,
                        'description': _descController.text,
                        'price': _priceController.text,
                        'duration': _durationController.text,
                        'isActive': isEdit
                            ? services[index!]['isActive']
                            : true,
                        'image': _selectedImage,
                      };
                      isEdit ? services[index!] = data : services.add(data);
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryTeal),
                child: Text(
                  isEdit ? "Update Service" : "Add Service",
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

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    ),
  );
  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) => TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
    ),
  );
  Widget _buildActiveBadge(bool isActive) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isActive
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      isActive ? "Active" : "Inactive",
      style: TextStyle(
        color: isActive ? Colors.green : Colors.grey,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
