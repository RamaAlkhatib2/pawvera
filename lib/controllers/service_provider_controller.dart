import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pawvera/models/service_provider_models.dart';

/// Central controller for the Service Provider Dashboard.
///
/// Uses a ChangeNotifier pattern so all dashboard tabs can listen to
/// real-time metric updates, shop status changes, etc.
class ServiceProviderController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── State ────────────────────────────────────────────
  ShopProfile? _shop;
  List<ServiceItem> _services = [];
  List<ShopOffer> _offers = [];
  List<ServiceBooking> _bookings = [];
  List<AuditLog> _auditLogs = [];
  bool _loading = true;
  String? _error;

  // Stream subscriptions
  StreamSubscription<DocumentSnapshot>? _shopSub;
  StreamSubscription<QuerySnapshot>? _servicesSub;
  StreamSubscription<QuerySnapshot>? _offersSub;
  StreamSubscription<QuerySnapshot>? _bookingsSub;
  StreamSubscription<QuerySnapshot>? _auditSub;

  // ── Getters ──────────────────────────────────────────
  bool get loading => _loading;
  String? get error => _error;
  ShopProfile? get shop => _shop;
  List<ServiceItem> get services => _services;
  List<ServiceItem> get activeServices =>
      _services.where((s) => s.isActive).toList();
  List<ShopOffer> get offers => _offers;
  List<ShopOffer> get activeOffers => _offers.where((o) => o.isActive).toList();
  List<ServiceBooking> get bookings => _bookings;
  List<AuditLog> get auditLogs => _auditLogs;

  // ── Derived Dashboard Metrics ────────────────────────
  int get totalBookings => _shop?.totalBookings ?? 0;
  int get activeBookings => _bookings
      .where((b) => b.status == 'pending' || b.status == 'confirmed')
      .length;
  double get totalRevenue => _shop?.totalRevenue ?? 0.0;
  int get activeServicesCount => activeServices.length;

  // ── Lifecycle ────────────────────────────────────────
  Future<void> init() async {
    _loading = true;
    notifyListeners();

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _error = 'Not authenticated';
      _loading = false;
      notifyListeners();
      return;
    }

    // Find the shop owned by this user
    final shopSnapshot = await _db
        .collection('service_shops')
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .get();

    if (shopSnapshot.docs.isEmpty) {
      // Auto-create a default shop profile for new providers
      await _createDefaultShop(uid);
      // Re-fetch
      final retry = await _db
          .collection('service_shops')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get();
      if (retry.docs.isEmpty) {
        _error = 'Failed to create shop';
        _loading = false;
        notifyListeners();
        return;
      }
      _listenToShop(retry.docs.first.id);
    } else {
      _listenToShop(shopSnapshot.docs.first.id);
    }
  }

  Future<void> _createDefaultShop(String ownerId) async {
    final ref = _db.collection('service_shops').doc();
    await ref.set({
      'id': ref.id,
      'ownerId': ownerId,
      'shopName': 'Pawfect Spa',
      'address': '123 Main St, Downtown',
      'phone': '+1 (555) 000-1111',
      'email': 'contact@pawfectspa.com',
      'workingHours': '9:00 AM - 7:00 PM',
      'status': 'Open',
      'isOpen': true,
      'imageUrl': null,
      'totalBookings': 0,
      'activeBookings': 0,
      'totalRevenue': 0.0,
      'activeServicesCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Add default services
    final batch = _db.batch();
    final defaultServices = [
      {
        'name': 'Full Grooming Package',
        'description': 'Bath, haircut, nail trim, and ear cleaning',
        'price': 45.0,
        'duration': '2 hours',
        'isActive': true,
      },
      {
        'name': 'Basic Bath & Brush',
        'description': 'Wash and brush service',
        'price': 30.0,
        'duration': '1 hour',
        'isActive': true,
      },
    ];
    for (final svc in defaultServices) {
      final svcRef = _db
          .collection('service_shops')
          .doc(ref.id)
          .collection('services')
          .doc();
      batch.set(svcRef, {
        ...svc,
        'id': svcRef.id,
        'shopId': ref.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    // Log the creation
    await _addAuditLog(ref.id, 'Shop Created', 'Service shop was created');
  }

  void _listenToShop(String shopId) {
    _shopSub?.cancel();
    _shopSub = _db
        .collection('service_shops')
        .doc(shopId)
        .snapshots()
        .listen(
          (snap) {
            if (snap.exists && snap.data() != null) {
              _shop = ShopProfile.fromMap(snap.data()!, snap.id);
              _loading = false;
              _error = null;
              notifyListeners();
            }
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );

    // Listen to subcollections
    _servicesSub = _db
        .collection('service_shops')
        .doc(shopId)
        .collection('services')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
          _services = snap.docs
              .map((doc) => ServiceItem.fromMap(doc.data(), doc.id))
              .toList();
          notifyListeners();
        });

    _offersSub = _db
        .collection('service_shops')
        .doc(shopId)
        .collection('offers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
          _offers = snap.docs
              .map((doc) => ShopOffer.fromMap(doc.data(), doc.id))
              .toList();
          notifyListeners();
        });

    _auditSub = _db
        .collection('service_shops')
        .doc(shopId)
        .collection('audit_logs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
          _auditLogs = snap.docs
              .map((doc) => AuditLog.fromMap(doc.data(), doc.id))
              .toList();
          notifyListeners();
        });

    // Bookings for this shop
    _bookingsSub = _db
        .collection('service_bookings')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
          _bookings = snap.docs
              .map((doc) => ServiceBooking.fromMap(doc.data(), doc.id))
              .toList();
          notifyListeners();
        });
  }

  String? get shopId => _shop?.id;

  @override
  void dispose() {
    _shopSub?.cancel();
    _servicesSub?.cancel();
    _offersSub?.cancel();
    _auditSub?.cancel();
    _bookingsSub?.cancel();
    super.dispose();
  }

  // ── Shop Info Actions ────────────────────────────────

  Future<void> updateShopInfo({
    String? shopName,
    String? address,
    String? phone,
    String? email,
    String? workingHours,
  }) async {
    final id = shopId;
    if (id == null) return;
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (shopName != null) data['shopName'] = shopName;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (workingHours != null) data['workingHours'] = workingHours;

    await _db.collection('service_shops').doc(id).update(data);
    await _addAuditLog(id, 'Shop Info Updated', 'Shop information was updated');
  }

  Future<void> setShopStatus(String status) async {
    final id = shopId;
    if (id == null) return;
    final isOpen = status == 'Open';
    await _db.collection('service_shops').doc(id).update({
      'status': status,
      'isOpen': isOpen,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _addAuditLog(
      id,
      'Shop Status Changed',
      'Shop status changed to $status',
    );
  }

  // ── Service Actions ─────────────────────────────────

  Future<void> addService({
    required String name,
    required String description,
    required double price,
    required String duration,
    bool isActive = true,
  }) async {
    final id = shopId;
    if (id == null) return;
    final ref = _db
        .collection('service_shops')
        .doc(id)
        .collection('services')
        .doc();
    await ref.set({
      'id': ref.id,
      'shopId': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _addAuditLog(id, 'Service Added', 'New service "$name" added');
    // Sync active count
    await _syncActiveServicesCount();
  }

  Future<void> updateService({
    required String serviceId,
    String? name,
    String? description,
    double? price,
    String? duration,
    bool? isActive,
  }) async {
    final id = shopId;
    if (id == null) return;
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (duration != null) data['duration'] = duration;
    if (isActive != null) data['isActive'] = isActive;

    await _db
        .collection('service_shops')
        .doc(id)
        .collection('services')
        .doc(serviceId)
        .update(data);

    final action = isActive == false ? 'Deactivated' : 'Updated';
    await _addAuditLog(id, 'Service $action', 'Service "$name" was $action');
    await _syncActiveServicesCount();
  }

  Future<void> deleteService(String serviceId) async {
    final id = shopId;
    if (id == null) return;
    await _db
        .collection('service_shops')
        .doc(id)
        .collection('services')
        .doc(serviceId)
        .delete();
    await _addAuditLog(id, 'Service Deleted', 'A service was deleted');
    await _syncActiveServicesCount();
  }

  Future<void> _syncActiveServicesCount() async {
    final id = shopId;
    if (id == null) return;
    final snapshot = await _db
        .collection('service_shops')
        .doc(id)
        .collection('services')
        .where('isActive', isEqualTo: true)
        .count()
        .get();
    await _db.collection('service_shops').doc(id).update({
      'activeServicesCount': snapshot.count ?? 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Offer Actions ───────────────────────────────────

  Future<void> addOffer({
    String? serviceId,
    String? serviceName,
    required int discountPercent,
    required String expiryDate,
    bool isShopWide = true,
    double? minPrice,
    double? maxPrice,
    double? minBookingAmount,
  }) async {
    final id = shopId;
    if (id == null) return;
    final ref = _db
        .collection('service_shops')
        .doc(id)
        .collection('offers')
        .doc();
    await ref.set({
      'id': ref.id,
      'shopId': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'discountPercent': discountPercent,
      'expiryDate': expiryDate,
      'isActive': true,
      'isShopWide': isShopWide,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minBookingAmount': minBookingAmount,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _addAuditLog(
      id,
      'Offer Created',
      'New ${isShopWide ? "shop-wide" : "service"} offer created: $discountPercent% off',
    );
  }

  Future<void> toggleOfferActive(String offerId, bool isActive) async {
    final id = shopId;
    if (id == null) return;
    await _db
        .collection('service_shops')
        .doc(id)
        .collection('offers')
        .doc(offerId)
        .update({
          'isActive': isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
    await _addAuditLog(
      id,
      isActive ? 'Offer Activated' : 'Offer Deactivated',
      'An offer was ${isActive ? "activated" : "deactivated"}',
    );
  }

  Future<void> deleteOffer(String offerId) async {
    final id = shopId;
    if (id == null) return;
    await _db
        .collection('service_shops')
        .doc(id)
        .collection('offers')
        .doc(offerId)
        .delete();
    await _addAuditLog(id, 'Offer Deleted', 'An offer was deleted');
  }

  // ── Booking Actions ─────────────────────────────────

  Future<void> updateBookingStatus(String bookingId, String status) async {
    final id = shopId;
    if (id == null) return;
    await _db.collection('service_bookings').doc(bookingId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update shop counters
    if (status == 'confirmed') {
      await _db.collection('service_shops').doc(id).update({
        'activeBookings': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else if (status == 'completed') {
      await _db.collection('service_shops').doc(id).update({
        'activeBookings': FieldValue.increment(-1),
        'totalBookings': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Revenue will be updated separately when price is tracked
    } else if (status == 'cancelled') {
      await _db.collection('service_shops').doc(id).update({
        'activeBookings': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await _addAuditLog(
      id,
      'Booking $status',
      'Booking $bookingId status changed to $status',
    );
  }

  // ── Audit Helper ────────────────────────────────────

  Future<void> _addAuditLog(
    String shopId,
    String action,
    String details,
  ) async {
    final ref = _db
        .collection('service_shops')
        .doc(shopId)
        .collection('audit_logs')
        .doc();
    await ref.set({
      'id': ref.id,
      'shopId': shopId,
      'action': action,
      'details': details,
      'displayDate': DateTime.now().toString(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Booking Conflict Check ──────────────────────────

  /// Check if a given time slot on a given date already has a confirmed booking
  Future<bool> hasSchedulingConflict({
    required String date,
    required String time,
    String? excludeBookingId,
  }) async {
    final id = shopId;
    if (id == null) return false;
    final existing = await _db
        .collection('service_bookings')
        .where('shopId', isEqualTo: id)
        .where('date', isEqualTo: date)
        .where('time', isEqualTo: time)
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();

    if (excludeBookingId != null) {
      return existing.docs.any((doc) => doc.id != excludeBookingId);
    }
    return existing.docs.isNotEmpty;
  }

  /// Public: Create a booking directly (used by Pet Owner flow)
  Future<String> createBookingForOwner({
    required String shopId,
    required String shopName,
    required String userName,
    required String userPhone,
    required String petName,
    required String petBreed,
    required String serviceId,
    required String serviceName,
    required double servicePrice,
    required String date,
    required String time,
    String? notes,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    // Check conflict
    final conflict = await hasSchedulingConflict(date: date, time: time);
    if (conflict) {
      throw Exception(
        'This time slot is already booked. Please choose another time.',
      );
    }

    final ref = _db.collection('service_bookings').doc();
    await ref.set({
      'id': ref.id,
      'shopId': shopId,
      'shopName': shopName,
      'userId': uid,
      'userName': userName,
      'userPhone': userPhone,
      'petName': petName,
      'petBreed': petBreed,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'date': date,
      'time': time,
      'status': 'pending',
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
