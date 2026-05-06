import 'package:flutter/material.dart';
import 'supplies_store.dart'; // مسار صفحة المتاجر (تأكدي من الاسم)ٍ

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
  String searchQuery = '';
  bool showFilterOptions = false;
  bool onSaleOnly = false;
  String selectedCategory = 'All';
  String sortBy = 'Popular';
  String selectedPriceRange = 'All';

  List<String> sortOptions = [
    'Popular',
    'Top Rated',
    'Price: Low to High',
    'Price: High to Low',
  ];

  List<String> priceRanges = [
    'All',
    'Under 20 JOD',
    '20-50 JOD',
    'Over 50 JOD',
  ];

  List<Map<String, String>> _filterProducts(
    List<Map<String, String>> products,
  ) {
    return products.where((product) {
      final query = searchQuery.toLowerCase();
      final price =
          double.tryParse(product['price']!.replaceAll(' JOD', '').trim()) ?? 0;
      final matchesSearch =
          query.isEmpty ||
          product['title']!.toLowerCase().contains(query) ||
          (product['desc']?.toLowerCase().contains(query) ?? false);
      final matchesOnSale =
          !onSaleOnly || (product['offer']?.isNotEmpty ?? false);
      final matchesCategory =
          selectedCategory == 'All' || product['category'] == selectedCategory;
      final matchesPriceRange =
          selectedPriceRange == 'All' ||
          (selectedPriceRange == 'Under 20 JOD' && price < 20) ||
          (selectedPriceRange == '20-50 JOD' && price >= 20 && price <= 50) ||
          (selectedPriceRange == 'Over 50 JOD' && price > 50);
      return matchesSearch &&
          matchesOnSale &&
          matchesCategory &&
          matchesPriceRange;
    }).toList();
  }

  List<Map<String, String>> _sortProducts(List<Map<String, String>> products) {
    final sorted = [...products];
    if (sortBy == 'Price: Low to High') {
      sorted.sort((a, b) {
        final priceA = double.tryParse(a['price']!.replaceAll(' JOD', '')) ?? 0;
        final priceB = double.tryParse(b['price']!.replaceAll(' JOD', '')) ?? 0;
        return priceA.compareTo(priceB);
      });
    } else if (sortBy == 'Price: High to Low') {
      sorted.sort((a, b) {
        final priceA = double.tryParse(a['price']!.replaceAll(' JOD', '')) ?? 0;
        final priceB = double.tryParse(b['price']!.replaceAll(' JOD', '')) ?? 0;
        return priceB.compareTo(priceA);
      });
    }
    return sorted;
  }

  // --- 2. قاعدة بيانات المنتجات (نفس اللي بعتيها مع روابط الصور) ---
  final Map<String, List<Map<String, String>>> allProducts = {
    'Comfort Paws Store': [
      {
        'title': 'Orthopedic Dog Bed',
        'desc': 'Premium joint support',
        'price': '35.0 JOD',
        'category': 'Beds',
        'image':
            'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?q=80&w=1000&auto=format&fit=crop',
        'offer': 'Best Seller',
      },
      {
        'title': 'Cat Tree House',
        'desc': 'Multi-level play area',
        'price': '45.0 JOD',
        'category': 'Toys',
        'image': 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'title': 'Pet Blanket',
        'desc': 'Warm & cozy wool',
        'price': '15.0 JOD',
        'category': 'Bedding',
        'image': 'https://images.unsplash.com/photo-1581888227599-779811939961?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'title': 'Elevated Feeder',
        'desc': 'Healthy eating posture',
        'price': '25.0 JOD',
        'category': 'Feeding',
        'image': 'https://images.unsplash.com/photo-1524230570005-20e7a2c03de0?q=80&w=1000&auto=format&fit=crop',
      },
    ],
    'Pet Supplies Plus': [
      {
        'title': 'Premium Dog Food',
        'desc': 'High protein formula',
        'price': '40.0 JOD',
        'category': 'Food',
        'image': 'https://images.unsplash.com/photo-1589924691106-073b19f5538d?q=80&w=1000&auto=format&fit=crop',
        'offer': '10% Off',
      },
      {
        'title': 'Feather Wand Toy',
        'desc': 'Interactive cat fun',
        'price': '8.0 JOD',
        'category': 'Toys',
        'image': 'https://images.unsplash.com/photo-1513284411132-47685382e39c?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'title': 'Pet Shampoo',
        'desc': 'Natural aloe vera',
        'price': '12.0 JOD',
        'category': 'Grooming',
        'image': 'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'title': 'Training Treats',
        'desc': 'Grain-free bites',
        'price': '10.0 JOD',
        'category': 'Treats',
        'image': 'https://images.unsplash.com/photo-1505628346881-b72b27e84530?q=80&w=1000&auto=format&fit=crop',
      },
    ],
    'Furry Friends Store': [
      {
        'title': 'Puzzle Toy',
        'desc': 'Mental stimulation',
        'price': '20.0 JOD',
        'category': 'Toys',
        'image': 'https://images.unsplash.com/photo-1541888941255-65801833752e?q=80&w=1000&auto=format&fit=crop',
        'offer': 'New',
      },
      {
        'title': 'Scratching Post',
        'desc': 'Durable sisal fiber',
        'price': '30.0 JOD',
        'category': 'Toys',
        'image': 'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'title': 'Pet Carrier',
        'desc': 'Breathable travel bag',
        'price': '28.0 JOD',
        'category': 'Travel',
        'image': 'https://images.unsplash.com/photo-1591768793355-74d7ca7360cd?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'title': 'Grooming Brush',
        'desc': 'Self-cleaning bristles',
        'price': '14.0 JOD',
        'category': 'Grooming',
        'image': 'https://images.unsplash.com/photo-1544568100-847a948585b9?q=80&w=1000&auto=format&fit=crop',
      },
    ],
    'Healthy Pets Market': [
      {
        'title': 'Organic Treats',
        'desc': '100% natural ingredients',
        'price': '18.0 JOD',
        'category': 'Food',
        'image': 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?q=80&w=1000&auto=format&fit=crop',
        'offer': 'Organic',
      },
      {
        'title': 'Supplement C',
        'desc': 'Immune system boost',
        'price': '22.0 JOD',
        'category': 'Health',
        'image': 'https://images.unsplash.com/photo-1583511666407-5f06ecb93012?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'title': 'Pet Balm',
        'desc': 'For dry paws and nose',
        'price': '16.0 JOD',
        'category': 'Grooming',
        'image': 'https://images.unsplash.com/photo-1583512603805-3cc6b41f3edb?q=80&w=1000&auto=format&fit=crop',
      },
      {
        'title': 'Ear Cleaner',
        'desc': 'Gentle & effective',
        'price': '10.0 JOD',
        'category': 'Health',
        'image': 'https://images.unsplash.com/photo-1583511666444-a93c5d35d74b?q=80&w=1000&auto=format&fit=crop',
      },
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
    final filteredProducts = _sortProducts(_filterProducts(storeProducts));
    final categories = [
      'All',
      ...storeProducts
          .map((p) => p['category'])
          .whereType<String>()
          .toSet()
          ,
    ];

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
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              _buildAppBarCircleIcon(
                Icons.favorite_border,
                count: favoritesList.length,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MyWishlistPage(wishlistItems: favoritesList),
                    ),
                  );
                },
              ),
              _buildAppBarCircleIcon(
                Icons.shopping_cart_outlined,
                count: cartList.length,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyCartPage(
                        cartItems: cartList,
                        storeData: widget.storeData,
                      ),
                    ),
                  );
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        storeName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A3E2B),
                        ),
                      ),
                      _buildRatingBadge(),
                    ],
                  ),
                  const Text(
                    'Premium pet furniture and bedding',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const Divider(height: 30),
                  Row(
                    children: [
                      _buildInfoItem(
                        Icons.location_on_outlined,
                        'Distance',
                        '${widget.storeData['distance'] ?? "1.5 km"} away',
                      ),
                      const SizedBox(width: 25),
                      _buildInfoItem(
                        Icons.access_time,
                        'Hours',
                        widget.storeData['hours'] ?? '9AM - 8PM',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Available Categories',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children:
                        (widget.storeData['categories'] as List<String>? ??
                                ['Furniture', 'Bedding', 'Home'])
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () => setState(() => searchQuery = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFilterChip(
                        Icons.tune,
                        'Filters',
                        isSelected: showFilterOptions,
                        onTap: () => setState(
                          () => showFilterOptions = !showFilterOptions,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        Icons.local_offer_outlined,
                        'On Sale',
                        isSelected: onSaleOnly,
                        onTap: () => setState(() => onSaleOnly = !onSaleOnly),
                      ),
                    ],
                  ),
                  if (showFilterOptions) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterSectionTitle('Sort By'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: sortOptions.map((option) {
                              return _buildOptionChip(
                                option,
                                selected: sortBy == option,
                                onTap: () => setState(() => sortBy = option),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          _buildFilterSectionTitle('Category'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: categories.map((category) {
                              return _buildOptionChip(
                                category,
                                selected: selectedCategory == category,
                                onTap: () =>
                                    setState(() => selectedCategory = category),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          _buildFilterSectionTitle('Price Range'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: priceRanges.map((range) {
                              return _buildOptionChip(
                                range,
                                selected: selectedPriceRange == range,
                                onTap: () =>
                                    setState(() => selectedPriceRange = range),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // --- 6. شبكة المنتجات (المعدلة) ---
          if (filteredProducts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 30,
                ),
                child: Text(
                  'No products found. حاول تغيير البحث أو الفلاتر.',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
          if (filteredProducts.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = filteredProducts[index];
                  return _buildProductCard(
                    product,
                    isFav: favoriteStatus[product['title']] ?? false,
                    onFavTap: () => _toggleFavorite(product),
                    onAddToCart: () => _addToCart(product),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProductDetailsPage(
                                product: product,
                                storeData: widget.storeData,
                                isInitiallyFavorite:
                                    favoriteStatus[product['title']] ?? false,
                                onToggleFavorite: () => _toggleFavorite(product),
                                onAddToCart: () => _addToCart(product),
                              ),
                        ),
                      );
                    },
                  );
                }, childCount: filteredProducts.length),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // --- دوال المساعدة للواجهة (Helper Widgets) ---

  Widget _buildAppBarCircleIcon(
    IconData icon, {
    int count = 0,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 8),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(icon, color: const Color(0xFF5A3E2B), size: 20),
              onPressed: onTap,
            ),
          ),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSafeImage(String? url, {required IconData fallbackIcon}) {
    if (url == null || url.isEmpty) {
      return Container(
        color: const Color(0xFFE0F2F1),
        child: Icon(fallbackIcon, size: 50, color: const Color(0xFF5BA092)),
      );
    }
    
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFFE0F2F1),
        child: Icon(fallbackIcon, size: 50, color: const Color(0xFF5BA092)),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
    );
  }

  void _showStoreReviewsDialog() {
    final storeName = widget.storeData['name']?.toString() ?? 'Store';
    final reviewProfile = _getStoreReviewProfile(storeName);
    final ratingValue = (reviewProfile['rating'] as double?) ?? 4.8;
    final ratingText = ratingValue.toStringAsFixed(1);
    final totalRatings = (reviewProfile['ratingsCount'] as int?) ?? 0;
    final reviews = (reviewProfile['reviews'] as List<Map<String, dynamic>>?) ?? [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFEFF6F7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 620),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'Store Reviews',
                      style: TextStyle(
                        color: Color(0xFF7A4B25),
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF8DC1B7), width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: const Icon(Icons.close, size: 16, color: Color(0xFF8DC1B7)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'See what customers are saying about $storeName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF5A6D8A),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ratingText,
                            style: const TextStyle(
                              color: Color(0xFF7A4B25),
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          _buildStarsRow(ratingValue, size: 18),
                          const SizedBox(height: 2),
                          Text(
                            '$totalRatings ratings',
                            style: const TextStyle(
                              color: Color(0xFF5A6D8A),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Based on ${reviews.length} customer reviews',
                          style: const TextStyle(
                            color: Color(0xFF5A6D8A),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder:
                        (context, index) =>
                            _buildStoreReviewCard(reviews[index]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStoreReviewProfile(String storeName) {
    const profiles = {
      'Comfort Paws Store': {
        'rating': 4.8,
        'ratingsCount': 412,
        'reviews': [
          {
            'name': 'Jennifer C.',
            'initial': 'J',
            'date': '2026-01-03',
            'stars': 5,
            'comment':
                "Absolutely love this store! The quality of their furniture is exceptional. My cats' new bed is perfect!",
          },
          {
            'name': 'Hassan Y.',
            'initial': 'H',
            'date': '2025-12-30',
            'stars': 5,
            'comment':
                'Premium products at premium prices, but totally worth it. Everything is so well-made and comfortable for pets.',
          },
          {
            'name': 'Maya R.',
            'initial': 'M',
            'date': '2025-12-22',
            'stars': 4,
            'comment':
                'Great quality overall and delivery was smooth. I only wish there were more color options.',
          },
        ],
      },
      'Pet Supplies Plus': {
        'rating': 4.7,
        'ratingsCount': 286,
        'reviews': [
          {
            'name': 'Adam K.',
            'initial': 'A',
            'date': '2026-01-05',
            'stars': 5,
            'comment':
                'Very good variety and fair prices. Found premium food and accessories in one place.',
          },
          {
            'name': 'Sara M.',
            'initial': 'S',
            'date': '2025-12-27',
            'stars': 4,
            'comment':
                'Staff were helpful and product quality is solid. Checkout took a bit longer than expected.',
          },
          {
            'name': 'Yousef N.',
            'initial': 'Y',
            'date': '2025-12-18',
            'stars': 5,
            'comment':
                'Excellent grooming products and quick service. I will definitely order again.',
          },
        ],
      },
      'Whisker World': {
        'rating': 4.5,
        'ratingsCount': 193,
        'reviews': [
          {
            'name': 'Noor A.',
            'initial': 'N',
            'date': '2026-01-02',
            'stars': 5,
            'comment':
                'Loved the cat toys collection. My cat was obsessed with the new scratching post.',
          },
          {
            'name': 'Khaled T.',
            'initial': 'K',
            'date': '2025-12-21',
            'stars': 4,
            'comment':
                'Good prices and friendly team. Some items were out of stock but alternatives were fine.',
          },
        ],
      },
    };

    final profile = profiles[storeName];
    if (profile != null) {
      return Map<String, dynamic>.from(profile);
    }

    return {
      'rating': 4.6,
      'ratingsCount': 120,
      'reviews': [
        {
          'name': 'Pet Owner',
          'initial': 'P',
          'date': '2025-12-20',
          'stars': 5,
          'comment': 'Great overall experience and good product quality.',
        },
        {
          'name': 'Samir O.',
          'initial': 'S',
          'date': '2025-12-10',
          'stars': 4,
          'comment': 'Helpful staff and clean store. I found most of what I needed.',
        },
      ],
    };
  }

  Widget _buildStarsRow(double rating, {double size = 16}) {
    final rounded = rating.round().clamp(0, 5);
    return Row(
      children: List.generate(5, (index) {
        final isFilled = index < rounded;
        return Icon(
          isFilled ? Icons.star : Icons.star_border,
          color: isFilled ? const Color(0xFFF3C000) : const Color(0xFFBFC8D5),
          size: size,
        );
      }),
    );
  }

  Widget _buildStoreReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4DDE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF5BA092),
                child: Text(
                  review['initial'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review['name'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF7A4B25),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F7EF),
                            border: Border.all(color: const Color(0xFFA8E0BE)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Color(0xFF0E9F47), size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Color(0xFF0E9F47),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildStarsRow((review['stars'] as int? ?? 5).toDouble()),
                  ],
                ),
              ),
              Text(
                review['date'] ?? '',
                style: const TextStyle(color: Color(0xFF5A6D8A), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['comment'] ?? '',
            style: const TextStyle(
              color: Color(0xFF4C5C73),
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge() {
    return GestureDetector(
      onTap: _showStoreReviewsDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.green, size: 16),
            Text(
              ' ${widget.storeData['rating'] ?? "4.8"}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3A6F5D),
      ),
    );
  }

  Widget _buildOptionChip(
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5BA092) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF5BA092) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF5BA092),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    IconData icon,
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5BA092) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF5BA092) : Colors.teal.shade50,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF5BA092),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF5BA092),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    Map<String, String> product, {
    required bool isFav,
    required VoidCallback onFavTap,
    required VoidCallback onAddToCart,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: _buildSafeImage(
                      product['image'],
                      fallbackIcon: Icons.pets,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavTap,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  if (product['offer'] != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3AA78E),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Text(
                          product['offer']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                  Text(
                    product['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF5A3E2B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product['desc'] ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['price']!,
                    style: const TextStyle(
                      color: Color(0xFF5BA092),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onAddToCart,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5BA092).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: Color(0xFF5BA092),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Add to Cart',
                            style: TextStyle(
                              color: Color(0xFF5BA092),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailsPage extends StatefulWidget {
  final Map<String, String> product;
  final Map<String, dynamic> storeData;
  final bool isInitiallyFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;

  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.storeData,
    required this.isInitiallyFavorite,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;
  late bool isFavorite;
  late List<Map<String, dynamic>> reviews;
  late int ratingsCount;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isInitiallyFavorite;
    final title = widget.product['title'] ?? 'Product';
    reviews = _getProductReviews(title);
    ratingsCount = 90 + (title.length * 14);
  }

  List<Map<String, dynamic>> _getProductReviews(String title) {
    final reviewsByProduct = {
      'Automatic Pet Feeder': [
        {
          'name': 'Dalal R.',
          'initial': 'D',
          'date': '2025-12-21',
          'stars': 5,
          'comment': "Game changer! I can feed my pets even when I'm away.",
        },
        {
          'name': 'Andrew M.',
          'initial': 'A',
          'date': '2025-12-08',
          'stars': 5,
          'comment': 'Amazing feeder! Portion control is perfect and scheduling is easy.',
        },
      ],
    };

    return reviewsByProduct[title] ??
        [
          {
            'name': 'Nora S.',
            'initial': 'N',
            'date': '2025-11-19',
            'stars': 5,
            'comment': 'Best purchase. Product quality is excellent and works as expected.',
          },
          {
            'name': 'Lina H.',
            'initial': 'L',
            'date': '2025-10-30',
            'stars': 4,
            'comment': 'Very useful overall. Delivery was fast and packaging was great.',
          },
          {
            'name': 'Omar K.',
            'initial': 'O',
            'date': '2025-10-12',
            'stars': 5,
            'comment': 'Exactly as described. Great value for money.',
          },
        ];
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final title = product['title'] ?? 'Product';
    final desc = product['desc'] ?? 'No description available.';
    final price = product['price'] ?? '0 JOD';
    final category = product['category'] ?? 'Accessories';
    final image = product['image'];
    final storeName = widget.storeData['name']?.toString() ?? 'Store';
    final distance = widget.storeData['distance']?.toString() ?? '1.5 km';

    final avgRating = (reviews.fold<double>(
              0,
              (sum, r) => sum + ((r['stars'] as int?)?.toDouble() ?? 5.0),
            ) /
            reviews.length)
        .toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF6F7),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD6E5E8)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF5A3E2B)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: Color(0xFF5A3E2B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (image != null && image.isNotEmpty)
              SizedBox(
                height: 270,
                width: double.infinity,
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: const Color(0xFFDCEDEE),
                        child: const Icon(Icons.pets, size: 60, color: Color(0xFF5BA092)),
                      ),
                ),
              ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 0),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FBFC),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 40 / 2,
                                color: Color(0xFF5A3E2B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'by FeedSmart',
                              style: const TextStyle(color: Color(0xFF5A6D8A), fontSize: 16 / 1.2),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.onToggleFavorite();
                          setState(() => isFavorite = !isFavorite);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E5E8)),
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : const Color(0xFF7A4B25),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF3C000), size: 22),
                      const SizedBox(width: 4),
                      Text(
                        avgRating,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5A3E2B),
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($ratingsCount ratings)',
                        style: const TextStyle(color: Color(0xFF5A6D8A), fontSize: 16),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4E9E96),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Color(0xFF0BA141),
                      fontWeight: FontWeight.w700,
                      fontSize: 38 / 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Color(0xFF5A3E2B),
                      fontWeight: FontWeight.w700,
                      fontSize: 32 / 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: Color(0xFF5A6D8A),
                      fontSize: 18 / 1.2,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Store',
                    style: TextStyle(
                      color: Color(0xFF5A3E2B),
                      fontWeight: FontWeight.w700,
                      fontSize: 26 / 1.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          storeName,
                          style: const TextStyle(color: Color(0xFF5A6D8A), fontSize: 30 / 1.6),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFBDD9DE)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$distance away',
                          style: const TextStyle(
                            color: Color(0xFF7A4B25),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text(
                        'Availability',
                        style: TextStyle(
                          color: Color(0xFF5A3E2B),
                          fontWeight: FontWeight.w700,
                          fontSize: 30 / 1.6,
                        ),
                      ),
                      const Spacer(),
                      const Text('Qty:', style: TextStyle(color: Color(0xFF5A6D8A), fontSize: 18)),
                      const SizedBox(width: 8),
                      _qtyBtn(
                        icon: Icons.remove,
                        onTap: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          color: Color(0xFF5A3E2B),
                          fontWeight: FontWeight.w700,
                          fontSize: 22 / 1.6,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _qtyBtn(
                        icon: Icons.add,
                        onTap: () => setState(() => quantity++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF11B84A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'In Stock',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onAddToCart();
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5BA092),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFBCD4D9)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF3C000), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Customer Reviews (${reviews.length})',
                        style: const TextStyle(
                          color: Color(0xFF5A3E2B),
                          fontWeight: FontWeight.w700,
                          fontSize: 30 / 1.6,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showWriteReviewDialog(title),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFB9DADF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.chat_bubble_outline, color: Color(0xFF7A4B25), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Write a Review',
                                style: TextStyle(
                                  color: Color(0xFF7A4B25),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...reviews.map((review) => _reviewCard(review)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWriteReviewDialog(String productTitle) {
    final reviewController = TextEditingController();
    int selectedStars = 0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFFEFF6F7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        const Text(
                          'Write a Review',
                          style: TextStyle(
                            color: Color(0xFF7A4B25),
                            fontWeight: FontWeight.w700,
                            fontSize: 38 / 1.7,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(dialogContext),
                          child: const Icon(Icons.close, color: Color(0xFF7A4B25)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Share your experience with $productTitle',
                        style: const TextStyle(
                          color: Color(0xFF6A7688),
                          fontSize: 30 / 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Rating',
                      style: TextStyle(
                        color: Color(0xFF7A4B25),
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => GestureDetector(
                          onTap: () => setDialogState(() => selectedStars = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              index < selectedStars ? Icons.star : Icons.star_border,
                              color: index < selectedStars
                                  ? const Color(0xFFF3C000)
                                  : const Color(0xFFBFC7D3),
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Your Review',
                      style: TextStyle(
                        color: Color(0xFF7A4B25),
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reviewController,
                      minLines: 3,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts about this product...',
                        hintStyle: const TextStyle(color: Color(0xFF7E8797)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFBDD9DE)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFBDD9DE)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF5BA092)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFB9DADF)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF7A4B25),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            final comment = reviewController.text.trim();
                            if (selectedStars == 0 || comment.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please add rating and review text.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            final now = DateTime.now();
                            final dateText =
                                '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

                            setState(() {
                              reviews.insert(0, {
                                'name': 'You',
                                'initial': 'Y',
                                'date': dateText,
                                'stars': selectedStars,
                                'comment': comment,
                              });
                              ratingsCount += 1;
                            });
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Review submitted successfully.'),
                                backgroundColor: Color(0xFF5BA092),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4E9E96),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Submit Review',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF5F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBCDCE1)),
        ),
        child: Icon(icon, color: const Color(0xFF7A4B25)),
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    final stars = (review['stars'] as int?) ?? 5;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBCD9DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF4E9E96),
                child: Text(
                  review['initial']?.toString() ?? '',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review['name']?.toString() ?? '',
                          style: const TextStyle(
                            color: Color(0xFF7A4B25),
                            fontWeight: FontWeight.w700,
                            fontSize: 18 / 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F7EF),
                            border: Border.all(color: const Color(0xFFA8E0BE)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Color(0xFF0E9F47), size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Color(0xFF0E9F47),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          color: const Color(0xFFF3C000),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                review['date']?.toString() ?? '',
                style: const TextStyle(color: Color(0xFF5A6D8A), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review['comment']?.toString() ?? '',
            style: const TextStyle(
              color: Color(0xFF4C5C73),
              fontSize: 16 / 1.2,
              height: 1.35,
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5A3E2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Wishlist",
              style: TextStyle(
                color: Color(0xFF5A3E2B),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "${wishlistItems.length} items",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      body: wishlistItems.isEmpty
          ? const Center(child: Text("Your wishlist is empty!"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio:
                    0.65, // عدلت النسبة لتوفير مساحة للزر داخل الكرت
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) =>
                  _buildStaticCard(context, wishlistItems[index]),
            ),

      // الزر الكبير في أسفل الصفحة
      bottomNavigationBar: wishlistItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("All items added to cart!"),
                      backgroundColor: Color(0xFF5BA092),
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyCartPage(
                        cartItems: wishlistItems, // تمرير القائمة كاملة
                        storeData: {
                          'name': 'Pet Supplies Plus', // بيانات افتراضية للمتجر
                          'image': 'assets/images/pet_store.png',
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                label: Text(
                  "Add All to Cart (${wishlistItems.length})",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5BA092),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
    );
  }

  Widget _buildStaticCard(BuildContext context, Map<String, String> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Image.network(
                product['image']!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE0F2F1),
                  child: const Icon(Icons.pets, size: 50, color: Color(0xFF5BA092)),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  product['price']!,
                  style: const TextStyle(
                    color: Color(0xFF5BA092),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () {
                      // 1. إظهار رسالة تأكيد للمستخدم
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${product['title']} added to cart!"),
                          backgroundColor: const Color(0xFF5BA092),
                          duration: const Duration(seconds: 1),
                        ),
                      );

                      // 2. الانتقال لصفحة السلة وتمرير بيانات المنتج
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyCartPage(
                            cartItems: [
                              product,
                            ], // نمرر المنتج الحالي داخل قائمة
                            storeData: {
                              'name':
                                  'Pet Supplies Plus', // يمكنك استبداله ببيانات ديناميكية إذا توفرت
                              'image': 'assets/images/pet_store.png',
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5BA092).withOpacity(0.1),
                      foregroundColor: const Color(0xFF5BA092),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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

// --- 8. صفحة السلة الاحترافية (My Cart Page) ---
class MyCartPage extends StatefulWidget {
  final List<Map<String, String>> cartItems;
  final Map<String, dynamic> storeData;
  const MyCartPage({
    super.key,
    required this.cartItems,
    required this.storeData,
  });

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  final Map<String, int> quantities = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.cartItems) {
      quantities[item['title']!] = 1;
    }
  }

  double _calculateSubtotal() {
    double subtotal = 0;
    for (var item in widget.cartItems) {
      double price =
          double.tryParse(item['price']!.replaceAll(' JOD', '')) ?? 0;
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF5A3E2B),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Shopping Cart",
              style: TextStyle(
                color: Color(0xFF5A3E2B),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "${widget.cartItems.length} items",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                item['image']!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 80,
                                  height: 80,
                                  color: const Color(0xFFE0F2F1),
                                  child: const Icon(Icons.shopping_cart, size: 40, color: Color(0xFF5BA092)),
                                ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Center(
                                      child: CircularProgressIndicator(color: Color(0xFF5BA092)),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF5A3E2B),
                                    ),
                                  ),
                                  const Text(
                                    "PetSmart",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['price']!,
                                    style: const TextStyle(
                                      color: Color(0xFF3AA78E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _buildQtyBtn(Icons.remove, () {
                                  if (qty > 1) {
                                    setState(() => quantities[title] = qty - 1);
                                  }
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _buildQtyBtn(Icons.add, () {
                                  setState(() => quantities[title] = qty + 1);
                                }),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      widget.cartItems.removeAt(index);
                                      quantities.remove(title);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.red.shade100,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (widget.cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    "Subtotal",
                    "${subtotal.toStringAsFixed(2)} JOD",
                  ),
                  _buildSummaryRow(
                    "Delivery Fee",
                    "${deliveryFee.toStringAsFixed(2)} JOD",
                  ),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    "Total",
                    "${total.toStringAsFixed(2)} JOD",
                    isTotal: true,
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                            subtotal: subtotal,
                            deliveryFee: deliveryFee,
                            total: total,
                            storeData: widget.storeData,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5BA092),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.payment, color: Colors.white),
                      label: const Text(
                        "Proceed to Checkout",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF5BA092).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF5BA092)),
      ),
    );
  }

  Widget _buildSummaryRow(String l, String v, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          v,
          style: TextStyle(
            color: isTotal ? const Color(0xFF3AA78E) : Colors.black,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// --- 9. صفحة الـ Checkout ---

// --- 9. صفحة الـ Checkout المعدلة لربط العنوان ---
class CheckoutPage extends StatefulWidget {
  final double subtotal, deliveryFee, total;
  final Map<String, dynamic> storeData;

  const CheckoutPage({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.storeData,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool isCashOnDelivery = false;

  // تعريف المتحكمات (Controllers) لجلب البيانات من الحقول
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneCountryCodeController = TextEditingController(
    text: '+962',
  );
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController additionalDirectionsController =
      TextEditingController();
  @override
  void dispose() {
    // تنظيف المتحكمات عند إغلاق الصفحة للحفاظ على الذاكرة
    nameController.dispose();
    phoneCountryCodeController.dispose();
    phoneNumberController.dispose();
    cityController.dispose();
    streetController.dispose();
    buildingController.dispose();
    floorController.dispose();
    apartmentController.dispose();
    additionalDirectionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5A3E2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Checkout",
          style: TextStyle(
            color: Color(0xFF5A3E2B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionCard(
              child: ListTile(
                leading: const Icon(Icons.storefront, color: Color(0xFF5BA092)),
                title: Text(
                  widget.storeData['name'] ?? "Store",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${widget.storeData['location'] ?? "Irbid"} • 1.5 km away",
                ),
              ),
            ),
            const SizedBox(height: 16),

            // قسم العنوان مع ربط الـ Controllers
            _buildSectionCard(
              title: "Delivery Address",
              icon: Icons.home_outlined,
              child: Column(
                children: [
                  _field(
                    "Full Name",
                    "John Doe",
                    nameController,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel("Phone Number", isRequired: true),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: phoneCountryCodeController,
                              keyboardType: TextInputType.phone,
                              decoration: _addressInputDecoration('+962'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: _addressInputDecoration(
                                '7X XXX XXXX',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          "City",
                          "Irbid",
                          cityController,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          "Street",
                          "Abo rashed street",
                          streetController,
                          isRequired: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _field(
                    "Building",
                    "Building 15",
                    buildingController,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          "Floor",
                          "3",
                          floorController,
                          isOptional: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          "Apartment",
                          "302",
                          apartmentController,
                          isOptional: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _field(
                    "Additional Directions",
                    "Any helpful directions for delivery...",
                    additionalDirectionsController,
                    isOptional: true,
                    minLines: 2,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: "Payment Method",
              icon: Icons.payment_outlined,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isCashOnDelivery = false),
                    child: _buildPaymentOption(
                      "Credit / Debit Card",
                      Icons.credit_card,
                      isSelected: !isCashOnDelivery,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => setState(() => isCashOnDelivery = true),
                    child: _buildPaymentOption(
                      "Cash on Delivery",
                      Icons.money,
                      isSelected: isCashOnDelivery,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: "Order Summary",
              icon: Icons.assignment_outlined,
              child: Column(
                children: [
                  _summaryRow(
                    "Items",
                    "${widget.subtotal.toStringAsFixed(2)} JOD",
                  ),
                  _summaryRow(
                    "Delivery Fee",
                    "${widget.deliveryFee.toStringAsFixed(2)} JOD",
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${widget.total.toStringAsFixed(2)} JOD",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3AA78E),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // تجهيز نص العنوان المدخل
                  String fullAddress =
                      "${nameController.text}\nPhone: ${phoneCountryCodeController.text} ${phoneNumberController.text}\n${cityController.text}, ${streetController.text}\n${buildingController.text}\nFloor: ${floorController.text.isEmpty ? '-' : floorController.text} | Apartment: ${apartmentController.text.isEmpty ? '-' : apartmentController.text}\nNotes: ${additionalDirectionsController.text.isEmpty ? '-' : additionalDirectionsController.text}";

                  if (isCashOnDelivery) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessPage(
                          amount: widget.total,
                          orderID: "#ORD005",
                          userAddress: fullAddress, // تمرير العنوان
                        ),
                      ),
                    );
                  } else {
                    _showSecurePaymentSheet(context, fullAddress);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5BA092),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Place Order",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSecurePaymentSheet(BuildContext context, String address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF7FBFB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Stack(
          // استخدمنا Stack عشان زر الإغلاق (X) فوق
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 40,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // محاذاة لليسار زي الصورة
                children: [
                  // العنوان والأيقونة
                  Row(
                    children: const [
                      Icon(
                        Icons.lock_outline,
                        color: Color(0xFF5A3E2B),
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Secure Payment",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A3E2B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your card details to complete the payment",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // كادر السعر (الأخضر الفاتح)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F3),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF3AA78E).withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total to Pay",
                          style: TextStyle(
                            color: Color(0xFF5BA092),
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "53.00 JOD",
                          style: TextStyle(
                            color: const Color(0xFF3AA78E),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Select Card Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A3E2B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // أنواع البطاقات (الـ Row اللي فيه الصور)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCardTypeItem(
                        Icons.credit_card,
                        "VISA",
                        isSelected: true,
                      ),
                      _buildCardTypeItem(Icons.payment, "MASTER"),
                      _buildCardTypeItem(Icons.account_balance_wallet, "AMEX"),
                      _buildCardTypeItem(Icons.credit_score, "DISC"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // حقول الإدخال
                  _buildLabel("Card Number"),
                  _buildTextField("1234 5678 9012 3456"),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Expiry Date"),
                            _buildTextField("MM/YY"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("CVC"),
                            _buildTextField("123"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildLabel("Cardholder Name"),
                  _buildTextField("JOHN DOE"),

                  const SizedBox(height: 20),

                  // تنبيه الأمان (Encrypted)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Your payment information is encrypted and secure. We never store your card details.",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30), // عشان يدفع الأزرار لتحت
                  // الأزرار السفلية
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Color(0xFF5BA092)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Color(0xFF5BA092),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showOTPDialog(context, address);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5BA092),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Pay 53.00 JOD",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // زر الإغلاق (X)
            Positioned(
              right: 15,
              top: 15,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ميثودات مساعدة لتنظيف الكود:
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF5A3E2B),
        fontSize: 13,
      ),
    ),
  );

  Widget _buildTextField(String hint) => TextField(
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    ),
  );

  Widget _buildCardTypeItem(
    IconData icon,
    String label, {
    bool isSelected = false,
  }) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8F4F1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF5BA092) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF5A3E2B)),
          if (isSelected)
            const Icon(Icons.check_circle, size: 14, color: Color(0xFF5BA092)),
        ],
      ),
    );
  }

  void _showOTPDialog(BuildContext context, String address) {
    showDialog(
      context: context,
      barrierDismissible: false, // عشان ما يسكر إذا كبس برا
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FBFB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // العنوان وزر الإغلاق
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Bank Authorization",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A3E2B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Text(
                "Confirm your payment with the one-time password",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // أيقونة الحماية الزرقاء (زي الصورة)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2962FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // صندوق التنبيه الأزرق الفاتح
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBDEFB)),
                ),
                child: const Text(
                  "We've sent a one-time password (OTP) to your registered mobile number ending in ****12",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF1565C0), fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Enter 6-Digit OTP",
                style: TextStyle(
                  color: Color(0xFF5A3E2B),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),

              // حقل الـ OTP (تنسيق 000|000)
              TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "000 000",
                  hintStyle: const TextStyle(
                    letterSpacing: 8,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF5BA092)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF5BA092)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Demo Mode Card (الصندوق الأصفر)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDE7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFF59D)),
                ),
                child: Column(
                  children: const [
                    Text(
                      "Demo Mode: Your OTP is",
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "791470",
                      style: TextStyle(
                        color: Color(0xFF5A3E2B),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // الأزرار السفلية
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF5BA092)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Color(0xFF5A3E2B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuccessPage(
                              amount: widget.total,
                              orderID: "#ORD004",
                              userAddress: address,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFA5D6A7,
                        ), // لون باهت شوي زي الصورة
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Verify & Pay",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(
    String label, {
    bool isRequired = false,
    bool isOptional = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF5A3E2B),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired)
          const Text(
            " *",
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (isOptional)
          const Text(
            " (Optional)",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6E7B8F),
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  InputDecoration _addressInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFFBFDFF),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF5BA092)),
      ),
    );
  }

  // الميثود المعدلة لاستقبال الـ Controller
  Widget _field(
    String label,
    String hint,
    TextEditingController controller, {
    bool isRequired = false,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, isRequired: isRequired, isOptional: isOptional),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          decoration: _addressInputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    String? title,
    IconData? icon,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF5A3E2B)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        if (title != null) const SizedBox(height: 15),
        child,
      ],
    ),
  );
  Widget _buildPaymentOption(String l, IconData i, {bool isSelected = false}) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF5BA092) : Colors.grey.shade200,
          ),
          color: isSelected ? const Color(0xFFF4F9F8) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              i,
              size: 20,
              color: isSelected ? const Color(0xFF5BA092) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              l,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
  Widget _summaryRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: const TextStyle(color: Colors.grey)),
        Text(v),
      ],
    ),
  );
}

// --- صفحة النجاح المعدلة لتعرض عنوان المستخدم ---
class SuccessPage extends StatelessWidget {
  final double amount;
  final String orderID;
  final String userAddress; // المتغير الجديد

  const SuccessPage({
    super.key,
    required this.amount,
    required this.orderID,
    required this.userAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Order Placed Successfully!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A3E2B),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rowDetail("Order Number", orderID),
                    const Divider(height: 30),
                    _rowDetail(
                      "Total Amount",
                      "${amount.toStringAsFixed(2)} JOD",
                      isGreen: true,
                    ),
                    const Divider(height: 30),
                    const Text(
                      "Estimated Delivery",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(
                          Icons.local_shipping_outlined,
                          color: Color(0xFF5BA092),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text("Tomorrow, 2:00 PM"),
                      ],
                    ),
                    const Divider(height: 30),

                    // عرض عنوان المستخدم الديناميكي
                    const Text(
                      "Delivery Address",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userAddress.isEmpty ? "No address provided" : userAddress,
                      style: const TextStyle(
                        height: 1.5,
                        fontSize: 14,
                        color: Color(0xFF5A3E2B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 1. زر عرض الطلبات (View My Orders)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // ملاحظة: إذا ظل هناك خط أحمر، اضغطي Ctrl + . على MyOrdersPage
                    // واختاري الـ import الصحيح الذي يقترحه VS Code
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyOrdersPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history, color: Colors.white),
                  label: const Text(
                    "View My Orders",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5BA092),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 2. زر العودة للمتاجر (Continue Shopping)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SuppliesStore(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5BA092)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continue Shopping",
                    style: TextStyle(
                      color: Color(0xFF5BA092),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة الـ Row Detail المعدلة لتناسب التصميم
  Widget _rowDetail(String label, String value, {bool isGreen = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isGreen ? const Color(0xFF5BA092) : Colors.black,
        ),
      ),
    ],
  );
}
