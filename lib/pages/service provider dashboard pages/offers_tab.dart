import 'package:flutter/material.dart';

class OffersTab extends StatefulWidget {
  const OffersTab({super.key});

  @override
  State<OffersTab> createState() => _OffersTabState();
}

class _OffersTabState extends State<OffersTab> {
  final Color primaryTeal = const Color(0xFF2D6A64);
  final Color accentOrange = const Color(0xFFE67E22);

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
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _minBookingController = TextEditingController();

  // حالات الـ Checkbox
  bool _applyPriceRange = false;
  bool _requireMinBooking = false;

  // خيارات الخصم السريع
  final List<int> quickDiscounts = [10, 15, 20, 25, 30, 50];
  int? selectedQuickDiscount;

  // قوائم مفصولة حسب النوع
  List<Map<String, dynamic>> get shopWideOffers =>
      activeOffers.where((o) => o['isShopWide'] == true).toList();
  List<Map<String, dynamic>> get serviceOffers =>
      activeOffers.where((o) => o['isShopWide'] == false).toList();

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

        // بطاقة: Shop Wide Offer
        _buildOfferTypeCard(
          title: "Shop Wide Offer",
          description: "Create discount offer for all services in your shop",
          buttonLabel: "+ Create shop-wide offer",
          icon: Icons.storefront_rounded,
          accentColor: accentOrange,
          onTap: () => _showOfferDialog(isShopWide: true),
        ),
        const SizedBox(height: 14),

        // بطاقة: Service Offer
        _buildOfferTypeCard(
          title: "Service Offer",
          description: "Create discount offer for a specific service",
          buttonLabel: "+ Create service offer",
          icon: Icons.content_cut_rounded,
          accentColor: primaryTeal,
          onTap: () => _showOfferDialog(isShopWide: false),
        ),

        const SizedBox(height: 24),
        const Text(
          "Shop Wide Offers",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        shopWideOffers.isEmpty
            ? _buildEmptyState(isShopWide: true)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shopWideOffers.length,
                itemBuilder: (context, index) => _buildOfferCard(
                  shopWideOffers[index],
                  activeOffers.indexOf(shopWideOffers[index]),
                ),
              ),

        const SizedBox(height: 20),
        const Text(
          "Service Offers",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        serviceOffers.isEmpty
            ? _buildEmptyState(isShopWide: false)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: serviceOffers.length,
                itemBuilder: (context, index) => _buildOfferCard(
                  serviceOffers[index],
                  activeOffers.indexOf(serviceOffers[index]),
                ),
              ),
      ],
    );
  }

  Widget _buildOfferTypeCard({
    required String title,
    required String description,
    required String buttonLabel,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + الأيقونة
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: Text(
                buttonLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // نافذة إضافة العرض - بتصميم جديد
  void _showOfferDialog({required bool isShopWide}) {
    selectedService = null;
    selectedQuickDiscount = null;
    _discountController.clear();
    _expiryController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    _minBookingController.clear();
    _applyPriceRange = false;
    _requireMinBooking = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 24,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان مع أيقونة
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (isShopWide ? accentOrange : primaryTeal)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isShopWide
                            ? Icons.storefront_rounded
                            : Icons.content_cut_rounded,
                        color: isShopWide ? accentOrange : primaryTeal,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isShopWide ? "New Shop-wide Offer" : "New Service Offer",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // اختيار الخدمة (فقط للـ Service Offer)
                if (!isShopWide) ...[
                  const Text(
                    "Select Service",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          "Choose a service",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
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
                  const SizedBox(height: 20),
                ],

                // قسم: Quick Discount Selection
                const Text(
                  "Quick Discount",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickDiscounts.map((discount) {
                    final isSelected = selectedQuickDiscount == discount;
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          selectedQuickDiscount = discount;
                          _discountController.text = discount.toString();
                        });
                      },
                      child: Container(
                        width: 56,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isShopWide ? accentOrange : primaryTeal)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? (isShopWide ? accentOrange : primaryTeal)
                                : Colors.grey[200]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$discount%',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // قسم: Or enter custom discount
                const Text(
                  "Or enter custom discount",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setModalState(() {
                      selectedQuickDiscount = null;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Enter discount percentage",
                    suffixText: "%",
                    suffixStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isShopWide ? accentOrange : primaryTeal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // قسم: Valid Until
                const Text(
                  "Valid Until",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: isShopWide ? accentOrange : primaryTeal,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      setModalState(
                        () => _expiryController.text = "${pickedDate.toLocal()}"
                            .split(' ')[0],
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Select expiry date",
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey[400],
                    ),
                    suffixIcon: _expiryController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            onPressed: () =>
                                setModalState(() => _expiryController.clear()),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isShopWide ? accentOrange : primaryTeal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Checkbox: Apply to service in specific price range (فقط للـ Shop-wide Offer)
                if (isShopWide) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => setModalState(
                            () => _applyPriceRange = !_applyPriceRange,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _applyPriceRange
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: _applyPriceRange
                                    ? (isShopWide ? accentOrange : primaryTeal)
                                    : Colors.grey[400],
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Apply to service in specific price range",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_applyPriceRange) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _minPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Min price",
                                    suffixText: "\$",
                                    suffixStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _maxPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Max price",
                                    suffixText: "\$",
                                    suffixStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Checkbox: Require minimum booking amount (فقط للـ Service Offer)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => setModalState(
                            () => _requireMinBooking = !_requireMinBooking,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _requireMinBooking
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: _requireMinBooking
                                    ? (isShopWide ? accentOrange : primaryTeal)
                                    : Colors.grey[400],
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Require minimum booking amount",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_requireMinBooking) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _minBookingController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Minimum amount",
                              suffixText: "\$",
                              suffixStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // الأزرار: Cancel + Create Offer
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isShopWide
                                ? accentOrange
                                : primaryTeal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
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
                                  'isActive': true,
                                  'minPrice': _applyPriceRange
                                      ? _minPriceController.text
                                      : null,
                                  'maxPrice': _applyPriceRange
                                      ? _maxPriceController.text
                                      : null,
                                  'minBooking': _requireMinBooking
                                      ? _minBookingController.text
                                      : null,
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
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer, int index) {
    final isShopWide = offer['isShopWide'] as bool;
    final accentColor = isShopWide ? accentOrange : primaryTeal;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "${offer['discount']}%",
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            offer['title'] ?? 'Offer',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isShopWide
                                ? accentOrange.withValues(alpha: 0.1)
                                : primaryTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isShopWide ? "Shop-wide" : "Service",
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Expires: ${offer['expiry']}",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (offer['minPrice'] != null &&
                        (offer['minPrice'] as String).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Price range: \$${offer['minPrice']} - \$${offer['maxPrice']}",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (offer['minBooking'] != null &&
                        (offer['minBooking'] as String).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Min booking: \$${offer['minBooking']}",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    activeOffers[index]['isActive'] =
                        !(activeOffers[index]['isActive'] ?? true);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (offer['isActive'] ?? true)
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (offer['isActive'] ?? true) ? "Active" : "Inactive",
                    style: TextStyle(
                      color: (offer['isActive'] ?? true)
                          ? Colors.green
                          : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => setState(() => activeOffers.removeAt(index)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

  Widget _buildEmptyState({bool isShopWide = true}) {
    return Center(
      child: Column(
        children: [
          Icon(
            isShopWide ? Icons.storefront_outlined : Icons.content_cut_outlined,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 10),
          Text(
            isShopWide ? "No shop-wide offers yet" : "No service offers yet",
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
