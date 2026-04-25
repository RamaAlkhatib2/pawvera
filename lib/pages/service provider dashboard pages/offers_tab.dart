import 'package:flutter/material.dart';

class OffersTab extends StatefulWidget {
  const OffersTab({super.key});

  @override
  State<OffersTab> createState() => _OffersTabState();
}

class _OffersTabState extends State<OffersTab> {
  final Color primaryTeal = const Color(0xFF2D6A64);

  // قائمة وهمية للخدمات (يفضل جلبها من Provider أو Database)
  List<String> myServices = [
    "Full Grooming Package",
    "Basic Bath & Brush",
    "Pet Vaccination",
  ];
  String? selectedService;

  // قائمة العروض المضافة
  List<Map<String, dynamic>> activeOffers = [];

  // متحكمات الحقول
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Manage Offers",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // أزرار إنشاء العروض
        Row(
          children: [
            Expanded(
              child: _buildCreateButton(
                "Create Shop-wide Offer",
                Icons.storefront,
                () => _showOfferDialog(isShopWide: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCreateButton(
                "Create Service Offer",
                Icons.content_cut,
                () => _showOfferDialog(isShopWide: false),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        const Text(
          "Active Offers",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        activeOffers.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeOffers.length,
                itemBuilder: (context, index) =>
                    _buildOfferCard(activeOffers[index], index),
              ),
      ],
    );
  }

  Widget _buildCreateButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryTeal, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // نافذة إضافة العرض
  void _showOfferDialog({required bool isShopWide}) {
    selectedService = null;
    _discountController.clear();
    _expiryController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isShopWide ? "New Shop-wide Offer" : "New Service Offer",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              if (!isShopWide) ...[
                const Text(
                  "Select Service *",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("Choose a service"),
                      value: selectedService,
                      items: myServices
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setModalState(() => selectedService = val),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],

              const Text(
                "Discount Percentage (%) *",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "e.g. 20",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              const Text(
                "Expiry Date *",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _expiryController,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setModalState(
                      () => _expiryController.text = "${pickedDate.toLocal()}"
                          .split(' ')[0],
                    );
                  }
                },
                decoration: InputDecoration(
                  hintText: "YYYY-MM-DD",
                  prefixIcon: const Icon(Icons.calendar_today, size: 18),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_discountController.text.isNotEmpty &&
                        _expiryController.text.isNotEmpty) {
                      setState(() {
                        activeOffers.add({
                          'title': isShopWide
                              ? "Full Shop Discount"
                              : selectedService,
                          'discount': _discountController.text,
                          'expiry': _expiryController.text,
                          'isShopWide': isShopWide,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Create Offer",
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
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: offer['isShopWide']
            ? primaryTeal.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: offer['isShopWide'] ? primaryTeal : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryTeal,
            child: Text(
              "${offer['discount']}%",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Expires: ${offer['expiry']}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => setState(() => activeOffers.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            "No active offers yet",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
