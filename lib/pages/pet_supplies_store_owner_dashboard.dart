import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/database_service.dart';
import 'login_view.dart';

class PetSuppliesStoreOwnerDashboard extends StatefulWidget {
  const PetSuppliesStoreOwnerDashboard({super.key});

  @override
  State<PetSuppliesStoreOwnerDashboard> createState() =>
      _PetSuppliesStoreOwnerDashboardState();
}

class _PetSuppliesStoreOwnerDashboardState
    extends State<PetSuppliesStoreOwnerDashboard> {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _tab = 0;

  Future<String?> _loadStoreId() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    // Stores live on the user doc itself for pet supplies providers.
    // The provider's uid IS the storeId for all downstream queries (products/orders).
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) return null;
    final data = userDoc.data() ?? const <String, dynamic>{};
    final isPetSuppliesProvider = data['role'] == 'provider' &&
        data['providerType'] == 'Pet Supplies Store';
    return isPetSuppliesProvider ? uid : null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _loadStoreId(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final storeId = snapshot.data;
        if (storeId == null) {
          return const Scaffold(body: Center(child: Text('No store found.')));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pet Supplies Store Dashboard'),
            actions: [
              IconButton(
                onPressed: () async {
                  await _auth.signOut();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    this.context,
                    MaterialPageRoute(builder: (_) => const LoginView()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: _tab == 0
              ? _ProductsTab(storeId: storeId, databaseService: _databaseService)
              : _OrdersTab(storeId: storeId, databaseService: _databaseService),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) => setState(() => _tab = value),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Products'),
              NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Manage Orders'),
            ],
          ),
        );
      },
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final String storeId;
  final DatabaseService databaseService;
  const _ProductsTab({required this.storeId, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: databaseService.streamProductsForStoreOwner(storeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = snapshot.data ?? [];
        return Stack(
          children: [
            ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text((product['title'] ?? '').toString()),
                  subtitle: Text(
                    '${((product['price'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)} JOD',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => _ProductFormDialog(
                        storeId: storeId,
                        databaseService: databaseService,
                        existingProduct: product,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _ProductFormDialog(
                    storeId: storeId,
                    databaseService: databaseService,
                  ),
                ),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  final String storeId;
  final DatabaseService databaseService;
  final Map<String, dynamic>? existingProduct;
  const _ProductFormDialog({
    required this.storeId,
    required this.databaseService,
    this.existingProduct,
  });

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  String _category = 'Food';
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    if (p != null) {
      _title.text = (p['title'] ?? '').toString();
      _description.text = (p['description'] ?? '').toString();
      _price.text = ((p['price'] as num?)?.toDouble() ?? 0).toString();
      _stock.text = ((p['stock'] as num?)?.toInt() ?? 0).toString();
      _category = (p['category'] ?? 'Food').toString();
      _imageUrl = (p['image'] ?? '').toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingProduct == null ? 'Add Product' : 'Edit Product'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: _description, decoration: const InputDecoration(labelText: 'Description')),
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price')),
          TextField(controller: _stock, decoration: const InputDecoration(labelText: 'Stock')),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: const [
              DropdownMenuItem(value: 'Food', child: Text('Food')),
              DropdownMenuItem(value: 'Toys', child: Text('Toys')),
              DropdownMenuItem(value: 'Accessories', child: Text('Accessories')),
              DropdownMenuItem(value: 'Health', child: Text('Health')),
            ],
            onChanged: (value) => setState(() => _category = value ?? 'Food'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final picker = ImagePicker();
              final file = await picker.pickImage(source: ImageSource.gallery);
              if (file == null) return;
              final bytes = await file.readAsBytes();
              final url = await widget.databaseService.uploadProductImageBytes(
                storeId: widget.storeId,
                bytes: bytes,
                fileName: file.name,
              );
              if (!context.mounted) return;
              setState(() => _imageUrl = url);
            },
            child: const Text('Upload Image'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final payload = {
              'title': _title.text.trim(),
              'description': _description.text.trim(),
              'price': double.tryParse(_price.text.trim()) ?? 0.0,
              'stock': int.tryParse(_stock.text.trim()) ?? 0,
              'category': _category,
              'image': _imageUrl,
            };
            if (widget.existingProduct == null) {
              await widget.databaseService.createProduct(
                storeId: widget.storeId,
                productData: payload,
              );
            } else {
              await widget.databaseService.updateProduct(
                (widget.existingProduct!['id'] ?? '').toString(),
                payload,
              );
            }
            if (!context.mounted) return;
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final String storeId;
  final DatabaseService databaseService;
  const _OrdersTab({required this.storeId, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: databaseService.streamOrdersForStoreOwner(storeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No orders yet.'));
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final order = docs[index].data();
            final status = (order['status'] ?? 'pending').toString();
            return ListTile(
              title: Text('Order #${order['id'] ?? docs[index].id}'),
              subtitle: Text(
                'Total ${((order['total'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)} JOD',
              ),
              trailing: DropdownButton<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('pending')),
                  DropdownMenuItem(value: 'confirmed', child: Text('confirmed')),
                  DropdownMenuItem(value: 'out_for_delivery', child: Text('out_for_delivery')),
                  DropdownMenuItem(value: 'delivered', child: Text('delivered')),
                  DropdownMenuItem(value: 'completed', child: Text('completed')),
                  DropdownMenuItem(value: 'cancelled', child: Text('cancelled')),
                ],
                onChanged: (value) async {
                  if (value == null) return;
                  await databaseService.updateOrderStatus(
                    orderId: docs[index].id,
                    status: value,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
