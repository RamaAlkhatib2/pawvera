import 'package:flutter/material.dart';
import 'booking_page.dart';

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

  @override
  Widget build(BuildContext context) {
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

            // قسم الفلترة (Screenshot 106)
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
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: _filterByOffers
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.green.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "1",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _filterByOffers
                                          ? Colors.white
                                          : Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
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
            const Text(
              "Special Offers",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildOfferCard(),

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

            // الخدمات (تظهر بناءً على الفلترة)
            if (!_filterByOffers || (_filterByOffers))
              _serviceItem(
                context,
                "Daily Dog Walking",
                "21.25 JOD",
                "25 JOD",
                "15% OFF",
                true,
              ),

            if (!_filterByOffers)
              _serviceItem(
                context,
                "Pet Sitting - Full Day",
                "55 JOD",
                "",
                "",
                false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF6F0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFB2E5D8)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFF3AA78E),
            child: Icon(Icons.percent, color: Colors.white, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Weekly Walking Package",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D6A5D),
                  ),
                ),
                Text(
                  "Valid until Mar 15, 2026",
                  style: TextStyle(fontSize: 11, color: Color(0xFF4A8B7E)),
                ),
              ],
            ),
          ),
          Text(
            "15% OFF",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
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
