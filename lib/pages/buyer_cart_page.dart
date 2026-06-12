import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';
import 'store_details.dart' show CheckoutPage;

/// Shopping cart (pet supplies).
///
/// When [storeId] is provided the cart is filtered to that store only.
/// Without [storeId] all stores are shown grouped by store.
class MyCartPage extends StatefulWidget {
  const MyCartPage({super.key, this.storeId, this.storeName});

  final String? storeId;
  final String? storeName;

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  final DatabaseService _db = DatabaseService();

  static const _bg = Color(0xFFEFFBFC);
  static const _brown = Color(0xFF5A2F0E);
  static const _teal = Color(0xFF4FA294);

  bool get _isFiltered => (widget.storeId ?? '').isNotEmpty;

  double _subtotal(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.fold<double>(
      0,
      (acc, doc) =>
          acc +
          (((doc.data()['price'] as num?)?.toDouble() ?? 0) *
              ((doc.data()['quantity'] as num?)?.toInt() ?? 1)),
    );
  }

  Future<double> _fetchDiscount(
    String storeId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    double subtotal,
  ) async {
    if (storeId.isEmpty) return 0;
    try {
      final offers = await _db.fetchActivePetStoreOffers(storeId);
      double best = 0;
      for (final offer in offers.where((o) => o['kind'] == 'store_wide')) {
        final minOrder = ((offer['minOrderJod'] as num?)?.toDouble() ?? 0);
        final pct = ((offer['discountPercent'] as num?)?.toDouble() ?? 0);
        final filterByPriceRange = offer['filterByPriceRange'] as bool? ?? false;
        if (pct <= 0 || subtotal < minOrder) continue;
        double qualifying = subtotal;
        if (filterByPriceRange) {
          final pMin = ((offer['priceMinJod'] as num?)?.toDouble() ?? 0);
          final pMax = ((offer['priceMaxJod'] as num?)?.toDouble() ?? 0);
          qualifying = docs.fold(0.0, (acc, doc) {
            final price = ((doc.data()['price'] as num?)?.toDouble() ?? 0);
            final qty = ((doc.data()['quantity'] as num?)?.toInt() ?? 1);
            return (pMin <= price && price <= pMax) ? acc + price * qty : acc;
          });
        }
        if (qualifying <= 0) continue;
        final value = qualifying * (pct / 100);
        if (value > best) best = value;
      }
      return best;
    } catch (_) {
      return 0;
    }
  }

  Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> _groupByStore(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final map = <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
    for (final doc in docs) {
      final sid = (doc.data()['storeId'] ?? '').toString();
      map.putIfAbsent(sid, () => []).add(doc);
    }
    return map;
  }

  String _storeLabel(
    String storeId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> items,
  ) {
    final name =
        (items.first.data()['storeName'] ?? '').toString().trim();
    return name.isNotEmpty ? name : 'Store';
  }

