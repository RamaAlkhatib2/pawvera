import 'package:flutter/material.dart';
import 'store_details.dart'; // تأكد من وجود هذا الملف في مشروعك

class SuppliesStore extends StatelessWidget {
  const SuppliesStore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          _buildTopButton(context, Icons.favorite_border, 'Wishlist'),
          _buildTopButton(context, Icons.history, 'Orders'),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // 1. شريط البحث (Search Bar)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products or stores...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. سطر الترتيب والعروض (Sort & Offers)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        isExpanded: true,
                        items: ['Nearest', 'Top Rated', 'Popular']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text('Sort: $value',
                                style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildOffersChip(),
              ],
            ),
          ),

          // 3. زر إظهار كل المتاجر (Show All Stores)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: InkWell(
              onTap: () {}, 
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFEF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border,
                        size: 18, color: Color(0xFF5A3E2B)),
                    SizedBox(width: 8),
                    Text('Show All Stores',
                        style: TextStyle(
                            color: Color(0xFF5A3E2B),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),

          // 4. فلاتر التصنيفات (Filter Tabs)
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterChip('All', isSelected: true, icon: Icons.tune),
                _filterChip('Food'),
                _filterChip('Toys'),
                _filterChip('Accessories'),
                _filterChip('Health'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 5. قائمة المتاجر
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
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

  static Widget _buildTopButton(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Wishlist') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWishlistPage()));
        } else if (label == 'Orders') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersPage()));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF5A3E2B)),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF5A3E2B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3AA78E).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_outlined, size: 18, color: Color(0xFF5A3E2B)),
          const SizedBox(width: 6),
          const Text('Offers Only',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5A3E2B))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Text('3',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3AA78E))),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, {bool isSelected = false, IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF5BA092) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF5BA092)),
            const SizedBox(width: 8),
          ],
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF5A3E2B),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
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
        String storeImage = "";
        List<String> categories = [];
        String reviews = "";

        if (name.contains("Comfort")) {
          storeImage = 'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7';
          categories = ['Furniture', 'Bedding', 'Home'];
          reviews = '(412)';
        } else if (name.contains("Plus")) {
          storeImage = 'https://images.unsplash.com/photo-1541599540903-216a46ca1dfa';
          categories = ['Food', 'Accessories', 'Toys'];
          reviews = '(250)';
        } else if (name.contains("Furry")) {
          storeImage = 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee';
          categories = ['Grooming', 'Toys', 'Training'];
          reviews = '(180)';
        } else {
          storeImage = 'https://images.unsplash.com/photo-1522276493077-9fe5ad01add6';
          categories = ['Health', 'Organic', 'Care'];
          reviews = '(95)';
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreDetails(
              storeData: {
                'name': name.trim(),
                'image': storeImage,
                'location': location,
                'distance': distance,
                'time': time,
                'rating': rating,
                'reviews': reviews,
                'hours': time,
                'categories': categories,
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

// --- صفحة المفضلة ---
class MyWishlistPage extends StatelessWidget {
  const MyWishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        title: const Text("My Wishlist", style: TextStyle(color: Color(0xFF5A3E2B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text("Your wishlist is empty", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// --- صفحة الطلبات ---
class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(color: Color(0xFF5A3E2B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text("No orders yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}