import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';
import 'store_details.dart' show CheckoutPage;

/// Shopping cart (pet supplies). Lives here so order history can open it
/// without a circular import with [store_details.dart].
class MyCartPage extends StatefulWidget {
  const MyCartPage({super.key});

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  final DatabaseService _databaseService = DatabaseService();

  static const _bg = Color(0xFFEFFBFC);
  static const _brown = Color(0xFF5A2F0E);
  static const _teal = Color(0xFF4FA294);

  double _cartTotal(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.fold<double>(
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
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _databaseService.streamMyCart(),
          builder: (context, snap) {
            final n = snap.data?.docs.length ?? 0;
            final count = snap.data?.docs.fold<int>(
                  0,
                  (a, d) =>
                      a + ((d.data()['quantity'] as num?)?.toInt() ?? 1),
                ) ??
                0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Shopping Cart',
                  style: TextStyle(
                    color: _brown,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                Text(
                  n == 0 ? '0 items' : '$count item${count == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
          if (docs.isEmpty) {
            return const Center(child: Text('Cart is empty.'));
          }
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
                            backgroundColor: _teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
    final discountPct = (item['discountPercent'] as num?)?.toDouble();

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
          Stack(
            clipBehavior: Clip.none,
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
              if (discountPct != null && discountPct > 0)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '-${discountPct.round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
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
              CartQuantityButton(icon: Icons.remove, onTap: onDecrease),
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
              CartQuantityButton(icon: Icons.add, onTap: onIncrease),
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

/// Shared +/- control (product page + cart).
class CartQuantityButton extends StatelessWidget {
  const CartQuantityButton({super.key, required this.icon, required this.onTap});

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
