import 'package:flutter/material.dart';

class ClinicDetailsPage extends StatelessWidget {
  final dynamic provider;
  const ClinicDetailsPage({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF5B9D8E);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                provider.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Special Offers",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (provider.hasOffer) _buildOfferCard(),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.pets, size: 20, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  "Services for ${provider.petType}s",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildServiceItem(
              primaryGreen,
              "Standard Grooming",
              "25 JOD",
              "35 JOD",
              "20% OFF",
            ),
            _buildServiceItem(primaryGreen, "Health Checkup", "15 JOD", "", ""),
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
                  "Seasonal Discount",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D6A5D),
                  ),
                ),
                Text(
                  "Get a special price for this month",
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
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(
    Color color,
    String title,
    String price,
    String oldPrice,
    String discount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                price,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
              if (oldPrice.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  oldPrice,
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    discount,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
