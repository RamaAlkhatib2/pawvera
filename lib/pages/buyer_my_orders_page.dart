import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';
import 'buyer_cart_page.dart';

bool _isPastBuyerOrderStatus(String raw) {
  final s = raw.toLowerCase().trim();
  return s == 'completed' || s == 'delivered' || s == 'cancelled';
}

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final _searchController = TextEditingController();
  String _query = '';
  int _streamRetryKey = 0;
  String? _reorderingOrderId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _repeatOrder(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    DatabaseService service,
  ) async {
    final id = doc.id;
    setState(() => _reorderingOrderId = id);
    try {
      await service.refillCartFromPetStoreOrder(doc.data());
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => const MyCartPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _reorderingOrderId = null);
    }
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
        key: ValueKey<int>(_streamRetryKey),
        stream: service.streamMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5BA092)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Could not load orders.'),
                    const SizedBox(height: 12),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          setState(() => _streamRetryKey++),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final rawDocs = snapshot.data?.docs ?? [];
          final allDocs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            rawDocs,
          )..sort((a, b) {
              final ta = a.data()['createdAt'];
              final tb = b.data()['createdAt'];
              if (ta is Timestamp && tb is Timestamp) {
                return tb.compareTo(ta);
              }
              if (ta is Timestamp) return -1;
              if (tb is Timestamp) return 1;
              return b.id.compareTo(a.id);
            });
          final filtered = allDocs
              .where((doc) => _matchesOrder(doc.id, doc.data()))
              .toList();
          final currentOrders = filtered
              .where(
                (doc) => !_isPastBuyerOrderStatus(
                  (doc.data()['status'] ?? '').toString(),
                ),
              )
              .toList();
          final pastOrders = filtered
              .where(
                (doc) => _isPastBuyerOrderStatus(
                  (doc.data()['status'] ?? '').toString(),
                ),
              )
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
                  child: allDocs.isEmpty
                      ? const Center(child: Text('You have no orders yet.'))
                      : filtered.isEmpty
                          ? const Center(
                              child: Text('No orders match your search.'),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                22,
                                0,
                                22,
                                22,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (currentOrders.isNotEmpty) ...[
                                    _sectionHeader(
                                      'Current orders',
                                      currentOrders.length,
                                    ),
                                    ...currentOrders.map(
                                      (doc) => _orderCardFor(
                                        context,
                                        doc,
                                        service,
                                      ),
                                    ),
                                  ],
                                  if (pastOrders.isNotEmpty) ...[
                                    if (currentOrders.isNotEmpty)
                                      const SizedBox(height: 12),
                                    _sectionHeader(
                                      'Past orders',
                                      pastOrders.length,
                                    ),
                                    ...pastOrders.map(
                                      (doc) => _orderCardFor(
                                        context,
                                        doc,
                                        service,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
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

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF5A3E2B),
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const Spacer(),
          Text(
            '$count',
            style: TextStyle(
              color: Colors.blueGrey.shade600,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderCardFor(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    DatabaseService service,
  ) {
    final orderId = doc.id;
    final order = doc.data();
    final status = (order['status'] ?? 'pending').toString();
    final normalizedStatus = status.toLowerCase();
    final isRated = order['isRated'] == true;
    final canRate =
        (normalizedStatus == 'completed' || normalizedStatus == 'delivered') &&
        !isRated;
    return _OrderCard(
      orderId: orderId,
      order: order,
      isReordering: _reorderingOrderId == orderId,
      onOrderAgain: () => _repeatOrder(doc, service),
      onRate: canRate
          ? () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => _RatePetStoreOrderSheet(
                  databaseService: service,
                  orderDocId: orderId,
                  order: order,
                ),
              );
            }
          : null,
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.orderId,
    required this.order,
    required this.isReordering,
    required this.onOrderAgain,
    required this.onRate,
  });

  final String orderId;
  final Map<String, dynamic> order;
  final bool isReordering;
  final VoidCallback onOrderAgain;
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
                  onPressed: isReordering ? null : onOrderAgain,
                  icon: isReordering
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(isReordering ? 'Adding…' : 'Order Again'),
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
  // One stars value + comment controller per product.
  final Map<String, int> _productStars = {};
  final Map<String, TextEditingController> _productComments = {};
  // Ordered list of (productId, title) so the UI preserves order.
  final List<MapEntry<String, String>> _products = [];

  final _storeComment = TextEditingController();
  late final String _storeId;
  int _storeStars = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _storeId = (widget.order['storeId'] ?? '').toString();
    final items = _orderLineItems(widget.order);
    final seen = <String>{};
    for (final m in items) {
      final pid = (m['productId'] ?? m['id'] ?? '').toString().trim();
      if (pid.isEmpty || !seen.add(pid)) continue;
      _products.add(MapEntry(pid, (m['title'] ?? pid).toString()));
      _productStars[pid] = 0;
      _productComments[pid] = TextEditingController();
    }
    _loadExistingRatings();
  }

  Future<void> _loadExistingRatings() async {
    try {
      final ratings = await widget.databaseService.fetchExistingOrderRatings(
        orderId: widget.orderDocId,
        storeId: _storeId,
        productIds: _products.map((e) => e.key).toList(),
      );
      if (!mounted) return;
      setState(() {
        _storeStars = ratings['store'] ?? 0;
        for (final entry in _products) {
          _productStars[entry.key] = ratings[entry.key] ?? 0;
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final c in _productComments.values) {
      c.dispose();
    }
    _storeComment.dispose();
    super.dispose();
  }

  Widget _starRow({required int value, required ValueChanged<int> onChanged}) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        return IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => onChanged(n),
          icon: Icon(
            value >= n ? Icons.star : Icons.star_border,
            color: Colors.amber,
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
    if (_storeStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please rate the store before submitting.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final customerName =
          await widget.databaseService.fetchCurrentUserName();
      // Rate each product the user tapped stars for.
      for (final entry in _products) {
        final stars = _productStars[entry.key] ?? 0;
        if (stars == 0) continue;
        await widget.databaseService.rateProduct(
          storeId: _storeId,
          productId: entry.key,
          stars: stars,
          comment: _productComments[entry.key]?.text.trim(),
          orderId: widget.orderDocId,
          customerName: customerName.isEmpty ? null : customerName,
        );
      }
      await widget.databaseService.rateStore(
        storeId: _storeId,
        stars: _storeStars,
        comment: _storeComment.text.trim(),
        orderId: widget.orderDocId,
        customerName: customerName.isEmpty ? null : customerName,
      );
      // Stamp the order so the "Rate Order" button disappears permanently.
      await widget.databaseService.markOrderAsRated(widget.orderDocId);
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
                // Drag handle
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // ── Per-product rating rows ─────────────────────────────
                if (_products.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  for (final entry in _products) ...[
                    Text(
                      entry.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    _starRow(
                      value: _productStars[entry.key] ?? 0,
                      onChanged: (n) =>
                          setState(() => _productStars[entry.key] = n),
                    ),
                    TextField(
                      controller: _productComments[entry.key],
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Product comment (optional)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Divider(color: Colors.grey.shade200),
                ],
                // ── Store rating ────────────────────────────────────────
                const SizedBox(height: 4),
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
                    hintText: 'Store comment (optional)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
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


