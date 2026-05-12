import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
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
    final rating = ((store['ratingAvg'] as num?)?.toDouble() ?? 0)
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
                'rating': rating,
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
                            child: _storeRatingBadge(rating),
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
                  '🏷 $offer',
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

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesOrder(String orderId, Map<String, dynamic> order) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final items = _orderLineItems(
      order,
    ).map((item) => (item['title'] ?? '').toString()).join(' ');
    final haystack = '$orderId ${order['storeName']} ${order['status']} $items'
        .toLowerCase();
    return haystack.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final service = DatabaseService();
    return Scaffold(
      backgroundColor: const Color(0xFFEFFBFC),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.streamMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5BA092)),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load orders.'));
          }
          final allDocs = snapshot.data?.docs ?? [];
          final docs = allDocs
              .where((doc) => _matchesOrder(doc.id, doc.data()))
              .toList();
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
                  child: Row(
                    children: [
                      _topSquareButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Orders',
                            style: TextStyle(
                              color: Color(0xFF5A3E2B),
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${allDocs.length} total orders',
                            style: TextStyle(color: Colors.blueGrey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search by order ID, store, status, items...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.blueGrey,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.teal.shade100),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.teal.shade100),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: docs.isEmpty
                      ? const Center(child: Text('No orders found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final orderId = docs[index].id;
                            final order = docs[index].data();
                            final status = (order['status'] ?? 'pending')
                                .toString();
                            final normalizedStatus = status.toLowerCase();
                            final canRate =
                                normalizedStatus == 'completed' ||
                                normalizedStatus == 'delivered';
                            return _OrderCard(
                              orderId: orderId,
                              order: order,
                              onRate: canRate
                                  ? () {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (ctx) =>
                                            _RatePetStoreOrderSheet(
                                              databaseService: service,
                                              orderDocId: orderId,
                                              order: order,
                                            ),
                                      );
                                    }
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topSquareButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      shadowColor: Colors.teal.withValues(alpha: 0.18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: const Color(0xFF5A3E2B)),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.orderId,
    required this.order,
    required this.onRate,
  });

  final String orderId;
  final Map<String, dynamic> order;
  final VoidCallback? onRate;

  String _dateText() {
    final value = order['createdAt'];
    if (value is Timestamp) {
      final d = value.toDate();
      return '${d.month}/${d.day}/${d.year}';
    }
    return '';
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'delivered' || s == 'completed') return Colors.green;
    if (s.contains('delivery')) return const Color(0xFF6558F5);
    return const Color(0xFF4FA294);
  }

  @override
  Widget build(BuildContext context) {
    final status = (order['status'] ?? 'pending').toString();
    final storeName = (order['storeName'] ?? 'Store').toString();
    final total = ((order['total'] as num?)?.toDouble() ?? 0);
    final items = _orderLineItems(order);
    final date = _dateText();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Order #$orderId',
                      style: const TextStyle(
                        color: Color(0xFF5A3E2B),
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${total.toStringAsFixed(2)} JOD',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (date.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(date, style: TextStyle(color: Colors.blueGrey.shade600)),
          ],
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text: 'Store: ',
              style: TextStyle(color: Colors.blueGrey.shade700),
              children: [
                TextSpan(
                  text: storeName,
                  style: const TextStyle(
                    color: Color(0xFF5A3E2B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Items: ${items.length} product(s)',
            style: TextStyle(color: Colors.blueGrey.shade700),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              items
                  .map((item) {
                    final title = (item['title'] ?? 'Product').toString();
                    final qty = ((item['quantity'] as num?)?.toInt() ?? 1);
                    return '• $title x$qty';
                  })
                  .join('\n'),
              style: TextStyle(color: Colors.blueGrey.shade700),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text('Order Again'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRate,
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Rate Order'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<Map<String, dynamic>> _orderLineItems(Map<String, dynamic> order) {
  final raw = order['items'];
  if (raw is! List) return [];
  final out = <Map<String, dynamic>>[];
  for (final e in raw) {
    if (e is Map<String, dynamic>) {
      out.add(e);
    } else if (e is Map) {
      out.add(Map<String, dynamic>.from(e));
    }
  }
  return out;
}

class _RatePetStoreOrderSheet extends StatefulWidget {
  const _RatePetStoreOrderSheet({
    required this.databaseService,
    required this.orderDocId,
    required this.order,
  });

  final DatabaseService databaseService;
  final String orderDocId;
  final Map<String, dynamic> order;

  @override
  State<_RatePetStoreOrderSheet> createState() =>
      _RatePetStoreOrderSheetState();
}

class _RatePetStoreOrderSheetState extends State<_RatePetStoreOrderSheet> {
  final _productComment = TextEditingController();
  final _storeComment = TextEditingController();
  late final String _storeId;
  late final List<Map<String, dynamic>> _items;
  String? _productId;
  int _productStars = 5;
  int _storeStars = 5;
  bool _submitting = false;

  List<MapEntry<String, String>> _productChoices() {
    final out = <MapEntry<String, String>>[];
    for (final m in _items) {
      final pid = (m['productId'] ?? m['id'] ?? '').toString().trim();
      if (pid.isEmpty) continue;
      out.add(MapEntry(pid, (m['title'] ?? pid).toString()));
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    _storeId = (widget.order['storeId'] ?? '').toString();
    _items = _orderLineItems(widget.order);
    final ch = _productChoices();
    _productId = ch.isEmpty ? null : ch.first.key;
  }

  @override
  void dispose() {
    _productComment.dispose();
    _storeComment.dispose();
    super.dispose();
  }

  Widget _starRow({required int value, required ValueChanged<int> onChanged}) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        return IconButton(
          onPressed: () => onChanged(n),
          icon: Icon(
            value >= n ? Icons.star : Icons.star_border,
            color: Colors.amber.shade700,
            size: 32,
          ),
        );
      }),
    );
  }

  Future<void> _submit() async {
    if (_storeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing store for this order.')),
      );
      return;
    }
    final productChoices = _productChoices();
    if (productChoices.isNotEmpty &&
        (_productId == null || _productId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a product to rate.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      if (productChoices.isNotEmpty && _productId != null) {
        await widget.databaseService.rateProduct(
          storeId: _storeId,
          productId: _productId!,
          stars: _productStars,
          comment: _productComment.text.trim(),
          orderId: widget.orderDocId,
        );
      }
      await widget.databaseService.rateStore(
        storeId: _storeId,
        stars: _storeStars,
        comment: _storeComment.text.trim(),
        orderId: widget.orderDocId,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      Navigator.pop(context);
      messenger?.showSnackBar(
        const SnackBar(content: Text('Thanks! Your review was saved.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Rate this order',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A3E2B),
                  ),
                ),
                Text(
                  'Order #${widget.orderDocId}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ...() {
                  final productChoiceList = _productChoices();
                  if (productChoiceList.isEmpty) return <Widget>[];
                  final selected =
                      _productId != null &&
                          productChoiceList.any((e) => e.key == _productId)
                      ? _productId!
                      : productChoiceList.first.key;
                  return [
                    DropdownButtonFormField<String>(
                      key: ValueKey<String>(selected),
                      initialValue: selected,
                      decoration: const InputDecoration(
                        labelText: 'Product',
                        border: OutlineInputBorder(),
                      ),
                      items: productChoiceList
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e.key,
                              child: Text(
                                e.value,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _productId = v),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Product rating',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    _starRow(
                      value: _productStars,
                      onChanged: (n) => setState(() => _productStars = n),
                    ),
                    TextField(
                      controller: _productComment,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Product comment (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ];
                }(),
                const Text(
                  'Store rating',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                _starRow(
                  value: _storeStars,
                  onChanged: (n) => setState(() => _storeStars = n),
                ),
                TextField(
                  controller: _storeComment,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Store comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5BA092),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit review'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
