import 'package:flutter/material.dart';
import 'booking_page.dart';

// نموذج بيانات الخدمة لتمكين الفلترة الديناميكية
class PetService {
  final String title;
  final String price;
  final String oldPrice;
  final String discount;
  final bool isPopular;
  final String petType; // النوع: Dogs, Cats, Birds, etc.
  final bool hasOffer;

  PetService({
    required this.title,
    required this.price,
    this.oldPrice = "",
    this.discount = "",
    this.isPopular = false,
    required this.petType,
    required this.hasOffer,
  });
}

class ClinicDetailsPage extends StatefulWidget {
  final dynamic provider;
  const ClinicDetailsPage({super.key, required this.provider});

  @override
  State<ClinicDetailsPage> createState() => _ClinicDetailsPageState();
}

class _ClinicDetailsPageState extends State<ClinicDetailsPage> {
  final Color primaryGreen = const Color(0xFF5B9D8E);

  String _selectedPetFilter = "All Pets";
  bool _filterByOffers = false;

  final List<String> _petTypes = [
    "All Pets",
    "Dogs",
    "Cats",
    "Birds",
    "Fish",
    "Other Pets",
  ];

  // قائمة الخدمات المتاحة (يمكنك إضافة المزيد هنا)
  final List<PetService> _servicesList = [
    PetService(
      title: "Daily Dog Walking",
      price: "21.25 JOD",
      oldPrice: "25 JOD",
      discount: "15% OFF",
      isPopular: true,
      petType: "Dogs",
      hasOffer: true,
    ),
    PetService(
      title: "Pet Sitting - Full Day",
      price: "55 JOD",
      petType: "Dogs",
      hasOffer: false,
    ),
    PetService(
      title: "Cat Grooming",
      price: "30 JOD",
      petType: "Cats",
      hasOffer: false,
    ),
    PetService(
      title: "Special Cat Care",
      price: "15 JOD",
      oldPrice: "20 JOD",
      discount: "25% OFF",
      petType: "Cats",
      hasOffer: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // منطق الفلترة: تصفية القائمة بناءً على المدخلات
    List<PetService> filteredServices = _servicesList.where((service) {
      bool matchesType =
          _selectedPetFilter == "All Pets" ||
          service.petType == _selectedPetFilter;
      bool matchesOffer = !_filterByOffers || service.hasOffer;
      return matchesType && matchesOffer;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.provider.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search services...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // قسم الفلترة (Dropdown & Offers Toggle)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filter by Pet Type",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPetFilter,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: _petTypes.map((String type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedPetFilter = value!);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _filterByOffers = !_filterByOffers,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _filterByOffers
                                  ? primaryGreen
                                  : Colors.white,
                              border: Border.all(
                                color: _filterByOffers
                                    ? primaryGreen
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 16,
                                  color: _filterByOffers
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Offers",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _filterByOffers
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            Row(
              children: [
                const Icon(Icons.pets, size: 20, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  "All $_selectedPetFilter Services",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // عرض الخدمات المفلترة ديناميكياً
            if (filteredServices.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("No services found for this filter."),
                ),
              )
            else
              ...filteredServices.map(
                (service) => _serviceItem(
                  context,
                  service.title,
                  service.price,
                  service.oldPrice,
                  service.discount,
                  service.isPopular,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _serviceItem(
    BuildContext context,
    String title,
    String price,
    String old,
    String disc,
    bool pop,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (pop)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "Popular",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                price,
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (old.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  old,
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => BookingPage(
                      serviceName: title,
                      price: price,
                      clinicName: widget.provider.name,
                      providerName: '',
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Book Now",
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
