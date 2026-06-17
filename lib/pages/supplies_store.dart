import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import 'buyer_my_orders_page.dart';
import 'store_details.dart' as store_pages;

class SuppliesStore extends StatefulWidget {
  const SuppliesStore({super.key});

  @override
  State<SuppliesStore> createState() => _SuppliesStoreState();
}

class _SuppliesStoreState extends State<SuppliesStore> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'Nearest';
  bool _showOnlyOffers = false;
  bool _showFavoriteStores = false;
  final Map<String, bool> _favoriteStoreOverrides = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildStoreImage(String url) {
    if (url.isEmpty) return _storePlaceholder();
    if (url.startsWith('data:')) {
      try {
        final bytes = base64Decode(url.substring(url.indexOf(',') + 1));
        return Image.memory(
          bytes,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (context, e, stack) => _storePlaceholder(),
        );
      } catch (_) {
        return _storePlaceholder();
      }
    }
    return Image.network(
      url,
      width: 96,
      height: 96,
      fit: BoxFit.cover,
      errorBuilder: (context, e, stack) => _storePlaceholder(),
    );
  }

  Widget _storePlaceholder() => Container(
    width: 96,
    height: 96,
    color: Colors.grey.shade100,
    child: const Icon(Icons.store, color: Colors.grey, size: 36),
  );

  void _toggleFavoriteStoresFilter() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'All';
      _selectedSort = 'Nearest';
      _showOnlyOffers = false;
      _showFavoriteStores = !_showFavoriteStores;
    });
  }

  List<Map<String, dynamic>> _sortedStores(List<Map<String, dynamic>> stores) {
    final list = [...stores];
    if (_selectedSort == 'Top Rated') {
      list.sort(
        (a, b) => ((b['ratingAvg'] as num?)?.toDouble() ?? 0).compareTo(
          (a['ratingAvg'] as num?)?.toDouble() ?? 0,
        ),
      );
    } else if (_selectedSort == 'Popular') {
      list.sort(
        (a, b) => ((b['ratingCount'] as num?)?.toInt() ?? 0).compareTo(
          (a['ratingCount'] as num?)?.toInt() ?? 0,
        ),
      );
    } else {
      list.sort(
        (a, b) => (a['name'] ?? '').toString().compareTo(
          (b['name'] ?? '').toString(),
        ),
      );
    }
    return list;
  }

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
            Text(
              'Pet Supplies',
              style: TextStyle(
                color: Color(0xFF5A3E2B),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Choose a store',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          _buildTopButton(
            context,
            Icons.favorite_border,
            'Wishlist',
            const store_pages.MyWishlistPage(),
          ),
          _buildTopButton(
            context,
            Icons.history,
            'Orders',
            const MyOrdersPage(),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search products or stores...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSort,
                        isExpanded: true,
                        items: ['Nearest', 'Top Rated', 'Popular']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedSort = value);
                          }
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black54,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      setState(() => _showOnlyOffers = !_showOnlyOffers),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _showOnlyOffers
                          ? const Color(0xFF3AA78E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _showOnlyOffers
                            ? const Color(0xFF3AA78E)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: 16,
                          color: _showOnlyOffers ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Offers',
                          style: TextStyle(
                            color: _showOnlyOffers ? Colors.white : Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _databaseService.streamFavoriteStores(),
              builder: (context, favoriteSnapshot) {
                final favoriteCount = favoriteSnapshot.data?.docs.length ?? 0;
                return GestureDetector(
                  onTap: _toggleFavoriteStoresFilter,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: _showFavoriteStores
                          ? const Color(0xFF3AA78E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _showFavoriteStores
                            ? const Color(0xFF3AA78E)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: _showFavoriteStores
                              ? Colors.white
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _showFavoriteStores
                              ? 'Favorite Stores ($favoriteCount)'
                              : 'Show All Stores',
                          style: TextStyle(
                            color: _showFavoriteStores
                                ? Colors.white
                                : Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Food', 'Toys', 'Accessories', 'Health'].map((
                category,
              ) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5BA092)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (category == 'All') ...[
                          Icon(
                            Icons.tune_rounded,
                            size: 13,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF5B9D8E),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF5A3E2B),
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _databaseService.streamFavoriteStores(),
              builder: (context, favoriteSnapshot) {
                final favoriteIds =
                    favoriteSnapshot.data?.docs
                        .map(
                          (doc) => (doc.data()['storeId'] ?? doc.id).toString(),
                        )
                        .toSet() ??
                    <String>{};
                for (final entry in _favoriteStoreOverrides.entries) {
                  if (entry.value) {
                    favoriteIds.add(entry.key);
                  } else {
                    favoriteIds.remove(entry.key);
                  }
                }
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _databaseService.streamStores(
                    searchQuery: _searchQuery,
                    category: _selectedCategory,
                    offersOnly: _showOnlyOffers,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF5BA092),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Could not load stores. Please try again.',
                          style: TextStyle(color: Colors.red.shade400),
                        ),
                      );
                    }
                    final allStores = _sortedStores(snapshot.data ?? []);
                    final stores = _showFavoriteStores
                        ? allStores
                              .where(
                                (store) => favoriteIds.contains(
                                  (store['id'] ?? '').toString(),
                                ),
                              )
                              .toList()
                        : allStores;
                    if (stores.isEmpty) {
                      return Center(
                        child: Text(
                          _showFavoriteStores
                              ? 'No favorite stores yet. Tap the heart icon on stores to save your favorites!'
                              : 'No stores found!',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: stores.length,
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        return _buildStoreCard(context, store);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton(
    BuildContext context,
    IconData icon,
    String label,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF5A3E2B)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5A3E2B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, Map<String, dynamic> store) {
    final name = (store['name'] ?? 'Store').toString();
    final storeId = (store['id'] ?? '').toString().trim();
    final fallbackRating = ((store['ratingAvg'] as num?)?.toDouble() ?? 0)
        .toStringAsFixed(1);
    final rawCategories = (store['categories'] as List?) ??
        (store['tags'] as List?) ??
        const [];
    final categories = rawCategories
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final street = (store['street'] ?? store['address'] ?? '').toString().trim();
    final location = (store['location'] ?? store['city'] ?? '').toString().trim();
    final addressLine = [street, location]
        .where((value) => value.isNotEmpty)
        .join(' • ');
    final activeOffers =
        (store['activeOffers'] as List?)?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    final hasOffer = activeOffers.isNotEmpty ||
        (store['offer'] ?? '').toString().isNotEmpty;
    final offerCount = activeOffers.isNotEmpty ? activeOffers.length : 1;
    final bannerUrl = store_pages.petStoreBannerImageUrl(store);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => store_pages.StoreDetails(
              storeData: {
                'id': store['id'],
                'name': name,
                'image': bannerUrl,
                'storeImageUrl': bannerUrl,
                'description': store['description'] ?? '',
                'address': store['address'] ?? store['street'] ?? '',
                'location': store['location'] ?? store['city'] ?? '',
                'distance': store['distance'] ?? 'Nearby',
                'time': store['businessHours'] ?? store['hours'] ?? '9AM - 9PM',
                'rating': fallbackRating,
                'reviews': '(${store['ratingCount'] ?? 0})',
                'categories': categories,
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE9F3F2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: image | name + rating | favourite ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildStoreImage(bannerUrl),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: _liveStoreRatingBadge(storeId, fallbackRating),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (store['description'] ?? '').toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: _databaseService.streamFavoriteStore(
                      (store['id'] ?? '').toString(),
                    ),
                    builder: (context, snapshot) {
                      final sid = (store['id'] ?? '').toString();
                      final backendFavorite = snapshot.data?.exists == true;
                      final isFav = _favoriteStoreOverrides[sid] ?? backendFavorite;
                      return GestureDetector(
                        onTap: () async {
                          final next = !isFav;
                          setState(() => _favoriteStoreOverrides[sid] = next);
                          try {
                            await _databaseService.toggleFavoriteStore(
                              storeId: sid,
                              storeSnapshot: store,
                            );
                          } catch (e) {
                            if (mounted) {
                              setState(() => _favoriteStoreOverrides[sid] = isFav);
                            }
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('$e')));
                          }
                        },
                        child: Container(
                          height: 36,
                          width: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey.shade400,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ── Category tags ──
              if (categories.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories
                      .map(
                        (cat) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F7F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cat,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              // ── Offer badge ──
              if (hasOffer) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$offerCount Special Offer${offerCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB6691D),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // ── Location row ──
              if (addressLine.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        addressLine,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              // ── Hours row ──
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    (store['hours'] ?? '9AM - 9PM').toString(),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Matches [store_details] store-review filter (single-field Firestore query).
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

  Widget _liveStoreRatingBadge(String storeId, String fallbackRating) {
    if (storeId.trim().isEmpty) {
      return _storeRatingBadge(fallbackRating);
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      key: ValueKey<String>('store_rating_$storeId'),
      stream: _databaseService.streamStoreReviews(storeId),
      builder: (context, snap) {
        if (snap.hasError) {
          return _storeRatingBadge(fallbackRating);
        }
        if (!snap.hasData) {
          return _storeRatingBadge('…');
        }
        final raw = snap.data!.docs;
        final docs =
            raw.where((d) => _storeReviewDocIsStore(d.data())).toList();
        final avg = _averageRatingFromStoreReviewDocs(docs);
        final n = docs.length;
        final label = '${avg.toStringAsFixed(1)} ($n)';
        return _storeRatingBadge(label);
      },
    );
  }

  Widget _storeRatingBadge(String rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 12),
          const SizedBox(width: 4),
          Text(
            rating,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

}

class MyWishlistPage extends StatelessWidget {
  const MyWishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DatabaseService();
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: Color(0xFF5A3E2B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.streamMyWishlist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5BA092)),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load wishlist.'));
          }
          final docs = (snapshot.data?.docs ?? [])
              .where((doc) => doc.data()['itemType'] != 'store')
              .toList();
          if (docs.isEmpty) {
            return const Center(child: Text('Your wishlist is empty'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index].data();
              return Card(
                child: ListTile(
                  title: Text((item['title'] ?? '').toString()),
                  subtitle: Text('${item['price'] ?? 0} JOD'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
