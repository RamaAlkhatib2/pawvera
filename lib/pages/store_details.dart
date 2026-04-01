import 'package:flutter/material.dart';

class StoreDetails extends StatefulWidget {
  final Map<String, dynamic> storeData;

  const StoreDetails({super.key, required this.storeData});

  @override
  State<StoreDetails> createState() => _StoreDetailsState();
}

class _StoreDetailsState extends State<StoreDetails> {
  // --- 1. إدارة الحالة (State Management) للمفضلة والسلة ---
  final Map<String, bool> favoriteStatus = {}; 
  final List<Map<String, String>> favoritesList = []; 
  final List<Map<String, String>> cartList = []; 

  // --- 2. قاعدة بيانات المنتجات (نفس اللي بعتيها مع روابط الصور) ---
  final Map<String, List<Map<String, String>>> allProducts = {
    'Comfort Paws Store': [
      {'title': 'Orthopedic Dog Bed', 'desc': 'Premium joint support', 'price': '35.0 JOD', 'image': 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?q=80&w=1000&auto=format&fit=crop', 'offer': 'Best Seller'},
      {'title': 'Cat Tree House', 'desc': 'Multi-level play area', 'price': '45.0 JOD', 'image': 'https://images.unsplash.com/photo-1545249390-6bdfa286032f'},
      {'title': 'Pet Blanket', 'desc': 'Warm & cozy wool', 'price': '15.0 JOD', 'image': 'https://images.unsplash.com/photo-1581888227599-779811939961?q=80&w=1000&auto=format&fit=crop'},
      {'title': 'Elevated Feeder', 'desc': 'Healthy eating posture', 'price': '25.0 JOD', 'image': 'https://www.thesprucepets.com/thmb/-cf-gysgx_wGR4VdsFzzwoYcLbw=/fit-in/1500x2016/filters:no_upscale():strip_icc()/sps-dog-bowls-test-yangbaga-elevated-jennifer-montes-4_crop-7901fcac9e424e7cbad661e0c2ac4878.jpeg'},
    ],
    'Pet Supplies Plus': [
      {'title': 'Premium Dog Food', 'desc': 'High protein formula', 'price': '40.0 JOD', 'image': 'https://images.unsplash.com/photo-1589924691106-073b19f5538d', 'offer': '10% Off'},
      {'title': 'Feather Wand Toy', 'desc': 'Interactive cat fun', 'price': '8.0 JOD', 'image': 'https://images.unsplash.com/photo-1513284411132-47685382e39c'},
      {'title': 'Pet Shampoo', 'desc': 'Natural aloe vera', 'price': '12.0 JOD', 'image': 'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7'},
      {'title': 'Training Treats', 'desc': 'Grain-free bites', 'price': '10.0 JOD', 'image': 'https://images.unsplash.com/photo-1505628346881-b72b27e84530'},   
    ],
    'Furry Friends Store': [
      {'title': 'Puzzle Toy', 'desc': 'Mental stimulation', 'price': '20.0 JOD', 'image': 'https://images.unsplash.com/photo-1541888941255-65801833752e', 'offer': 'New'},
      {'title': 'Scratching Post', 'desc': 'Durable sisal fiber', 'price': '30.0 JOD', 'image': 'https://images.unsplash.com/photo-1533738363-b7f9aef128ce'},
      {'title': 'Pet Carrier', 'desc': 'Breathable travel bag', 'price': '28.0 JOD', 'image': 'https://images.unsplash.com/photo-1591768793355-74d7ca7360cd'},
      {'title': 'Grooming Brush', 'desc': 'Self-cleaning bristles', 'price': '14.0 JOD', 'image': 'https://images.unsplash.com/photo-1544568100-847a948585b9'},
    ],
    'Healthy Pets Market': [
      {'title': 'Organic Treats', 'desc': '100% natural ingredients', 'price': '18.0 JOD', 'image': 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e', 'offer': 'Organic'},
      {'title': 'Supplement C', 'desc': 'Immune system boost', 'price': '22.0 JOD', 'image': 'https://images.unsplash.com/photo-1583511666407-5f06ecb93012'},
      {'title': 'Pet Balm', 'desc': 'For dry paws and nose', 'price': '16.0 JOD', 'image': 'https://images.unsplash.com/photo-1583512603805-3cc6b41f3edb'},
      {'title': 'Ear Cleaner', 'desc': 'Gentle & effective', 'price': '10.0 JOD', 'image': 'https://images.unsplash.com/photo-1583511666444-a93c5d35d74b'},
    ],
  };

  void _toggleFavorite(Map<String, String> product) {
    final String title = product['title']!;
    setState(() {
      if (favoriteStatus[title] == true) {
        favoriteStatus[title] = false;
        favoritesList.removeWhere((p) => p['title'] == title);
      } else {
        favoriteStatus[title] = true;
        favoritesList.add(product);
      }
    });
  }

  void _addToCart(Map<String, String> product) {
    setState(() {
      cartList.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['title']} added to cart!'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF5BA092),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String storeName = widget.storeData['name'] ?? "Store";
    final storeProducts = allProducts[storeName] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      body: CustomScrollView(
        slivers: [
          // --- 3. AppBar (مع الـ Badges للقلب والسلة) ---
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF5BA092),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              _buildAppBarCircleIcon(
                Icons.favorite_border,
                count: favoritesList.length,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyWishlistPage(wishlistItems: favoritesList)));
                },
              ),
              _buildAppBarCircleIcon(
                Icons.shopping_cart_outlined, 
                count: cartList.length,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyCartPage(cartItems: cartList, storeData: widget.storeData)));
                },
              ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildSafeImage(
                widget.storeData['image'],
                fallbackIcon: Icons.storefront,
              ),
            ),
          ),

          // --- 4. تفاصيل المتجر (نفس اللي كان عندك) ---
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(storeName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5A3E2B))),
                      _buildRatingBadge(),
                    ],
                  ),
                  const Text('Premium pet furniture and bedding', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const Divider(height: 30),
                  Row(
                    children: [
                      _buildInfoItem(Icons.location_on_outlined, 'Distance', '${widget.storeData['distance'] ?? "1.5 km"} away'),
                      const SizedBox(width: 25),
                      _buildInfoItem(Icons.access_time, 'Hours', widget.storeData['hours'] ?? '9AM - 8PM'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Available Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: (widget.storeData['categories'] as List<String>? ?? ['Furniture', 'Bedding', 'Home'])
                        .map((cat) => _buildCategoryTag(cat))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // --- 5. البحث والفلترة (نفس اللي كان عندك) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFilterChip(Icons.tune, 'Filters'),
                      const SizedBox(width: 10),
                      _buildFilterChip(Icons.local_offer_outlined, 'On Sale'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // --- 6. شبكة المنتجات (المعدلة) ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = storeProducts[index];
                  return _buildProductCard(
                    product, 
                    isFav: favoriteStatus[product['title']] ?? false,
                    onFavTap: () => _toggleFavorite(product),
                    onAddToCart: () => _addToCart(product),
                  );
                },
                childCount: storeProducts.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // --- دوال المساعدة للواجهة (Helper Widgets) ---

  Widget _buildAppBarCircleIcon(IconData icon, {int count = 0, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 8),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(icon: Icon(icon, color: const Color(0xFF5A3E2B), size: 20), onPressed: onTap),
          ),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSafeImage(String? url, {required IconData fallbackIcon}) {
    return Image.network(
      url ?? "",
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFFE0F2F1),
        child: Icon(fallbackIcon, size: 50, color: const Color(0xFF5BA092)),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      },
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.green, size: 16),
          Text(' ${widget.storeData['rating'] ?? "4.8"}',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }

  Widget _buildFilterChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade50),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5BA092)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Color(0xFF5BA092), fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product, {required bool isFav, required VoidCallback onFavTap, required VoidCallback onAddToCart}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _buildSafeImage(product['image'], fallbackIcon: Icons.pets),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavTap,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.grey, size: 18),
                    ),
                  ),
                ),
                if (product['offer'] != null)
                  Positioned(
                    top: 0, left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(color: Color(0xFF3AA78E), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomRight: Radius.circular(10))),
                      child: Text(product['offer']!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5A3E2B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(product['desc'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1),
                const SizedBox(height: 8),
                Text(product['price']!, style: const TextStyle(color: Color(0xFF5BA092), fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onAddToCart,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFF5BA092).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, color: Color(0xFF5BA092), size: 18),
                        SizedBox(width: 8),
                        Text('Add to Cart', style: TextStyle(color: Color(0xFF5BA092), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 7. صفحة المفضلة (My Wishlist Page) ---
class MyWishlistPage extends StatelessWidget {
  final List<Map<String, String>> wishlistItems;
  const MyWishlistPage({super.key, required this.wishlistItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF5A3E2B)), onPressed: () => Navigator.pop(context)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("My Wishlist", style: TextStyle(color: Color(0xFF5A3E2B), fontWeight: FontWeight.bold, fontSize: 18)),
            Text("${wishlistItems.length} items", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      body: wishlistItems.isEmpty
          ? const Center(child: Text("Your wishlist is empty!"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 16, mainAxisSpacing: 16),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) => _buildStaticCard(wishlistItems[index]),
            ),
    );
  }

  Widget _buildStaticCard(Map<String, String> product) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Image.network(product['image']!, fit: BoxFit.cover, width: double.infinity))),
          Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1), Text(product['price']!, style: const TextStyle(color: Color(0xFF5BA092), fontWeight: FontWeight.bold))])),
        ],
      ),
    );
  }
}

