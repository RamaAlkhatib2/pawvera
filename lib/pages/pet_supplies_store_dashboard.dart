import 'package:flutter/material.dart';
import 'login_view.dart';

class PetSuppliesStoreDashboard extends StatefulWidget {
  const PetSuppliesStoreDashboard({super.key});

  @override
  State<PetSuppliesStoreDashboard> createState() =>
      _PetSuppliesStoreDashboardState();
}

class _PetSuppliesStoreDashboardState extends State<PetSuppliesStoreDashboard> {
  int _selectedTabIndex = 0;
  bool _isStoreOpen = true;
  String _selectedOrdersFilter = 'All';
  String _orderSearchQuery = '';
  String _productSearchQuery = '';
  String _offerSearchQuery = '';
  String _auditSearchQuery = '';
  DateTime? _selectedOrderDate;
  DateTime? _selectedAuditDate;

  final TextEditingController _profileNameController = TextEditingController(
    text: 'John Anderson',
  );
  final TextEditingController _profileEmailController = TextEditingController(
    text: 'hhh@gmail.com',
  );
  final TextEditingController _profilePhoneController = TextEditingController(
    text: '+1 (555) 444-5555',
  );
  final TextEditingController _profileBusinessNameController =
      TextEditingController(text: 'Pet Supplies Plus');

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final List<Map<String, dynamic>> _storeWideOffers = [
    {
      'title': '20% Off on Orders Above 50 JOD',
      'description':
          'Get 20% discount on all products when you order above 50 JOD',
      'discount': '20% OFF',
      'type': 'Store-Wide',
      'validUntil': 'Valid until: Feb 15, 2026',
      'minOrder': 'Min order: 50',
      'status': 'Active',
    },
  ];

