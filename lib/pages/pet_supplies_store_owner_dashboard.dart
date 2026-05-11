import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../services/database_service.dart';
import 'login_view.dart';

// ─── Design tokens (match legacy store dashboard) ───────────────────────────

const Color _kBrown = Color(0xFF634732);
const Color _kTeal = Color(0xFF4A908A);
const Color _kBg = Color(0xFFE8F5F0);
const Color _kOrange = Color(0xFFFF8A50);
const Color _kBlueOffer = Color(0xFF5B8FD9);

String _productImageUrl(Map<String, dynamic> p) =>
    (p['image'] ?? p['imageUrl'] ?? '').toString().trim();

String _formatPetStoreOfferValidUntil(Map<String, dynamic> m) {
  final vu = m['validUntil'];
  if (vu is Timestamp) {
    return DateFormat.yMMMd().format(vu.toDate());
  }
  return (m['validUntilText'] ?? '').toString().trim();
}

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
          return const Scaffold(
            backgroundColor: _kBg,
            body: Center(child: CircularProgressIndicator(color: _kTeal)),
          );
        }
        final storeId = snapshot.data;
        if (storeId == null) {
          return const Scaffold(
            body: Center(child: Text('No store found.')),
          );
        }
        return Scaffold(
          backgroundColor: _kBg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _DashboardHeader(
                    storeId: storeId,
                    firestore: _firestore,
                    auth: _auth,
                    databaseService: _databaseService,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _HorizontalTabBar(
                    selectedIndex: _tab,
                    onSelect: (i) => setState(() => _tab = i),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _TabBody(
                    tab: _tab,
                    storeId: storeId,
                    databaseService: _databaseService,
                    firestore: _firestore,
                    onGoToOrders: () => setState(() => _tab = 1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String storeId;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final DatabaseService databaseService;

  const _DashboardHeader({
    required this.storeId,
    required this.firestore,
    required this.auth,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    // Use this context for navigation after async work — do not use the
    // StreamBuilder builder's context (it can be deactivated when the stream updates).
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: firestore.collection('users').doc(storeId).snapshots(),
      builder: (snapshotContext, snap) {
        final data = snap.data?.data() ?? const <String, dynamic>{};
        final storeName =
            (data['businessName'] ?? data['name'] ?? 'Your store').toString();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pet Supplies Store Dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _kBrown,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    storeName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderIconButton(
              icon: Icons.person_outline,
              label: 'Profile',
              onPressed: () => _openProfileSheet(
                context,
                storeId: storeId,
                data: data,
                databaseService: databaseService,
              ),
            ),
            const SizedBox(width: 8),
            _HeaderIconButton(
              icon: Icons.logout,
              label: 'Logout',
              onPressed: () => _logout(context, auth),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _logout(BuildContext navigatorContext, FirebaseAuth auth) async {
    try {
      await auth.signOut();
    } catch (e) {
      if (!navigatorContext.mounted) return;
      ScaffoldMessenger.of(navigatorContext).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
      return;
    }
    if (!navigatorContext.mounted) return;
    Navigator.of(navigatorContext, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginView()),
                    (route) => false,
                  );
  }

  static Future<void> _openProfileSheet(
    BuildContext context, {
    required String storeId,
    required Map<String, dynamic> data,
    required DatabaseService databaseService,
  }) async {
    final nameCtrl = TextEditingController(
      text: (data['businessName'] ?? data['name'] ?? '').toString(),
    );
    final emailCtrl = TextEditingController(
      text: (data['email'] ?? '').toString(),
    );
    final phoneCtrl = TextEditingController(
      text: (data['phone'] ?? '').toString(),
    );
    final addressCtrl = TextEditingController(
      text: (data['address'] ?? '').toString(),
    );
    final hoursCtrl = TextEditingController(
      text: (data['businessHours'] ?? data['hours'] ?? '').toString(),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Store profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kBrown,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Business name'),
              ),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                readOnly: true,
              ),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: hoursCtrl,
                decoration: const InputDecoration(
                  labelText: 'Hours (e.g. 9AM - 9PM)',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _kTeal),
                onPressed: () async {
                  try {
                    await databaseService.updateStoreProfile(storeId, {
                      'businessName': nameCtrl.text.trim(),
                      'phone': phoneCtrl.text.trim(),
                      'address': addressCtrl.text.trim(),
                      'businessHours': hoursCtrl.text.trim(),
                    });
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                  } catch (e) {
                    if (!ctx.mounted) return;
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('$e')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: _kTeal),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: _kBrown),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _HorizontalTabBar({
    required this.selectedIndex,
    required this.onSelect,
  });

  static const _tabs = [
    ('Overview', Icons.bar_chart_outlined),
    ('Orders', Icons.assignment_outlined),
    ('Products', Icons.inventory_2_outlined),
    ('Offers', Icons.local_offer_outlined),
    ('Reviews', Icons.star_outline),
    ('Store', Icons.storefront_outlined),
    ('Audit', Icons.fact_check_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final sel = selectedIndex == index;
          final (label, icon) = _tabs[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: sel ? _kTeal : Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => onSelect(index),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: sel ? null : Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: sel ? Colors.white : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          color: sel ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  final int tab;
  final String storeId;
  final DatabaseService databaseService;
  final FirebaseFirestore firestore;
  final VoidCallback onGoToOrders;

  const _TabBody({
    required this.tab,
    required this.storeId,
    required this.databaseService,
    required this.firestore,
    required this.onGoToOrders,
  });

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      0 => _OverviewTab(
          storeId: storeId,
          databaseService: databaseService,
          firestore: firestore,
          onViewAllOrders: onGoToOrders,
        ),
      1 => _OrdersManagerTab(
          storeId: storeId,
          databaseService: databaseService,
        ),
      2 => _ProductsManagerTab(
          storeId: storeId,
          databaseService: databaseService,
        ),
      3 => _OffersTab(
          storeId: storeId,
          databaseService: databaseService,
        ),
      4 => _ReviewsTab(
          storeId: storeId,
          databaseService: databaseService,
        ),
      5 => _StoreSettingsTab(
          storeId: storeId,
          firestore: firestore,
          databaseService: databaseService,
        ),
      6 => _AuditTab(
          storeId: storeId,
          databaseService: databaseService,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

// ─── Overview (live metrics + store status + recent orders) ──────────────────

class _OverviewTab extends StatelessWidget {
  final String storeId;
  final DatabaseService databaseService;
  final FirebaseFirestore firestore;
  final VoidCallback onViewAllOrders;

  const _OverviewTab({
    required this.storeId,
    required this.databaseService,
    required this.firestore,
    required this.onViewAllOrders,
  });

  static List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortedOrders(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) {
    final docs = snap.docs.toList();
    docs.sort((a, b) {
      final ta = a.data()['createdAt'];
      final tb = b.data()['createdAt'];
      if (ta is Timestamp && tb is Timestamp) {
        return tb.compareTo(ta);
      }
      return 0;
    });
    return docs;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: firestore.collection('users').doc(storeId).snapshots(),
      builder: (context, userSnap) {
        final userData = userSnap.data?.data() ?? const <String, dynamic>{};
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: databaseService.streamOrdersForStoreOwner(storeId),
          builder: (context, orderSnap) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: databaseService.streamProductsForStoreOwner(storeId),
              builder: (context, prodSnap) {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: databaseService.streamStoreReviews(storeId),
                  builder: (context, revSnap) {
                    final orders = orderSnap.data?.docs ?? [];
                    final products = prodSnap.data ?? [];
                    final reviews = revSnap.data?.docs ?? [];

                    final orderDocs = orderSnap.hasData
                        ? _sortedOrders(orderSnap.data!)
                        : <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                    final totalOrders = orders.length;
                    final activeStatuses = {
                      'pending',
                      'confirmed',
                      'preparing',
                      'out_for_delivery',
                    };
                    final activeOrders = orders
                        .where((d) => activeStatuses
                            .contains((d.data()['status'] ?? '').toString()))
                        .length;
                    double revenue = 0;
                    for (final d in orders) {
                      final st = (d.data()['status'] ?? '').toString();
                      if (st == 'delivered' || st == 'completed') {
                        revenue +=
                            ((d.data()['total'] as num?)?.toDouble() ?? 0);
                      }
                    }

                    double avgRating = 0;
                    if (reviews.isNotEmpty) {
                      var sum = 0.0;
                      for (final r in reviews) {
                        sum += ((r.data()['stars'] as num?)?.toDouble() ?? 0);
                      }
                      avgRating = sum / reviews.length;
                    }

                    final lowStock = products.where((p) {
                      final s = (p['stock'] as num?)?.toInt() ?? 0;
                      return s > 0 && s <= 10;
                    }).length;

                    final isOpen = userData['isActive'] == true ||
                        (userData['status'] ?? '').toString() == 'active';
                    final storeName = (userData['businessName'] ??
                            userData['name'] ??
                            'Store')
                        .toString();
                    final address =
                        (userData['address'] ?? '').toString().trim();
                    final city = (userData['city'] ?? '').toString().trim();
                    final locationLine = [address, city]
                        .where((e) => e.isNotEmpty)
                        .join(' • ');
                    final hours = (userData['businessHours'] ??
                            userData['hours'] ??
                            '—')
                        .toString();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Total Orders',
                                value: '$totalOrders',
                                icon: Icons.shopping_bag_outlined,
                                iconBg: const Color(0xFFE3F2FD),
                                iconColor: const Color(0xFF1976D2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Active Orders',
                                value: '$activeOrders',
                                icon: Icons.local_shipping_outlined,
                                iconBg: const Color(0xFFF3E5F5),
                                iconColor: const Color(0xFF9C27B0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Total Revenue',
                                value: '${revenue.toStringAsFixed(2)} JOD',
                                icon: Icons.attach_money,
                                iconBg: const Color(0xFFF0F4F3),
                                iconColor: _kTeal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Store Rating',
                                value: reviews.isEmpty
                                    ? '—'
                                    : '${avgRating.toStringAsFixed(1)} ⭐',
                                icon: Icons.star_outline,
                                iconBg: const Color(0xFFFFF3E0),
                                iconColor: const Color(0xFFFFA500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (lowStock > 0)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5D9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFB38A)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_rounded,
                                    color: Color(0xFFFF6B35), size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Low Stock Alert',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _kBrown,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$lowStock product(s) running low on stock. Review your inventory.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (lowStock > 0) const SizedBox(height: 20),
                        _StoreStatusCard(
                          storeId: storeId,
                          isOpen: isOpen,
                          storeName: storeName,
                          locationLine:
                              locationLine.isEmpty ? '—' : locationLine,
                          hours: hours,
                          databaseService: databaseService,
                        ),
                        const SizedBox(height: 20),
                        _RecentOrdersCard(
                          orders: orderDocs.take(5).toList(),
                          onViewAll: onViewAllOrders,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _kBrown,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreStatusCard extends StatelessWidget {
  final String storeId;
  final bool isOpen;
  final String storeName;
  final String locationLine;
  final String hours;
  final DatabaseService databaseService;

  const _StoreStatusCard({
    required this.storeId,
    required this.isOpen,
    required this.storeName,
    required this.locationLine,
    required this.hours,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Store Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kBrown,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen ? const Color(0xFF4CAF50) : const Color(0xFFFF6B6B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOpen ? 'OPEN' : 'CLOSED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.store, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(child: Text(storeName)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(child: Text(locationLine)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(hours),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isOpen
                      ? null
                      : () async {
                          try {
                            await databaseService.updateStoreStatus(
                              storeId: storeId,
                              isOpen: true,
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$e')),
                            );
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(
                      color: !isOpen ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor:
                        !isOpen ? const Color(0xFF4CAF50) : Colors.grey,
                  ),
                  child: const Text('Open Store'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: !isOpen
                      ? null
                      : () async {
                          try {
                            await databaseService.updateStoreStatus(
                              storeId: storeId,
                              isOpen: false,
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$e')),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isOpen ? _kTeal : Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Close Store',
                    style: TextStyle(color: Colors.white),
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

class _RecentOrdersCard extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> orders;
  final VoidCallback onViewAll;

  const _RecentOrdersCard({
    required this.orders,
    required this.onViewAll,
  });

  static String _orderLabel(Map<String, dynamic> o, String docId) {
    final id = (o['id'] ?? docId).toString();
    if (id.length <= 8) return '#$id';
    return '#${id.substring(id.length - 6)}';
  }

  static String _subtitle(Map<String, dynamic> o) {
    final addr = o['deliveryAddress'];
    if (addr is Map && (addr['address'] ?? '').toString().isNotEmpty) {
      return (addr['address'] ?? '').toString();
    }
    final uid = (o['userId'] ?? '').toString();
    if (uid.length > 6) return 'Customer ${uid.substring(0, 6)}…';
    return 'Customer';
  }

  static String _displayStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return raw.isEmpty ? 'Pending' : raw;
    }
  }

  static Color _statusColor(String display) {
    switch (display) {
      case 'Pending':
        return const Color(0xFFFFA500);
      case 'Confirmed':
        return const Color(0xFF2196F3);
      case 'Preparing':
        return const Color(0xFF7E57C2);
      case 'Out for Delivery':
        return const Color(0xFF9C27B0);
      case 'Delivered':
      case 'Completed':
        return const Color(0xFF4CAF50);
      case 'Cancelled':
        return Colors.grey.shade600;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _kBrown,
            ),
          ),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No orders yet.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ...List.generate(orders.length, (i) {
              final doc = orders[i];
              final o = doc.data();
              final status = _displayStatus((o['status'] ?? '').toString());
              return Column(
                children: [
                  if (i > 0) ...[
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _orderLabel(o, doc.id),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _kBrown,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _subtitle(o),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (i < orders.length - 1) const SizedBox(height: 8),
                ],
              );
            }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewAll,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFE8F5EE),
                foregroundColor: _kTeal,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'View All Orders',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pet store order helpers (Orders tab + detail dialog) ───────────────────

String _petStoreOrderCode(String docId) {
  if (docId.isEmpty) return 'ORD';
  final tail =
      docId.length <= 6 ? docId : docId.substring(docId.length - 6);
  return 'ORD${tail.toUpperCase()}';
}

String _petStorePaymentLabel(dynamic raw) {
  switch ('${raw ?? ''}'.toLowerCase()) {
    case 'cash':
      return 'Cash on Delivery';
    case 'credit':
      return 'Credit Card';
    default:
      final s = '$raw'.trim();
      return s.isEmpty ? '—' : s;
  }
}

String _petStoreFormatOrderDate(dynamic createdAt) {
  if (createdAt is Timestamp) {
    return DateFormat("MMM dd, yyyy 'at' h:mm a").format(createdAt.toDate());
  }
  return '—';
}

String _petStoreFormatCompletedDate(dynamic createdAt) {
  if (createdAt is Timestamp) {
    return DateFormat('MMM dd, yyyy').format(createdAt.toDate());
  }
  return '—';
}

bool _petStoreIsPipelineStatus(String raw) {
  return const {
    'pending',
    'confirmed',
    'preparing',
    'out_for_delivery',
  }.contains(raw.toLowerCase());
}

class _PetStoreOrderDetailDialog extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> order;
  final DatabaseService databaseService;

  const _PetStoreOrderDetailDialog({
    required this.docId,
    required this.order,
    required this.databaseService,
  });

  static Future<void> show(
    BuildContext context, {
    required String docId,
    required Map<String, dynamic> order,
    required DatabaseService databaseService,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black45,
      builder: (ctx) => _PetStoreOrderDetailDialog(
        docId: docId,
        order: order,
        databaseService: databaseService,
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              k,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: _kBrown,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: _kBrown,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = (order['userId'] ?? '').toString();
    final addr = order['deliveryAddress'];
    final subtotal = ((order['subtotal'] as num?)?.toDouble() ?? 0);
    final deliveryFee = ((order['deliveryFee'] as num?)?.toDouble() ?? 0);
    final total = ((order['total'] as num?)?.toDouble() ?? 0);
    final items = (order['items'] as List?) ?? [];

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: const Color(0xFFF0F9FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _kBrown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'View complete order information and customer details',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEBEB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _kv('Order ID', _petStoreOrderCode(docId)),
                          _kv('Date', _petStoreFormatOrderDate(order['createdAt'])),
                          _kv('Payment', _petStorePaymentLabel(order['paymentMethod'])),
                        ],
                      ),
                    ),
                    _heading('Customer Information'),
                    FutureBuilder<Map<String, String?>>(
                      future: databaseService.fetchBuyerPublicProfile(uid),
                      builder: (context, snap) {
                        final p = snap.data ??
                            {'name': null, 'email': null, 'phone': null};
                        final addrMap = addr is Map<String, dynamic>
                            ? addr
                            : <String, dynamic>{};
                        final phoneFromAddr =
                            (addrMap['phone'] ?? '').toString().trim();
                        final phone = (p['phone'] ?? '').toString().trim().isNotEmpty
                            ? p['phone']!
                            : phoneFromAddr;
                        final name = (p['name'] ?? '').toString().trim();
                        final email = (p['email'] ?? '').toString().trim();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _kv('Name', name.isNotEmpty ? name : '—'),
                            if (email.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 88,
                                      child: Text(
                                        'Email',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        email,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1565C0),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              _kv('Email', '—'),
                            _kv('Phone', phone.isNotEmpty ? phone : '—'),
                          ],
                        );
                      },
                    ),
                    _heading('Delivery Address'),
                    Builder(
                      builder: (context) {
                        if (addr is! Map) {
                          return Text(
                            '—',
                            style: TextStyle(color: Colors.grey.shade700),
                          );
                        }
                        final m = Map<String, dynamic>.from(addr);
                        final recipient = (m['recipientName'] ?? m['name'] ?? '')
                            .toString()
                            .trim();
                        final street = (m['address'] ?? m['street'] ?? '')
                            .toString()
                            .trim();
                        final city = (m['city'] ?? '').toString().trim();
                        final floor = (m['floor'] ?? '').toString().trim();
                        final apt = (m['apartment'] ?? m['apt'] ?? '')
                            .toString()
                            .trim();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (recipient.isNotEmpty) _kv('Name', recipient),
                            if (street.isNotEmpty) _kv('Street', street),
                            if (city.isNotEmpty) _kv('City', city),
                            if (floor.isNotEmpty) _kv('Floor', floor),
                            if (apt.isNotEmpty) _kv('Apartment', apt),
                            if (recipient.isEmpty &&
                                street.isEmpty &&
                                city.isEmpty &&
                                floor.isEmpty &&
                                apt.isEmpty)
                              Text(
                                '—',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                          ],
                        );
                      },
                    ),
                    _heading('Order Items'),
                    ...items.map<Widget>((e) {
                      if (e is! Map) {
                        return const SizedBox.shrink();
                      }
                      final title = (e['title'] ?? 'Item').toString();
                      final qty = (e['quantity'] as num?)?.toInt() ?? 1;
                      final unit = (e['price'] as num?)?.toDouble() ?? 0;
                      final line = unit * qty;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBEBEB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$title × $qty',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _kBrown,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '${line.toStringAsFixed(2)} JOD',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _kBrown,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 24),
                    _summaryRow('Subtotal', '${subtotal.toStringAsFixed(2)} JOD'),
                    _summaryRow(
                      'Delivery Fee',
                      '${deliveryFee.toStringAsFixed(2)} JOD',
                    ),
                    const Divider(height: 20),
                    _summaryRow(
                      'Total Amount',
                      '${total.toStringAsFixed(2)} JOD',
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _kTeal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: _kBrown,
              fontSize: bold ? 14 : 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: _kBrown,
              fontSize: bold ? 14 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactPastOrderCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final DatabaseService databaseService;
  final int Function(List<dynamic> items) itemCountFn;

  const _CompactPastOrderCard({
    required this.doc,
    required this.databaseService,
    required this.itemCountFn,
  });

  @override
  Widget build(BuildContext context) {
    final order = doc.data();
    final statusRaw = (order['status'] ?? '').toString();
    final disp = _OrdersManagerTabState._displayStatus(statusRaw);
    final color = _OrdersManagerTabState._statusPillColor(disp);
    final total = ((order['total'] as num?)?.toDouble() ?? 0).toStringAsFixed(2);
    final items = (order['items'] as List?) ?? [];
    final n = itemCountFn(items);
    final userId = (order['userId'] ?? '').toString();
    final dateStr = _petStoreFormatCompletedDate(order['createdAt']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _petStoreOrderCode(doc.id),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _kBrown,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<String?>(
                            future: databaseService.fetchUserDisplayName(userId),
                            builder: (context, nameSnap) {
                              return Text(
                                nameSnap.data ?? 'Customer',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        disp,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      n == 1 ? '1 item' : '$n items',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '$total JOD',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _kBrown,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _PetStoreOrderDetailDialog.show(
                      context,
                      docId: doc.id,
                      order: order,
                      databaseService: databaseService,
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: _kBrown,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

// ─── Orders tab ──────────────────────────────────────────────────────────────

class _OrdersManagerTab extends StatefulWidget {
  final String storeId;
  final DatabaseService databaseService;

  const _OrdersManagerTab({
    required this.storeId,
    required this.databaseService,
  });

  @override
  State<_OrdersManagerTab> createState() => _OrdersManagerTabState();
}

class _OrdersManagerTabState extends State<_OrdersManagerTab> {
  final _search = TextEditingController();
  DateTime? _filterDate;
  String _statusChip = 'all';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  static List<QueryDocumentSnapshot<Map<String, dynamic>>> _sort(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) {
    final docs = snap.docs.toList();
    docs.sort((a, b) {
      final ta = a.data()['createdAt'];
      final tb = b.data()['createdAt'];
      if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
      return 0;
    });
    return docs;
  }

  static String _displayStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return raw;
    }
  }

  static Color _statusPillColor(String display) {
    switch (display) {
      case 'Pending':
        return const Color(0xFFFFC107);
      case 'Confirmed':
        return const Color(0xFF2196F3);
      case 'Preparing':
        return const Color(0xFF7E57C2);
      case 'Out for Delivery':
        return const Color(0xFF9C27B0);
      case 'Delivered':
      case 'Completed':
        return const Color(0xFF4CAF50);
      case 'Cancelled':
        return Colors.grey.shade600;
      default:
        return _kTeal;
    }
  }

  int _itemCount(List<dynamic> items) {
    var n = 0;
    for (final e in items) {
      if (e is Map) {
        n += ((e['quantity'] as num?)?.toInt() ?? 1);
      } else {
        n += 1;
      }
    }
    return n == 0 ? items.length : n;
  }

  bool _matchesFilters(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String q,
    DateTime? dateOnly,
    String chip,
  ) {
    final o = doc.data();
    final id = (o['id'] ?? doc.id).toString();
    final status = (o['status'] ?? '').toString().toLowerCase();
    final disp = _displayStatus(status);
    final items = (o['items'] as List?) ?? [];
    final itemStr = items.map((e) => e.toString()).join(' ').toLowerCase();
    final addr = o['deliveryAddress'];
    final addrStr = addr is Map ? addr.values.join(' ').toLowerCase() : '';
    final userId = (o['userId'] ?? '').toString().toLowerCase();
    if (q.isNotEmpty) {
      final hay = '$id $status $disp $itemStr $addrStr $userId'.toLowerCase();
      if (!hay.contains(q)) return false;
    }
    if (dateOnly != null) {
      final ts = o['createdAt'];
      if (ts is Timestamp) {
        final d = ts.toDate();
        if (d.year != dateOnly.year ||
            d.month != dateOnly.month ||
            d.day != dateOnly.day) {
          return false;
        }
      } else {
        return false;
      }
    }
    switch (chip) {
      case 'pending':
        return status == 'pending';
      case 'confirmed':
        return status == 'confirmed';
      case 'prep':
        return status == 'preparing';
      case 'out':
        return status == 'out_for_delivery';
      case 'past':
        return {'delivered', 'completed', 'cancelled'}.contains(status);
      default:
        return true;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (d != null) setState(() => _filterDate = d);
  }

  Widget _chip(String id, String label) {
    final sel = _statusChip == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: sel,
        onSelected: (_) => setState(() => _statusChip = id),
        selectedColor: _kTeal,
        labelStyle: TextStyle(
          color: sel ? Colors.white : _kBrown,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: sel ? _kTeal : Colors.grey.shade300),
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: widget.databaseService.streamOrdersForStoreOwner(widget.storeId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: _kTeal));
        }
        final allDocs = _OrdersManagerTabState._sort(snap.data!);
        final q = _search.text.trim().toLowerCase();
        final docs =
            allDocs.where((d) => _matchesFilters(d, q, _filterDate, _statusChip)).toList();

        List<Widget> buildOrderBody() {
          if (docs.isEmpty) {
            return [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  allDocs.isEmpty ? 'No orders yet.' : 'No orders match filters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ];
          }
          final split =
              _statusChip == 'all' && q.isEmpty && _filterDate == null;
          if (split) {
            final pipeline = docs
                .where(
                  (d) => _petStoreIsPipelineStatus(
                    (d.data()['status'] ?? '').toString(),
                  ),
                )
                .toList();
            final done = docs.where((d) {
              final s = (d.data()['status'] ?? '').toString().toLowerCase();
              return s == 'delivered' || s == 'completed';
            }).toList();
            final cancelled = docs.where((d) {
              final s = (d.data()['status'] ?? '').toString().toLowerCase();
              return s == 'cancelled';
            }).toList();
            return [
              if (pipeline.isNotEmpty) ...[
                Text(
                  'Active orders',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                ...pipeline.map(
                  (doc) => _OrderCard(
                    doc: doc,
                    databaseService: widget.databaseService,
                    itemCountFn: _itemCount,
                  ),
                ),
              ],
              if (done.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Completed orders',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _kBrown,
                  ),
                ),
                const SizedBox(height: 8),
                ...done.map(
                  (doc) => _CompactPastOrderCard(
                    doc: doc,
                    databaseService: widget.databaseService,
                    itemCountFn: _itemCount,
                  ),
                ),
              ],
              if (cancelled.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Cancelled',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                ...cancelled.map(
                  (doc) => _CompactPastOrderCard(
                    doc: doc,
                    databaseService: widget.databaseService,
                    itemCountFn: _itemCount,
                  ),
                ),
              ],
            ];
          }
          return docs.map((doc) {
            final st = (doc.data()['status'] ?? '').toString().toLowerCase();
            if (st == 'delivered' || st == 'completed' || st == 'cancelled') {
              return _CompactPastOrderCard(
                doc: doc,
                databaseService: widget.databaseService,
                itemCountFn: _itemCount,
              );
            }
            return _OrderCard(
              doc: doc,
              databaseService: widget.databaseService,
              itemCountFn: _itemCount,
            );
          }).toList();
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: _kTeal),
                hintText: 'Search by order ID, customer, status, items...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _filterDate == null
                          ? 'mm/dd/yyyy'
                          : DateFormat.yMd().format(_filterDate!),
                    ),
                  ),
                ),
                if (_filterDate != null)
                  IconButton(
                    onPressed: () => setState(() => _filterDate = null),
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('all', 'All'),
                  _chip('pending', 'Pending'),
                  _chip('confirmed', 'Confirmed'),
                  _chip('prep', 'Preparing'),
                  _chip('out', 'Out for Delivery'),
                  _chip('past', 'Past Orders'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'All Orders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _kBrown,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: _kTeal,
                  child: Text(
                    '${docs.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...buildOrderBody(),
          ],
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final DatabaseService databaseService;
  final int Function(List<dynamic> items) itemCountFn;

  const _OrderCard({
    required this.doc,
    required this.databaseService,
    required this.itemCountFn,
  });

  @override
  Widget build(BuildContext context) {
    final order = doc.data();
    final statusRaw = (order['status'] ?? 'pending').toString();
    final st = statusRaw.toLowerCase();
    final disp = _OrdersManagerTabState._displayStatus(statusRaw);
    final total = ((order['total'] as num?)?.toDouble() ?? 0).toStringAsFixed(2);
    final items = (order['items'] as List?) ?? [];
    final n = itemCountFn(items);
    final addr = order['deliveryAddress'];
    String address = '';
    String phoneFromAddr = '';
    if (addr is Map) {
      final city = (addr['city'] ?? '').toString().trim();
      final line = (addr['address'] ?? '').toString().trim();
      address = [line, city].where((e) => e.isNotEmpty).join(', ');
      phoneFromAddr = (addr['phone'] ?? '').toString().trim();
    }
    final userId = (order['userId'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB8D4E8), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _petStoreOrderCode(doc.id),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _kBrown,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _OrdersManagerTabState._statusPillColor(disp),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    disp,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<String?>(
              future: databaseService.fetchUserDisplayName(userId),
              builder: (context, nameSnap) {
                final name = nameSnap.data;
                return Text(
                  name ?? 'Customer',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _orderRow(Icons.inventory_2_outlined, '$n item(s)'),
            _orderRow(Icons.payments_outlined, '\u{0024} $total JOD'),
            FutureBuilder<Map<String, String?>>(
              future: databaseService.fetchBuyerPublicProfile(userId),
              builder: (context, profSnap) {
                final pPhone =
                    (profSnap.data?['phone'] ?? '').toString().trim();
                final line =
                    phoneFromAddr.isNotEmpty ? phoneFromAddr : pPhone;
                if (line.isEmpty) return const SizedBox.shrink();
                return _orderRow(Icons.phone_outlined, line);
              },
            ),
            if (address.isNotEmpty) _orderRow(Icons.home_outlined, address),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _kBrown,
                side: const BorderSide(color: _kTeal),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: () => _PetStoreOrderDetailDialog.show(
                context,
                docId: doc.id,
                order: order,
                databaseService: databaseService,
              ),
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('View Details'),
            ),
            if (st == 'pending') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _kTeal,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        try {
                          await databaseService.updateOrderStatus(
                            orderId: doc.id,
                            status: 'confirmed',
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Accept Order'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE65100),
                      side: const BorderSide(color: Color(0xFFFFAB91)),
                    ),
                    onPressed: () async {
                      try {
                        await databaseService.updateOrderStatus(
                          orderId: doc.id,
                          status: 'cancelled',
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$e')),
                          );
                        }
                      }
                    },
                    child: const Text('Reject'),
                  ),
                ],
              ),
            ] else if (st == 'confirmed') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _kTeal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    try {
                      await databaseService.updateOrderStatus(
                        orderId: doc.id,
                        status: 'preparing',
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Start Preparing'),
                ),
              ),
            ] else if (st == 'preparing') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _kTeal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    try {
                      await databaseService.updateOrderStatus(
                        orderId: doc.id,
                        status: 'out_for_delivery',
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Out for Delivery'),
                ),
              ),
            ] else if (st == 'out_for_delivery') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _kTeal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    try {
                      await databaseService.updateOrderStatus(
                        orderId: doc.id,
                        status: 'delivered',
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark as Delivered'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _orderRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey.shade800)),
          ),
        ],
      ),
    );
  }
}

// ─── Products tab ────────────────────────────────────────────────────────────

class _ProductsManagerTab extends StatefulWidget {
  final String storeId;
  final DatabaseService databaseService;

  const _ProductsManagerTab({
    required this.storeId,
    required this.databaseService,
  });

  @override
  State<_ProductsManagerTab> createState() => _ProductsManagerTabState();
}

class _ProductsManagerTabState extends State<_ProductsManagerTab> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _thumb(String url) {
    if (url.isEmpty) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.image_outlined, color: Colors.grey.shade500),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: 72,
          height: 72,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image_outlined),
        ),
        loadingBuilder: (ctx, child, prog) {
          if (prog == null) return child;
          return SizedBox(
            width: 72,
            height: 72,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: prog.expectedTotalBytes != null
                    ? prog.cumulativeBytesLoaded / prog.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: widget.databaseService.streamProductsForStoreOwner(widget.storeId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: _kTeal));
        }
        final all = snapshot.data!;
        final q = _search.text.trim().toLowerCase();
        final filtered = q.isEmpty
            ? all
            : all.where((p) {
                final title = (p['title'] ?? '').toString().toLowerCase();
                final brand = (p['brand'] ?? '').toString().toLowerCase();
                final cat = (p['category'] ?? '').toString().toLowerCase();
                return title.contains(q) ||
                    brand.contains(q) ||
                    cat.contains(q);
              }).toList();
        final activeProducts =
            filtered.where((p) => p['isActive'] != false).toList();
        final inactiveProducts =
            filtered.where((p) => p['isActive'] == false).toList();
        final active = activeProducts.length;
        final low = all.where((p) {
          final s = (p['stock'] as num?)?.toInt() ?? 0;
          return s > 0 && s <= 10;
        }).toList();

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Product Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _kBrown,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: _kTeal),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => _ProductFormDialog(
                          storeId: widget.storeId,
                          databaseService: widget.databaseService,
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add Product'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: _kTeal),
                    hintText: 'Search products by name, brand, or category...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (low.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5D9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFB38A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Color(0xFFFF6B35)),
                            SizedBox(width: 8),
                            Text(
                              'Low Stock Products',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _kBrown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...low.map(
                          (p) => Text(
                            '• ${p['title']} — Only ${p['stock']} left',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text(
                      'Active Products',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _kBrown,
                      ),
                    ),
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: _kTeal,
                      child: Text(
                        '$active',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (activeProducts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      q.isEmpty
                          ? 'No active products yet. Add your first product.'
                          : 'No active products match your search.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  )
                else
                  ...activeProducts.map(
                    (p) => _ProductManageCard(
                      product: p,
                      storeId: widget.storeId,
                      databaseService: widget.databaseService,
                      thumb: _thumb,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                if (inactiveProducts.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Inactive Products',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _kBrown,
                        ),
                      ),
                      const SizedBox(width: 6),
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.grey.shade400,
                        child: Text(
                          '${inactiveProducts.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...inactiveProducts.map(
                    (p) => _InactiveProductCard(
                      product: p,
                      storeId: widget.storeId,
                      databaseService: widget.databaseService,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ProductManageCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String storeId;
  final DatabaseService databaseService;
  final Widget Function(String url) thumb;
  final VoidCallback onChanged;

  const _ProductManageCard({
    required this.product,
    required this.storeId,
    required this.databaseService,
    required this.thumb,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final id = (product['id'] ?? '').toString();
    final title = (product['title'] ?? '').toString();
    final brand = (product['brand'] ?? '—').toString();
    final cat = (product['category'] ?? '').toString();
    final price = ((product['price'] as num?)?.toDouble() ?? 0);
    final orig = (product['originalPrice'] as num?)?.toDouble();
    final stock = (product['stock'] as num?)?.toInt() ?? 0;
    final hasSale = product['hasSale'] == true;
    final offer = (product['offer'] ?? '').toString();
    final img = _productImageUrl(product);
    final active = product['isActive'] != false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                thumb(img),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _kBrown,
                              ),
                            ),
                          ),
                          if (hasSale)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                orig != null && orig > price
                                    ? 'SALE'
                                    : 'SALE',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        brand,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                      ),
                      if (offer.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            offer,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: _kTeal),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          cat.isEmpty ? 'Category' : cat,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _kTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (orig != null && orig > price)
                      Text(
                        '${orig.toStringAsFixed(2)} JOD',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    Text(
                      '${price.toStringAsFixed(2)} JOD',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: hasSale ? Colors.red.shade700 : _kTeal,
                      ),
                    ),
                    Text(
                      'Stock: $stock',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final updated = await showDialog<bool>(
                      context: context,
                      builder: (_) => _ManageSaleDialog(
                        productId: id,
                        product: product,
                        databaseService: databaseService,
                      ),
                    );
                    if (updated == true) onChanged();
                  },
                  icon: Icon(
                    Icons.local_offer_outlined,
                    size: 16,
                    color: hasSale ? Colors.red : _kTeal,
                  ),
                  label: Text(hasSale ? 'Manage Sale' : 'Put on Sale'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: hasSale ? Colors.red : _kTeal,
                  ),
                ),
                OutlinedButton(
                  onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _ProductFormDialog(
                        storeId: storeId,
                        databaseService: databaseService,
                        existingProduct: product,
                      ),
                    ),
                  child: const Text('Edit'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await databaseService.updateProduct(id, {
                        'isActive': !active,
                      });
                      onChanged();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$e')),
                        );
                      }
                    }
                  },
                  child: Text(active ? 'Deactivate' : 'Activate'),
                ),
                IconButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                  context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete product?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    try {
                      await databaseService.deleteProduct(id);
                      onChanged();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

class _InactiveProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String storeId;
  final DatabaseService databaseService;
  final VoidCallback onChanged;

  const _InactiveProductCard({
    required this.product,
    required this.storeId,
    required this.databaseService,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final id = (product['id'] ?? '').toString();
    final title = (product['title'] ?? '').toString();
    final brand = (product['brand'] ?? '—').toString();
    final price = ((product['price'] as num?)?.toDouble() ?? 0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _kBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    brand,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${price.toStringAsFixed(2)} JOD',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _kBrown,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () async {
                try {
                  await databaseService.updateProduct(id, {'isActive': true});
                  onChanged();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              },
              child: const Text('Activate'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete product?'),
                    content: const Text(
                      'This product will be permanently removed from your store.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (ok != true) return;
                try {
                  await databaseService.deleteProduct(id);
                  onChanged();
                } catch (e) {
                  if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageSaleDialog extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> product;
  final DatabaseService databaseService;

  const _ManageSaleDialog({
    required this.productId,
    required this.product,
    required this.databaseService,
  });

  @override
  State<_ManageSaleDialog> createState() => _ManageSaleDialogState();
}

class _ManageSaleDialogState extends State<_ManageSaleDialog> {
  final _percent = TextEditingController();
  DateTime? _until;

  @override
  void initState() {
    super.initState();
    final offer = (widget.product['offer'] ?? '').toString();
    final match = RegExp(r'(\\d+)').firstMatch(offer);
    if (match != null) {
      _percent.text = match.group(1) ?? '';
    }
  }

  @override
  void dispose() {
    _percent.dispose();
    super.dispose();
  }

  double? _computeSalePrice() {
    final pct = double.tryParse(_percent.text.trim());
    if (pct == null || pct <= 0) return null;
    final orig =
        ((widget.product['originalPrice'] as num?)?.toDouble()) ??
            ((widget.product['price'] as num?)?.toDouble() ?? 0);
    if (orig <= 0) return null;
    return orig * (1 - pct / 100.0);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _until ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (d != null) {
      setState(() => _until = d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orig =
        ((widget.product['originalPrice'] as num?)?.toDouble()) ??
            ((widget.product['price'] as num?)?.toDouble() ?? 0);
    final salePrice = _computeSalePrice();
    final code = _petStoreOrderCode(widget.productId);

    return AlertDialog(
      title: const Text('Manage Sale'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (widget.product['title'] ?? '').toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _kBrown,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Original Price: ${orig.toStringAsFixed(2)} JOD',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: 'percentage',
              items: const [
                DropdownMenuItem(
                  value: 'percentage',
                  child: Text('Discount Percentage'),
                ),
              ],
              decoration: const InputDecoration(labelText: 'Sale Type'),
              onChanged: (_) {},
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _percent,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Discount Percentage (%)',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 6),
            Text(
              salePrice == null
                  ? 'Sale Price: —'
                  : 'Sale Price: ${salePrice.toStringAsFixed(2)} JOD',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _kBrown,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText: 'Sale Valid Until (Optional)',
                hintText: 'mm/dd/yyyy',
                suffixIcon: const Icon(Icons.calendar_today, size: 18),
              ),
              controller: TextEditingController(
                text: _until == null
                    ? ''
                    : DateFormat.yMd().format(_until!),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sale ID: $code',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            try {
              await widget.databaseService.updateProduct(widget.productId, {
                'hasSale': false,
                'offer': '',
                if (widget.product['originalPrice'] != null)
                  'price':
                      ((widget.product['originalPrice'] as num?)?.toDouble() ??
                          orig),
              });
              if (!context.mounted) return;
              Navigator.pop(context, true);
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$e')),
              );
            }
          },
          child: const Text(
            'Remove Sale',
            style: TextStyle(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            final pct = double.tryParse(_percent.text.trim());
            final sale = _computeSalePrice();
            if (pct == null || pct <= 0 || sale == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enter a valid discount percentage.'),
                ),
              );
              return;
            }
            try {
              await widget.databaseService.updateProduct(widget.productId, {
                'hasSale': true,
                'originalPrice': orig,
                'price': sale,
                'offer': '${pct.round()}% off',
                if (_until != null) 'saleValidUntil': Timestamp.fromDate(_until!),
              });
              if (!context.mounted) return;
              Navigator.pop(context, true);
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$e')),
              );
            }
          },
          child: const Text('Update Sale'),
        ),
      ],
    );
  }
}

// ─── Pet store offer dialogs (Firestore `users/{storeId}/pet_store_offers`) ───

class _CreateStoreWideOfferDialog extends StatefulWidget {
  final String storeId;
  final DatabaseService databaseService;

  const _CreateStoreWideOfferDialog({
    required this.storeId,
    required this.databaseService,
  });

  static Future<void> show(
    BuildContext context, {
    required String storeId,
    required DatabaseService databaseService,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => _CreateStoreWideOfferDialog(
        storeId: storeId,
        databaseService: databaseService,
      ),
    );
  }

  @override
  State<_CreateStoreWideOfferDialog> createState() =>
      _CreateStoreWideOfferDialogState();
}

class _CreateStoreWideOfferDialogState extends State<_CreateStoreWideOfferDialog> {
  final _customPct = TextEditingController(text: '10');
  final _priceMin = TextEditingController();
  final _priceMax = TextEditingController();
  final _minOrder = TextEditingController();
  DateTime? _validUntil;
  bool _filterPriceRange = false;
  bool _requireMinOrder = false;

  static const _quick = <double>[10, 15, 20, 25, 30, 50];

  @override
  void dispose() {
    _customPct.dispose();
    _priceMin.dispose();
    _priceMax.dispose();
    _minOrder.dispose();
    super.dispose();
  }

  void _setPct(double v) {
    setState(() => _customPct.text = v.round().toString());
  }

  double _parsedPct() =>
      double.tryParse(_customPct.text.trim()) ?? 0;

  String _previewTitle() {
    final p = _parsedPct();
    if (p <= 0) return '—';
    if (_requireMinOrder) {
      final mo = double.tryParse(_minOrder.text.trim()) ?? 0;
      if (mo > 0) {
        return '${p.round()}% Off on Orders Above ${mo.toStringAsFixed(0)} JOD';
      }
    }
    return '${p.round()}% Off Store-Wide';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );
    if (d != null) setState(() => _validUntil = d);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF0F9FA),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      title: Row(
        children: [
          Icon(Icons.storefront_outlined, color: _kOrange, size: 26),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Create Store-Wide Offer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _kBrown,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Apply a discount to all products in your store',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quick Discount Selection',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _kBrown,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quick.map((v) {
                  final sel = _customPct.text.trim() == v.round().toString();
                  return ChoiceChip(
                    label: Text('${v.round()}%'),
                    selected: sel,
                    onSelected: (_) => _setPct(v),
                    selectedColor: _kOrange,
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : _kBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customPct,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Or Enter Custom Discount (%)',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Text(
                'Valid Until *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _kBrown,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  _validUntil == null
                      ? 'mm/dd/yyyy'
                      : DateFormat.yMd().format(_validUntil!),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _filterPriceRange,
                onChanged: (v) =>
                    setState(() => _filterPriceRange = v ?? false),
                title: const Text('Apply to products in specific price range'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              if (_filterPriceRange) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceMin,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Min Price (JOD)',
                          hintText: 'e.g., 10',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _priceMax,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max Price (JOD)',
                          hintText: 'e.g., 100',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              CheckboxListTile(
                value: _requireMinOrder,
                onChanged: (v) => setState(() => _requireMinOrder = v ?? false),
                title: const Text('Require minimum order amount'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              if (_requireMinOrder)
                TextField(
                  controller: _minOrder,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minimum order (JOD)',
                  ),
                ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8DC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kOrange.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'Preview: ${_previewTitle()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _kBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _kOrange),
          onPressed: () async {
            final pct = _parsedPct();
            if (pct <= 0 || pct > 100) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter a valid discount %.')),
              );
              return;
            }
            if (_validUntil == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Valid until date is required.')),
              );
              return;
            }
            final minJ =
                _requireMinOrder ? double.tryParse(_minOrder.text.trim()) ?? 0 : 0;
            final title = _previewTitle();
            final desc =
                '${pct.round()}% discount when conditions are met. Valid until ${DateFormat.yMMMd().format(_validUntil!)}.';
            final fields = <String, dynamic>{
              'kind': 'store_wide',
              'title': title,
              'description': desc,
              'discountPercent': pct,
              'discountLabel': '${pct.round()}% OFF',
              'minOrderJod': minJ,
              'validUntil': Timestamp.fromDate(_validUntil!),
              'validUntilText': DateFormat.yMMMd().format(_validUntil!),
              'filterByPriceRange': _filterPriceRange,
            };
            if (_filterPriceRange) {
              fields['priceMinJod'] =
                  double.tryParse(_priceMin.text.trim()) ?? 0;
              fields['priceMaxJod'] =
                  double.tryParse(_priceMax.text.trim()) ?? 0;
            }
            try {
              await widget.databaseService.createPetStoreOffer(
                storeId: widget.storeId,
                fields: fields,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$e')),
              );
            }
          },
          child: const Text('Create Offer'),
        ),
      ],
    );
  }
}

class _CreateProductSaleOfferDialog extends StatefulWidget {
  final String storeId;
  final DatabaseService databaseService;
  final List<Map<String, dynamic>> products;

  const _CreateProductSaleOfferDialog({
    required this.storeId,
    required this.databaseService,
    required this.products,
  });

  static Future<void> show(
    BuildContext context, {
    required String storeId,
    required DatabaseService databaseService,
    required List<Map<String, dynamic>> products,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => _CreateProductSaleOfferDialog(
        storeId: storeId,
        databaseService: databaseService,
        products: products,
      ),
    );
  }

  @override
  State<_CreateProductSaleOfferDialog> createState() =>
      _CreateProductSaleOfferDialogState();
}

class _CreateProductSaleOfferDialogState
    extends State<_CreateProductSaleOfferDialog> {
  String? _productId;
  final _customPct = TextEditingController(text: '15');
  final _title = TextEditingController();
  final _desc = TextEditingController();
  DateTime? _validUntil;

  static const _quick = <double>[10, 15, 20, 25, 30, 50];

  @override
  void initState() {
    super.initState();
    if (widget.products.isNotEmpty) {
      _productId = widget.products.first['id']?.toString();
    }
  }

  @override
  void dispose() {
    _customPct.dispose();
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _setPct(double v) {
    setState(() => _customPct.text = v.round().toString());
  }

  double _parsedPct() =>
      double.tryParse(_customPct.text.trim()) ?? 0;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );
    if (d != null) setState(() => _validUntil = d);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF0F9FA),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      title: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: _kBlueOffer, size: 26),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Create Product Sale',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _kBrown,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create a special sale offer for a specific product',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (widget.products.isEmpty)
                const Text('Add at least one product first.')
              else
                DropdownButtonFormField<String>(
                  initialValue: _productId,
                  decoration: const InputDecoration(
                    labelText: 'Select Product *',
                  ),
                  items: widget.products
                      .map(
                        (p) => DropdownMenuItem(
                          value: p['id']?.toString(),
                          child: Text(
                            (p['title'] ?? p['id']).toString(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _productId = v),
                ),
              const SizedBox(height: 12),
              const Text(
                'Quick Discount Selection',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _kBrown,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quick.map((v) {
                  final sel = _customPct.text.trim() == v.round().toString();
                  return ChoiceChip(
                    label: Text('${v.round()}%'),
                    selected: sel,
                    onSelected: (_) => _setPct(v),
                    selectedColor: _kBlueOffer,
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : _kBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _customPct,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Or Enter Custom Discount (%)',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Offer title (optional)',
                  hintText: 'Auto from product & discount if empty',
                ),
              ),
              TextField(
                controller: _desc,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Valid Until *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _kBrown,
                  fontSize: 13,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  _validUntil == null
                      ? 'mm/dd/yyyy'
                      : DateFormat.yMd().format(_validUntil!),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _kBlueOffer),
          onPressed: widget.products.isEmpty || _productId == null
              ? null
              : () async {
                  final pct = _parsedPct();
                  if (pct <= 0 || pct > 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter a valid discount %.')),
                    );
                    return;
                  }
                  if (_validUntil == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Valid until date is required.'),
                      ),
                    );
                    return;
                  }
                  final pr = widget.products.firstWhere(
                    (e) => e['id']?.toString() == _productId,
                    orElse: () => <String, dynamic>{},
                  );
                  final pTitle = (pr['title'] ?? '').toString();
                  final offerTitle = _title.text.trim().isEmpty
                      ? '${pct.round()}% Off $pTitle'
                      : _title.text.trim();
                  try {
                    await widget.databaseService.createPetStoreOffer(
                      storeId: widget.storeId,
                      fields: {
                        'kind': 'product_sale',
                        'productId': _productId,
                        'productTitle': pTitle,
                        'title': offerTitle,
                        'description': _desc.text.trim(),
                        'discountPercent': pct,
                        'discountLabel': '${pct.round()}% OFF',
                        'validUntil': Timestamp.fromDate(_validUntil!),
                        'validUntilText':
                            DateFormat.yMMMd().format(_validUntil!),
                      },
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$e')),
                    );
                  }
                },
          child: const Text('Create Sale'),
        ),
      ],
    );
  }
}

class _EditPetStoreOfferDialog extends StatefulWidget {
  final String storeId;
  final DatabaseService databaseService;
  final String offerId;
  final Map<String, dynamic> initial;

  const _EditPetStoreOfferDialog({
    required this.storeId,
    required this.databaseService,
    required this.offerId,
    required this.initial,
  });

  static Future<void> show(
    BuildContext context, {
    required String storeId,
    required DatabaseService databaseService,
    required String offerId,
    required Map<String, dynamic> initial,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => _EditPetStoreOfferDialog(
        storeId: storeId,
        databaseService: databaseService,
        offerId: offerId,
        initial: initial,
      ),
    );
  }

  @override
  State<_EditPetStoreOfferDialog> createState() =>
      _EditPetStoreOfferDialogState();
}

class _EditPetStoreOfferDialogState extends State<_EditPetStoreOfferDialog> {
  late String _kind;
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _disc = TextEditingController();
  final _minJ = TextEditingController();
  final _priceMin = TextEditingController();
  final _priceMax = TextEditingController();
  DateTime? _until;
  List<Map<String, dynamic>> _products = [];
  String? _productId;

  @override
  void initState() {
    super.initState();
    _kind = (widget.initial['kind'] ?? 'store_wide').toString();
    _title.text = (widget.initial['title'] ?? '').toString();
    _desc.text = (widget.initial['description'] ?? '').toString();
    _disc.text =
        ((widget.initial['discountPercent'] as num?)?.toString() ?? '');
    _minJ.text =
        ((widget.initial['minOrderJod'] as num?)?.toString() ?? '');
    _priceMin.text =
        ((widget.initial['priceMinJod'] as num?)?.toString() ?? '');
    _priceMax.text =
        ((widget.initial['priceMaxJod'] as num?)?.toString() ?? '');
    final vu = widget.initial['validUntil'];
    if (vu is Timestamp) _until = vu.toDate();
    _productId = widget.initial['productId']?.toString();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final list = await widget.databaseService
        .streamProductsForStoreOwner(widget.storeId)
        .first;
    if (mounted) setState(() => _products = list);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _disc.dispose();
    _minJ.dispose();
    _priceMin.dispose();
    _priceMax.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _until ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );
    if (d != null) setState(() => _until = d);
  }

  @override
  Widget build(BuildContext context) {
    final isStore = _kind == 'store_wide';
    return AlertDialog(
      backgroundColor: const Color(0xFFF0F9FA),
      title: const Text(
        'Edit Offer',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: _kBrown,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update offer details and settings',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: isStore ? 'store_wide' : 'product_sale',
                decoration: const InputDecoration(labelText: 'Offer Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'store_wide',
                    child: Text('Store-Wide Offer'),
                  ),
                  DropdownMenuItem(
                    value: 'product_sale',
                    child: Text('Product Sale'),
                  ),
                ],
                onChanged: (v) => setState(() => _kind = v ?? 'store_wide'),
              ),
              if (!isStore && _products.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (!isStore && _products.isNotEmpty) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _productId != null &&
                          _products.any((p) => p['id']?.toString() == _productId)
                      ? _productId
                      : _products.first['id']?.toString(),
                  decoration: const InputDecoration(labelText: 'Select Product *'),
                  items: _products
                      .map(
                        (p) => DropdownMenuItem(
                          value: p['id']?.toString(),
                          child: Text(
                            (p['title'] ?? p['id']).toString(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _productId = v),
                ),
              ],
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Offer Title'),
              ),
              TextField(
                controller: _desc,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _disc,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Discount (%)',
                      ),
                    ),
                  ),
                  if (isStore) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _minJ,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Min order (JOD)',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (isStore) ...[
                const SizedBox(height: 4),
                const Text(
                  'Price Range (Optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _kBrown,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceMin,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Min Price (JOD)',
                          hintText: 'e.g., 10',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _priceMax,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max Price (JOD)',
                          hintText: 'e.g., 100',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  _until == null
                      ? 'Valid Until'
                      : DateFormat.yMd().format(_until!),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _kTeal),
          onPressed: () async {
            final pct = double.tryParse(_disc.text.trim()) ?? 0;
            if (pct <= 0 || pct > 100) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid discount %.')),
              );
              return;
            }
            final patch = <String, dynamic>{
              'kind': _kind,
              'title': _title.text.trim(),
              'description': _desc.text.trim(),
              'discountPercent': pct,
              'discountLabel': '${pct.round()}% OFF',
            };
            if (_until != null) {
              patch['validUntil'] = Timestamp.fromDate(_until!);
              patch['validUntilText'] = DateFormat.yMMMd().format(_until!);
            }
            if (_kind == 'store_wide') {
              patch['minOrderJod'] = double.tryParse(_minJ.text.trim()) ?? 0;
              patch['priceMinJod'] = double.tryParse(_priceMin.text.trim()) ?? 0;
              patch['priceMaxJod'] = double.tryParse(_priceMax.text.trim()) ?? 0;
              patch.remove('productId');
              patch.remove('productTitle');
            } else {
              final pid = _productId ??
                  widget.initial['productId']?.toString();
              if (pid == null || pid.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select a product.')),
                );
                return;
              }
              Map<String, dynamic>? pr;
              for (final e in _products) {
                if (e['id']?.toString() == pid) {
                  pr = e;
                  break;
                }
              }
              patch['productId'] = pid;
              patch['productTitle'] =
                  (pr?['title'] ?? widget.initial['productTitle'] ?? '')
                      .toString();
            }
            try {
              await widget.databaseService.updatePetStoreOffer(
                storeId: widget.storeId,
                offerId: widget.offerId,
                patch: patch,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$e')),
              );
            }
          },
          child: const Text('Update Offer'),
        ),
      ],
    );
  }
}

// ─── Offers (Firestore `users/{storeId}/pet_store_offers`) ───────────────────

class _OffersTab extends StatefulWidget {
  final String storeId;
  final DatabaseService databaseService;

  const _OffersTab({required this.storeId, required this.databaseService});

  @override
  State<_OffersTab> createState() => _OffersTabState();
}

class _OffersTabState extends State<_OffersTab> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openProductSaleDialog(BuildContext context) async {
    final products = await widget.databaseService
        .streamProductsForStoreOwner(widget.storeId)
        .first;
    if (!context.mounted) return;
    await _CreateProductSaleOfferDialog.show(
      context,
      storeId: widget.storeId,
      databaseService: widget.databaseService,
      products: products,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: widget.databaseService.streamPetStoreOffers(widget.storeId),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Could not load offers.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snap.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Deploy Firestore rules and indexes, or check your connection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: _kTeal));
        }
        final q = _search.text.trim().toLowerCase();
        var docs = snap.data!.docs.toList();
        docs.sort((a, b) {
          final ta = a.data()['createdAt'];
          final tb = b.data()['createdAt'];
          if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
          return 0;
        });
        if (q.isNotEmpty) {
          docs = docs.where((d) {
            final m = d.data();
            final blob =
                '${m['title']} ${m['description']} ${m['discountLabel']} '
                    '${m['productTitle'] ?? ''}'
                    .toLowerCase();
            return blob.contains(q);
          }).toList();
        }
        bool isActive(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
            d.data()['isActive'] != false;

        List<QueryDocumentSnapshot<Map<String, dynamic>>> byKind(
          String kind,
        ) =>
            docs.where((d) => d.data()['kind'] == kind).toList();

        final storeWide = byKind('store_wide');
        final productSales = byKind('product_sale');
        final storeActive = storeWide.where(isActive).toList();
        final storeInactive = storeWide.where((d) => !isActive(d)).toList();
        final productActive = productSales.where(isActive).toList();
        final productInactive = productSales.where((d) => !isActive(d)).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            const Text(
              'Create Offers & Promotions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _kBrown,
              ),
            ),
            Text(
              'Choose the type of offer you want to create',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.percent, color: _kOrange),
                hintText: 'Search offers by title, description, or product...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _createOfferHeroCard(
              leadingIcon: Icons.storefront_outlined,
              title: 'Store-Wide Offer',
              subtitle: 'Apply discount to all products in your store',
              color: _kOrange,
              onPressed: () => _CreateStoreWideOfferDialog.show(
                context,
                storeId: widget.storeId,
                databaseService: widget.databaseService,
              ),
              buttonLabel: '+ Create Store-Wide Offer',
            ),
            const SizedBox(height: 12),
            _createOfferHeroCard(
              leadingIcon: Icons.inventory_2_outlined,
              title: 'Product Sale',
              subtitle: 'Create discount for specific products',
              color: _kBlueOffer,
              onPressed: () => _openProductSaleDialog(context),
              buttonLabel: '+ Create Product Sale',
            ),
            const SizedBox(height: 20),
            _offerSectionHeader(
              icon: Icons.storefront_outlined,
              label: 'Store-Wide Offers',
              count: storeActive.length,
            ),
            if (storeActive.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'No active store-wide offers.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              )
            else
              ...storeActive.map(
                (d) => _FirestoreOfferCard(
                  doc: d,
                  storeId: widget.storeId,
                  databaseService: widget.databaseService,
                  orangeStyle: true,
                  inactiveList: false,
                ),
              ),
            const SizedBox(height: 16),
            _offerSectionHeader(
              icon: Icons.inventory_2_outlined,
              label: 'Product Sales',
              count: productActive.length,
            ),
            if (productActive.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'No active product sales.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              )
            else
              ...productActive.map(
                (d) => _FirestoreOfferCard(
                  doc: d,
                  storeId: widget.storeId,
                  databaseService: widget.databaseService,
                  orangeStyle: false,
                  inactiveList: false,
                ),
              ),
            if (storeInactive.isNotEmpty || productInactive.isNotEmpty) ...[
              const SizedBox(height: 20),
              _offerSectionHeader(
                icon: Icons.pause_circle_outline,
                label: 'Inactive Offers',
                count: storeInactive.length + productInactive.length,
              ),
              ...storeInactive.map(
                (d) => _FirestoreOfferCard(
                  doc: d,
                  storeId: widget.storeId,
                  databaseService: widget.databaseService,
                  orangeStyle: true,
                  inactiveList: true,
                ),
              ),
              ...productInactive.map(
                (d) => _FirestoreOfferCard(
                  doc: d,
                  storeId: widget.storeId,
                  databaseService: widget.databaseService,
                  orangeStyle: false,
                  inactiveList: true,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _offerSectionHeader({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: _kBrown, size: 20),
          const SizedBox(width: 6),
          Text(
            '$label ($count)',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: _kBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createOfferHeroCard({
    required IconData leadingIcon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
    required String buttonLabel,
  }) {
    final light = Color.lerp(color, Colors.white, 0.88)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: light,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(leadingIcon, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _kBrown,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: color, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onPressed,
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirestoreOfferCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final String storeId;
  final DatabaseService databaseService;
  final bool orangeStyle;
  final bool inactiveList;

  const _FirestoreOfferCard({
    required this.doc,
    required this.storeId,
    required this.databaseService,
    required this.orangeStyle,
    required this.inactiveList,
  });

  @override
  Widget build(BuildContext context) {
    final m = doc.data();
    final color = orangeStyle ? _kOrange : _kBlueOffer;
    final light = Color.lerp(color, Colors.white, 0.9)!;
    final kind = (m['kind'] ?? '').toString();
    final typeLabel = kind == 'store_wide' ? 'Store-Wide' : 'Product Sale';
    final validStr = _formatPetStoreOfferValidUntil(m);
    final minJ = (m['minOrderJod'] as num?)?.toDouble() ?? 0;

    if (inactiveList) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      (m['title'] ?? '').toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _kBrown,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      typeLabel,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                (m['description'] ?? '').toString(),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        await databaseService.updatePetStoreOffer(
                          storeId: storeId,
                          offerId: doc.id,
                          patch: {'isActive': true},
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$e')),
                          );
                        }
                      }
                    },
                    child: const Text('Activate'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete offer?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (ok != true || !context.mounted) return;
                      try {
                        await databaseService.deletePetStoreOffer(
                          storeId,
                          doc.id,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final active = m['isActive'] != false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: light,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.percent, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (m['title'] ?? '').toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _kBrown,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(typeLabel, style: const TextStyle(fontSize: 10)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (m['discountLabel'] ?? '').toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              (m['description'] ?? '').toString(),
              style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
            ),
            if (validStr.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: color),
                    const SizedBox(width: 6),
                    Text(
                      'Valid until: $validStr',
                      style: TextStyle(fontSize: 12, color: color),
                    ),
                  ],
                ),
              ),
            if (kind == 'store_wide' && minJ > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Min order: ${minJ.toStringAsFixed(0)} JOD',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _EditPetStoreOfferDialog.show(
                    context,
                    storeId: storeId,
                    databaseService: databaseService,
                    offerId: doc.id,
                    initial: Map<String, dynamic>.from(m),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await databaseService.updatePetStoreOffer(
                        storeId: storeId,
                        offerId: doc.id,
                        patch: {'isActive': !active},
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$e')),
                        );
                      }
                    }
                  },
                  child: Text(active ? 'Deactivate' : 'Activate'),
                ),
                IconButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete offer?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true || !context.mounted) return;
                    try {
                      await databaseService.deletePetStoreOffer(
                        storeId,
                        doc.id,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reviews (Firestore `reviews` where storeId == provider uid) ───────────

const Color _kReviewCardBorder = Color(0xFF9EC9E0);

class _PetStoreReviewGroup {
  _PetStoreReviewGroup({
    required this.userId,
    required this.orderId,
  });

  final String userId;
  final String orderId;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> productDocs = [];
  QueryDocumentSnapshot<Map<String, dynamic>>? storeDoc;

  static int _docMs(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final t = doc.data()['updatedAt'] ?? doc.data()['createdAt'];
    if (t is Timestamp) return t.millisecondsSinceEpoch;
    return 0;
  }

  QueryDocumentSnapshot<Map<String, dynamic>>? pickLatestProductDoc() {
    if (productDocs.isEmpty) return null;
    final sorted = [...productDocs]
      ..sort((a, b) => _docMs(b).compareTo(_docMs(a)));
    return sorted.first;
  }

  int sortKeyMs() {
    var best = 0;
    final pd = pickLatestProductDoc();
    if (pd != null) best = best > _docMs(pd) ? best : _docMs(pd);
    if (storeDoc != null) {
      best = best > _docMs(storeDoc!) ? best : _docMs(storeDoc!);
    }
    return best;
  }

  String? customerNameHint() {
    for (final d in productDocs) {
      final n = (d.data()['customerName'] ?? '').toString().trim();
      if (n.isNotEmpty) return n;
    }
    final s = storeDoc;
    if (s != null) {
      final n = (s.data()['customerName'] ?? '').toString().trim();
      if (n.isNotEmpty) return n;
    }
    return null;
  }

  String headerDateStr() {
    Timestamp? bestTs;
    var best = 0;
    for (final d in productDocs) {
      final t = d.data()['createdAt'];
      if (t is Timestamp && t.millisecondsSinceEpoch >= best) {
        best = t.millisecondsSinceEpoch;
        bestTs = t;
      }
    }
    final s = storeDoc;
    if (s != null) {
      final t = s.data()['createdAt'];
      if (t is Timestamp && t.millisecondsSinceEpoch >= best) {
        bestTs = t;
      }
    }
    if (bestTs != null) return DateFormat.yMMMd().format(bestTs.toDate());
    return '';
  }
}

List<_PetStoreReviewGroup> _groupPetStoreReviewDocs(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) {
  final map = <String, _PetStoreReviewGroup>{};
  for (final doc in docs) {
    final d = doc.data();
    final type = (d['type'] ?? '').toString();
    final uid = (d['userId'] ?? '').toString();
    final oid = (d['orderId'] ?? '').toString().trim();
    if (oid.isNotEmpty && (type == 'product' || type == 'store')) {
      final key = '$uid|$oid';
      final g = map.putIfAbsent(key, () => _PetStoreReviewGroup(userId: uid, orderId: oid));
      if (type == 'product') {
        g.productDocs.add(doc);
      } else if (type == 'store') {
        final cur = g.storeDoc;
        if (cur == null || _PetStoreReviewGroup._docMs(doc) >= _PetStoreReviewGroup._docMs(cur)) {
          g.storeDoc = doc;
        }
      }
    } else {
      final key = 'legacy|${doc.id}';
      final g = map.putIfAbsent(
        key,
        () => _PetStoreReviewGroup(userId: uid, orderId: ''),
      );
      if (type == 'product') {
        g.productDocs.add(doc);
      } else if (type == 'store') {
        g.storeDoc = doc;
      }
    }
  }
  final list = map.values.toList();
  list.sort((a, b) => b.sortKeyMs().compareTo(a.sortKeyMs()));
  return list;
}

class _ReviewsTab extends StatelessWidget {
  final String storeId;
  final DatabaseService databaseService;

  const _ReviewsTab({required this.storeId, required this.databaseService});

  static Widget _starsRow(int stars, {double size = 20}) {
    final n = stars.clamp(0, 5);
    return Row(
      children: List.generate(
        5,
        (j) => Icon(
          j < n ? Icons.star : Icons.star_border,
          color: Colors.amber.shade700,
          size: size,
        ),
      ),
    );
  }

  static Widget _reviewSection({
    required String label,
    required int stars,
    required String comment,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        _starsRow(stars),
        if (comment.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            comment,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.35),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: databaseService.streamAllReviewsForStore(storeId),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load reviews.\n${snap.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: _kTeal));
        }
        final docs = snap.data!.docs.toList();
        if (docs.isEmpty) {
          return const Center(child: Text('No reviews yet.'));
        }
        final groups = _groupPetStoreReviewDocs(docs);
        final withStore = groups.where((g) => g.storeDoc != null).toList();
        double avgStore = 0;
        if (withStore.isNotEmpty) {
          var s = 0.0;
          for (final g in withStore) {
            s += ((g.storeDoc!.data()['stars'] as num?)?.toDouble() ?? 0);
          }
          avgStore = s / withStore.length;
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Row(
              children: [
                const Text(
                  'Customer Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kBrown,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kTeal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${groups.length} reviews',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 38),
                      const SizedBox(width: 8),
                      Text(
                        withStore.isEmpty ? '—' : avgStore.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: _kBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Average Store Rating',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on ${withStore.length} reviews',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...groups.map((g) {
              final uid = g.userId;
              final productDoc = g.pickLatestProductDoc();
              final storeDoc = g.storeDoc;
              final nameHint = g.customerNameHint();
              final dateStr = g.headerDateStr();
              final oid = g.orderId.trim();
              final orderLabel = oid.isNotEmpty ? 'Order #$oid' : '';

              final pStars = productDoc != null
                  ? ((productDoc.data()['stars'] as num?)?.toInt() ?? 0)
                  : 0;
              final pComment =
                  productDoc != null ? (productDoc.data()['comment'] ?? '').toString() : '';
              final sStars = storeDoc != null
                  ? ((storeDoc.data()['stars'] as num?)?.toInt() ?? 0)
                  : 0;
              final sComment =
                  storeDoc != null ? (storeDoc.data()['comment'] ?? '').toString() : '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _kReviewCardBorder, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: nameHint != null && nameHint.isNotEmpty
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nameHint,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: _kBrown,
                                        ),
                                      ),
                                      if (dateStr.isNotEmpty)
                                        Text(
                                          dateStr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  )
                                : FutureBuilder<String?>(
                                    future: databaseService.fetchUserDisplayName(uid),
                                    builder: (ctx, ns) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ns.data ?? 'Customer',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: _kBrown,
                                            ),
                                          ),
                                          if (dateStr.isNotEmpty)
                                            Text(
                                              dateStr,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                          if (orderLabel.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                orderLabel,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                      if (productDoc != null) ...[
                        const SizedBox(height: 14),
                        _reviewSection(
                          label: 'Product Rating:',
                          stars: pStars,
                          comment: pComment,
                        ),
                      ],
                      if (storeDoc != null) ...[
                        const SizedBox(height: 14),
                        _reviewSection(
                          label: 'Store Rating:',
                          stars: sStars,
                          comment: sComment,
                        ),
                      ],
                      if (productDoc == null && storeDoc == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('No rating data.'),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// ─── Store tab ───────────────────────────────────────────────────────────────

class _StoreSettingsTab extends StatefulWidget {
  final String storeId;
  final FirebaseFirestore firestore;
  final DatabaseService databaseService;

  const _StoreSettingsTab({
    required this.storeId,
    required this.firestore,
    required this.databaseService,
  });

  @override
  State<_StoreSettingsTab> createState() => _StoreSettingsTabState();
}

class _StoreSettingsTabState extends State<_StoreSettingsTab> {
  final _storeName = TextEditingController();
  final _location = TextEditingController();
  final _street = TextEditingController();
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _hours = TextEditingController();
  String _storeImageUrl = '';
  bool _hydrated = false;

  @override
  void dispose() {
    _storeName.dispose();
    _location.dispose();
    _street.dispose();
    _description.dispose();
    _phone.dispose();
    _email.dispose();
    _hours.dispose();
    super.dispose();
  }

  void _applyData(Map<String, dynamic> data) {
    _storeName.text = (data['businessName'] ?? data['name'] ?? '').toString();
    _location.text = (data['location'] ?? data['city'] ?? '').toString();
    _street.text = (data['street'] ?? data['address'] ?? '').toString();
    _description.text = (data['description'] ?? '').toString();
    _phone.text = (data['phone'] ?? '').toString();
    _email.text = (data['email'] ?? '').toString();
    _hours.text =
        (data['businessHours'] ?? data['hours'] ?? '').toString();
    _storeImageUrl =
        (data['storeImageUrl'] ?? data['image'] ?? '').toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: widget.firestore.collection('users').doc(widget.storeId).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: _kTeal));
        }
        final data = snap.data!.data() ?? const <String, dynamic>{};
        if (!_hydrated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _hydrated) return;
            _hydrated = true;
            _applyData(data);
            setState(() {});
          });
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            const Text(
              'Store Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _kBrown,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _storeName,
                    decoration: const InputDecoration(labelText: 'Store name'),
                  ),
                  TextField(
                    controller: _location,
                    decoration: const InputDecoration(labelText: 'Location / area'),
                  ),
                  TextField(
                    controller: _street,
                    decoration: const InputDecoration(labelText: 'Street / address'),
                  ),
                  TextField(
                    controller: _description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  TextField(
                    controller: _phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    readOnly: true,
                  ),
                  TextField(
                    controller: _hours,
                    decoration:
                        const InputDecoration(labelText: 'Operating hours'),
                  ),
                  const SizedBox(height: 12),
                  if (_storeImageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _storeImageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final file =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (file == null) return;
                      final bytes = await file.readAsBytes();
                      final url = await widget.databaseService
                          .uploadStoreProfileImageBytes(
                        storeId: widget.storeId,
                        bytes: bytes,
                        fileName: file.name,
                      );
                      if (!mounted) return;
                      setState(() => _storeImageUrl = url);
                    },
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Store photo'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _kTeal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await widget.databaseService.updateStoreProfile(
                          widget.storeId,
                          {
                            'businessName': _storeName.text.trim(),
                            'name': _storeName.text.trim(),
                            'location': _location.text.trim(),
                            'city': _location.text.trim(),
                            'street': _street.text.trim(),
                            'address': _street.text.trim(),
                            'description': _description.text.trim(),
                            'phone': _phone.text.trim(),
                            'businessHours': _hours.text.trim(),
                            'hours': _hours.text.trim(),
                            if (_storeImageUrl.isNotEmpty)
                              'storeImageUrl': _storeImageUrl,
                            if (_storeImageUrl.isNotEmpty) 'image': _storeImageUrl,
                          },
                        );
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Saved')),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('$e')),
                        );
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Audit tab ─────────────────────────────────────────────────────────────

class _AuditTab extends StatefulWidget {
  final String storeId;
  final DatabaseService databaseService;

  const _AuditTab({
    required this.storeId,
    required this.databaseService,
  });

  @override
  State<_AuditTab> createState() => _AuditTabState();
}

class _AuditTabState extends State<_AuditTab> {
  final _search = TextEditingController();
  DateTime? _date;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: widget.databaseService.streamPetStoreAuditLogs(widget.storeId),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load audit log: ${snap.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: _kTeal));
        }
        var docs = snap.data!.docs.toList();
        docs.sort((a, b) {
          final ta = a.data()['createdAt'];
          final tb = b.data()['createdAt'];
          if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
          return 0;
        });
        final q = _search.text.trim().toLowerCase();
        if (q.isNotEmpty) {
          docs = docs.where((d) {
            final m = d.data();
            return '${m['title']} ${m['description']}'
                .toLowerCase()
                .contains(q);
          }).toList();
        }
        if (_date != null) {
          docs = docs.where((d) {
            final ts = d.data()['createdAt'];
            if (ts is! Timestamp) return false;
            final dt = ts.toDate();
            return dt.year == _date!.year &&
                dt.month == _date!.month &&
                dt.day == _date!.day;
          }).toList();
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search audit logs by action or description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _date ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) setState(() => _date = d);
                    },
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _date == null
                          ? 'mm/dd/yyyy'
                          : DateFormat.yMd().format(_date!),
                    ),
                  ),
                ),
                if (_date != null)
                  IconButton(
                    onPressed: () => setState(() => _date = null),
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text(
                  'Activity Log',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _kBrown,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: _kTeal,
                  child: Text(
                    '${docs.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (docs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No activity yet. Open/close store, edit products, or update orders to build this log.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              )
            else
              ...docs.map((d) {
                final m = d.data();
                final ts = m['createdAt'];
                String when = '';
                if (ts is Timestamp) {
                  when = DateFormat.yMMMd().add_jm().format(ts.toDate());
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.show_chart, color: Colors.blue.shade400),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                (m['title'] ?? '').toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _kBrown,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (m['description'] ?? '').toString(),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(when, style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

// ─── Product dialog ──────────────────────────────────────────────────────────

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
  final _brand = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _originalPrice = TextEditingController();
  final _stock = TextEditingController();
  String _category = 'Food';
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    if (p != null) {
      _title.text = (p['title'] ?? '').toString();
      _brand.text = (p['brand'] ?? '').toString();
      _description.text = (p['description'] ?? '').toString();
      _price.text = ((p['price'] as num?)?.toDouble() ?? 0).toString();
      final op = (p['originalPrice'] as num?)?.toDouble();
      _originalPrice.text = op != null ? op.toString() : '';
      _stock.text = ((p['stock'] as num?)?.toInt() ?? 0).toString();
      _category = (p['category'] ?? 'Food').toString();
      _imageUrl = _productImageUrl(p);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _brand.dispose();
    _description.dispose();
    _price.dispose();
    _originalPrice.dispose();
    _stock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingProduct == null ? 'Add Product' : 'Edit Product'),
      content: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _brand,
              decoration: const InputDecoration(labelText: 'Brand'),
            ),
            TextField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (JOD)'),
            ),
            TextField(
              controller: _originalPrice,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Original price (optional, for sales)',
              ),
            ),
            TextField(
              controller: _stock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock'),
            ),
          DropdownButtonFormField<String>(
              initialValue: const {'Food', 'Toys', 'Accessories', 'Health'}
                      .contains(_category)
                  ? _category
                  : 'Food',
              decoration: const InputDecoration(labelText: 'Category'),
            items: const [
              DropdownMenuItem(value: 'Food', child: Text('Food')),
              DropdownMenuItem(value: 'Toys', child: Text('Toys')),
                DropdownMenuItem(
                  value: 'Accessories',
                  child: Text('Accessories'),
                ),
              DropdownMenuItem(value: 'Health', child: Text('Health')),
            ],
            onChanged: (value) => setState(() => _category = value ?? 'Food'),
            ),
            const SizedBox(height: 12),
            if (_imageUrl.isNotEmpty) ...[
              const Text('Photo preview'),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Text('Could not load image'),
                ),
          ),
          const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
            onPressed: () async {
              final picker = ImagePicker();
                final file =
                    await picker.pickImage(source: ImageSource.gallery);
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
              icon: const Icon(Icons.upload_file),
              label: Text(_imageUrl.isEmpty ? 'Upload image' : 'Change image'),
          ),
        ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _kTeal),
          onPressed: () async {
            final price = double.tryParse(_price.text.trim()) ?? 0;
            final orig = double.tryParse(_originalPrice.text.trim());
            final payload = <String, dynamic>{
              'title': _title.text.trim(),
              'brand': _brand.text.trim(),
              'description': _description.text.trim(),
              'price': price,
              'stock': int.tryParse(_stock.text.trim()) ?? 0,
              'category': _category,
              'image': _imageUrl,
              'imageUrl': _imageUrl,
            };
            if (orig != null && orig > 0) {
              payload['originalPrice'] = orig;
            }
            try {
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
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$e')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
