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
  final String duration;
  final String subtitle;
  final bool hasOffer;

  PetService({
    required this.title,
    required this.price,
    this.oldPrice = "",
    this.discount = "",
    this.isPopular = false,
    required this.petType,
    required this.duration,
    this.subtitle = "",
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
  String _searchQuery = '';

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
      duration: "45 mins",
      subtitle: "Daily walks with certified dog walkers, GPS tracking included",
      hasOffer: true,
    ),
    PetService(
      title: "Pet Sitting - Full Day",
      price: "55 JOD",
      petType: "Dogs",
      duration: "8 hours",
      subtitle: "Professional in-home pet care with regular updates and photos",
      hasOffer: false,
    ),
    PetService(
      title: "Cat Grooming",
      price: "30 JOD",
      petType: "Cats",
      duration: "1 hour",
      subtitle: "Gentle grooming for cats with coat care and nail trim",
      hasOffer: false,
    ),
    PetService(
      title: "Special Cat Care",
      price: "15 JOD",
      oldPrice: "20 JOD",
      discount: "25% OFF",
      petType: "Cats",
      duration: "30 mins",
      subtitle: "Calm cat care package for routine wellness and comfort",
      hasOffer: true,
    ),
    PetService(
      title: "Dog Daycare Package",
      price: "45 JOD",
      petType: "Dogs",
      duration: "Full day",
      subtitle:
          "Playtime, rest breaks and socialization in a safe daycare space",
      hasOffer: false,
    ),
    PetService(
      title: "Bird Care Service",
      price: "30 JOD",
      petType: "Birds",
      duration: "Per visit",
      subtitle: "Light feeding and companionship for your feathered friend",
      hasOffer: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // منطق الفلترة: تصفية القائمة بناءً على المدخلات
    List<PetService> filteredServices = _servicesList.where((service) {
      final matchesType =
          _selectedPetFilter == "All Pets" ||
          service.petType == _selectedPetFilter;
      final matchesOffer = !_filterByOffers || service.hasOffer;
      final matchesSearch =
          _searchQuery.isEmpty ||
          service.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesOffer && matchesSearch;
    }).toList();

    final shopImageUrl = _getProviderImageUrl();
    final shopDescription = _getProviderDescription();
    final shopLocation = _getProviderLocation();
    final shopHours = _getProviderHours();

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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  const BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: shopImageUrl != null
                        ? Image.network(
                            shopImageUrl,
                            width: double.infinity,
                            height: 170,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 170,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.store,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                        : Container(
                            height: 170,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.store,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.provider.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF274C4B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          shopDescription,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoBubble(
                              Icons.location_on_outlined,
                              shopLocation,
                            ),
                            const SizedBox(width: 8),
                            _buildInfoBubble(Icons.access_time, shopHours),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search services...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  const BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _filterByOffers = !_filterByOffers),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: _filterByOffers ? primaryGreen : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _filterByOffers
                                ? primaryGreen
                                : Colors.grey.shade300,
                          ),
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
                            const SizedBox(width: 6),
                            Text(
                              "Offers ${_servicesList.where((s) => s.hasOffer).length}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _filterByOffers
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBEE9D5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B9D8E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.percent,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Weekly Walking Package",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF274C4B),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Book 5 walks, get 1 free! Valid until Mar 15, 2026",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B9D8E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "15% OFF",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.pets, size: 20, color: Color(0xFF5B9D8E)),
                const SizedBox(width: 8),
                Text(
                  "All ${_selectedPetFilter == 'All Pets' ? 'Pets' : _selectedPetFilter} (${_servicesList.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (filteredServices.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("No services found for this filter."),
                ),
              )
            else
              ...filteredServices.map(
                (service) => _serviceItem(context, service),
              ),
          ],
        ),
      ),
    );
  }

  Widget _serviceItem(BuildContext context, PetService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF274C4B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (service.isPopular)
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Popular",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTag(service.petType, Colors.blue.shade50, Colors.blue),
              const SizedBox(width: 8),
              _buildTag(service.duration, Colors.grey.shade200, Colors.black54),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    service.price,
                    style: TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (service.oldPrice.isNotEmpty)
                    Text(
                      service.oldPrice,
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (service.discount.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    service.discount,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => BookingPage(
                      serviceName: service.title,
                      price: service.price,
                      clinicName: widget.provider.name,
                      providerName: '',
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Book Now",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _getProviderImageUrl() {
    try {
      final imageUrl = widget.provider.imageUrl;
      if (imageUrl is String && imageUrl.isNotEmpty) return imageUrl;
    } catch (_) {}
    try {
      final imageUrl = widget.provider['imageUrl'];
      if (imageUrl is String && imageUrl.isNotEmpty) return imageUrl;
    } catch (_) {}
    return null;
  }

  String _getProviderDescription() {
    try {
      final description = widget.provider.description;
      if (description is String && description.isNotEmpty) return description;
    } catch (_) {}
    return 'Professional pet care with trusted services.';
  }

  String _getProviderLocation() {
    try {
      final location = widget.provider.location;
      if (location is String && location.isNotEmpty) return location;
    } catch (_) {}
    return 'Unknown location';
  }

  String _getProviderHours() {
    try {
      final hours = widget.provider.hours;
      if (hours is String && hours.isNotEmpty) return hours;
    } catch (_) {}
    return 'Hours unavailable';
  }

  Widget _buildInfoBubble(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color background, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
