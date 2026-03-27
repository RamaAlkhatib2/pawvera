import 'package:flutter/material.dart';

class StoreDetails extends StatefulWidget {
  final String storeName;
  const StoreDetails({super.key, required this.storeName});

  @override
  State<StoreDetails> createState() => _StoreDetailsState();
}

class _StoreDetailsState extends State<StoreDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5A3E2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.storeName, style: const TextStyle(color: Color(0xFF5A3E2B), fontWeight: FontWeight.bold, fontSize: 18)),
            const Text('Comfort Paws Bedding Center', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border, color: Color(0xFF5A3E2B)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.info_outline, color: Color(0xFF5A3E2B)), onPressed: () {}),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Header with Categories (Horizontal Scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildCategoryTab('All', isSelected: true),
                _buildCategoryTab('Bedding'),
                _buildCategoryTab('Toys'),
                _buildCategoryTab('Accessories'),
              ],
            ),
          ),

          // 2. Search Products Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search within this store...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildCircularButton(Icons.tune), // Filter Icon
              ],
            ),
          ),

          // 3. Floating Quick Buttons Row (Optional based on design)
          _buildQuickActions(),

          // 4. Products Grid
          Expanded(
            child: GridView(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70, // Controls product card height
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              children: [
                _buildProductCard(
                  title: 'Classic Gray Pet Bed',
                  desc: 'Soft & Comfortable bedding',
                  price: '25.00 JOD',
                  offer: 'Hot Offer: 10% Off',
                  icon: Icons.single_bed_outlined,
                ),
                _buildProductCard(
                  title: 'Deluxe Orthopedic Bed',
                  desc: 'Joint support and extra comfort',
                  price: '45.00 JOD',
                  icon: Icons.chair_outlined,
                ),
                _buildProductCard(
                  title: 'Pet Blanket',
                  desc: 'Warm & cozy for cool nights',
                  price: '15.00 JOD',
                  icon: Icons.layers_outlined,
                ),
                _buildProductCard(
                  title: 'Wooden Pet Bed Frame',
                  desc: 'Sturdy frame for any bed style',
                  price: '60.00 JOD',
                  icon: Icons.crop_din,
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating Cart Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF3AA78E),
        child: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
      ),
    );
  }

  // --- Widgets Helpers ---

  Widget _buildCategoryTab(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF3AA78E).withOpacity(0.2),
        labelStyle: TextStyle(color: isSelected ? const Color(0xFF3AA78E) : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _buildCircularButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
      child: Icon(icon, size: 20, color: const Color(0xFF5A3E2B)),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _quickActionButton('Filter Products', Icons.tune),
          _quickActionButton('Best Sellers', Icons.local_offer_outlined),
          _quickActionButton('In Stock', Icons.check_circle_outline),
        ],
      ),
    );
  }

  Widget _quickActionButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFE8F4F1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF3AA78E)),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5A3E2B))),
        ],
      ),
    );
  }

  Widget _buildProductCard({required String title, required String desc, required String price, String? offer, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (offer != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: const BoxDecoration(color: Color(0xFF3AA78E), borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
              child: Text(offer, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.image_outlined, size: 60, color: Colors.grey), // Placeholder for product image
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF3AA78E))),
                _buildCircularButton(Icons.add_shopping_cart), // Add Button
              ],
            ),
          ),
        ],
      ),
    );
  }
}