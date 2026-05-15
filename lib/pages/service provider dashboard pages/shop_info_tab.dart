import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pawvera/controllers/service_provider_controller.dart';
import 'package:pawvera/models/service_provider_models.dart';

class ShopInfoTab extends StatefulWidget {
  const ShopInfoTab({super.key});

  @override
  State<ShopInfoTab> createState() => _ShopInfoTabState();
}

class _ShopInfoTabState extends State<ShopInfoTab> {
  static const Color primaryTeal = Color(0xFF2D6A64);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _openEditShopInfo(ShopProfile shop) {
    _nameController.text = shop.shopName;
    _locationController.text = shop.address;
    _phoneController.text = shop.phone;
    _emailController.text = shop.email;
    _hoursController.text = shop.workingHours;

    // Local state for the bottom sheet only
    Uint8List? selectedImageBytes;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickImage() async {
              final picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 1024,
                maxHeight: 1024,
                imageQuality: 85,
              );
              if (image != null) {
                final bytes = await image.readAsBytes();
                setSheetState(() {
                  selectedImageBytes = bytes;
                });
              }
            }

            Future<void> saveShopInfo() async {
              final ctrl = context.read<ServiceProviderController>();
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(this.context);
              setSheetState(() => isUploading = true);
              try {
                String? imageUrl;

                // Upload image if a new one was selected
                if (selectedImageBytes != null) {
                  try {
                    imageUrl = await ctrl
                        .uploadShopImageBytes(selectedImageBytes!)
                        .timeout(const Duration(seconds: 10));
                  } catch (_) {
                    // Fall back to base64 data URL if Firebase Storage isn't configured
                    imageUrl = ctrl.encodeImageAsDataUrl(selectedImageBytes!);
                  }
                }

                await ctrl.updateShopInfo(
                  shopName: _nameController.text,
                  address: _locationController.text,
                  phone: _phoneController.text,
                  email: _emailController.text,
                  workingHours: _hoursController.text,
                  imageUrl: imageUrl,
                );

                setSheetState(() => isUploading = false);
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text("Shop information updated successfully"),
                  ),
                );
              } catch (e) {
                setSheetState(() => isUploading = false);
                messenger.showSnackBar(
                  SnackBar(content: Text("Failed to update: $e")),
                );
              }
            }

            return _buildEditForm(
              shop: shop,
              selectedImageBytes: selectedImageBytes,
              isUploading: isUploading,
              onPickImage: pickImage,
              onSave: saveShopInfo,
            );
          },
        );
      },
    );
  }

  Widget buildShopImagePreview(
    String? imageUrl,
    Uint8List? selectedImageBytes,
    double height,
  ) {
    if (selectedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          selectedImageBytes,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => buildPlaceholderImage(height),
        ),
      );
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => buildPlaceholderImage(height),
        ),
      );
    }
    return buildPlaceholderImage(height);
  }

  Widget buildPlaceholderImage(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 4),
          Text(
            "Shop Image",
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProviderController>(
      builder: (context, ctrl, _) {
        if (ctrl.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final shop = ctrl.shop;
        if (shop == null) {
          return const Center(child: Text('Shop not found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Shop Management",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildStatusCard(shop, ctrl),
              const SizedBox(height: 16),
              _buildInfoCard(shop),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(ShopProfile shop, ServiceProviderController ctrl) {
    Color statusColor;
    switch (shop.status) {
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
                  shop.status,
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
              _statusButton("Open", Colors.green, shop.status == "Open", () {
                ctrl.setShopStatus("Open");
              }),
              const SizedBox(width: 8),
              _statusButton("Busy", Colors.orange, shop.status == "Busy", () {
                ctrl.setShopStatus("Busy");
              }),
              const SizedBox(width: 8),
              _statusButton("Closed", Colors.red, shop.status == "Closed", () {
                ctrl.setShopStatus("Closed");
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(
    String label,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
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

  Widget _buildInfoCard(ShopProfile shop) {
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
          // Shop image at the top of the info card
          Center(child: buildShopImagePreview(shop.imageUrl, null, 150)),
          const SizedBox(height: 16),
          const Text(
            "Shop Information",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _infoRow(Icons.storefront_outlined, shop.shopName),
          _infoRow(Icons.location_on_outlined, shop.address),
          _infoRow(Icons.phone_outlined, shop.phone),
          _infoRow(Icons.email_outlined, shop.email),
          _infoRow(Icons.access_time, shop.workingHours),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openEditShopInfo(shop),
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

  Widget _buildEditForm({
    required ShopProfile shop,
    required Uint8List? selectedImageBytes,
    required bool isUploading,
    required VoidCallback onPickImage,
    required VoidCallback onSave,
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

            // Shop Image Section
            _buildLabel("Shop Image"),
            const SizedBox(height: 8),
            Stack(
              children: [
                buildShopImagePreview(shop.imageUrl, selectedImageBytes, 160),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: InkWell(
                    onTap: onPickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: primaryTeal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (selectedImageBytes != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "New image selected",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                    fontStyle: FontStyle.italic,
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
                onPressed: isUploading ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
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
