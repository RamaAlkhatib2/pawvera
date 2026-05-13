import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';

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
                    return 'â€¢ $title x$qty';
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


