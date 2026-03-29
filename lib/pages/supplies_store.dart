import 'package:flutter/material.dart';
import 'store_details.dart'; // تأكدي إنك عملتِ ملف store_details.dart

class SuppliesStore extends StatelessWidget {
  const SuppliesStore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5A3E2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pet Supplies',
                style: TextStyle(
                    color: Color(0xFF5A3E2B),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text('Choose a store',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        actions: [
          _buildTopButton(Icons.favorite_border, 'Wishlist'),
          _buildTopButton(Icons.history, 'Orders'),
          const SizedBox(width: 10),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products or stores...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // 2. Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterChip('All', isSelected: true),
                _filterChip('Food'),
                _filterChip('Toys'),
                _filterChip('Accessories'),
                _filterChip('Health'),
              ],
            ),
          ),

          // 3. Sort & Offers Row
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: 'Nearest',
                        items: ['Nearest', 'Top Rated'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text('Sort: $value', style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4F1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF3AA78E).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer_outlined, size: 18, color: Color(0xFF5A3E2B)),
                      const SizedBox(width: 5),
                      const Text('Offers Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Text('3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3AA78E))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Show All Stores Button
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEBE8E4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 18, color: Color(0xFF5A3E2B)),
                  SizedBox(width: 8),
                  Text('Show All Stores', style: TextStyle(color: Color(0xFF5A3E2B), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),

          // 5. Stores List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildStoreCard(
                  context: context,
                  name: 'Comfort Paws Store',
                  desc: 'Premium pet furniture and bedding',
                  rating: '4.8',
                  location: 'King Fahd Avenue',
                  distance: '1.5 km',
                  time: '9AM - 8PM',
                  tags: ['Furniture', 'Bedding', 'Home'],
                ),
                _buildStoreCard(
                  context: context,
                  name: 'Pet Supplies Plus',
                  desc: 'Complete pet supply store with premium brands',
                  rating: '4.7',
                  offer: '20% Off on Orders Above 50 JOD',
                  location: 'Al-Jabal Street',
                  distance: '2.3 km',
                  time: '9AM - 9PM',
                  tags: ['Food', 'Toys', 'Accessories'],
                ),
                _buildStoreCard(
                  context: context,
                  name: 'Furry Friends Store',
                  desc: 'Toys, treats and accessories for all pets',
                  rating: '4.6',
                  offer: '15% Off All Toys',
                  location: 'Al-Salam Road',
                  distance: '3.8 km',
                  time: '10AM - 8PM',
                  tags: ['Toys', 'Treats', 'Accessories'],
                ),
                _buildStoreCard(
                  context: context,
                  name: 'Healthy Pets Market',
                  desc: 'Organic food and health products',
                  rating: '4.9',
                  offer: '10% Off Organic Products',
                  location: 'Prince Mohammed Street',
                  distance: '4.2 km',
                  time: '8AM - 10PM',
                  tags: ['Food', 'Health', 'Supplements'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets Helpers ---

  Widget _buildTopButton(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5A3E2B)),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Color(0xFF5A3E2B), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        backgroundColor: Colors.white,
        selectedColor:const Color(0xFF3AA78E).withOpacity(0.2),
        labelStyle: TextStyle(color: isSelected ? const Color(0xFF3AA78E) : Colors.black),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _buildStoreCard({
    required BuildContext context,
    required String name,
    required String desc,
    required String rating,
    String? offer,
    required String location,
    required String distance,
    required String time,
    required List<String> tags,
  }) {
    return GestureDetector(
   onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StoreDetails(
        storeData: {
          'name': name.trim(), // بنبعث الاسم "نظيف" بدون فراغات
          'location': location,
          'distance': distance,
          'time': time,
          'rating': rating,
        },
      ),
    ),
  );
},
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.store, color: Colors.grey)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFF3AA78E),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text('★ $rating', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            if (offer != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200)),
                child: Text('🏷 $offer',
                    style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
                spacing: 8,
                children: tags
                    .map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.grey.shade50))
                    .toList()),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$location  •  $distance', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Spacer(),
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}