  Widget _buildItemList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final item = docs[index].data();
        final qty = ((item['quantity'] as num?)?.toInt() ?? 1);
        final productId = (item['productId'] ?? docs[index].id).toString();
        return _CartProductCard(
          item: item,
          quantity: qty,
          onDecrease: qty <= 1
              ? null
              : () => _db.addOrUpdateCartItem(
                    storeId: (item['storeId'] ?? '').toString(),
                    productId: productId,
                    quantity: qty - 1,
                    productSnapshot: item,
                  ),
          onIncrease: () => _db.addOrUpdateCartItem(
            storeId: (item['storeId'] ?? '').toString(),
            productId: productId,
            quantity: qty + 1,
            productSnapshot: item,
          ),
          onRemove: () => _db.removeCartItem(productId),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final subtotal = _subtotal(docs);
    const deliveryFee = 5.0;
    final storeId = docs.isNotEmpty
        ? (docs.first.data()['storeId'] ?? '').toString()
        : '';
    return FutureBuilder<double>(
      future: _fetchDiscount(storeId, docs, subtotal),
      builder: (context, snap) {
        final discount = snap.data ?? 0;
        final total = subtotal - discount + deliveryFee;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.teal.shade100),
          ),
          child: Column(
            children: [
              _summaryRow('Subtotal', subtotal),
              if (discount > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Discount',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '-${discount.toStringAsFixed(2)} JOD',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              _summaryRow('Delivery Fee', deliveryFee),
              Divider(height: 22, color: Colors.teal.shade100),
              _summaryRow('Total', total, bold: true),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CheckoutPage(cartDocs: docs, subtotal: subtotal),
                    ),
                  ),
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
        );
      },
    );
  }

  Widget _summaryRow(String label, double amount, {bool bold = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: _brown,
            fontSize: bold ? 17 : 16,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          '${amount.toStringAsFixed(2)} JOD',
          style: TextStyle(
            color: bold ? Colors.green : _brown,
            fontSize: bold ? 17 : 16,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── Filtered (single-store) view ──────────────────────────────────────────

  Widget _buildFilteredBody(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Your cart for this store is empty.',
              style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 15),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [_buildItemList(docs)],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildSummaryCard(docs),
        ),
      ],
    );
  }

  // ── Grouped (all-stores) view ─────────────────────────────────────────────

  Widget _buildGroupedBody(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs,
  ) {
    if (allDocs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty.',
              style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 15),
            ),
          ],
        ),
      );
    }

    final groups = _groupByStore(allDocs);
    final storeIds = groups.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: storeIds.length,
      itemBuilder: (context, i) {
        final sid = storeIds[i];
        final items = groups[sid]!;
        final label = _storeLabel(sid, items);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (i > 0) const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.storefront_outlined,
                    size: 18, color: Color(0xFF4FA294)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF2D6A64),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildItemList(items),
            const SizedBox(height: 14),
            _buildSummaryCard(items),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = _isFiltered
        ? _db.streamMyCartForStore(widget.storeId!)
        : _db.streamMyCart();

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
        title: _isFiltered
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.storeName ?? 'Store Cart',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _brown,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const Text(
                    'Shopping Cart',
                    style: TextStyle(
                      color: Color(0xFF4FA294),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Text(
                'My Carts',
                style: TextStyle(
                  color: _brown,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4FA294)),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load cart.'));
          }
          final docs = snapshot.data?.docs ?? [];
          return _isFiltered
              ? _buildFilteredBody(docs)
              : _buildGroupedBody(docs);
        },
      ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildProductImage(image),
                  ),
                  if (discountPct != null && discountPct > 0)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${discountPct.round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
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
                        fontSize: 15,
                      ),
                    ),
                    if (brand.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon:
                    const Icon(Icons.delete_outline, color: Colors.redAccent),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${(price * quantity).toStringAsFixed(2)} JOD',
                style: const TextStyle(
                  color: Color(0xFF4FA294),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              if (quantity > 1) ...[
                const SizedBox(width: 6),
                Text(
                  '(${price.toStringAsFixed(2)} × $quantity)',
                  style: TextStyle(
                    color: Colors.blueGrey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
              const Spacer(),
              CartQuantityButton(
                icon: Icons.remove,
                onTap: onDecrease,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF5A2F0E),
                  ),
                ),
              ),
              CartQuantityButton(icon: Icons.add, onTap: onIncrease),
            ],
          ),
        ],
      ),
    );
  }
}

class CartQuantityButton extends StatelessWidget {
  const CartQuantityButton({super.key, required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap == null
              ? Colors.grey.shade100
              : const Color(0xFFEFFBFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap == null
                ? Colors.grey.shade300
                : const Color(0xFF4FA294),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? Colors.grey.shade400
              : const Color(0xFF4FA294),
        ),
      ),
    );
  }
}

Widget _buildProductImage(String url) {
  const placeholder = SizedBox(
    width: 80,
    height: 80,
    child: ColoredBox(
      color: Color(0xFFECF5F4),
      child: Center(
        child: Icon(Icons.pets, color: Color(0xFF4FA294), size: 30),
      ),
    ),
  );
  if (url.isEmpty) return placeholder;
  if (url.startsWith('data:')) {
    try {
      final bytes = base64Decode(url.substring(url.indexOf(',') + 1));
      return Image.memory(bytes,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, e, s) => placeholder);
    } catch (_) {
      return placeholder;
    }
  }
  return Image.network(url,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, e, s) => placeholder);
}
