import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import 'store_details.dart';

class SuppliesStore extends StatefulWidget {
  const SuppliesStore({super.key});

  @override
  State<SuppliesStore> createState() => _SuppliesStoreState();
}

class _SuppliesStoreState extends State<SuppliesStore> {
  final DatabaseService _databaseService = DatabaseService();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'Nearest';
  bool _showOnlyOffers = false;

  @override
  void initState() {
    super.initState();
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
      list.sort((a, b) => (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
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
            Text('Choose a store', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        actions: [
          _buildTopButton(
            context,
            Icons.favorite_border,
            'Wishlist',
            const MyWishlistPage(),
          ),
          _buildTopButton(context, Icons.history, 'Orders', const MyOrdersPage()),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
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
                    onSelected: (value) => setState(() => _selectedSort = value),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'Nearest', child: Text('Sort: Nearest')),
                      PopupMenuItem(value: 'Top Rated', child: Text('Sort: Top Rated')),
                      PopupMenuItem(value: 'Popular', child: Text('Sort: Popular')),
                    ],
                    child: _pill('Sort: $_selectedSort'),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _showOnlyOffers = !_showOnlyOffers),
                  child: _pill(
                    'Offers Only',
                    selected: _showOnlyOffers,
                    icon: Icons.local_offer_outlined,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Food', 'Toys', 'Accessories', 'Health'].map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF5BA092) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF5A3E2B),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _databaseService.streamStores(
                searchQuery: _searchQuery,
                category: _selectedCategory,
                offersOnly: _showOnlyOffers,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF5BA092)));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Could not load stores. Please try again.',
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                  );
                }
                final stores = _sortedStores(snapshot.data ?? []);
                if (stores.isEmpty) {
                  return const Center(child: Text('No stores found!'));
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
            Icon(icon, size: 18, color: selected ? const Color(0xFF3AA78E) : const Color(0xFF5A3E2B)),
            const SizedBox(width: 6),
          ],
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF5A3E2B))),
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
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
    final rating = ((store['ratingAvg'] as num?)?.toDouble() ?? 0).toStringAsFixed(1);
    final tags = (store['tags'] as List?)?.cast<String>() ?? <String>[];
    final offer = (store['offer'] ?? '').toString();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreDetails(
              storeData: {
                'id': store['id'],
                'name': name,
                'image': store['image'],
                'location': store['location'] ?? '',
                'distance': store['distance'] ?? '',
                'time': store['hours'] ?? '9AM - 9PM',
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3AA78E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '★ $rating',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (store['description'] ?? '').toString(),
                        style: const TextStyle(color: Colors.black, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (offer.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
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
          style: TextStyle(color: Color(0xFF5A3E2B), fontWeight: FontWeight.bold),
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
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5BA092)));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load wishlist.'));
          }
          final docs = snapshot.data?.docs ?? [];
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

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DatabaseService();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F8),
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(color: Color(0xFF5A3E2B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.streamMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5BA092)));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load orders.'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final order = docs[index].data();
              return Card(
                child: ListTile(
                  title: Text('Order #${order['id'] ?? docs[index].id}'),
                  subtitle: Text('Status: ${order['status'] ?? 'pending'}'),
                  trailing: Text('${order['total'] ?? 0} JOD'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}