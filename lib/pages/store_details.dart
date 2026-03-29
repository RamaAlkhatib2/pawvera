import 'package:flutter/material.dart';

class StoreDetails extends StatefulWidget {
  final Map<String, dynamic> storeData; 

  const StoreDetails({super.key, required this.storeData});

  @override
  State<StoreDetails> createState() => _StoreDetailsState();
}

class _StoreDetailsState extends State<StoreDetails> {
  // 1. قاعدة بيانات المنتجات (مفاتيحها هي الأسماء بالظبط)
  final Map<String, List<Map<String, String>>> allProducts = {
    'Comfort Paws Store': [
      {'title': 'Orthopedic Dog Bed', 'desc': 'Premium joint support', 'price': '35.0 JOD', 'offer': 'Best Seller'},
      {'title': 'Cat Tree House', 'desc': 'Multi-level play area', 'price': '45.0 JOD'},
      {'title': 'Pet Blanket', 'desc': 'Warm & cozy wool', 'price': '15.0 JOD'},
      {'title': 'Elevated Feeder', 'desc': 'Healthy eating posture', 'price': '25.0 JOD'},
    ],
    'Pet Supplies Plus': [
      {'title': 'Premium Dog Food', 'desc': 'High protein formula', 'price': '40.0 JOD', 'offer': '10% Off'},
      {'title': 'Feather Wand Toy', 'desc': 'Interactive cat fun', 'price': '8.0 JOD'},
      {'title': 'Pet Shampoo', 'desc': 'Natural aloe vera', 'price': '12.0 JOD'},
      {'title': 'Training Treats', 'desc': 'Grain-free bites', 'price': '10.0 JOD'},
    ],
    'Furry Friends Store': [
      {'title': 'Puzzle Toy', 'desc': 'Mental stimulation', 'price': '20.0 JOD', 'offer': 'New'},
      {'title': 'Scratching Post', 'desc': 'Durable sisal fiber', 'price': '30.0 JOD'},
      {'title': 'Pet Carrier', 'desc': 'Breathable travel bag', 'price': '28.0 JOD'},
      {'title': 'Grooming Brush', 'desc': 'Self-cleaning bristles', 'price': '14.0 JOD'},
    ],
    'Healthy Pets Market': [
      {'title': 'Organic Treats', 'desc': '100% natural ingredients', 'price': '18.0 JOD', 'offer': 'Organic'},
      {'title': 'Supplement C', 'desc': 'Immune system boost', 'price': '22.0 JOD'},
      {'title': 'Pet Balm', 'desc': 'For dry paws and nose', 'price': '16.0 JOD'},
      {'title': 'Ear Cleaner', 'desc': 'Gentle & effective', 'price': '10.0 JOD'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    // جلب البيانات من الماب بناءً على الاسم اللي وصل من الصفحة الأولى
    final String storeName = widget.storeData['name'] ?? "";
    final storeProducts = allProducts[storeName] ?? [];

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
            Text(storeName, 
                style: const TextStyle(color: Color(0xFF5A3E2B), fontWeight: FontWeight.bold, fontSize: 18)),
            Text('${widget.storeData['location'] ?? ""} • ${widget.storeData['distance'] ?? ""}', 
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
          // 1. Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildCategoryTab('All', isSelected: true),
                _buildCategoryTab('Food'),
                _buildCategoryTab('Toys'),
                _buildCategoryTab('Health'),
              ],
            ),
          ),

          // 2. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search in $storeName...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildCircularButton(Icons.tune),
              ],
            ),
          ),

          // 3. Products Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: storeProducts.length,
              itemBuilder: (context, index) {
                final product = storeProducts[index];
                return _buildProductCard(
                  title: product['title']!,
                  desc: product['desc']!,
                  price: product['price']!,
                  offer: product['offer'],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF3AA78E),
        child: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
      ),
    );
  }

  // --- Widgets المساعدة ---

  Widget _buildCategoryTab(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF3AA78E).withOpacity(0.2),
        labelStyle: TextStyle(color: isSelected ? const Color(0xFF3AA78E) : Colors.black, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _buildCircularButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
      child: Icon(icon, size: 20, color: const Color(0xFF5A3E2B)),
    );
  }

  Widget _buildProductCard({required String title, required String desc, required String price, String? offer}) {
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
              decoration: const BoxDecoration(color: Color(0xFF3AA78E), borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomRight: Radius.circular(10))),
              child: Text(offer, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Icon(Icons.pets, size: 40, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3AA78E))),
                    const Icon(Icons.add_circle, color: Color(0xFF5A3E2B), size: 24),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}