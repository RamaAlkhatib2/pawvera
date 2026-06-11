import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/database_service.dart';
import 'buyer_cart_page.dart' show CartQuantityButton, MyCartPage;
import 'buyer_my_orders_page.dart';
import 'supplies_store.dart';
import '../widgets/secure_payment_dialog.dart';

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

/// Firestore user docs may use [image], [storeImageUrl], or legacy keys.
String petStoreBannerImageUrl(Map<String, dynamic> m) {
  for (final key in ['image', 'storeImageUrl', 'storeImage', 'photoUrl']) {
    final s = (m[key] ?? '').toString().trim();
    if (s.isNotEmpty) return s;
  }
  return '';
}

/// Displays a Firebase Storage URL or a base64 data-URI image.
Widget _flexImage(
  String url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? placeholder,
}) {
  final fallback = placeholder ?? const SizedBox.shrink();
  if (url.startsWith('data:')) {
    try {
      final bytes = base64Decode(url.substring(url.indexOf(',') + 1));
      return Image.memory(bytes, width: width, height: height, fit: fit,
          errorBuilder: (_, e, s) => fallback);
    } catch (_) {
      return fallback;
    }
  }
  return Image.network(url, width: width, height: height, fit: fit,
      errorBuilder: (_, e, s) => fallback);
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
    final image = petStoreBannerImageUrl(storeData);
    final fallbackRating = _value('rating', '0.0');
    final fallbackReviews = _value('reviews', '(0)');
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
                  : _flexImage(
                      image,
                      height: 120,
                      width: double.infinity,
                      placeholder: Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.blueGrey.shade50,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 40,
                          color: _teal,
                        ),
                      ),
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
                          ),
                        ),
                        child: _storeId.trim().isEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  '★ $fallbackRating $fallbackReviews',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                                key: ValueKey<String>('store_hero_rating_$_storeId'),
                                stream:
                                    service.streamStoreReviews(_storeId),
                                builder: (context, snap) {
                                  var label =
                                      '★ $fallbackRating $fallbackReviews';
                                  if (snap.connectionState ==
                                      ConnectionState.waiting) {
                                    label = '★ …';
                                  } else if (!snap.hasError &&
                                      snap.hasData) {
                                    final raw = snap.data?.docs ?? [];
                                    final docs = raw
                                        .where(
                                          (d) => _storeReviewDocIsStore(
                                            d.data(),
                                          ),
                                        )
                                        .toList();
                                    final avg =
                                        _averageRatingFromStoreReviewDocs(
                                      docs,
                                    );
                                    final n = docs.length;
                                    label =
                                        '★ ${avg.toStringAsFixed(1)} ($n)';
                                  }
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
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
                        : _flexImage(
                            imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: Container(
                              color: Colors.blueGrey.shade50,
                              child: const Icon(Icons.pets,
                                  size: 42, color: Color(0xFF4FA294)),
                            ),
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

bool _storeReviewDocIsStore(Map<String, dynamic> m) {
  final t = (m['type'] ?? '').toString();
  if (t == 'product') return false;
  if (t == 'store') return true;
  return (m['productId'] ?? '').toString().trim().isEmpty;
}

double _averageRatingFromStoreReviewDocs(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) {
  if (docs.isEmpty) return 0;
  var sum = 0.0;
  for (final d in docs) {
    final m = d.data();
    final raw = m['stars'] ?? m['rating'] ?? m['star'];
    sum += ((raw as num?)?.toDouble() ?? 0).clamp(0, 5);
  }
  return sum / docs.length;
}

List<Widget> _averageStarRow(double avg, {double size = 22}) {
  final out = <Widget>[];
  for (var i = 0; i < 5; i++) {
    final threshold = i + 1.0;
    IconData icon;
    Color color;
    if (avg >= threshold - 1e-6) {
      icon = Icons.star_rounded;
      color = Colors.amber.shade700;
    } else if (avg >= threshold - 0.5) {
      icon = Icons.star_half_rounded;
      color = Colors.amber.shade700;
    } else {
      icon = Icons.star_outline_rounded;
      color = Colors.grey.shade400;
    }
    out.add(Icon(icon, color: color, size: size));
  }
  return out;
}

String _formatReviewDate(dynamic createdAt) {
  if (createdAt is Timestamp) {
    final d = createdAt.toDate();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
  return '';
}

class _StoreReviewsDialog extends StatelessWidget {
  const _StoreReviewsDialog({
    required this.storeId,
    required this.storeName,
    required this.databaseService,
  });

  final String storeId;
  final String storeName;
  final DatabaseService databaseService;

  static const _mintBg = Color(0xFFF0F9F9);
  static const _brown = Color(0xFF5A2F0E);
  static const _teal = Color(0xFF4FA294);

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.78;
    return Dialog(
      backgroundColor: _mintBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 520,
        height: maxH.clamp(420.0, 640.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Text(
              'Store Reviews',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.brown.shade900,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'See what customers are saying about $storeName',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueGrey.shade700,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: databaseService.streamStoreReviews(storeId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _teal),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Could not load reviews.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                    );
                  }
                  final raw = snapshot.data?.docs ?? [];
                  final docs = raw
                      .where((d) => _storeReviewDocIsStore(d.data()))
                      .toList()
                    ..sort((a, b) {
                      final ta = a.data()['createdAt'];
                      final tb = b.data()['createdAt'];
                      if (ta is Timestamp && tb is Timestamp) {
                        return tb.compareTo(ta);
                      }
                      if (ta is Timestamp) return -1;
                      if (tb is Timestamp) return 1;
                      return 0;
                    });

                  final avg = _averageRatingFromStoreReviewDocs(docs);
                  final count = docs.length;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      avg.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: Colors.brown.shade900,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(children: _averageStarRow(avg)),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$count rating${count == 1 ? '' : 's'}',
                                      style: TextStyle(
                                        color: Colors.blueGrey.shade600,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Based on $count customer ${count == 1 ? 'review' : 'reviews'}',
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade700,
                                      fontSize: 15,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (docs.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                'No reviews yet.',
                                style: TextStyle(color: Colors.blueGrey.shade600),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: docs.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final data = docs[index].data();
                                final name =
                                    (data['customerName'] ?? 'Customer')
                                        .toString()
                                        .trim();
                                final displayName =
                                    name.isEmpty ? 'Customer' : name;
                                final comment =
                                    (data['comment'] ?? '').toString().trim();
                                final stars =
                                    ((data['stars'] as num?)?.toInt() ?? 0)
                                        .clamp(0, 5);
                                final verified = (data['orderId'] ?? '')
                                    .toString()
                                    .trim()
                                    .isNotEmpty;
                                final dateStr =
                                    _formatReviewDate(data['createdAt']);
                                final initial = displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
                                    : '?';

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: _teal,
                                            child: Text(
                                              initial,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Wrap(
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .center,
                                                        spacing: 8,
                                                        runSpacing: 6,
                                                        children: [
                                                          Text(
                                                            displayName,
                                                            style:
                                                                const TextStyle(
                                                              color: _brown,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          if (verified)
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 8,
                                                                vertical: 3,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .green
                                                                    .shade50,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                border: Border.all(
                                                                  color: Colors
                                                                      .green
                                                                      .shade600,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .verified_rounded,
                                                                    size: 14,
                                                                    color: Colors
                                                                        .green
                                                                        .shade700,
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 4),
                                                                  Text(
                                                                    'Verified',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .green
                                                                          .shade800,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (dateStr.isNotEmpty)
                                                      Text(
                                                        dateStr,
                                                        style: TextStyle(
                                                          color: Colors
                                                              .blueGrey
                                                              .shade600,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            i < stars
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            color: Colors.amber.shade700,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      if (comment.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        Text(
                                          comment,
                                          style: TextStyle(
                                            color: Colors.blueGrey.shade800,
                                            fontSize: 14,
                                            height: 1.45,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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
                          : _flexImage(imageUrl,
                              placeholder: Container(
                                color: Colors.blueGrey.shade50,
                                child: const Icon(Icons.pets,
                                    size: 70, color: _teal),
                              )),
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
            CartQuantityButton(
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
            CartQuantityButton(
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
                    if (!context.mounted) return;
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
                      : _flexImage(
                          image,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: Container(
                            width: double.infinity,
                            color: Colors.blueGrey.shade50,
                            child: const Icon(
                              Icons.pets,
                              color: Color(0xFF4FA294),
                              size: 42,
                            ),
                          ),
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
  static const _bg = Color(0xFFF0F9F9);
  static const _brown = Color(0xFF5D4037);
  static const _teal = Color(0xFF4FA294);

  final DatabaseService _databaseService = DatabaseService();
  final _fullNameCtrl = TextEditingController();
  final _countryCodeCtrl = TextEditingController(text: '+962');
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _aptCtrl = TextEditingController();
  final _directionsCtrl = TextEditingController();

  String _paymentMethod = 'credit';
  bool _loading = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _countryCodeCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _streetCtrl.dispose();
    _buildingCtrl.dispose();
    _floorCtrl.dispose();
    _aptCtrl.dispose();
    _directionsCtrl.dispose();
    super.dispose();
  }

  int get _itemCount => widget.cartDocs.fold<int>(
        0,
        (a, d) => a + ((d.data()['quantity'] as num?)?.toInt() ?? 1),
      );

  InputDecoration _fieldDec({
    required String label,
    String? hint,
    bool requiredField = false,
  }) {
    return InputDecoration(
      label: Text.rich(
        TextSpan(
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          children: [
            TextSpan(text: label),
            if (requiredField)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _teal, width: 1.4),
      ),
    );
  }

  InputDecoration _directionsDec() {
    return InputDecoration(
      hintText: 'Any helpful directions for delivery...',
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _teal, width: 1.4),
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveryFee = widget.cartDocs.isEmpty ? 0.0 : 5.0;
    final total = widget.subtotal + deliveryFee;
    final storeIds = widget.cartDocs
        .map((doc) => (doc.data()['storeId'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
    final storeId = storeIds.length == 1 ? storeIds.first : '';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: _brown,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (storeId.isNotEmpty)
            FutureBuilder<Map<String, dynamic>>(
              future:
                  _databaseService.fetchPetStorePublicForCheckout(storeId),
              builder: (context, snap) {
                final name = (snap.data?['name'] ?? 'Store').toString();
                final loc = (snap.data?['location'] ?? '').toString().trim();
                return _whiteCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.storefront_outlined,
                          color: Colors.blue.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: _brown,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            if (loc.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      loc,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          _whiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.home_outlined, color: _teal, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        color: _brown,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _fullNameCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: _fieldDec(
                    label: 'Full Name',
                    hint: 'John Doe',
                    requiredField: true,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 92,
                      child: TextField(
                        controller: _countryCodeCtrl,
                        keyboardType: TextInputType.text,
                        decoration: _fieldDec(
                          label: 'Code',
                          hint: '+962',
                          requiredField: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _fieldDec(
                          label: 'Phone Number',
                          hint: '7X XXX XXXX',
                          requiredField: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityCtrl,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: _fieldDec(
                          label: 'City',
                          hint: 'Irbid',
                          requiredField: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _streetCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDec(
                          label: 'Street',
                          hint: 'Abo rashed street',
                          requiredField: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _buildingCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDec(
                    label: 'Building',
                    hint: 'Building 15',
                    requiredField: true,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _floorCtrl,
                        keyboardType: TextInputType.text,
                        decoration: _fieldDec(
                          label: 'Floor',
                          hint: '3',
                          requiredField: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _aptCtrl,
                        decoration: _fieldDec(
                          label: 'Apartment',
                          hint: '302',
                          requiredField: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _whiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notes_outlined, color: _teal, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Delivery Instructions',
                      style: TextStyle(
                        color: _brown,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Optional',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _directionsCtrl,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: _directionsDec().copyWith(counterText: ''),
                ),
              ],
            ),
          ),
          _whiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.credit_card, color: _teal, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        color: _brown,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _CheckoutPaymentOption(
                  selected: _paymentMethod == 'credit',
                  title: 'Credit / Debit Card',
                  icon: Icons.credit_card_outlined,
                  onTap: () => setState(() => _paymentMethod = 'credit'),
                ),
                const SizedBox(height: 10),
                _CheckoutPaymentOption(
                  selected: _paymentMethod == 'cash',
                  title: 'Cash on Delivery',
                  icon: Icons.payments_outlined,
                  onTap: () => setState(() => _paymentMethod = 'cash'),
                ),
              ],
            ),
          ),
          _whiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, color: _teal, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        color: _brown,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _summaryLine('Items ($_itemCount)', widget.subtotal),
                const SizedBox(height: 8),
                _summaryLine('Delivery Fee', deliveryFee),
                Divider(height: 22, color: Colors.teal.shade100),
                Row(
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        color: _brown,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${total.toStringAsFixed(2)} JOD',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _loading ? null : _placeOrder,
              style: FilledButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                _loading ? 'Placing order…' : 'Place Order',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(String label, double amount) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.brown.shade700,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '${amount.toStringAsFixed(2)} JOD',
          style: const TextStyle(
            color: _brown,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Future<void> _placeOrder() async {
    final fullName = _fullNameCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final street = _streetCtrl.text.trim();
    final building = _buildingCtrl.text.trim();
    final cc = _countryCodeCtrl.text.trim();
    final pn = _phoneCtrl.text.trim();
    final floor = _floorCtrl.text.trim();
    final apt = _aptCtrl.text.trim();
    final directions = _directionsCtrl.text.trim();

    if (fullName.isEmpty ||
        city.isEmpty ||
        street.isEmpty ||
        building.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required address fields.')),
      );
      return;
    }
    final phoneDigits = pn.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
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

    final composedAddress = '$street, Building $building';
    final phoneDisplay = '$cc $pn'.trim();

    final deliveryAddress = <String, dynamic>{
      'fullName': fullName,
      'recipientName': fullName,
      'name': fullName,
      'countryCode': cc,
      'phoneNumber': pn,
      'phone': phoneDisplay,
      'city': city,
      'street': street,
      'address': composedAddress,
      'building': building,
      'floor': floor,
      'apartment': apt,
      if (directions.isNotEmpty) 'additionalDirections': directions,
    };

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

    final storeId = storeIds.first;
    final deliveryFee = widget.cartDocs.isEmpty ? 0.0 : 5.0;
    final orderTotalJod = widget.subtotal + deliveryFee;

    if (_paymentMethod == 'credit') {
      if (!mounted) return;
      final meta = await showSecurePaymentDialog(
        context,
        totalJod: orderTotalJod,
        deliveryPhoneDigits: pn,
      );
      if (!mounted || meta == null) return;

      setState(() => _loading = true);
      try {
        final receipt = await _databaseService.setOrder(
          storeId: storeId,
          items: items,
          deliveryAddress: deliveryAddress,
          paymentMethod: _paymentMethod,
          cardPaymentMeta: meta.toFirestoreMap(),
        );
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => OrderPlacedSuccessPage(
              orderId: receipt.orderId,
              totalJod: receipt.totalJod,
              deliveryAddress: deliveryAddress,
            ),
          ),
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
      return;
    }

    setState(() => _loading = true);
    try {
      final receipt = await _databaseService.setOrder(
        storeId: storeId,
        items: items,
        deliveryAddress: deliveryAddress,
        paymentMethod: _paymentMethod,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderPlacedSuccessPage(
            orderId: receipt.orderId,
            totalJod: receipt.totalJod,
            deliveryAddress: deliveryAddress,
          ),
        ),
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

class _CheckoutPaymentOption extends StatelessWidget {
  const _CheckoutPaymentOption({
    required this.selected,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  static const _teal = Color(0xFF4FA294);
  static const _brown = Color(0xFF5D4037);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F5F5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _teal : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: _brown, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _brown,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: _teal, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderPlacedSuccessPage extends StatelessWidget {
  const OrderPlacedSuccessPage({
    super.key,
    required this.orderId,
    required this.totalJod,
    required this.deliveryAddress,
  });

  final String orderId;
  final double totalJod;
  final Map<String, dynamic> deliveryAddress;

  static const _bg = Color(0xFFEFFBFC);
  static const _teal = Color(0xFF4FA294);
  static const _brown = Color(0xFF5A2F0E);

  String _orderLabel() {
    if (orderId.isEmpty) return '#ORD';
    final tail =
        orderId.length <= 6 ? orderId : orderId.substring(orderId.length - 6);
    return '#ORD${tail.toUpperCase()}';
  }

  List<String> _addressLines() {
    final d = deliveryAddress;
    final name = (d['fullName'] ?? d['recipientName'] ?? '').toString().trim();
    final city = (d['city'] ?? '').toString().trim();
    final street = (d['street'] ?? '').toString().trim();
    final addr = (d['address'] ?? '').toString().trim();
    final bld = (d['building'] ?? '').toString().trim();
    final floor = (d['floor'] ?? '').toString().trim();
    final apt = (d['apartment'] ?? '').toString().trim();
    final phone = (d['phone'] ?? '').toString().trim();

    final line2 = [street, city].where((e) => e.isNotEmpty).join(', ');
    final parts = <String>[];
    if (bld.isNotEmpty) parts.add('Bldg $bld');
    if (floor.isNotEmpty) parts.add('Fl $floor');
    if (apt.isNotEmpty) parts.add('Apt $apt');
    final line3 = parts.isNotEmpty ? parts.join(', ') : phone;

    final out = <String>[];
    if (name.isNotEmpty) out.add(name);
    if (line2.isNotEmpty) {
      out.add(line2);
    } else if (addr.isNotEmpty) {
      out.add(addr);
    }
    if (line3.isNotEmpty) {
      out.add(line3);
    } else if (phone.isNotEmpty && (out.isEmpty || out.last != phone)) {
      out.add(phone);
    }
    return out.isEmpty ? const ['—'] : out;
  }

  @override
  Widget build(BuildContext context) {
    final addrLines = _addressLines();

    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: Colors.white,
        foregroundColor: _teal,
        elevation: 2,
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Need help?'),
              content: const Text(
                'This is a demo checkout. For real orders, contact support from your profile.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        child: const Text('?', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 52,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Order Placed Successfully!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.brown.shade900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Thank you for your order. We'll start preparing it right away.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey.shade700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.teal.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order Number',
                                  style: TextStyle(
                                    color: Colors.brown.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _orderLabel(),
                                  style: TextStyle(
                                    color: _brown,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 22, color: Colors.teal.shade50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    color: Colors.brown.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${totalJod.toStringAsFixed(2)} JOD',
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 22, color: Colors.teal.shade50),
                            Text(
                              'Estimated Delivery',
                              style: TextStyle(
                                color: Colors.brown.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.local_shipping_outlined,
                                  size: 22,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Tomorrow, 2:00 PM',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.brown.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 22, color: Colors.teal.shade50),
                            Text(
                              'Delivery Address',
                              style: TextStyle(
                                color: Colors.brown.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...addrLines.map(
                              (line) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  line,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.35,
                                    color: Colors.brown.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const MyOrdersPage(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.history_rounded, size: 22),
                  label: const Text(
                    'View My Orders',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const SuppliesStore(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _teal,
                    side: const BorderSide(color: _teal, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
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
}