// --- 8. صفحة السلة الاحترافية (My Cart Page) ---
class MyCartPage extends StatefulWidget {
  final List<Map<String, String>> cartItems;
  final Map<String, dynamic> storeData;
  const MyCartPage({super.key, required this.cartItems, required this.storeData});

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  final Map<String, int> quantities = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.cartItems) { quantities[item['title']!] = 1; }
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    for (var item in widget.cartItems) {
      double price = double.tryParse(item['price']!.replaceAll(' JOD', '')) ?? 0;
      subtotal += price * (quantities[item['title']] ?? 1);
    }
    return subtotal;
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = _calculateSubtotal();
    double deliveryFee = widget.cartItems.isEmpty ? 0 : 5.00;
    double total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: Padding(padding: const EdgeInsets.all(8.0), child: CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF5A3E2B), size: 20), onPressed: () => Navigator.pop(context)))),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Shopping Cart", style: TextStyle(color: Color(0xFF5A3E2B), fontWeight: FontWeight.bold, fontSize: 18)), Text("${widget.cartItems.length} items", style: const TextStyle(color: Colors.grey, fontSize: 12))]),
      ),
      body: Column(children: [
        Expanded(
          child: widget.cartItems.isEmpty 
          ? const Center(child: Text("Your cart is empty!")) 
          : ListView.builder(
              padding: const EdgeInsets.all(16), 
              itemCount: widget.cartItems.length, 
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                final title = item['title']!;
                int qty = quantities[title] ?? 1;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16), 
                  padding: const EdgeInsets.all(12), 
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
                  child: Row(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(item['image']!, width: 80, height: 80, fit: BoxFit.cover)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF5A3E2B))), const Text("PetSmart", style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 8), Text(item['price']!, style: const TextStyle(color: Color(0xFF3AA78E), fontWeight: FontWeight.bold, fontSize: 16))])),
                    Row(children: [
                      _buildQtyBtn(Icons.remove, () { if (qty > 1) setState(() => quantities[title] = qty - 1); }),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold))),
                      _buildQtyBtn(Icons.add, () { setState(() => quantities[title] = qty + 1); }),
                      const SizedBox(width: 8),
                      GestureDetector(onTap: () { setState(() { widget.cartItems.removeAt(index); quantities.remove(title); }); }, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(border: Border.all(color: Colors.red.shade100), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_outline, color: Colors.red, size: 20))),
                    ]),
                  ]),
                );
              }
            )
        ),
        if (widget.cartItems.isNotEmpty) 
          Container(
            padding: const EdgeInsets.all(20), 
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: Column(children: [
              _buildSummaryRow("Subtotal", "${subtotal.toStringAsFixed(2)} JOD"),
              _buildSummaryRow("Delivery Fee", "${deliveryFee.toStringAsFixed(2)} JOD"),
              const Divider(height: 20),
              _buildSummaryRow("Total", "${total.toStringAsFixed(2)} JOD", isTotal: true),
              const SizedBox(height: 15),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage(subtotal: subtotal, deliveryFee: deliveryFee, total: total, storeData: widget.storeData))),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5BA092), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                icon: const Icon(Icons.payment, color: Colors.white), label: const Text("Proceed to Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            ]),
          ),
      ]),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(color: const Color(0xFF5BA092).withOpacity(0.3)), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: const Color(0xFF5BA092))));
  }

  Widget _buildSummaryRow(String l, String v, {bool isTotal = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)), Text(v, style: TextStyle(color: isTotal ? const Color(0xFF3AA78E) : Colors.black, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal))]);
  }
}

