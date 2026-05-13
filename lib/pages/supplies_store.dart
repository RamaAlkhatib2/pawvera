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
                  child: PopupMenuButton<String>(
                    onSelected: (value) =>
                        setState(() => _selectedSort = value),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'Nearest',
                        child: Text('Sort: Nearest'),
                      ),
                      PopupMenuItem(
                        value: 'Top Rated',
                        child: Text('Sort: Top Rated'),
                      ),
                      PopupMenuItem(
                        value: 'Popular',
                        child: Text('Sort: Popular'),
                      ),
                    ],
                    child: _pill('Sort: $_selectedSort'),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      setState(() => _showOnlyOffers = !_showOnlyOffers),
                  child: _pill(
                    'Offers Only',
                    selected: _showOnlyOffers,
                    icon: Icons.local_offer_outlined,
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
                return InkWell(
                  onTap: _toggleFavoriteStoresFilter,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _showFavoriteStores
                          ? const Color(0xFF5BA092)
                          : const Color(0xFFEFFBFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.teal.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showFavoriteStores
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 19,
                          color: _showFavoriteStores
                              ? Colors.white
                              : const Color(0xFF5A3E2B),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _showFavoriteStores
                              ? 'Favorite Stores ($favoriteCount)'
                              : 'Show All Stores',
                          style: TextStyle(
                            color: _showFavoriteStores
                                ? Colors.white
                                : const Color(0xFF5A3E2B),
                            fontWeight: FontWeight.w700,
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
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF5A3E2B),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
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

  Widget _pill(String label, {bool selected = false, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8F4F1) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? const Color(0xFF3AA78E) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: selected
                  ? const Color(0xFF3AA78E)
                  : const Color(0xFF5A3E2B),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A3E2B)),
          ),
          if (icon == null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
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
    final storeId = (store['id'] ?? '').toString();
    final fallbackRating = ((store['ratingAvg'] as num?)?.toDouble() ?? 0)
        .toStringAsFixed(1);
    final tags = ((store['tags'] as List?) ?? const [])
        .map((tag) => tag.toString())
        .where((tag) => tag.trim().isNotEmpty)
        .toList();
    final activeOffers =
        (store['activeOffers'] as List?)?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    final offer = activeOffers.isNotEmpty
        ? (activeOffers.first['title'] ?? '').toString()
        : (store['offer'] ?? '').toString();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => store_pages.StoreDetails(
              storeData: {
                'id': store['id'],
                'name': name,
                'image': store['image'] ?? store['storeImageUrl'],
                'description': store['description'] ?? '',
                'address': store['address'] ?? store['street'] ?? '',
                'location': store['location'] ?? store['city'] ?? '',
                'distance': store['distance'] ?? 'Nearby',
                'time': store['businessHours'] ?? store['hours'] ?? '9AM - 9PM',
                'rating': fallbackRating,
                'reviews': '(${store['ratingCount'] ?? 0})',
                'categories': tags,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    image: (store['image'] ?? '').toString().isEmpty
                        ? null
                        : DecorationImage(
                            image: NetworkImage((store['image']).toString()),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: (store['image'] ?? '').toString().isEmpty
                      ? const Icon(Icons.store, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: _liveStoreRatingBadge(
                              storeId,
                              fallbackRating,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (store['description'] ?? '').toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _databaseService.streamFavoriteStore(
                    (store['id'] ?? '').toString(),
                  ),
                  builder: (context, snapshot) {
                    final storeId = (store['id'] ?? '').toString();
                    final backendFavorite = snapshot.data?.exists == true;
                    final isFavorite =
                        _favoriteStoreOverrides[storeId] ?? backendFavorite;
                    return _storeFavoriteButton(
                      isFavorite: isFavorite,
                      onTap: () async {
                        final nextFavorite = !isFavorite;
                        setState(() {
                          _favoriteStoreOverrides[storeId] = nextFavorite;
                        });
                        try {
                          await _databaseService.toggleFavoriteStore(
                            storeId: storeId,
                            storeSnapshot: store,
                          );
                        } catch (e) {
                          if (mounted) {
                            setState(() {
                              _favoriteStoreOverrides[storeId] = isFavorite;
                            });
                          }
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('$e')));
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            if (offer.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  'ًںڈ· $offer',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.grey.shade50,
                      ),
                    )
                    .toList(),
              ),
            ],
            const Divider(),
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
                    (store['location'] ?? '').toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ),
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  (store['hours'] ?? '9AM - 9PM').toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
          ],
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
      sum += ((d.data()['stars'] as num?)?.toDouble() ?? 0).clamp(0, 5);
    }
    return sum / docs.length;
  }

  Widget _liveStoreRatingBadge(String storeId, String fallbackRating) {
    if (storeId.trim().isEmpty) {
      return _storeRatingBadge(fallbackRating);
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _databaseService.streamStoreReviews(storeId),
      builder: (context, snap) {
        var label = fallbackRating;
        if (snap.connectionState == ConnectionState.waiting) {
          label = '…';
        } else if (!snap.hasError && snap.hasData) {
          final raw = snap.data?.docs ?? [];
          final docs =
              raw.where((d) => _storeReviewDocIsStore(d.data())).toList();
          final avg = _averageRatingFromStoreReviewDocs(docs);
          final n = docs.length;
          label = '${avg.toStringAsFixed(1)} ($n)';
        }
        return _storeRatingBadge(label);
      },
    );
  }

  Widget _storeRatingBadge(String rating) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF4FA294),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 15),
          const SizedBox(width: 4),
          Text(
            rating,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeFavoriteButton({
    required bool isFavorite,
    required Future<void> Function() onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.redAccent : Colors.blueGrey.shade300,
            size: 21,
          ),
        ),
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
