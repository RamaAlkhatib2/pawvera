import 'package:flutter/material.dart';
import 'booking_page.dart';

class ClinicDetailsPage extends StatelessWidget {
  final dynamic provider;
  const ClinicDetailsPage({super.key, required this.provider});

  final Color primaryGreen = const Color(0xFF5B9D8E);

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
          provider.name,
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
            const SizedBox(height: 15),
            Row(
              children: [
                _smallChip("All Pets"),
                const SizedBox(width: 10),
                _smallChip("Offers", count: "1"),
              ],
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
                  "All ${provider.petType} Services",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _serviceItem(
              context,
              "Daily Dog Walking",
              "21.25 JOD",
              "25 JOD",
              "15% OFF",
              true,
            ),
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

  Widget _smallChip(String label, {String? count}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        if (count != null) ...[
          const SizedBox(width: 5),
          Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ],
    ),
  );

  Widget _buildOfferCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFDFF6F0),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFB2E5D8)),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFF3AA78E),
          child: Icon(Icons.percent, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Weekly Package",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D6A5D),
                ),
              ),
              Text(
                "Book 5 walks, get 1 free!",
                style: TextStyle(fontSize: 11, color: Color(0xFF4A8B7E)),
              ),
            ],
          ),
        ),
        const Text(
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

  Widget _serviceItem(
    BuildContext context,
    String title,
    String price,
    String old,
    String disc,
    bool pop,
  ) => Container(
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
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  "Popular",
                  style: TextStyle(color: Colors.orange, fontSize: 9),
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
                    clinicName: provider.name,
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