  final List<Map<String, dynamic>> _productSales = [
    {
      'title': '15% Off Premium Dog Food',
      'description': 'Special discount on Premium Dog Food 20kg',
      'discount': '15% OFF',
      'type': 'Product Sale',
      'validUntil': 'Valid until: Feb 28, 2026',
      'status': 'Active',
    },
  ];

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD001',
      'customer': 'Sarah Johnson',
      'email': 'sarah@email.com',
      'date': 'Jan 05, 2026 at 10:30 AM',
      'payment': 'Credit Card',
      'items': '2 item(s)',
      'total': '107.40 JOD',
      'phone': '+1 (555) 123-4567',
      'address': 'Building 15, King Fahd Road, Riyadh',
      'addressLine1': 'Building 15, King Fahd Road',
      'addressLine2': 'Riyadh',
      'floor': '3',
      'apartment': '302',
      'status': 'Pending',
      'orderItems': [
        {'name': 'Premium Dog Food 10kg', 'quantity': 2, 'price': '110.00 JOD'},
        {'name': 'Interactive Dog Toy', 'quantity': 1, 'price': '18.00 JOD'},
      ],
      'subtotal': '128.00 JOD',
      'discount': '-25.60 JOD',
      'deliveryFee': '5.00 JOD',
    },
    {
      'id': 'ORD002',
      'customer': 'Mike Brown',
      'email': 'mike@email.com',
      'date': 'Jan 06, 2026 at 02:15 PM',
      'payment': 'Cash on Delivery',
      'items': '1 item(s)',
      'total': '71.00 JOD',
      'phone': '+1 (555) 987-6543',
      'address': 'Tower 23, Al-Olaya Street, Riyadh',
      'addressLine1': 'Tower 23, Al-Olaya Street',
      'addressLine2': 'Riyadh',
      'floor': '5',
      'apartment': '110',
      'status': 'Confirmed',
      'orderItems': [
        {'name': 'Cat Litter Premium 5kg', 'quantity': 1, 'price': '71.00 JOD'},
      ],
      'subtotal': '71.00 JOD',
      'discount': '-0.00 JOD',
      'deliveryFee': '0.00 JOD',
    },
    {
      'id': 'ORD003',
      'customer': 'Emily Davis',
      'email': 'emily@email.com',
      'date': 'Jan 07, 2026 at 11:00 AM',
      'payment': 'Apple Pay',
      'items': '1 item(s)',
      'total': '33.00 JOD',
      'phone': '+1 (555) 456-7890',
      'address': 'Building 8, Prince Mohammad Street, Riyadh',
      'addressLine1': 'Building 8, Prince Mohammad Street',
      'addressLine2': 'Riyadh',
      'floor': '1',
      'apartment': '204',
      'status': 'Out for Delivery',
      'orderItems': [
        {'name': 'Interactive Dog Toy', 'quantity': 1, 'price': '33.00 JOD'},
      ],
      'subtotal': '33.00 JOD',
      'discount': '-0.00 JOD',
      'deliveryFee': '0.00 JOD',
    },
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Premium Dog Food 10kg',
      'brand': 'NutraPet',
      'category': 'Food',
      'price': '44.00 JOD',
      'originalPrice': '55.00 JOD',
      'stock': '150',
      'discount': '20%',
      'hasSale': true,
      'isActive': true,
      'image':
          'https://images.unsplash.com/photo-1589924691106-073b19f5538d?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'Cat Litter Premium 5kg',
      'brand': 'CleanPaws',
      'category': 'Accessories',
      'price': '22.00 JOD',
      'stock': '85',
      'discount': '',
      'hasSale': false,
      'isActive': true,
      'image':
          'https://images.unsplash.com/photo-1572365992253-3cb3e56dd362?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'Interactive Dog Toy',
      'brand': 'PlayPaws',
      'category': 'Toys',
      'price': '18.00 JOD',
      'stock': '42',
      'discount': '20%',
      'hasSale': true,
      'isActive': true,
      'image':
          'https://images.unsplash.com/photo-1513284411132-47685382e39c?q=80&w=1000&auto=format&fit=crop',
    },
    {
      'name': 'Pet Multivitamin Tablets',
      'brand': 'VitaPet',
      'category': 'Health',
      'price': '28.00 JOD',
      'stock': '5',
      'discount': '',
      'hasSale': false,
      'isActive': true,
      'image':
          'https://images.unsplash.com/photo-1584399579527-02b89e2c85ef?q=80&w=1000&auto=format&fit=crop',
    },
  ];

  void _updateOrderStatus(String orderId, String newStatus) {
    setState(() {
      final index = _orders.indexWhere((order) => order['id'] == orderId);
      if (index != -1) {
        _orders[index] = Map<String, dynamic>.from(_orders[index]);
        _orders[index]['status'] = newStatus;
      }
    });
  }

  void _addStoreWideOffer(Map<String, dynamic> offer) {
    setState(() {
      _storeWideOffers.insert(0, offer);
    });
  }

  void _addProductSale(Map<String, dynamic> offer) {
    setState(() {
      _productSales.insert(0, offer);
    });
  }

  void _updateStoreWideOffer(int index, Map<String, dynamic> offer) {
    setState(() {
      _storeWideOffers[index] = offer;
    });
  }

  void _updateProductSale(int index, Map<String, dynamic> offer) {
    setState(() {
      _productSales[index] = offer;
    });
  }

  void _toggleOfferActive(int index, bool isStoreWide) {
    setState(() {
      if (isStoreWide) {
        _storeWideOffers[index] = Map<String, dynamic>.from(
          _storeWideOffers[index],
        );
        _storeWideOffers[index]['status'] =
            _storeWideOffers[index]['status'] == 'Active'
            ? 'Inactive'
            : 'Active';
      } else {
        _productSales[index] = Map<String, dynamic>.from(_productSales[index]);
        _productSales[index]['status'] =
            _productSales[index]['status'] == 'Active' ? 'Inactive' : 'Active';
      }
    });
  }

  void _removeOffer(int index, bool isStoreWide) {
    setState(() {
      if (isStoreWide) {
        _storeWideOffers.removeAt(index);
      } else {
        _productSales.removeAt(index);
      }
    });
  }

  @override
  void dispose() {
    _profileNameController.dispose();
    _profileEmailController.dispose();
    _profilePhoneController.dispose();
    _profileBusinessNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showStoreWideOfferDialog({Map<String, dynamic>? offer, int? index}) {
    String selectedDiscount = '20';
    final titleController = TextEditingController(
      text: offer != null
          ? offer['title'] as String
          : '20% Off on Orders Above 50 JOD',
    );
    final descriptionController = TextEditingController(
      text: offer != null
          ? offer['description'] as String
          : 'Get 20% discount on all products when you order above 50 JOD',
    );
    final discountController = TextEditingController(
      text: offer != null
          ? (offer['discount'] as String).replaceAll('% OFF', '').trim()
          : '20',
    );
    final minOrderController = TextEditingController(
      text:
          offer != null &&
              offer['minOrder'] != null &&
              (offer['minOrder'] as String).isNotEmpty
          ? (offer['minOrder'] as String).replaceAll(RegExp('[^0-9]'), '')
          : '50',
    );
    final minPriceController = TextEditingController(
      text: offer != null ? offer['minPrice'] as String? ?? '' : '',
    );
    final maxPriceController = TextEditingController(
      text: offer != null ? offer['maxPrice'] as String? ?? '' : '',
    );
    DateTime? selectedDate;
    String selectedDateText = 'mm/dd/yyyy';

    if (offer != null) {
      final raw = offer['discount'] as String;
      selectedDiscount = raw.replaceAll('% OFF', '').trim();
      discountController.text = selectedDiscount;
      final validText = offer['validUntil'] as String? ?? '';
      if (validText.isNotEmpty) {
        selectedDateText = validText.replaceFirst('Valid until: ', '');
        selectedDate = _parseFormattedDate(selectedDateText);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (context, innerSetState) {

              final isEdit = offer != null;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEdit
                                    ? 'Edit Offer'
                                    : 'Create Store-Wide Offer',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF634732),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Update offer details and settings',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Offer Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: 'Store-Wide Offer',
                            items: const [
                              DropdownMenuItem(
                                value: 'Store-Wide Offer',
                                child: Text('Store-Wide Offer'),
                              ),
                            ],
                            onChanged: null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Offer Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: discountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Discount (%)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                innerSetState(() {
                                  selectedDiscount = value.isEmpty
                                      ? '0'
                                      : value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: minOrderController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Min Order Amount (JOD)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: minPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Min Price (JOD)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
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
                              controller: maxPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Max Price (JOD)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? now,
                            firstDate: now,
                            lastDate: DateTime(now.year + 2),
                          );
                          if (picked != null) {
                            innerSetState(() {
                              selectedDate = picked;
                              selectedDateText = _formatSelectedDate(picked);
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Valid Until',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDateText,
                                style: TextStyle(
                                  color: selectedDate == null
                                      ? Colors.grey[500]
                                      : Colors.black,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey[300]!),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final validUntilText = selectedDate == null
                                    ? ''
                                    : 'Valid until: ${_formatSelectedDate(selectedDate!)}';
                                final newOffer = {
                                  'title': titleController.text.trim(),
                                  'description': descriptionController.text
                                      .trim(),
                                  'discount':
                                      '${discountController.text.trim()}% OFF',
                                  'type': 'Store-Wide',
                                  'validUntil': validUntilText,
                                  'minOrder':
                                      minOrderController.text.trim().isEmpty
                                      ? ''
                                      : 'Min order: ${minOrderController.text.trim()}',
                                  'minPrice': minPriceController.text.trim(),
                                  'maxPrice': maxPriceController.text.trim(),
                                  'status': 'Active',
                                };
                                if (index != null) {
                                  _updateStoreWideOffer(index, newOffer);
                                } else {
                                  _addStoreWideOffer(newOffer);
                                }
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B9D8E),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                isEdit ? 'Update Offer' : 'Create Offer',
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
      },
    );
  }

  void _showProductSaleDialog({Map<String, dynamic>? offer, int? index}) {

    String selectedDiscount = '15';
    String selectedProduct = _products.first['name'] as String;
    final titleController = TextEditingController(
      text: offer != null
          ? offer['title'] as String
          : '$selectedDiscount% Off ${selectedProduct}',
    );
    final descriptionController = TextEditingController(
      text: offer != null
          ? offer['description'] as String
          : 'Create a special sale offer for a specific product',
    );
    final discountController = TextEditingController(
      text: offer != null
          ? (offer['discount'] as String).replaceAll('% OFF', '').trim()
          : '15',
    );
    DateTime? selectedDate;
    String selectedDateText = 'mm/dd/yyyy';

    if (offer != null) {
      selectedProduct = offer['product'] as String? ?? selectedProduct;
      final raw = offer['discount'] as String;
      selectedDiscount = raw.replaceAll('% OFF', '').trim();
      discountController.text = selectedDiscount;
      titleController.text = offer['title'] as String;
      descriptionController.text = offer['description'] as String;
      final validText = offer['validUntil'] as String? ?? '';
      if (validText.isNotEmpty) {
        selectedDateText = validText.replaceFirst('Valid until: ', '');
        selectedDate = _parseFormattedDate(selectedDateText);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (context, innerSetState) {
              final previewText = '$selectedDiscount% Off $selectedProduct';
              final isEdit = offer != null;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEdit ? 'Edit Offer' : 'Create Product Sale',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF634732),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Update offer details and settings',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Offer Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: 'Product Sale',
                            items: const [
                              DropdownMenuItem(
                                value: 'Product Sale',
                                child: Text('Product Sale'),
                              ),
                            ],
                            onChanged: null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Select Product *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedProduct,
                            isExpanded: true,
                            items: _products.map((product) {
                              return DropdownMenuItem<String>(
                                value: product['name'] as String,
                                child: Text(product['name'] as String),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                innerSetState(() {
                                  selectedProduct = value;
                                  titleController.text =
                                      '$selectedDiscount% Off $selectedProduct';
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Offer Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: discountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Discount (%)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        onChanged: (value) {
                          innerSetState(() {
                            selectedDiscount = value.isEmpty ? '0' : value;
                            titleController.text =
                                '$selectedDiscount% Off $selectedProduct';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? now,
                            firstDate: now,
                            lastDate: DateTime(now.year + 2),
                          );
                          if (picked != null) {
                            innerSetState(() {
                              selectedDate = picked;
                              selectedDateText = _formatSelectedDate(picked);
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Valid Until',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDateText,
                                style: TextStyle(
                                  color: selectedDate == null
                                      ? Colors.grey[500]
                                      : Colors.black,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Preview: $previewText',
                          style: const TextStyle(color: Color(0xFF0D47A1)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey[300]!),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final validUntilText = selectedDate == null
                                    ? ''
                                    : 'Valid until: ${_formatSelectedDate(selectedDate!)}';
                                final newOffer = {
                                  'title': titleController.text.trim(),
                                  'description': descriptionController.text
                                      .trim(),
                                  'discount':
                                      '${discountController.text.trim()}% OFF',
                                  'type': 'Product Sale',
                                  'validUntil': validUntilText,
                                  'status': 'Active',
                                  'product': selectedProduct,
                                };
                                if (index != null) {
                                  _updateProductSale(index, newOffer);
                                } else {
                                  _addProductSale(newOffer);
                                }
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                isEdit ? 'Update Sale' : 'Create Sale',
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
      },
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Order Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF634732),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'View complete order information and customer details',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F4EE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Order ID: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF634732),
                                ),
                              ),
                              TextSpan(
                                text: order['id'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF634732),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${order['date']}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Payment: ${order['payment']}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF634732),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order['customer'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['email'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['phone'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF634732),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order['customer'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['addressLine1'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order['addressLine2'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Floor: ${order['floor']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Apartment: ${order['apartment']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF634732),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List<Widget>.from(
                      (order['orderItems'] as List<Map<String, dynamic>>).map(
                        (item) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item['name']} x ${item['quantity']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                item['price'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 36, thickness: 1.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          order['subtotal'] as String,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Discount',
                          style: TextStyle(color: Color(0xFF2E7D32)),
                        ),
                        Text(
                          order['discount'] as String,
                          style: const TextStyle(color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery Fee',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          order['deliveryFee'] as String,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF634732),
                        ),
                      ),
                      Text(
                        order['total'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF634732),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9D8E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _addProduct(Map<String, dynamic> product) {
    setState(() {
      _products.insert(0, product);
    });
  }

  void _showManageSaleDialog(BuildContext context, int index) {
    final product = Map<String, dynamic>.from(_products[index]);
    final originalPrice =
        product['originalPrice'] as String? ?? product['price'] as String;
    final discountController = TextEditingController(
      text: (product['discount'] as String).replaceAll('%', '').trim().isEmpty
          ? '20'
          : (product['discount'] as String).replaceAll('%', ''),
    );
    DateTime? selectedDate;
    String selectedDateText = 'mm/dd/yyyy';
    if (product['saleValidUntil'] != null &&
        (product['saleValidUntil'] as String).isNotEmpty) {
      selectedDate = _parseFormattedDate(product['saleValidUntil'] as String);
      selectedDateText = product['saleValidUntil'] as String;
    }
    String saleTypeValue = 'Discount Percentage';

    String parsePrice(String priceText) {
      final cleaned = priceText.replaceAll('JOD', '').replaceAll(' ', '');
      return cleaned.isEmpty ? '0' : cleaned;
    }

    double calculateSalePrice() {
      final discount = int.tryParse(discountController.text.trim()) ?? 0;
      final basePrice = double.tryParse(parsePrice(originalPrice)) ?? 0.0;
      final salePrice = basePrice * (1 - discount / 100);
      return salePrice < 0 ? 0 : salePrice;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (context, innerSetState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Manage Sale',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF634732),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Set discount percentage and sale duration for this product',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        product['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF634732),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Original Price: $originalPrice',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Sale Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: saleTypeValue,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'Discount Percentage',
                                child: Text('Discount Percentage'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                innerSetState(() {
                                  saleTypeValue = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: discountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Discount Percentage (%)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        onChanged: (_) {
                          innerSetState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sale Price: ${calculateSalePrice().toStringAsFixed(2)} JOD',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? now,
                            firstDate: now,
                            lastDate: DateTime(now.year + 2),
                          );
                          if (picked != null) {
                            innerSetState(() {
                              selectedDate = picked;
                              selectedDateText = _formatSelectedDate(picked);
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Sale Valid Until (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDateText,
                                style: TextStyle(
                                  color: selectedDate == null
                                      ? Colors.grey[500]
                                      : Colors.black,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _products[index] = Map<String, dynamic>.from(
                                    product,
                                  );
                                  _products[index]['hasSale'] = false;
                                  _products[index]['discount'] = '';
                                  _products[index]['price'] = originalPrice;
                                  _products[index]['saleValidUntil'] = '';
                                });
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Remove Sale'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final discountValue =
                                    int.tryParse(
                                      discountController.text.trim(),
                                    ) ??
                                    0;
                                setState(() {
                                  _products[index] = Map<String, dynamic>.from(
                                    product,
                                  );
                                  _products[index]['hasSale'] = true;
                                  _products[index]['discount'] =
                                      '$discountValue%';
                                  _products[index]['originalPrice'] =
                                      originalPrice;
                                  _products[index]['price'] =
                                      '${calculateSalePrice().toStringAsFixed(2)} JOD';
                                  _products[index]['saleValidUntil'] =
                                      selectedDate == null
                                      ? ''
                                      : _formatSelectedDate(selectedDate!);
                                });
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD32F2F),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Update Sale'),
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
      },
    );
  }

  void _deactivateProductAtIndex(int index) {
    setState(() {
      _products[index] = Map<String, dynamic>.from(_products[index]);
      _products[index]['isActive'] = false;
    });
  }

  void _removeProductAtIndex(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  void _activateProductAtIndex(int index) {
    setState(() {
      _products[index] = Map<String, dynamic>.from(_products[index]);
      _products[index]['isActive'] = true;
    });
  }

  Widget _buildInactiveProductCard(Map<String, dynamic> product, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D5F5A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['brand'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                product['price'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5F5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () {
                  _activateProductAtIndex(index);
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF5B9D8E)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Activate',
                  style: TextStyle(color: Color(0xFF5B9D8E)),
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  _removeProductAtIndex(index);
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFD32F2F)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFD32F2F)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editProductAtIndex(BuildContext context, int index) {
    final product = _products[index];
    final nameController = TextEditingController(
      text: product['name'] as String,
    );
    final brandController = TextEditingController(
      text: product['brand'] as String,
    );
    final priceController = TextEditingController(
      text: (product['price'] as String).replaceAll(' JOD', ''),
    );
    final stockController = TextEditingController(
      text: product['stock'] as String,
    );
    final imageUrlController = TextEditingController(
      text: product['image'] as String,
    );
    final descriptionController = TextEditingController(
      text: product['description'] as String? ?? '',
    );
    String categoryValue = product['category'] as String;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Edit Product',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF634732),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Update your product details',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: brandController,
                    decoration: InputDecoration(
                      labelText: 'Brand *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: categoryValue,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'Food',
                                child: Text('Food'),
                              ),
                              DropdownMenuItem(
                                value: 'Accessories',
                                child: Text('Accessories'),
                              ),
                              DropdownMenuItem(
                                value: 'Toys',
                                child: Text('Toys'),
                              ),
                              DropdownMenuItem(
                                value: 'Health',
                                child: Text('Health'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  categoryValue = value;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Price (JOD) *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Stock Quantity *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'Image URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Optional: Add a product image URL',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _products[index] = {
                                'name': nameController.text.trim(),
                                'brand': brandController.text.trim(),
                                'category': categoryValue,
                                'price': '${priceController.text.trim()} JOD',
                                'originalPrice':
                                    '${priceController.text.trim()} JOD',
                                'stock': stockController.text.trim(),
                                'discount': product['discount'],
                                'hasSale': product['hasSale'],
                                'isActive': product['isActive'],
                                'image': imageUrlController.text.trim().isEmpty
                                    ? 'https://via.placeholder.com/100'
                                    : imageUrlController.text.trim(),
                                'description': descriptionController.text
                                    .trim(),
                              };
                            });
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B9D8E),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 25),
                _buildTabBar(),
                const SizedBox(height: 20),
                _buildTabContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pet Supplies Store',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF634732),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pet Supplies Plus',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'profile') {
              // Navigate to profile page
            } else if (value == 'logout') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, size: 20, color: Color(0xFF634732)),
                  SizedBox(width: 8),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.more_vert, color: Color(0xFF5B9D8E)),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      'Overview',
      'Orders',
      'Products',
      'Offers',
      'Reviews',
      'Store',
      'Audit',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5B9D8E) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _getTabIcon(index),
                    size: 18,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  IconData _getTabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.shopping_bag;
      case 2:
        return Icons.inventory_2;
      case 3:
        return Icons.local_offer;
      case 4:
        return Icons.star;
      case 5:
        return Icons.storefront;
      case 6:
        return Icons.history;
      default:
        return Icons.dashboard;
    }
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildOrdersTab();
      case 2:
        return _buildProductsTab();
      case 3:
        return _buildOffersTab();
      case 4:
        return _buildReviewsTab();
      case 5:
        return _buildStoreTab();
      case 6:
        return _buildAuditTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Orders',
                value: '3',
                icon: Icons.shopping_bag,
                backgroundColor: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF1976D2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Active Orders',
                value: '3',
                icon: Icons.local_shipping,
                backgroundColor: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Revenue',
                value: '0.00 JOD',
                icon: Icons.attach_money,
                backgroundColor: const Color(0xFFF0F4F3),
                iconColor: const Color(0xFF5B9D8E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Store Rating',
                value: '5.0 ⭐',
                icon: Icons.star,
                backgroundColor: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFFFA500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Low Stock Alert
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE5D9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFB38A)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: const Color(0xFFFF6B35),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Low Stock Alert',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF634732),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '1 product(s) running low on stock. Review your inventory.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Store Status
        Container(
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
                    'Store Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF634732),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isStoreOpen
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isStoreOpen ? 'OPEN' : 'CLOSED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.store, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  const Text('Pet Supplies Plus'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  const Text('Al-Jabal Street • 2.3 km'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  const Text('9AM - 9PM'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: !_isStoreOpen
                          ? () {
                              setState(() {
                                _isStoreOpen = true;
                              });
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(
                          color: !_isStoreOpen
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: !_isStoreOpen
                            ? const Color(0xFF4CAF50)
                            : Colors.grey,
                      ),
                      child: Text(
                        'Open Store',
                        style: TextStyle(
                          color: !_isStoreOpen
                              ? const Color(0xFF4CAF50)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isStoreOpen
                          ? () {
                              setState(() {
                                _isStoreOpen = false;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isStoreOpen
                            ? const Color(0xFFFF6B6B)
                            : Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Close Store',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Recent Orders
        Container(
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
                'Recent Orders',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF634732),
                ),
              ),
              const SizedBox(height: 16),
              _buildRecentOrderItem('ORD001', 'Sarah Johnson', 'Pending'),
              const SizedBox(height: 8),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 8),
              _buildRecentOrderItem('ORD002', 'Mike Brown', 'Confirmed'),
              const SizedBox(height: 8),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 8),
              _buildRecentOrderItem(
                'ORD003',
                'Emily Davis',
                'Out for Delivery',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTabIndex = 1;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F5EE),
                    foregroundColor: const Color(0xFF5B9D8E),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'View All Orders',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF634732),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrderItem(
    String orderId,
    String customerName,
    String status,
  ) {
    Color statusColor = Colors.grey;
    if (status == 'Pending') statusColor = const Color(0xFFFFA500);
    if (status == 'Confirmed') statusColor = const Color(0xFF2196F3);
    if (status == 'Out for Delivery') statusColor = const Color(0xFF9C27B0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              orderId,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF634732),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              customerName,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    final query = _orderSearchQuery.trim().toLowerCase();
    final showAll = _selectedOrdersFilter == 'All';
    final showPastOrders = _selectedOrdersFilter == 'Past Orders';

    final activeOrders = _orders.where((order) {
      if (order['status'] == 'Delivered') return false;
      if (!showAll &&
          !showPastOrders &&
          order['status'] != _selectedOrdersFilter)
        return false;
      if (showPastOrders) return false;
      if (query.isEmpty) return true;
      return order['id']!.toLowerCase().contains(query) ||
          order['customer']!.toLowerCase().contains(query);
    }).toList();

    final completedOrders = _orders.where((order) {
      if (order['status'] != 'Delivered') return false;
      if (query.isEmpty) return true;
      return order['id']!.toLowerCase().contains(query) ||
          order['customer']!.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search and Filter
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _orderSearchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by order ID, customer',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedOrderDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  setState(() {
                    _selectedOrderDate = selectedDate;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedOrderDate == null
                          ? 'mm/dd/yyyy'
                          : _formatSelectedDate(_selectedOrderDate!),
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Filter Buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', _selectedOrdersFilter == 'All'),
              const SizedBox(width: 8),
              _buildFilterChip('Pending', _selectedOrdersFilter == 'Pending'),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Confirmed',
                _selectedOrdersFilter == 'Confirmed',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Out for Delivery',
                _selectedOrdersFilter == 'Out for Delivery',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Past Orders',
                _selectedOrdersFilter == 'Past Orders',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // All Orders
        Text(
          showPastOrders ? 'Completed Orders' : 'All Orders',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF634732),
          ),
        ),
        const SizedBox(height: 12),

        // Active Orders
        if (!showPastOrders)
          if (activeOrders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Text(
                'No orders found.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeOrders.length,
              itemBuilder: (context, index) {
                final order = activeOrders[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildOrderCard(order),
                );
              },
            )
        else if (completedOrders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Text(
              'No completed orders found.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completedOrders.length,
            itemBuilder: (context, index) {
              final order = completedOrders[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOrderCard(order),
              );
            },
          ),

        if (!showPastOrders && completedOrders.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Completed Orders',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF634732),
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completedOrders.length,
            itemBuilder: (context, index) {
              final order = completedOrders[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOrderCard(order),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOrdersFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B9D8E) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF5B9D8E) : Colors.grey[200]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _formatSelectedDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$month/$day/$year';
  }

  DateTime? _parseFormattedDate(String dateText) {
    final parts = dateText.split('/');
    if (parts.length != 3) return null;
    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (month == null || day == null || year == null) return null;
    return DateTime(year, month, day);
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    Color statusColor = Colors.grey;
    if (order['status'] == 'Pending') statusColor = const Color(0xFFFFA500);
    if (order['status'] == 'Confirmed') statusColor = const Color(0xFF2196F3);
    if (order['status'] == 'Out for Delivery')
      statusColor = const Color(0xFF9C27B0);
    if (order['status'] == 'Delivered') statusColor = const Color(0xFF4CAF50);

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
          // Header with ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['id']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF634732),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['customer']!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order['status']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Order Details
          Row(
            children: [
              Icon(Icons.shopping_bag, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                order['items']!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                order['total']!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order['phone']!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order['address']!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // View Details Button
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                _showOrderDetails(order);
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF5B9D8E)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              if (order['status'] == 'Pending')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateOrderStatus(order['id']!, 'Confirmed');
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Accept Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9D8E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )
              else if (order['status'] == 'Confirmed')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateOrderStatus(order['id']!, 'Out for Delivery');
                    },
                    icon: const Icon(Icons.shopping_bag, size: 16),
                    label: const Text('Start Preparing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9D8E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )
              else if (order['status'] == 'Out for Delivery')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateOrderStatus(order['id']!, 'Delivered');
                    },
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Mark as Delivered'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9D8E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )
              else if (order['status'] == 'Delivered')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Delivered'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade200,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              if (order['status'] == 'Pending') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    final query = _productSearchQuery.trim().toLowerCase();
    final filteredActiveProductIndices = _products
        .asMap()
        .entries
        .where((entry) {
          final product = entry.value;
          if (product['isActive'] != true) return false;
          if (query.isEmpty) return true;
          return (product['name'] as String).toLowerCase().contains(query) ||
              (product['brand'] as String).toLowerCase().contains(query) ||
              (product['category'] as String).toLowerCase().contains(query);
        })
        .map((entry) => entry.key)
        .toList();

    final filteredInactiveProductIndices = _products
        .asMap()
        .entries
        .where((entry) {
          final product = entry.value;
          if (product['isActive'] == true) return false;
          if (query.isEmpty) return true;
          return (product['name'] as String).toLowerCase().contains(query) ||
              (product['brand'] as String).toLowerCase().contains(query) ||
              (product['category'] as String).toLowerCase().contains(query);
        })
        .map((entry) => entry.key)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Add Product Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Product Management',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF634732),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showAddProductDialog(context);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9D8E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search Products
        TextField(
          onChanged: (value) {
            setState(() {
              _productSearchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search products by name, brand, or category...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Low Stock Alert
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE5D9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFB38A)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: const Color(0xFFFF6B35),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Low Stock Products',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF634732),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '• Pet Multivitamin Tablets - Only 5 left',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Active Products Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Products (${filteredActiveProductIndices.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF634732),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Product Cards
        if (filteredActiveProductIndices.isEmpty &&
            filteredInactiveProductIndices.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Text(
              'No products found.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        else ...[
          if (filteredActiveProductIndices.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Text(
                'No active products found.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredActiveProductIndices.length,
              itemBuilder: (context, index) {
                final productIndex = filteredActiveProductIndices[index];
                final product = _products[productIndex];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildProductCard(product, productIndex),
                );
              },
            ),

          if (filteredInactiveProductIndices.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Inactive Products (${filteredInactiveProductIndices.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF634732),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredInactiveProductIndices.length,
              itemBuilder: (context, index) {
                final productIndex = filteredInactiveProductIndices[index];
                final product = _products[productIndex];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildInactiveProductCard(product, productIndex),
                );
              },
            ),
          ],
        ],
      ],
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final priceController = TextEditingController(text: '0');
    final stockController = TextEditingController(text: '0');
    final imageUrlController = TextEditingController();
    final descriptionController = TextEditingController();
    String categoryValue = 'Food';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Add New Product',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF634732),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Create a new product listing for your store',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name *',
                      hintText: 'e.g., Premium Dog Food',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: brandController,
                    decoration: InputDecoration(
                      labelText: 'Brand *',
                      hintText: 'e.g., NutriPet',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: categoryValue,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'Food',
                                child: Text('Food'),
                              ),
                              DropdownMenuItem(
                                value: 'Accessories',
                                child: Text('Accessories'),
                              ),
                              DropdownMenuItem(
                                value: 'Toys',
                                child: Text('Toys'),
                              ),
                              DropdownMenuItem(
                                value: 'Health',
                                child: Text('Health'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  categoryValue = value;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Price (JOD) *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Stock Quantity *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'Image URL',
                      hintText: 'https://example.com/image.jpg',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Optional: Add a product image URL',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Product description...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameController.text.trim().isEmpty ||
                                brandController.text.trim().isEmpty) {
                              return;
                            }
                            _addProduct({
                              'name': nameController.text.trim(),
                              'brand': brandController.text.trim(),
                              'category': categoryValue,
                              'price': '${priceController.text.trim()} JOD',
                              'originalPrice':
                                  '${priceController.text.trim()} JOD',
                              'stock': stockController.text.trim(),
                              'discount': '',
                              'hasSale': false,
                              'isActive': true,
                              'image': imageUrlController.text.trim().isEmpty
                                  ? 'https://via.placeholder.com/100'
                                  : imageUrlController.text.trim(),
                              'description': descriptionController.text.trim(),
                            });
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B9D8E),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Add Product'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF634732),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product['brand'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (product['hasSale'] == true &&
                            product['originalPrice'] != null &&
                            product['originalPrice'] != product['price'])
                          Text(
                            product['originalPrice'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          product['price'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF634732),
                          ),
                        ),
                        if (product['hasSale'] == true &&
                            product['saleValidUntil'] != null &&
                            (product['saleValidUntil'] as String).isNotEmpty)
                          Text(
                            'Valid until ${product['saleValidUntil']}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category and Stock
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product['category'],
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ),
                    Text(
                      'Stock: ${product['stock']}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Action Buttons
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (product['hasSale'])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_offer,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SALE-${product['discount']}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (product['hasSale'])
                      ElevatedButton.icon(
                        onPressed: () {
                          _showManageSaleDialog(context, index);
                        },
                        icon: const Icon(Icons.local_offer, size: 12),
                        label: const Text('Manage Sale'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          textStyle: const TextStyle(fontSize: 10),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () {
                          _showManageSaleDialog(context, index);
                        },
                        icon: const Icon(Icons.local_offer, size: 12),
                        label: const Text('Put on Sale'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: () {
                        _editProductAtIndex(context, index);
                      },
                      icon: const Icon(Icons.edit, size: 12),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        _deactivateProductAtIndex(index);
                      },
                      icon: const Icon(Icons.delete, size: 12),
                      label: const Text('Deactivate'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _removeProductAtIndex(index);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersTab() {
    final query = _offerSearchQuery.trim().toLowerCase();
    final filteredActiveStoreWideOffers = _storeWideOffers
        .asMap()
        .entries
        .where((entry) {
          final offer = entry.value;
          if (offer['status'] != 'Active') return false;
          if (query.isEmpty) return true;
          return (offer['title'] as String).toLowerCase().contains(query) ||
              (offer['description'] as String).toLowerCase().contains(query) ||
              (offer['discount'] as String).toLowerCase().contains(query) ||
              (offer['type'] as String).toLowerCase().contains(query) ||
              (offer['product'] as String? ?? '').toLowerCase().contains(query);
        })
        .toList();

    final filteredActiveProductSales = _productSales.asMap().entries.where((
      entry,
    ) {
      final offer = entry.value;
      if (offer['status'] != 'Active') return false;
      if (query.isEmpty) return true;
      return (offer['title'] as String).toLowerCase().contains(query) ||
          (offer['description'] as String).toLowerCase().contains(query) ||
          (offer['discount'] as String).toLowerCase().contains(query) ||
          (offer['type'] as String).toLowerCase().contains(query) ||
          (offer['product'] as String? ?? '').toLowerCase().contains(query);
    }).toList();

    final filteredInactiveStoreWideOffers = _storeWideOffers
        .asMap()
        .entries
        .where((entry) {
          final offer = entry.value;
          if (offer['status'] != 'Inactive') return false;
          if (query.isEmpty) return true;
          return (offer['title'] as String).toLowerCase().contains(query) ||
              (offer['description'] as String).toLowerCase().contains(query) ||
              (offer['discount'] as String).toLowerCase().contains(query) ||
              (offer['type'] as String).toLowerCase().contains(query) ||
              (offer['product'] as String? ?? '').toLowerCase().contains(query);
        })
        .toList();

    final filteredInactiveProductSales = _productSales.asMap().entries.where((
      entry,
    ) {
      final offer = entry.value;
      if (offer['status'] != 'Inactive') return false;
      if (query.isEmpty) return true;
      return (offer['title'] as String).toLowerCase().contains(query) ||
          (offer['description'] as String).toLowerCase().contains(query) ||
          (offer['discount'] as String).toLowerCase().contains(query) ||
          (offer['type'] as String).toLowerCase().contains(query) ||
          (offer['product'] as String? ?? '').toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Offers & Promotions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF634732),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Choose the type of offer you want to create',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            onChanged: (value) {
              setState(() {
                _offerSearchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search offers by title, description, or discount...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Store-Wide Offer Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5D9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB38A)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.store, size: 24, color: const Color(0xFFFF6B35)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store-Wide Offer',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF634732),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Apply discount to all products in your store',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showStoreWideOfferDialog();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Store-Wide Offer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Product Sale Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBDEFB)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_offer,
                      size: 24,
                      color: const Color(0xFF1976D2),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Sale',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF634732),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Create discount for specific products',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showProductSaleDialog();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Product Sale'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Store-Wide Offers Section
          Text(
            'Store-Wide Offers (${filteredActiveStoreWideOffers.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF634732),
            ),
          ),
          const SizedBox(height: 12),
          if (filteredActiveStoreWideOffers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Text(
                'No store-wide offers found.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else
            ...filteredActiveStoreWideOffers.map((entry) {
              final index = entry.key;
              final offer = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOfferCard(offer, index, true),
              );
            }).toList(),

          const SizedBox(height: 24),

          // Product Sales Section
          Text(
            'Product Sales (${filteredActiveProductSales.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF634732),
            ),
          ),
          const SizedBox(height: 12),
          if (filteredActiveProductSales.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Text(
                'No product sales found.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else
            ...filteredActiveProductSales.map((entry) {
              final index = entry.key;
              final offer = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOfferCard(offer, index, false),
              );
            }).toList(),

          const SizedBox(height: 24),

          Text(
            'Inactive Offers (${filteredInactiveStoreWideOffers.length + filteredInactiveProductSales.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF634732),
            ),
          ),
          const SizedBox(height: 12),
          if (filteredInactiveStoreWideOffers.isEmpty &&
              filteredInactiveProductSales.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Text(
                'No inactive offers yet.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else ...[
            ...filteredInactiveStoreWideOffers.map((entry) {
              final index = entry.key;
              final offer = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOfferCard(offer, index, true),
              );
            }),
            ...filteredInactiveProductSales.map((entry) {
              final index = entry.key;
              final offer = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOfferCard(offer, index, false),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildOfferCard(
    Map<String, dynamic> offer,
    int index,
    bool isStoreWide,
  ) {
    final isActive = offer['status'] == 'Active';
    Color statusColor = isActive ? const Color(0xFFFF6B35) : Colors.grey;
    Color backgroundColor = isActive
        ? const Color(0xFFFFF3E0)
        : Colors.grey.shade100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFFFFB38A) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer['title'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF634732),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer['description'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      offer['discount'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      offer['type'],
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.event, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                offer['validUntil'],
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              if (offer['minOrder'] != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.shopping_bag, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  offer['minOrder'],
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  if (isStoreWide) {
                    _showStoreWideOfferDialog(offer: offer, index: index);
                  } else {
                    _showProductSaleDialog(offer: offer, index: index);
                  }
                },
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  _toggleOfferActive(index, isStoreWide);
                },
                icon: Icon(
                  offer['status'] == 'Active'
                      ? Icons.pause_circle
                      : Icons.play_circle,
                  size: 14,
                ),
                label: Text(
                  offer['status'] == 'Active' ? 'Deactivate' : 'Activate',
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  _removeOffer(index, isStoreWide);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    final reviews = [
      {
        'name': 'John Wilson',
        'orderId': 'ORD004',
        'date': 'Jan 02, 2026',
        'productRating': 5,
        'productReview': 'Excellent quality dog food! My dog loves it.',
        'storeRating': 5,
        'storeReview': 'Fast delivery and great customer service!',
      },
      {
        'name': 'Lisa Anderson',
        'orderId': 'ORD005',
        'date': 'Jan 01, 2026',
        'productRating': 4,
        'productReview': 'Good product, but a bit pricey.',
        'storeRating': 5,
        'storeReview': 'Great store, highly recommended!',
      },
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Average Rating Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE5B4)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.star,
                              color: Color(0xFFFFA500),
                              size: 28,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '5.0',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF634732),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Average Store Rating',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Based on ${reviews.length} reviews',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Customer Reviews Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF634732),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9D8E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${reviews.length} reviews',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Review Cards
          ...reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildReviewCard(review),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['name'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF634732),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    review['date'],
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  review['orderId'],
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Product Rating: ${'⭐ ' * review['productRating']}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF634732),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            review['productReview'],
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Text(
            'Store Rating: ${'⭐ ' * review['storeRating']}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF634732),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            review['storeReview'],
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF634732),
            ),
          ),
          const SizedBox(height: 20),

          // Store Details Card
          Container(
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
                  'Store Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF634732),
                  ),
                ),
                const SizedBox(height: 16),

                // Store Name
                const Text(
                  'Store Name',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF634732),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: TextEditingController(text: 'Pet Supplies Plus'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Location
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF634732),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: TextEditingController(text: 'Downtown Mall'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Street
                const Text(
                  'Street',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF634732),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: TextEditingController(text: 'Al-Jabal Street'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF634732),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: TextEditingController(
                    text: 'Complete pet supply store with premium brands',
                  ),
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone and Email Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phone',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF634732),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: TextEditingController(
                              text: '+1 (555) 000-9999',
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF634732),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: TextEditingController(
                              text: 'store@petsuppliesplu',
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Operating Hours
                const Text(
                  'Operating Hours',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF634732),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: TextEditingController(text: '9AM - 9PM'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save Changes Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9D8E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Profile Button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: GestureDetector(
              onTap: _showProfileDialog,
              child: Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF634732),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF634732),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Update your personal information and account details',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Full Name
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF634732),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _profileNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Email
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF634732),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _profileEmailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Phone
                  const Text(
                    'Phone',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF634732),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _profilePhoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Business Name
                  const Text(
                    'Business Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF634732),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _profileBusinessNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Change Password Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showChangePasswordDialog();
                      },
                      icon: const Icon(Icons.lock, size: 16),
                      label: const Text('Change Password'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile changes saved'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B9D8E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF634732),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your current password and choose a new one',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Current Password
                  const Text(
                    'Current Password',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF634732),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // New Password
                  const Text(
                    'New Password',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF634732),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Confirm New Password
                  const Text(
                    'Confirm New Password',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF634732),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_newPasswordController.text != _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('New passwords do not match'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password changed successfully'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B9D8E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text('Change Password'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuditTab() {
    final allAuditLogs = [
      {
        'action': 'Store Opened',
        'description': 'Store status changed to open',
        'timestamp': 'Apr 20, 2026 at 16:09',
        'dateTime': DateTime(2026, 4, 20, 16, 9),
        'icon': Icons.info,
      },
      {
        'action': 'New Offer Added',
        'description': 'A store-wide discount was added',
        'timestamp': 'Apr 19, 2026 at 10:30',
        'dateTime': DateTime(2026, 4, 19, 10, 30),
        'icon': Icons.local_offer,
      },
      {
        'action': 'Product Deactivated',
        'description': 'An inactive product was moved to archive',
        'timestamp': 'Apr 18, 2026 at 14:20',
        'dateTime': DateTime(2026, 4, 18, 14, 20),
        'icon': Icons.delete,
      },
    ];
    final query = _auditSearchQuery.trim().toLowerCase();
    final filteredAuditLogs = allAuditLogs.where((log) {
      if (query.isNotEmpty &&
          !(log['action'] as String).toLowerCase().contains(query) &&
          !(log['description'] as String).toLowerCase().contains(query)) {
        return false;
      }
      if (_selectedAuditDate != null) {
        final logDate = log['dateTime'] as DateTime;
        return logDate.year == _selectedAuditDate!.year &&
            logDate.month == _selectedAuditDate!.month &&
            logDate.day == _selectedAuditDate!.day;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search and Date Filter
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _auditSearchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search audit logs by action',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedAuditDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  setState(() {
                    _selectedAuditDate = selectedDate;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedAuditDate == null
                          ? 'mm/dd/yyyy'
                          : _formatSelectedDate(_selectedAuditDate!),
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    if (_selectedAuditDate != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAuditDate = null;
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Activity Log Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activity Log',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF634732),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9D8E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                filteredAuditLogs.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Audit Log Cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredAuditLogs.length,
          itemBuilder: (context, index) {
            final log = filteredAuditLogs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAuditLogCard(log),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAuditLogCard(Map<String, dynamic> log) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  log['icon'],
                  size: 20,
                  color: const Color(0xFF5B9D8E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log['action'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF634732),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log['description'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                log['timestamp'],
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
