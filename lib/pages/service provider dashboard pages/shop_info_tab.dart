import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ShopInfoTab extends StatefulWidget {
  const ShopInfoTab({super.key});

  @override
  State<ShopInfoTab> createState() => _ShopInfoTabState();
}

class _ShopInfoTabState extends State<ShopInfoTab> {
  static const Color primaryTeal = Color(0xFF2D6A64);

  // بيانات المتجر الأساسية
  String shopName = "Pawfect Spa";
  String shopLocation = "123 Main St, Downtown";
  String shopPhone = "+1 (555) 000-1111";
  String shopEmail = "contact@pawfectspa.com";
  String shopHours = "9:00 AM - 7:00 PM";
  String shopStatus = "Open"; // الأوضاع: Open, Busy, Closed
  File? shopImage;

  // متحكمات التعديل
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  // تغيير حالة المتجر
  void _updateStatus(String newStatus) {
    setState(() {
      shopStatus = newStatus;
    });
  }

  // ميثود فتح واجهة التعديل
  void _openEditShopInfo() {
    _nameController.text = shopName;
    _locationController.text = shopLocation;
    _phoneController.text = shopPhone;
    _emailController.text = shopEmail;
    _hoursController.text = shopHours;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => _buildEditForm(setModalState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Shop Management",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // كرت حالة المتجر (Shop Status)
          _buildStatusCard(),

          const SizedBox(height: 16),

          // كرت معلومات المتجر
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    switch (shopStatus) {
      case "Open":
        statusColor = Colors.green;
        break;
      case "Busy":
        statusColor = Colors.orange;
        break;
      case "Closed":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Shop Status",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  shopStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statusButton("Open", Colors.green, shopStatus == "Open"),
              const SizedBox(width: 8),
              _statusButton("Busy", Colors.orange, shopStatus == "Busy"),
              const SizedBox(width: 8),
              _statusButton("Closed", Colors.red, shopStatus == "Closed"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String label, Color color, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => _updateStatus(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            border: Border.all(color: isSelected ? color : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Shop Information",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _infoRow(Icons.storefront_outlined, shopName),
          _infoRow(Icons.location_on_outlined, shopLocation),
          _infoRow(Icons.phone_outlined, shopPhone),
          _infoRow(Icons.email_outlined, shopEmail),
          _infoRow(Icons.access_time, shopHours),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openEditShopInfo,
              icon: const Icon(Icons.edit_note, size: 20),
              label: const Text("Edit Information"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // نافذة تعديل البيانات (نفس ستايل صور الفيجما المرفقة)
  Widget _buildEditForm(StateSetter setModalState) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Edit Shop Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildLabel("Shop Image"),
            Center(
              child: GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null)
                    setModalState(() => shopImage = File(picked.path));
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: shopImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(shopImage!, fit: BoxFit.cover),
                        )
                      : const Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildLabel("Shop Name *"),
            _buildTextField(_nameController, "Shop Name"),
            const SizedBox(height: 15),
            _buildLabel("Location *"),
            _buildTextField(_locationController, "Address"),
            const SizedBox(height: 15),
            _buildLabel("Phone *"),
            _buildTextField(_phoneController, "Phone number"),
            const SizedBox(height: 15),
            _buildLabel("Email *"),
            _buildTextField(_emailController, "Email address"),
            const SizedBox(height: 15),
            _buildLabel("Open Hours *"),
            _buildTextField(_hoursController, "e.g., 9:00 AM - 7:00 PM"),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    shopName = _nameController.text;
                    shopLocation = _locationController.text;
                    shopPhone = _phoneController.text;
                    shopEmail = _emailController.text;
                    shopHours = _hoursController.text;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Update Information",
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
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    ),
  );
  Widget _buildTextField(TextEditingController controller, String hint) =>
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      );
}
