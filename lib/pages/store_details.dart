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

  String get _storeId => (widget.storeData['id'] ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Food', 'Toys', 'Accessories', 'Health'];
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.storeData['name'] ?? 'Store').toString()),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyWishlistPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyCartPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                final category = categories[index];
                final selected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = category),
                );
              },
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemCount: categories.length,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _databaseService.streamStoreProducts(
                _storeId,
                searchQuery: _searchQuery,
                category: _selectedCategory,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load products.'));
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductCard(
                      product: product,
                      onViewDetails: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsPage(
                              storeId: _storeId,
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onViewDetails;
  final Future<void> Function() onAddToCart;

  const _ProductCard({
    required this.product,
    required this.onViewDetails,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final title = (product['title'] ?? product['name'] ?? 'Product').toString();
    final price = ((product['price'] as num?)?.toDouble() ?? 0).toStringAsFixed(
      2,
    );
    final imageUrl = (product['image'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: imageUrl.isEmpty
            ? const CircleAvatar(child: Icon(Icons.pets))
            : CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
        title: Text(title),
        subtitle: Text('$price JOD'),
        onTap: onViewDetails,
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: onAddToCart,
        ),
      ),
    );
  }
}

class ProductDetailsPage extends StatefulWidget {
  final String storeId;
  final Map<String, dynamic> product;
  const ProductDetailsPage({
    super.key,
    required this.storeId,
    required this.product,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final DatabaseService _databaseService = DatabaseService();
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final productId = (widget.product['id'] ?? '').toString();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _databaseService.streamProductById(productId),
      builder: (context, snapshot) {
        final product = snapshot.data?.data() ?? widget.product;
        final title = (product['title'] ?? product['name'] ?? 'Product')
            .toString();
        final description = (product['description'] ?? '').toString();
        final imageUrl = (product['image'] ?? '').toString();
        final price = ((product['price'] as num?)?.toDouble() ?? 0)
            .toStringAsFixed(2);
        return Scaffold(
          appBar: AppBar(title: const Text('Product Details')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text('$price JOD', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Text(description),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_quantity', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      onPressed: () => setState(() => _quantity++),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _databaseService.addOrUpdateCartItem(
                          storeId: widget.storeId,
                          productId: productId,
                          quantity: _quantity,
                          productSnapshot: {
                            ...product,
                            'title': product['title'] ?? product['name'],
                          },
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cart updated')),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text('Add to Cart'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyWishlistPage extends StatelessWidget {
  const MyWishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DatabaseService();
    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.streamMyWishlist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('Wishlist is empty'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final item = docs[index].data();
              return ListTile(
                title: Text((item['title'] ?? '').toString()),
                subtitle: Text(
                  '${((item['price'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)} JOD',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => service.removeWishlistItem(
                    (item['productId'] ?? docs[index].id).toString(),
                  ),
                ),
              );
            },
          );
        },
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
          final total = _cartTotal(docs);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final item = docs[index].data();
                    final qty = ((item['quantity'] as num?)?.toInt() ?? 1);
                    return ListTile(
                      title: Text((item['title'] ?? '').toString()),
                      subtitle: Text(
                        '${((item['price'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)} JOD',
                      ),
                      trailing: SizedBox(
                        width: 130,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: qty <= 1
                                  ? null
                                  : () {
                                      _databaseService.addOrUpdateCartItem(
                                        storeId:
                                            (item['storeId'] ?? '').toString(),
                                        productId:
                                            (item['productId'] ?? docs[index].id)
                                                .toString(),
                                        quantity: qty - 1,
                                        productSnapshot: item,
                                      );
                                    },
                            ),
                            Text('$qty'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                _databaseService.addOrUpdateCartItem(
                                  storeId: (item['storeId'] ?? '').toString(),
                                  productId:
                                      (item['productId'] ?? docs[index].id)
                                          .toString(),
                                  quantity: qty + 1,
                                  productSnapshot: item,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Total: ${total.toStringAsFixed(2)} JOD',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutPage(
                              cartDocs: docs,
                              subtotal: total,
                            ),
                          ),
                        );
                      },
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SuccessPage()),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!context.mounted) return;
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
