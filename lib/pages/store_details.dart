import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';

class StoreDetails extends StatefulWidget {
  final Map<String, dynamic> storeData;
  const StoreDetails({super.key, required this.storeData});

  @override
  State<StoreDetails> createState() => _StoreDetailsState();
}

class _StoreDetailsState extends State<StoreDetails> {
  final DatabaseService _databaseService = DatabaseService();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'Popular';
  bool _showFilters = false;
  bool _onSaleOnly = false;
  String _priceRange = 'All';

  String get _storeId => (widget.storeData['id'] ?? '').toString();

  static const _teal = Color(0xFF4FA294);
  static const _bg = Color(0xFFEFFBFC);

  double _price(Map<String, dynamic> product) {
    return ((product['price'] as num?)?.toDouble() ?? 0);
  }

  List<Map<String, dynamic>> _visibleProducts(
    List<Map<String, dynamic>> products,
  ) {
    final list = products.where((product) {
      final price = _price(product);
      final inRange = switch (_priceRange) {
        'Under 20 JOD' => price < 20,
        '20-50 JOD' => price >= 20 && price <= 50,
        'Over 50 JOD' => price > 50,
        _ => true,
      };
      return inRange;
    }).toList();
    list.sort((a, b) {
      if (_selectedSort == 'Top Rated') {
        return (((b['ratingAvg'] as num?)?.toDouble() ?? 0)).compareTo(
          ((a['ratingAvg'] as num?)?.toDouble() ?? 0),
        );
      }
      if (_selectedSort == 'Price: Low to High') {
        return _price(a).compareTo(_price(b));
      }
      if (_selectedSort == 'Price: High to Low') {
        return _price(b).compareTo(_price(a));
      }
      return (((b['ratingCount'] as num?)?.toInt() ?? 0)).compareTo(
        ((a['ratingCount'] as num?)?.toInt() ?? 0),
      );
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      'Food',
      'Accessories',
      'Toys',
      'Health',
      'Grooming',
      'Treats',
      'Furniture',
      'Bedding',
      'Supplements',
    ];
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _StoreHero(storeData: widget.storeData)),
            SliverToBoxAdapter(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _databaseService.streamActivePetStoreOffers(_storeId),
                builder: (context, snapshot) {
                  final offers =
                      snapshot.data ?? const <Map<String, dynamic>>[];
                  if (offers.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                    child: Column(
                      children: offers
                          .take(2)
                          .map((offer) => _OfferBanner(offer: offer))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.blueGrey,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(color: Colors.teal.shade100),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(color: Colors.teal.shade100),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ActionChipButton(
                      icon: Icons.tune,
                      label: 'Filters',
                      selected: _showFilters,
                      onTap: () => setState(() => _showFilters = !_showFilters),
                    ),
                    _ActionChipButton(
                      icon: Icons.local_offer_outlined,
                      label: 'On Sale',
                      selected: _onSaleOnly,
                      onTap: () => setState(() => _onSaleOnly = !_onSaleOnly),
                    ),
                  ],
                ),
              ),
            ),
            if (_showFilters)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                  child: _FiltersPanel(
                    selectedSort: _selectedSort,
                    selectedCategory: _selectedCategory,
                    priceRange: _priceRange,
                    categories: categories,
                    onSortChanged: (value) =>
                        setState(() => _selectedSort = value),
                    onCategoryChanged: (value) =>
                        setState(() => _selectedCategory = value),
                    onPriceChanged: (value) =>
                        setState(() => _priceRange = value),
                  ),
                ),
              ),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _databaseService.streamStoreProducts(
                _storeId,
                searchQuery: _searchQuery,
                category: _selectedCategory,
                onSaleOnly: _onSaleOnly,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: _teal),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('Failed to load products.')),
                  );
                }
                final products = _visibleProducts(snapshot.data ?? []);
                if (products.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No products found.')),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = products[index];
                      return _ProductCard(
                        storeId: _storeId,
                        storeName: (widget.storeData['name'] ?? '').toString(),
                        product: product,
                        databaseService: _databaseService,
                        onViewDetails: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsPage(
                                storeId: _storeId,
                                storeName: (widget.storeData['name'] ?? '')
                                    .toString(),
                                product: product,
                              ),
                            ),
                          );
                        },
                        onAddToCart: () async {
                          await _databaseService.addOrUpdateCartItem(
                            storeId: _storeId,
                            productId: (product['id'] ?? '').toString(),
                            quantity: 1,
                            productSnapshot: product,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')),
                          );
                        },
                      );
                    }, childCount: products.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.67,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreHero extends StatelessWidget {
  const _StoreHero({required this.storeData});

  final Map<String, dynamic> storeData;

  static const _teal = Color(0xFF4FA294);
  static const _brown = Color(0xFF5A2F0E);

  String _value(String key, [String fallback = '']) {
    return (storeData[key] ?? fallback).toString();
  }

  String get _storeId => _value('id');

  @override
  Widget build(BuildContext context) {
    final service = DatabaseService();
    final name = _value('name', 'Pet Supplies Store');
    final image = _value('image');
    final rating = _value('rating', '0.0');
    final reviews = _value('reviews', '(0)');
    final categories =
        (storeData['categories'] as List?)?.cast<String>() ?? const <String>[];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Row(
                children: [
                  _SquareIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _brown,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: service.streamMyWishlist(),
                    builder: (context, snapshot) {
                      final count = (snapshot.data?.docs ?? [])
                          .where((doc) => doc.data()['itemType'] != 'store')
                          .length;
                      return _HeaderIconWithBadge(
                        icon: Icons.favorite_border,
                        color: _brown,
                        count: count,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyWishlistPage(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: service.streamMyCart(),
                    builder: (context, snapshot) {
                      final count =
                          snapshot.data?.docs.fold<int>(
                            0,
                            (total, doc) =>
                                total +
                                ((doc.data()['quantity'] as num?)?.toInt() ??
                                    1),
                          ) ??
                          0;
                      return _HeaderIconWithBadge(
                        icon: Icons.shopping_cart_outlined,
                        count: count,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyCartPage()),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: image.isEmpty
                  ? Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.blueGrey.shade50,
                      child: const Icon(
                        Icons.storefront,
                        size: 44,
                        color: _teal,
                      ),
                    )
                  : Image.network(
                      image,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: _brown,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => showDialog<void>(
                          context: context,
                          builder: (_) => _StoreReviewsDialog(
                            storeId: _storeId,
                            storeName: name,
                            databaseService: service,
                            rating: rating,
                            reviews: reviews,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '★ $rating $reviews',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _value('description', 'Complete pet supply store'),
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontSize: 12,
                    ),
                  ),
                  const Divider(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.location_on_outlined,
                          title: 'Distance',
                          value: _value('distance', 'Nearby'),
                        ),
                      ),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.access_time,
                          title: 'Hours',
                          value: _value('time', '9AM - 9PM'),
                          green: true,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 18),
                  const Text(
                    'Available Categories',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: categories
                        .map(
                          (category) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: _brown,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.near_me_outlined,
                        size: 16,
                        color: Colors.blueGrey.shade400,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _value('address', _value('location')),
                          style: TextStyle(
                            color: Colors.blueGrey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
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

class _ProductCard extends StatefulWidget {
  final String storeId;
  final String storeName;
  final Map<String, dynamic> product;
  final DatabaseService databaseService;
  final VoidCallback onViewDetails;
  final Future<void> Function() onAddToCart;

  const _ProductCard({
    required this.storeId,
    required this.storeName,
    required this.product,
    required this.databaseService,
    required this.onViewDetails,
    required this.onAddToCart,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool? _wishlistOverride;
  bool _wishlistBusy = false;

  Future<void> _toggleWishlist(bool currentValue) async {
    if (_wishlistBusy) return;
    final productId = (widget.product['id'] ?? '').toString();
    if (productId.isEmpty) return;
    setState(() {
      _wishlistBusy = true;
      _wishlistOverride = !currentValue;
    });
    try {
      await widget.databaseService.toggleWishlistItem(
        storeId: widget.storeId,
        productId: productId,
        productSnapshot: {
          ...widget.product,
          'storeName': widget.storeName,
          'image': widget.product['image'] ?? widget.product['imageUrl'],
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _wishlistOverride = currentValue);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _wishlistBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final title = (product['title'] ?? product['name'] ?? 'Product').toString();
    final price = ((product['price'] as num?)?.toDouble() ?? 0);
    final originalPrice = (product['originalPrice'] as num?)?.toDouble();
    final imageUrl = (product['image'] ?? product['imageUrl'] ?? '').toString();
    final rating = ((product['ratingAvg'] as num?)?.toDouble() ?? 0);
    final ratingCount = ((product['ratingCount'] as num?)?.toInt() ?? 0);
    final productId = (product['id'] ?? '').toString();
    final hasSale =
        product['hasSale'] == true ||
        (product['offer'] ?? '').toString().trim().isNotEmpty ||
        (originalPrice != null && originalPrice > price);
    final discount = originalPrice != null && originalPrice > price
        ? (((originalPrice - price) / originalPrice) * 100).round()
        : null;

    return InkWell(
      onTap: widget.onViewDetails,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: imageUrl.isEmpty
                        ? Container(
                            width: double.infinity,
                            color: Colors.blueGrey.shade50,
                            child: const Icon(
                              Icons.pets,
                              size: 42,
                              color: Color(0xFF4FA294),
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  if (hasSale)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          discount == null ? 'SALE' : '-$discount%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child:
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: widget.databaseService.streamWishlistItem(
                            productId,
                          ),
                          builder: (context, snapshot) {
                            final backendFavorite =
                                snapshot.data?.exists == true &&
                                snapshot.data?.data()?['itemType'] != 'store';
                            final isFavorite =
                                _wishlistOverride ?? backendFavorite;
                            return _WishlistHeartButton(
                              isFavorite: isFavorite,
                              onTap: () => _toggleWishlist(isFavorite),
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF5A2F0E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 3),
                      Text(
                        '${rating.toStringAsFixed(1)} ($ratingCount)',
                        style: TextStyle(
                          color: Colors.blueGrey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Text(
                        '${price.toStringAsFixed(0)} JOD',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (originalPrice != null && originalPrice > price)
                        Text(
                          '${originalPrice.toStringAsFixed(2)} JOD',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: widget.onAddToCart,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4FA294),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text('Add to Cart'),
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

class _WishlistHeartButton extends StatelessWidget {
  const _WishlistHeartButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.redAccent : Colors.blueGrey.shade400,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF5A2F0E),
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      shadowColor: Colors.teal.withValues(alpha: 0.22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(width: 46, height: 46, child: Icon(icon, color: color)),
      ),
    );
  }
}

class _HeaderIconWithBadge extends StatelessWidget {
  const _HeaderIconWithBadge({
    required this.icon,
    required this.onTap,
    this.count = 0,
    this.color = const Color(0xFF5A2F0E),
  });

  final IconData icon;
  final VoidCallback onTap;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _SquareIconButton(icon: icon, color: color, onTap: onTap),
        if (count > 0)
          Positioned(
            right: -6,
            top: -8,
            child: CircleAvatar(
              radius: 11,
              backgroundColor: Colors.redAccent,
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.green = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool green;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: green ? Colors.green.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            icon,
            size: 18,
            color: green ? Colors.green : Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 11),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF5A2F0E),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OfferBanner extends StatelessWidget {
  const _OfferBanner({required this.offer});

  final Map<String, dynamic> offer;

  @override
  Widget build(BuildContext context) {
    final title = (offer['title'] ?? 'Store offer').toString();
    final description = (offer['description'] ?? '').toString();
    final validUntil = (offer['validUntilText'] ?? '').toString();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.percent, color: Colors.deepOrange.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF5A2F0E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      description,
                      style: TextStyle(color: Colors.deepOrange.shade700),
                    ),
                  ),
                if (validUntil.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Valid until $validUntil',
                      style: TextStyle(color: Colors.deepOrange.shade700),
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

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE5F7F4) : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? const Color(0xFF4FA294) : Colors.teal.shade100,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: const Color(0xFF5A2F0E)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5A2F0E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({
    required this.selectedSort,
    required this.selectedCategory,
    required this.priceRange,
    required this.categories,
    required this.onSortChanged,
    required this.onCategoryChanged,
    required this.onPriceChanged,
  });

  final String selectedSort;
  final String selectedCategory;
  final String priceRange;
  final List<String> categories;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onPriceChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('Sort By'),
          _chips(
            [
              'Popular',
              'Top Rated',
              'Price: Low to High',
              'Price: High to Low',
            ],
            selectedSort,
            onSortChanged,
          ),
          const SizedBox(height: 14),
          _section('Category'),
          _chips(categories, selectedCategory, onCategoryChanged),
          const SizedBox(height: 14),
          _section('Price Range'),
          _chips(
            ['All', 'Under 20 JOD', '20-50 JOD', 'Over 50 JOD'],
            priceRange,
            onPriceChanged,
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF5A2F0E),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _chips(
    List<String> values,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        final active = value == selected;
        return ChoiceChip(
          selected: active,
          label: Text(value),
          onSelected: (_) => onChanged(value),
          selectedColor: const Color(0xFF4FA294),
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.teal.shade100),
          labelStyle: TextStyle(
            color: active ? Colors.white : const Color(0xFF5A2F0E),
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }
}

class _StoreReviewsDialog extends StatelessWidget {
  const _StoreReviewsDialog({
    required this.storeId,
    required this.storeName,
    required this.databaseService,
    required this.rating,
    required this.reviews,
  });

  final String storeId;
  final String storeName;
  final DatabaseService databaseService;
  final String rating;
  final String reviews;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFEFFBFC),
      insetPadding: const EdgeInsets.all(26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                'Store Reviews',
                style: const TextStyle(
                  color: Color(0xFF5A2F0E),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'See what customers are saying about $storeName',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey.shade700),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      rating,
                      style: const TextStyle(
                        color: Color(0xFF5A2F0E),
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Based on $reviews customer ratings',
                        style: TextStyle(color: Colors.blueGrey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: databaseService.streamStoreReviews(storeId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4FA294),
                        ),
                      );
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No reviews yet.'));
                    }
                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        final name = (data['customerName'] ?? 'Customer')
                            .toString();
                        final comment = (data['comment'] ?? '').toString();
                        final stars = ((data['stars'] as num?)?.toInt() ?? 0);
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.teal.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF4FA294),
                                    child: Text(
                                      name.isEmpty
                                          ? '?'
                                          : name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        color: Color(0xFF5A2F0E),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < stars ? Icons.star : Icons.star_border,
                                    color: Colors.amber.shade700,
                                    size: 18,
                                  ),
                                ),
                              ),
                              if (comment.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  comment,
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductDetailsPage extends StatefulWidget {
  final String storeId;
  final String storeName;
  final Map<String, dynamic> product;
  const ProductDetailsPage({
    super.key,
    required this.storeId,
    required this.product,
    this.storeName = '',
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final DatabaseService _databaseService = DatabaseService();
  int _quantity = 1;
  bool? _wishlistOverride;
  bool _wishlistBusy = false;

  static const _teal = Color(0xFF4FA294);
  static const _bg = Color(0xFFEFFBFC);
  static const _brown = Color(0xFF5A2F0E);

  String get _productId => (widget.product['id'] ?? '').toString();

  Future<void> _toggleWishlist(bool currentValue) async {
    if (_wishlistBusy || _productId.isEmpty) return;
    setState(() {
      _wishlistBusy = true;
      _wishlistOverride = !currentValue;
    });
    try {
      await _databaseService.toggleWishlistItem(
        storeId: widget.storeId,
        productId: _productId,
        productSnapshot: {
          ...widget.product,
          'storeName': widget.storeName,
          'image': widget.product['image'] ?? widget.product['imageUrl'],
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _wishlistOverride = currentValue);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _wishlistBusy = false);
    }
  }

  Future<void> _addCurrentToCart(Map<String, dynamic> product) async {
    try {
      await _databaseService.addOrUpdateCartItem(
        storeId: widget.storeId,
        productId: _productId,
        quantity: _quantity,
        productSnapshot: {
          ...product,
          'storeName': widget.storeName,
          'title': product['title'] ?? product['name'],
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to cart')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _databaseService.streamProductById(_productId),
          builder: (context, snapshot) {
            // Merge live data over fallback so the UI keeps working even before
            // the first snapshot resolves (or if the doc was deleted).
            final liveData = snapshot.data?.data();
            final product = <String, dynamic>{
              ...widget.product,
              if (liveData != null) ...liveData,
              'id': _productId,
            };
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildProductCard(product)),
                SliverToBoxAdapter(child: _buildQuantityAndAdd(product)),
                SliverToBoxAdapter(child: _buildRelatedTitle()),
                _buildRelatedGrid(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Row(
        children: [
          _SquareIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Product Details',
              style: TextStyle(
                color: _brown,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _databaseService.streamMyWishlist(),
            builder: (context, snapshot) {
              final count = (snapshot.data?.docs ?? [])
                  .where((doc) => doc.data()['itemType'] != 'store')
                  .length;
              return _HeaderIconWithBadge(
                icon: Icons.favorite_border,
                count: count,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyWishlistPage()),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _databaseService.streamMyCart(),
            builder: (context, snapshot) {
              final count =
                  snapshot.data?.docs.fold<int>(
                    0,
                    (total, doc) =>
                        total +
                        ((doc.data()['quantity'] as num?)?.toInt() ?? 1),
                  ) ??
                  0;
              return _HeaderIconWithBadge(
                icon: Icons.shopping_cart_outlined,
                count: count,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyCartPage()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final imageUrl = (product['image'] ?? product['imageUrl'] ?? '').toString();
    final title = (product['title'] ?? product['name'] ?? 'Product').toString();
    final brand = (product['brand'] ?? '').toString();
    final description = (product['description'] ?? '').toString();
    final price = ((product['price'] as num?)?.toDouble() ?? 0);
    final originalPrice = (product['originalPrice'] as num?)?.toDouble();
    final rating = ((product['ratingAvg'] as num?)?.toDouble() ?? 0);
    final ratingCount = ((product['ratingCount'] as num?)?.toInt() ?? 0);
    final stock = ((product['stock'] as num?)?.toInt() ?? 0);
    final category = (product['category'] ?? '').toString();
    final offer = (product['offer'] ?? '').toString();
    final hasSale =
        product['hasSale'] == true ||
        offer.trim().isNotEmpty ||
        (originalPrice != null && originalPrice > price);
    final discount = originalPrice != null && originalPrice > price
        ? (((originalPrice - price) / originalPrice) * 100).round()
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrl.isEmpty
                          ? Container(
                              color: Colors.blueGrey.shade50,
                              child: const Icon(
                                Icons.pets,
                                size: 70,
                                color: _teal,
                              ),
                            )
                          : Image.network(imageUrl, fit: BoxFit.cover),
                    ),
                    if (hasSale)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            discount == null ? 'SALE' : '-$discount%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child:
                          StreamBuilder<
                            DocumentSnapshot<Map<String, dynamic>>
                          >(
                            stream: _databaseService.streamWishlistItem(
                              _productId,
                            ),
                            builder: (context, snapshot) {
                              final backendFavorite =
                                  snapshot.data?.exists == true &&
                                  snapshot.data?.data()?['itemType'] != 'store';
                              final isFavorite =
                                  _wishlistOverride ?? backendFavorite;
                              return _WishlistHeartButton(
                                isFavorite: isFavorite,
                                onTap: () => _toggleWishlist(isFavorite),
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _brown,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (brand.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      brand,
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (widget.storeName.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          size: 14,
                          color: _teal,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            widget.storeName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _teal,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 17),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(1)} ($ratingCount)',
                        style: TextStyle(
                          color: Colors.blueGrey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (category.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: _brown,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${price.toStringAsFixed(2)} JOD',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (originalPrice != null && originalPrice > price) ...[
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '${originalPrice.toStringAsFixed(2)} JOD',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        stock > 0 ? 'In Stock ($stock)' : 'Out of Stock',
                        style: TextStyle(
                          color: stock > 0
                              ? Colors.green.shade700
                              : Colors.redAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (offer.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            size: 16,
                            color: Colors.deepOrange.shade700,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              offer,
                              style: TextStyle(
                                color: Colors.deepOrange.shade800,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (description.isNotEmpty) ...[
                    const Divider(height: 22),
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: _brown,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.blueGrey.shade800,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityAndAdd(Map<String, dynamic> product) {
    final stock = ((product['stock'] as num?)?.toInt() ?? 0);
    final outOfStock = stock <= 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.teal.shade100),
        ),
        child: Row(
          children: [
            _QuantityButton(
              icon: Icons.remove,
              onTap: _quantity > 1
                  ? () => setState(() => _quantity--)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '$_quantity',
                style: const TextStyle(
                  color: _brown,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _QuantityButton(
              icon: Icons.add,
              onTap: (stock == 0 || _quantity < stock)
                  ? () => setState(() => _quantity++)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: outOfStock
                      ? null
                      : () => _addCurrentToCart(product),
                  style: FilledButton.styleFrom(
                    backgroundColor: _teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: Text(
                    outOfStock ? 'Out of Stock' : 'Add to Cart',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(22, 4, 22, 10),
      child: Text(
        'More from this store',
        style: TextStyle(
          color: _brown,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildRelatedGrid() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _databaseService.streamStoreProducts(widget.storeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator(color: _teal)),
            ),
          );
        }
        final all = snapshot.data ?? const <Map<String, dynamic>>[];
        final others = all
            .where((p) => (p['id'] ?? '').toString() != _productId)
            .toList();
        if (others.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(22, 0, 22, 22),
              child: Text(
                'No other products from this store yet.',
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final other = others[index];
                return _ProductCard(
                  storeId: widget.storeId,
                  storeName: widget.storeName,
                  product: other,
                  databaseService: _databaseService,
                  onViewDetails: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(
                          storeId: widget.storeId,
                          storeName: widget.storeName,
                          product: other,
                        ),
                      ),
                    );
                  },
                  onAddToCart: () async {
                    await _databaseService.addOrUpdateCartItem(
                      storeId: widget.storeId,
                      productId: (other['id'] ?? '').toString(),
                      quantity: 1,
                      productSnapshot: {
                        ...other,
                        'storeName': widget.storeName,
                      },
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart')),
                    );
                  },
                );
              },
              childCount: others.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 16,
              childAspectRatio: 0.67,
            ),
          ),
        );
      },
    );
  }
}

class MyWishlistPage extends StatelessWidget {
  const MyWishlistPage({super.key});

  static const _bg = Color(0xFFEFFBFC);
  static const _teal = Color(0xFF4FA294);
  static const _brown = Color(0xFF5A2F0E);

  Future<void> _addToCart(
    BuildContext context,
    DatabaseService service,
    Map<String, dynamic> item,
  ) async {
    await service.addOrUpdateCartItem(
      storeId: (item['storeId'] ?? '').toString(),
      productId: (item['productId'] ?? item['id'] ?? '').toString(),
      quantity: 1,
      productSnapshot: item,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added to cart')));
  }

  Future<void> _addAllToCart(
    BuildContext context,
    DatabaseService service,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    for (final doc in docs) {
      await service.addOrUpdateCartItem(
        storeId: (doc.data()['storeId'] ?? '').toString(),
        productId: (doc.data()['productId'] ?? doc.id).toString(),
        quantity: 1,
        productSnapshot: doc.data(),
      );
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Wishlist added to cart')));
  }

  @override
  Widget build(BuildContext context) {
    final service = DatabaseService();
    return Scaffold(
      backgroundColor: _bg,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.streamMyWishlist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _teal));
          }
          final docs = (snapshot.data?.docs ?? [])
              .where((doc) => doc.data()['itemType'] != 'store')
              .toList();
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
                  child: Row(
                    children: [
                      _SquareIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Wishlist',
                            style: TextStyle(
                              color: _brown,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${docs.length} items',
                            style: TextStyle(color: Colors.blueGrey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.teal.shade100),
                if (docs.isEmpty)
                  Expanded(child: _WishlistEmptyState())
                else ...[
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(22),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final item = docs[index].data();
                        return _WishlistProductCard(
                          item: item,
                          onRemove: () => service.removeWishlistItem(
                            (item['productId'] ?? docs[index].id).toString(),
                          ),
                          onAddToCart: () => _addToCart(context, service, item),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: () => _addAllToCart(context, service, docs),
                        style: FilledButton.styleFrom(
                          backgroundColor: _teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: Text('Add All to Cart (${docs.length} items)'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WishlistEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.teal.shade100),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Your wishlist is empty',
              style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 18),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4FA294),
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
              ),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistProductCard extends StatelessWidget {
  const _WishlistProductCard({
    required this.item,
    required this.onRemove,
    required this.onAddToCart,
  });

  final Map<String, dynamic> item;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final title = (item['title'] ?? 'Product').toString();
    final brand = (item['brand'] ?? '').toString();
    final storeName = (item['storeName'] ?? '').toString();
    final image = (item['image'] ?? '').toString();
    final price = ((item['price'] as num?)?.toDouble() ?? 0);
    final rating = ((item['ratingAvg'] as num?)?.toDouble() ?? 0);
    final ratingCount = ((item['ratingCount'] as num?)?.toInt() ?? 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                    top: Radius.circular(14),
                  ),
                  child: image.isEmpty
                      ? Container(
                          width: double.infinity,
                          color: Colors.blueGrey.shade50,
                          child: const Icon(
                            Icons.pets,
                            color: Color(0xFF4FA294),
                            size: 42,
                          ),
                        )
                      : Image.network(
                          image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _WishlistHeartButton(
                    isFavorite: true,
                    onTap: onRemove,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5A2F0E),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                if (brand.isNotEmpty)
                  Text(
                    brand,
                    style: TextStyle(
                      color: Colors.blueGrey.shade600,
                      fontSize: 12,
                    ),
                  ),
                if (storeName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        size: 14,
                        color: Color(0xFF4FA294),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          storeName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF4FA294),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                    const SizedBox(width: 3),
                    Text(
                      '${rating.toStringAsFixed(1)} ($ratingCount)',
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${price.toStringAsFixed(0)} JOD',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    _SquareIconButton(
                      icon: Icons.shopping_cart_outlined,
                      onTap: onAddToCart,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyCartPage extends StatefulWidget {
  const MyCartPage({super.key});

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  final DatabaseService _databaseService = DatabaseService();

  double _cartTotal(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.fold(
      0,
      (runningTotal, doc) =>
          runningTotal +
          (((doc.data()['price'] as num?)?.toDouble() ?? 0) *
              ((doc.data()['quantity'] as num?)?.toInt() ?? 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _databaseService.streamMyCart(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load cart.'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('Cart is empty.'));
          final subtotal = _cartTotal(docs);
          final deliveryFee = docs.isEmpty ? 0.0 : 5.0;
          final total = subtotal + deliveryFee;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final item = docs[index].data();
                    final qty = ((item['quantity'] as num?)?.toInt() ?? 1);
                    final productId = (item['productId'] ?? docs[index].id)
                        .toString();
                    return _CartProductCard(
                      item: item,
                      quantity: qty,
                      onDecrease: qty <= 1
                          ? null
                          : () => _databaseService.addOrUpdateCartItem(
                              storeId: (item['storeId'] ?? '').toString(),
                              productId: productId,
                              quantity: qty - 1,
                              productSnapshot: item,
                            ),
                      onIncrease: () => _databaseService.addOrUpdateCartItem(
                        storeId: (item['storeId'] ?? '').toString(),
                        productId: productId,
                        quantity: qty + 1,
                        productSnapshot: item,
                      ),
                      onRemove: () =>
                          _databaseService.removeCartItem(productId),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.teal.shade100),
                  ),
                  child: Column(
                    children: [
                      _cartSummaryRow('Subtotal', subtotal),
                      const SizedBox(height: 10),
                      _cartSummaryRow('Delivery Fee', deliveryFee),
                      Divider(height: 22, color: Colors.teal.shade100),
                      _cartSummaryRow('Total', total, bold: true),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutPage(
                                  cartDocs: docs,
                                  subtotal: subtotal,
                                ),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF4FA294),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          icon: const Icon(Icons.credit_card),
                          label: const Text('Proceed to Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cartSummaryRow(String label, double amount, {bool bold = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF5A2F0E),
            fontSize: bold ? 17 : 16,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          '${amount.toStringAsFixed(2)} JOD',
          style: TextStyle(
            color: bold ? Colors.green : const Color(0xFF5A2F0E),
            fontSize: bold ? 17 : 16,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _CartProductCard extends StatelessWidget {
  const _CartProductCard({
    required this.item,
    required this.quantity,
    required this.onIncrease,
    required this.onRemove,
    this.onDecrease,
  });

  final Map<String, dynamic> item;
  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final title = (item['title'] ?? 'Product').toString();
    final brand = (item['brand'] ?? '').toString();
    final image = (item['image'] ?? '').toString();
    final price = ((item['price'] as num?)?.toDouble() ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: image.isEmpty
                ? Container(
                    width: 100,
                    height: 100,
                    color: Colors.blueGrey.shade50,
                    child: const Icon(
                      Icons.pets,
                      color: Color(0xFF4FA294),
                      size: 34,
                    ),
                  )
                : Image.network(
                    image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5A2F0E),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                if (brand.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    brand,
                    style: TextStyle(color: Colors.blueGrey.shade600),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  '${price.toStringAsFixed(0)} JOD',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuantityButton(icon: Icons.remove, onTap: onDecrease),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    color: Color(0xFF5A2F0E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _QuantityButton(icon: Icons.add, onTap: onIncrease),
              const SizedBox(width: 8),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                elevation: 1,
                child: IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.teal.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withValues(alpha: 0.14),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF5A2F0E)),
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> cartDocs;
  final double subtotal;
  const CheckoutPage({
    super.key,
    required this.cartDocs,
    required this.subtotal,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final DatabaseService _databaseService = DatabaseService();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  String _paymentMethod = 'cash';
  bool _loading = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryFee = widget.cartDocs.isEmpty ? 0.0 : 5.0;
    final total = widget.subtotal + deliveryFee;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _cityCtrl,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'credit', child: Text('Credit Card')),
              ],
              onChanged: (value) =>
                  setState(() => _paymentMethod = value ?? 'cash'),
              decoration: const InputDecoration(labelText: 'Payment Method'),
            ),
            const SizedBox(height: 16),
            _row('Subtotal', widget.subtotal),
            _row('Delivery', deliveryFee),
            _row('Total', total, bold: true),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _placeOrder,
                child: _loading
                    ? const CircularProgressIndicator()
                    : Text('Place Order (${total.toStringAsFixed(2)} JOD)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, double amount, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 17 : 15,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(title, style: style),
          const Spacer(),
          Text('${amount.toStringAsFixed(2)} JOD', style: style),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    final address = _addressCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    if (address.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please complete address.')));
      return;
    }
    final storeIds = widget.cartDocs
        .map((doc) => (doc.data()['storeId'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
    if (storeIds.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout supports one store per order.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final items = widget.cartDocs.map((doc) {
        final data = doc.data();
        return {
          'productId': (data['productId'] ?? doc.id).toString(),
          'title': (data['title'] ?? '').toString(),
          'price': ((data['price'] as num?)?.toDouble() ?? 0),
          'quantity': ((data['quantity'] as num?)?.toInt() ?? 1),
          'image': (data['image'] ?? '').toString(),
        };
      }).toList();

      await _databaseService.setOrder(
        storeId: storeIds.first,
        items: items,
        deliveryAddress: {'address': address, 'city': city},
        paymentMethod: _paymentMethod,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SuccessPage()),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 84, color: Colors.green),
              const SizedBox(height: 12),
              const Text(
                'Order placed successfully',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your order has been saved and your cart was cleared.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