// --- 9. صفحة الـ Checkout ---
class CheckoutPage extends StatelessWidget {
  final double subtotal, deliveryFee, total; 
  final Map<String, dynamic> storeData;

  const CheckoutPage({super.key, required this.subtotal, required this.deliveryFee, required this.total, required this.storeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, 
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF5A3E2B)), onPressed: () => Navigator.pop(context)), 
        title: const Text("Checkout", style: TextStyle(color: Color(0xFF5A3E2B), fontWeight: FontWeight.bold))
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        _buildSectionCard(child: ListTile(leading: const Icon(Icons.storefront, color: Color(0xFF5BA092)), title: Text(storeData['name'] ?? "Store", style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("${storeData['location'] ?? "Irbid"} • 1.5 km away"))),
        const SizedBox(height: 16),
        _buildSectionCard(title: "Delivery Address", icon: Icons.home_outlined, child: Column(children: [
          _buildTextField("Full Name", "John Doe"),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: _buildTextField("City", "Irbid")), const SizedBox(width: 10), Expanded(child: _buildTextField("Street", "Abo rashed street"))]),
          const SizedBox(height: 12),
          _buildTextField("Building", "Building 15"),
        ])),
        const SizedBox(height: 16),
        _buildSectionCard(title: "Payment Method", icon: Icons.payment_outlined, child: Column(children: [
          _buildPaymentOption("Credit / Debit Card", Icons.credit_card, isSelected: true),
          const SizedBox(height: 10),
          _buildPaymentOption("Cash on Delivery", Icons.money),
        ])),
        const SizedBox(height: 16),
        _buildSectionCard(title: "Order Summary", icon: Icons.assignment_outlined, child: Column(children: [
          _summaryRow("Items", "${subtotal.toStringAsFixed(2)} JOD"),
          _summaryRow("Delivery Fee", "${deliveryFee.toStringAsFixed(2)} JOD"),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("${total.toStringAsFixed(2)} JOD", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3AA78E), fontSize: 16))]),
        ])),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5BA092), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Place Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
      ])),
    );
  }

  Widget _buildSectionCard({String? title, IconData? icon, required Widget child}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (title != null) Row(children: [Icon(icon, size: 20, color: const Color(0xFF5A3E2B)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]), if (title != null) const SizedBox(height: 15), child]));
  Widget _buildTextField(String l, String h) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(height: 5), TextField(decoration: InputDecoration(hintText: h, filled: true, fillColor: const Color(0xFFFBFDFF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200))))]);
  Widget _buildPaymentOption(String l, IconData i, {bool isSelected = false}) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: isSelected ? const Color(0xFF5BA092) : Colors.grey.shade200), color: isSelected ? const Color(0xFFF4F9F8) : Colors.white), child: Row(children: [Icon(i, size: 20), const SizedBox(width: 12), Text(l)]));
  Widget _summaryRow(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.grey)), Text(v)]));
}