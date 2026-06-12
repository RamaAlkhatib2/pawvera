import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:convert';

/// Firestore may store `tags` or `categories` as mixed types; never throw from stream transforms.
List<String> _storeListNormalized(Object? raw) {
  if (raw is! List) return <String>[];
  return raw
      .map((e) => e.toString().trim().toLowerCase())
      .where((s) => s.isNotEmpty)
      .toList();
}

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to continue.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');
  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');
  CollectionReference<Map<String, dynamic>> get _usersCart =>
      _db.collection('users_cart');
  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection('reviews');

  /// One shared stream per [storeId] so list rebuilds (search/favorites) do not
  /// cancel/recreate Firestore listeners (which broke live store ratings on the list page).
  final Map<String, Stream<QuerySnapshot<Map<String, dynamic>>>>
  _storeReviewsByStoreId = {};

  final Map<String, Stream<QuerySnapshot<Map<String, dynamic>>>>
  _serviceShopReviewsByShopId = {};

  /// Pet care shop review (not pet-supplies `store` / `product` types).
  static bool reviewDocIsServiceShop(Map<String, dynamic> m) {
    final t = (m['type'] ?? '').toString();
    if (t == 'product' || t == 'store') return false;
    if (t == 'service_shop' || t == 'shop') return true;
    final shopId = (m['shopId'] ?? '').toString().trim();
    if (shopId.isEmpty) return false;
    return (m['productId'] ?? '').toString().trim().isEmpty &&
        (m['storeId'] ?? '').toString().trim().isEmpty;
  }

  static double averageStarsFromReviewDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (docs.isEmpty) return 0;
    var sum = 0.0;
    for (final d in docs) {
      final m = d.data();
      final raw = m['stars'] ?? m['rating'] ?? m['star'];
      sum += ((raw as num?)?.toDouble() ?? 0).clamp(0, 5);
    }
    return sum / docs.length;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
  _filterServiceShopReviewDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> raw,
  ) {
    return raw.where((d) => reviewDocIsServiceShop(d.data())).toList();
  }

  // --- User Profile ---

  // Get current user data
  Stream<DocumentSnapshot> get userData {
    String uid = _auth.currentUser!.uid;
    return _db.collection('users').doc(uid).snapshots();
  }

  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    String uid = _auth.currentUser!.uid;
    return await _db.collection('users').doc(uid).update(data);
  }

  // --- Pets ---

  // Add a new pet
  Future<void> addPet(Map<String, dynamic> petData) async {
    String uid = _auth.currentUser!.uid;
    await _db.collection('users').doc(uid).collection('pets').add({
      ...petData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadPetImage({
    required String uid,
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final safe = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final ref = _storage.ref().child(
        'users/$uid/pets/${DateTime.now().millisecondsSinceEpoch}_$safe',
      );
      await ref.putData(bytes).timeout(const Duration(seconds: 30));
      return await ref.getDownloadURL();
    } catch (_) {
      return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    }
  }

  // Get list of pets for current user
  Stream<QuerySnapshot> get userPets {
    String uid = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(uid)
        .collection('pets')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // --- Bookings & Appointments ---

  // Create a booking
  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    final shopId = bookingData['shopId'] as String?;
    final userId = _auth.currentUser!.uid;
    String? shopBookingId;

    // Save to shop's subcollection FIRST (so we can capture the booking ID)
    if (shopId != null && shopId.isNotEmpty) {
      try {
        final ref = _db
            .collection('service_shops')
            .doc(shopId)
            .collection('bookings')
            .doc();
        shopBookingId = ref.id;
        // Convert price to string safely (avoids crash if price is a num)
        final priceStr = bookingData['price']?.toString() ?? '0';
        await ref.set({
          'id': ref.id,
          'shopId': shopId,
          'shopName':
              bookingData['clinicName'] ?? bookingData['provider'] ?? '',
          'userId': userId,
          'userName': bookingData['name'] ?? '',
          'userPhone': bookingData['phone'] ?? '',
          'petName': bookingData['pet'] ?? '',
          'petBreed': '',
          'serviceId': bookingData['serviceId'] ?? '',
          'serviceName': bookingData['service'] ?? '',
          'servicePrice':
              double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ??
              0.0,
          'date': bookingData['date'] ?? '',
          'time': bookingData['time'] ?? '',
          'status': 'confirmed',
          'notes': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // If shop subcollection save fails, still continue with user save
      }
    }

    // Save to users/{userId}/bookings/ (compatible with deployed Firestore rules)
    await _db.collection('users').doc(userId).collection('bookings').add({
      ...bookingData,
      'userId': userId,
      'shopBookingId': ?shopBookingId,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates date+time in both the user's and the shop's booking documents.
  /// [newDate] must be in "d/M/yyyy" format (e.g. "26/5/2026").
  Future<void> rescheduleBooking({
    required String userBookingId,
    required String shopId,
    required String shopBookingId,
    required String newDate,
    required String newTime,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final updates = {
      'date': newDate,
      'time': newTime,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _db
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .doc(userBookingId)
        .update(updates);
    if (shopId.isNotEmpty && shopBookingId.isNotEmpty) {
      try {
        await _db
            .collection('service_shops')
            .doc(shopId)
            .collection('bookings')
            .doc(shopBookingId)
            .update(updates);
      } catch (_) {}
    }
  }

  // Get my bookings
  Stream<QuerySnapshot> get myBookings {
    final uid = _auth.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('bookings').snapshots();
  }

  // --- Reminders ---

  // Add reminder
  Future<String> addReminder(Map<String, dynamic> reminderData) async {
    final uid = _auth.currentUser!.uid;
    final ref = _db.collection('users').doc(uid).collection('reminders').doc();
    await ref.set({
      ...reminderData,
      'id': ref.id,
      'notificationSent': false,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // Update reminder
  Future<void> updateReminder(
    String reminderId,
    Map<String, dynamic> data,
  ) async {
    final uid = _auth.currentUser!.uid;
    await _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .doc(reminderId)
        .update({...data, 'updatedAt': FieldValue.serverTimestamp()});
  }

  // Delete reminder
  Future<void> deleteReminder(String reminderId) async {
    final uid = _auth.currentUser!.uid;
    await _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .doc(reminderId)
        .delete();
  }

  // Stream reminders ordered by date ascending
  Stream<QuerySnapshot> get reminders {
    final uid = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .orderBy('dateTime', descending: false)
        .snapshots();
  }

  // --- Pet Care Shop Favorites ---

  Stream<QuerySnapshot> get favoritePetCareShops {
    final uid = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(uid)
        .collection('pet_care_favorites')
        .snapshots();
  }

  Future<void> toggleFavoritePetCareShop(String shopId) async {
    final uid = _auth.currentUser!.uid;
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('pet_care_favorites')
        .doc(shopId);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'shopId': shopId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Returns the set of booked time slot strings for [shopId] on [date].
  /// Queries the shop's bookings subcollection and excludes cancelled ones.
  Future<Set<String>> getBookedTimeSlotsForShop(
    String shopId,
    String date,
  ) async {
    if (shopId.isEmpty) return {};
    try {
      final snap = await _db
          .collection('service_shops')
          .doc(shopId)
          .collection('bookings')
          .where('date', isEqualTo: date)
          .get();
      return snap.docs
          .where((doc) {
            final status = (doc.data()['status'] ?? '')
                .toString()
                .toLowerCase();
            return status != 'cancelled';
          })
          .map((doc) => (doc.data()['time'] ?? '').toString())
          .where((t) => t.isNotEmpty)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  /// Returns true if [shopId] already has a non-cancelled booking for [date]+[time].
  Future<bool> isShopTimeslotBooked(
    String shopId,
    String date,
    String time,
  ) async {
    if (shopId.isEmpty) return false;
    final booked = await getBookedTimeSlotsForShop(shopId, date);
    return booked.contains(time);
  }

  /// Returns true if the current user's [petName] already has a non-cancelled
  /// booking at [date]+[time] (prevents double-booking a pet at the same time).
  Future<bool> hasPetBookingConflict({
    required String petName,
    required String date,
    required String time,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || petName.isEmpty) return false;
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('bookings')
          .where('date', isEqualTo: date)
          .get();
      return snap.docs.any((doc) {
        final d = doc.data();
        final status = (d['status'] ?? '').toString().toLowerCase();
        return status != 'cancelled' &&
            d['pet'] == petName &&
            d['time'] == time;
      });
    } catch (_) {
      return false;
    }
  }

  // --- Reminder Types (admin-managed global list) ---

  CollectionReference<Map<String, dynamic>> get _reminderTypes =>
      _db.collection('reminder_types');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamReminderTypes() =>
      _reminderTypes.orderBy('name').snapshots();

  Future<void> seedDefaultReminderTypesIfEmpty() async {
    final snap = await _reminderTypes.limit(1).get();
    if (snap.docs.isNotEmpty) return;
    const defaults = ['Vaccination', 'Medication', 'Grooming', 'Checkup'];
    final batch = _db.batch();
    for (final name in defaults) {
      final ref = _reminderTypes.doc();
      batch.set(ref, {
        'id': ref.id,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  // --- Notifications ---

  CollectionReference<Map<String, dynamic>> get _notificationsCol =>
      _db.collection('users').doc(_uid).collection('notifications');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyNotifications() =>
      _notificationsCol.orderBy('createdAt', descending: true).snapshots();

  Future<void> markNotificationRead(String notifId) async =>
      _notificationsCol.doc(notifId).update({'isRead': true});

  Future<void> markAllNotificationsRead() async {
    final snap = await _notificationsCol
        .where('isRead', isEqualTo: false)
        .get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String notifId) async =>
      _notificationsCol.doc(notifId).delete();

  Future<void> deleteNotifications(List<String> ids) async {
    if (ids.isEmpty) return;
    final batch = _db.batch();
    for (final id in ids) {
      batch.delete(_notificationsCol.doc(id));
    }
    await batch.commit();
  }

  // --- Notification Service: fires due reminder notifications ---
  // Call on app open to convert due reminders into notification docs.
  Future<void> checkAndFireDueReminderNotifications() async {
    final uid = _auth.currentUser!.uid;
    final now = Timestamp.fromDate(DateTime.now());
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .where('notificationSent', isEqualTo: false)
        .where('dateTime', isLessThanOrEqualTo: now)
        .get();
    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snap.docs) {
      final data = doc.data();
      final notifRef = _notificationsCol.doc();
      batch.set(notifRef, {
        'id': notifRef.id,
        'userId': uid,
        'title': 'Reminder: ${data['title'] ?? ''}',
        'description': '${data['title']} for ${data['petName'] ?? 'your pet'}',
        'type': 'reminder',
        'isRead': false,
        'reminderId': doc.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
      final updates = <String, dynamic>{'notificationSent': true};
      if ((data['repeat'] ?? 'Never') == 'Never') {
        updates['isCompleted'] = true;
      }
      batch.update(doc.reference, updates);
    }
    await batch.commit();
  }

  // Update a pet's metadata
  Future<void> updatePet(String petId, Map<String, dynamic> data) async {
    String uid = _auth.currentUser!.uid;
    await _db
        .collection('users')
        .doc(uid)
        .collection('pets')
        .doc(petId)
        .update(data);
  }

  // Delete a pet
  Future<void> deletePet(String petId) async {
    String uid = _auth.currentUser!.uid;
    await _db
        .collection('users')
        .doc(uid)
        .collection('pets')
        .doc(petId)
        .delete();
  }

  // --- Bookings update/delete ---

  // Update a booking
  Future<void> updateBooking(
    String bookingId,
    Map<String, dynamic> data,
  ) async {
    final uid = _auth.currentUser!.uid;
    await _db
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .doc(bookingId)
        .update(data);
  }

  // Delete a booking
  Future<void> deleteBooking(String bookingId) async {
    final uid = _auth.currentUser!.uid;
    await _db
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .doc(bookingId)
        .delete();
  }

  // --- Online Store: Data Initialization ---

  /// Reserved for future migrations. Does **not** seed demo stores — those
  /// were easy to confuse with real Firebase data and hid console-created docs
  /// that lacked `isActive: true`.
  Future<void> ensureStoreCollectionsInitialized() async {}

  // --- Online Store: Browsing & Discovery ---

  bool _isActivePetStoreOffer(Map<String, dynamic> offer) {
    if (offer['isActive'] == false) return false;
    final validUntil = offer['validUntil'];
    if (validUntil is Timestamp) {
      final endOfDay = validUntil.toDate().add(const Duration(days: 1));
      if (DateTime.now().isAfter(endOfDay)) return false;
    }
    return true;
  }

  List<Map<String, dynamic>> _activeOffersFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final rows = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .where(_isActivePetStoreOffer)
        .toList();
    rows.sort((a, b) {
      final ap = ((a['discountPercent'] as num?)?.toDouble() ?? 0);
      final bp = ((b['discountPercent'] as num?)?.toDouble() ?? 0);
      return bp.compareTo(ap);
    });
    return rows;
  }

  Future<List<Map<String, dynamic>>> _fetchActivePetStoreOffers(
    String storeId,
  ) async {
    if (storeId.isEmpty) return <Map<String, dynamic>>[];
    try {
      final snapshot = await _petStoreOffersCol(storeId).get();
      return _activeOffersFromSnapshot(snapshot);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Stream<List<Map<String, dynamic>>> streamStores({
    String? searchQuery,
    String? category,
    bool offersOnly = false,
    bool onlyActive = true,
  }) {
    // Stores are provider users (role=='provider', providerType=='Pet Supplies Store').
    // Role/type filters run on the server; visibility, search, category, and
    // offer filters run in Dart so missing fields can't break the stream.
    final query = _db
        .collection('users')
        .where('role', isEqualTo: 'provider')
        .where('providerType', isEqualTo: 'Pet Supplies Store');

    return query.snapshots().asyncMap((snapshot) async {
      final normalizedQuery = (searchQuery ?? '').trim().toLowerCase();
      final normalizedCategory = (category ?? 'all').trim().toLowerCase();

      final storeRows = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final offers = await _fetchActivePetStoreOffers(doc.id);
          return {
            ...data,
            'id': doc.id,
            // Surface `businessName` as `name` so the existing UI keeps working.
            'name': (data['businessName'] ?? data['name'] ?? '').toString(),
            'activeOffers': offers,
            'hasActiveOffers':
                offers.isNotEmpty ||
                (data['offer'] ?? '').toString().trim().isNotEmpty,
          };
        }),
      );

      final filteredDocs = storeRows.where((data) {
        if (onlyActive && data['isActive'] != true) {
          return false;
        }
        final name = (data['businessName'] ?? data['name'] ?? '')
            .toString()
            .toLowerCase();
        final description = (data['description'] ?? '')
            .toString()
            .toLowerCase();
        final tags = _storeListNormalized(data['tags']);
        final categories = _storeListNormalized(data['categories']);
        final combinedTags = {...tags, ...categories};
        final hasOffers = data['hasActiveOffers'] == true;

        final matchesSearch =
            normalizedQuery.isEmpty ||
            name.contains(normalizedQuery) ||
            description.contains(normalizedQuery);
        final matchesCategory =
            normalizedCategory == 'all' ||
            combinedTags.contains(normalizedCategory);
        final matchesOffer = !offersOnly || hasOffers;

        return matchesSearch && matchesCategory && matchesOffer;
      }).toList();

      filteredDocs.sort(
        (a, b) => (a['name'] ?? '').toString().compareTo(
          (b['name'] ?? '').toString(),
        ),
      );
      return filteredDocs;
    });
  }

  Stream<List<Map<String, dynamic>>> streamActivePetStoreOffers(
    String storeId,
  ) {
    return _petStoreOffersCol(
      storeId,
    ).snapshots().map(_activeOffersFromSnapshot);
  }

  Future<List<Map<String, dynamic>>> fetchActivePetStoreOffers(
    String storeId,
  ) => _fetchActivePetStoreOffers(storeId);

  Stream<List<Map<String, dynamic>>> streamStoreProducts(
    String storeId, {
    String searchQuery = '',
    String category = 'All',
    bool onSaleOnly = false,
  }) {
    // Single-field `where('storeId')` avoids a composite index; filter `isActive` client-side.
    final query = _products.where('storeId', isEqualTo: storeId);

    return query.snapshots().map((snapshot) {
      final normalizedQuery = searchQuery.trim().toLowerCase();
      final normalizedCategory = category.trim().toLowerCase();

      final filteredDocs = snapshot.docs
          .where((doc) {
            final data = doc.data();
            if (data['isActive'] == false) return false;
            final title = (data['title'] ?? '').toString().toLowerCase();
            final desc = (data['description'] ?? '').toString().toLowerCase();
            final productCategory = (data['category'] ?? '')
                .toString()
                .toLowerCase();
            final offerText =
                (data['offer'] ?? '').toString().trim().isNotEmpty;
            final flaggedOnSale = data['hasSale'] == true;
            final origPrice = (data['originalPrice'] as num?)?.toDouble();
            final curPrice = (data['price'] as num?)?.toDouble() ?? 0;
            final pricedDown =
                origPrice != null && origPrice > curPrice;
            final hasOffer = offerText || flaggedOnSale || pricedDown;

            final matchesSearch =
                normalizedQuery.isEmpty ||
                title.contains(normalizedQuery) ||
                desc.contains(normalizedQuery);
            final matchesCategory =
                normalizedCategory == 'all' ||
                productCategory == normalizedCategory;
            final matchesSale = !onSaleOnly || hasOffer;
            return matchesSearch && matchesCategory && matchesSale;
          })
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      return filteredDocs;
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamProductById(
    String productId,
  ) {
    return _products.doc(productId).snapshots();
  }

  // --- Online Store: Cart & Wishlist ---

  /// No [orderBy]: Firestore returns stable document-ID order. Ordering by
  /// [updatedAt] made the edited line jump to the top whenever quantity changed.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyCart() {
    return _usersCart.doc(_uid).collection('cart_items').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyCartForStore(
    String storeId,
  ) {
    return _usersCart
        .doc(_uid)
        .collection('cart_items')
        .where('storeId', isEqualTo: storeId)
        .snapshots();
  }

  Future<void> addOrUpdateCartItem({
    required String storeId,
    required String productId,
    required int quantity,
    required Map<String, dynamic> productSnapshot,
    String? storeName,
  }) async {
    try {
      final itemRef = _usersCart
          .doc(_uid)
          .collection('cart_items')
          .doc(productId);
      final now = FieldValue.serverTimestamp();
      final existing = await itemRef.get();
      final sn = (storeName ??
              productSnapshot['storeName'] ??
              '')
          .toString()
          .trim();
      final data = <String, dynamic>{
        'id': productId,
        'storeId': storeId,
        if (sn.isNotEmpty) 'storeName': sn,
        'productId': productId,
        'userId': _uid,
        'title': productSnapshot['title'],
        'price': productSnapshot['price'],
        'image': productSnapshot['image'],
        'quantity': quantity,
        'updatedAt': now,
      };
      if (!existing.exists) {
        data['createdAt'] = now;
      }
      await itemRef.set(data, SetOptions(merge: true));
    } catch (_) {
      throw Exception('Unable to update cart item. Please try again.');
    }
  }

  Future<void> removeCartItem(String productId) async {
    try {
      await _usersCart
          .doc(_uid)
          .collection('cart_items')
          .doc(productId)
          .delete();
    } catch (_) {
      throw Exception('Unable to remove cart item right now.');
    }
  }

  Future<void> clearMyCart() async {
    try {
      final cartSnapshot = await _usersCart
          .doc(_uid)
          .collection('cart_items')
          .get();
      final batch = _db.batch();
      for (final doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {
      throw Exception('Unable to clear your cart at the moment.');
    }
  }

  /// Removes only cart items that belong to [storeId] for the current user.
  Future<void> removeCartItemsForStore(String storeId) async {
    try {
      if (storeId.trim().isEmpty) return;
      final cartSnapshot = await _usersCart
          .doc(_uid)
          .collection('cart_items')
          .where('storeId', isEqualTo: storeId)
          .get();
      if (cartSnapshot.docs.isEmpty) return;
      final batch = _db.batch();
      for (final doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {
      throw Exception('Unable to update your cart at the moment.');
    }
  }

  /// Clears the cart then adds each line from a previous pet-store [order]
  /// (same shape as saved in `orders`). Same flow as shopping then checkout.
  Future<void> refillCartFromPetStoreOrder(Map<String, dynamic> order) async {
    final storeId = (order['storeId'] ?? '').toString().trim();
    if (storeId.isEmpty) {
      throw Exception('This order has no store.');
    }
    final raw = order['items'];
    if (raw is! List || raw.isEmpty) {
      throw Exception('This order has no items to repeat.');
    }
    final items = <Map<String, dynamic>>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) {
        items.add(e);
      } else if (e is Map) {
        items.add(Map<String, dynamic>.from(e));
      }
    }
    await clearMyCart();
    for (final item in items) {
      final productId = (item['productId'] ?? item['id'] ?? '')
          .toString()
          .trim();
      if (productId.isEmpty) continue;
      final qty = ((item['quantity'] as num?)?.toInt() ?? 1);
      if (qty < 1) continue;
      final snap = Map<String, dynamic>.from(item);
      snap['storeId'] = storeId;
      await addOrUpdateCartItem(
        storeId: storeId,
        productId: productId,
        quantity: qty,
        productSnapshot: snap,
      );
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyWishlist() {
    return _usersCart
        .doc(_uid)
        .collection('wishlist_items')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamWishlistItem(
    String productId,
  ) {
    return _usersCart
        .doc(_uid)
        .collection('wishlist_items')
        .doc(productId)
        .snapshots();
  }

  Future<void> toggleWishlistItem({
    required String storeId,
    required String productId,
    required Map<String, dynamic> productSnapshot,
  }) async {
    try {
      final ref = _usersCart
          .doc(_uid)
          .collection('wishlist_items')
          .doc(productId);
      final existing = await ref.get();
      if (existing.exists) {
        await ref.delete();
      } else {
        await ref.set({
          'id': productId,
          'itemType': 'product',
          'storeId': storeId,
          'productId': productId,
          'userId': _uid,
          'title': productSnapshot['title'] ?? productSnapshot['name'],
          'brand': productSnapshot['brand'],
          'price': productSnapshot['price'],
          'image': productSnapshot['image'] ?? productSnapshot['imageUrl'],
          'storeName': productSnapshot['storeName'],
          'ratingAvg': productSnapshot['ratingAvg'],
          'ratingCount': productSnapshot['ratingCount'],
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      throw Exception('Unable to update wishlist. Please try again.');
    }
  }

  Future<void> removeWishlistItem(String productId) async {
    try {
      await _usersCart
          .doc(_uid)
          .collection('wishlist_items')
          .doc(productId)
          .delete();
    } catch (_) {
      throw Exception('Unable to remove wishlist item right now.');
    }
  }

  String _favoriteStoreDocId(String storeId) => 'store_$storeId';

  Stream<QuerySnapshot<Map<String, dynamic>>> streamFavoriteStores() {
    return _usersCart
        .doc(_uid)
        .collection('wishlist_items')
        .where('itemType', isEqualTo: 'store')
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamFavoriteStore(
    String storeId,
  ) {
    return _usersCart
        .doc(_uid)
        .collection('wishlist_items')
        .doc(_favoriteStoreDocId(storeId))
        .snapshots();
  }

  Future<void> toggleFavoriteStore({
    required String storeId,
    required Map<String, dynamic> storeSnapshot,
  }) async {
    if (storeId.trim().isEmpty) {
      throw Exception('Invalid store.');
    }
    try {
      final ref = _usersCart
          .doc(_uid)
          .collection('wishlist_items')
          .doc(_favoriteStoreDocId(storeId));
      final existing = await ref.get();
      if (existing.exists) {
        await ref.delete();
      } else {
        await ref.set({
          'id': storeId,
          'itemType': 'store',
          'storeId': storeId,
          'userId': _uid,
          'name': storeSnapshot['name'] ?? storeSnapshot['businessName'],
          'image': storeSnapshot['image'] ?? storeSnapshot['storeImageUrl'],
          'description': storeSnapshot['description'],
          'location': storeSnapshot['location'] ?? storeSnapshot['address'],
          'ratingAvg': storeSnapshot['ratingAvg'],
          'ratingCount': storeSnapshot['ratingCount'],
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {
      throw Exception('Unable to update favorite stores. Please try again.');
    }
  }

  // --- Online Store: Ordering & Checkout ---

  void _validatePetStoreDeliveryAddress(Map<String, dynamic> d) {
    String s(String k) => (d[k] ?? '').toString().trim();
    if (s('fullName').isEmpty) {
      throw Exception('Full name is required.');
    }
    if (s('city').isEmpty) {
      throw Exception('City is required.');
    }
    if (s('street').isEmpty) {
      throw Exception('Street is required.');
    }
    if (s('building').isEmpty) {
      throw Exception('Building is required.');
    }
    final digits = s('phoneNumber').replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) {
      throw Exception('Enter a valid phone number.');
    }
  }

  /// Public store profile for checkout (name, location line).
  Future<Map<String, dynamic>> fetchPetStorePublicForCheckout(
    String storeId,
  ) async {
    if (storeId.trim().isEmpty) {
      return {'name': '', 'location': ''};
    }
    try {
      final d = await _db.collection('users').doc(storeId).get();
      if (!d.exists) {
        return {'name': 'Store', 'location': ''};
      }
      final data = d.data() ?? {};
      final name = (data['businessName'] ?? data['name'] ?? 'Store').toString();
      final location = (data['location'] ?? data['address'] ?? '')
          .toString()
          .trim();
      return {'name': name, 'location': location};
    } catch (_) {
      return {'name': 'Store', 'location': ''};
    }
  }

  void _validateCardPaymentMeta(Map<String, dynamic> m) {
    const allowedBrands = {'visa', 'mastercard', 'amex', 'discover'};
    for (final k in m.keys) {
      if (!const {'brand', 'lastFourDigits', 'cardholderName'}.contains(k)) {
        throw Exception('Invalid payment payload.');
      }
    }
    final brand = (m['brand'] ?? '').toString().toLowerCase();
    if (!allowedBrands.contains(brand)) {
      throw Exception('Invalid card brand.');
    }
    final last = (m['lastFourDigits'] ?? '').toString();
    if (!RegExp(r'^\d{4}$').hasMatch(last)) {
      throw Exception('Invalid card reference.');
    }
    if ((m['cardholderName'] ?? '').toString().trim().length < 2) {
      throw Exception('Invalid cardholder name.');
    }
  }

  Future<({String orderId, double totalJod})> setOrder({
    required String storeId,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
    required String paymentMethod, // cash | credit
    Map<String, dynamic>? cardPaymentMeta,
  }) async {
    if (items.isEmpty) {
      throw Exception('Your cart is empty.');
    }
    if (paymentMethod != 'cash' && paymentMethod != 'credit') {
      throw Exception('Unsupported payment method.');
    }
    _validatePetStoreDeliveryAddress(deliveryAddress);
    if (paymentMethod == 'credit') {
      if (cardPaymentMeta == null) {
        throw Exception('Card payment confirmation is required.');
      }
      _validateCardPaymentMeta(cardPaymentMeta);
    } else if (cardPaymentMeta != null) {
      throw Exception('Invalid payment data for cash order.');
    }
    try {
      final subtotal = items.fold<double>(
        0,
        (runningTotal, item) =>
            runningTotal +
            ((item['price'] as num?)?.toDouble() ?? 0) *
                ((item['quantity'] as num?)?.toInt() ?? 1),
      );
      final deliveryFee = items.isEmpty ? 0.0 : 5.0;
      final offers = await _fetchActivePetStoreOffers(storeId);
      Map<String, dynamic>? appliedOffer;
      double discount = 0;
      for (final offer in offers.where((o) => o['kind'] == 'store_wide')) {
        final minOrder = ((offer['minOrderJod'] as num?)?.toDouble() ?? 0);
        final pct = ((offer['discountPercent'] as num?)?.toDouble() ?? 0);
        final filterByPriceRange = offer['filterByPriceRange'] as bool? ?? false;
        if (pct <= 0 || subtotal < minOrder) continue;
        double qualifying = subtotal;
        if (filterByPriceRange) {
          final pMin = ((offer['priceMinJod'] as num?)?.toDouble() ?? 0);
          final pMax = ((offer['priceMaxJod'] as num?)?.toDouble() ?? 0);
          qualifying = items.fold(0.0, (acc, item) {
            final price = ((item['price'] as num?)?.toDouble() ?? 0);
            final qty = ((item['quantity'] as num?)?.toInt() ?? 1);
            return (pMin <= price && price <= pMax) ? acc + price * qty : acc;
          });
        }
        if (qualifying <= 0) continue;
        final value = qualifying * (pct / 100);
        if (value > discount) {
          discount = value;
          appliedOffer = offer;
        }
      }
      final total = subtotal - discount + deliveryFee;
      final orderRef = _orders.doc();

      var storeName = 'Store';
      try {
        final storeDoc = await _db.collection('users').doc(storeId).get();
        if (storeDoc.exists) {
          final sd = storeDoc.data() ?? {};
          storeName = (sd['businessName'] ?? sd['name'] ?? 'Store')
              .toString()
              .trim();
          if (storeName.isEmpty) storeName = 'Store';
        }
      } catch (_) {}

      final orderData = {
        'id': orderRef.id,
        'storeId': storeId,
        'storeName': storeName,
        'userId': _uid,
        'items': items,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentMethod == 'credit' ? 'paid' : 'pending',
        'status': 'pending',
        'subtotal': subtotal,
        'discount': discount,
        'deliveryFee': deliveryFee,
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (appliedOffer != null) {
        orderData['appliedOffer'] = appliedOffer;
      }
      if (paymentMethod == 'credit' && cardPaymentMeta != null) {
        orderData['cardPayment'] = {
          'brand': cardPaymentMeta['brand'],
          'lastFourDigits': cardPaymentMeta['lastFourDigits'],
          'cardholderName': cardPaymentMeta['cardholderName'],
        };
      }
      await orderRef.set(orderData);

      // Remove only the items from the purchased store so other stores'
      // items remain in the user's cart.
      await removeCartItemsForStore(storeId);
      return (orderId: orderRef.id, totalJod: total);
    } catch (_) {
      throw Exception('Could not place order. Please try again.');
    }
  }

  /// Single-field [where] avoids a composite index. Sort by [createdAt] in the UI.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyOrders() {
    return _orders.where('userId', isEqualTo: _uid).snapshots();
  }

  /// Buyer-side self-notification: called from the buyer's own app context so
  /// the write goes to the buyer's OWN sub-collection (no cross-user permission
  /// issues). Idempotent — uses [buyerNotifiedStatus] on the order to skip if
  /// this status was already notified.
  Future<void> selfNotifyOrderStatus(
    String orderId,
    Map<String, dynamic> orderData,
  ) async {
    final uid = _uid;
    if (uid.isEmpty) return;

    final status = (orderData['status'] ?? '').toString();
    final alreadyNotified =
        (orderData['buyerNotifiedStatus'] ?? '').toString();

    // Skip pending, cancelled, or already-notified states.
    if (status.isEmpty ||
        status == 'pending' ||
        status == alreadyNotified) {
      return;
    }

    final storeName =
        (orderData['storeName'] ?? 'the store').toString().trim();
    final (title, description) =
        _orderStatusNotificationText(status, storeName);
    if (title.isEmpty) {
      return;
    }

    try {
      final ref = _notificationsCol.doc();
      await ref.set({
        'id': ref.id,
        'userId': uid,
        'title': title,
        'description': description,
        'type': 'order',
        'isRead': false,
        'orderId': orderId,
        'orderStatus': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Stamp the order so we don't notify for this status again.
      await _orders.doc(orderId).update({'buyerNotifiedStatus': status});
    } catch (e) {
      // ignore: avoid_print
      print('[PawVera] selfNotifyOrderStatus error: $e');
    }
  }

  // --- Pet Care: Ratings ---

  Future<bool> canRatePetCareBooking({
    required String bookingId,
    String? shopId,
  }) async {
    final id = bookingId.trim();
    if (id.isEmpty) return false;
    final doc = await _db
        .collection('users')
        .doc(_uid)
        .collection('bookings')
        .doc(id)
        .get();
    if (!doc.exists) return false;
    final data = doc.data() ?? <String, dynamic>{};
    final status = (data['status'] ?? '').toString().toLowerCase();
    if (status.isNotEmpty && status != 'completed' && status != 'confirmed') {
      return false;
    }
    final sid = (shopId ?? data['shopId'] ?? '').toString().trim();
    if (sid.isEmpty) return false;
    return true;
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?>
  _getPetCareServiceReviewForBooking(String bookingId) async {
    final id = bookingId.trim();
    if (id.isEmpty) return null;
    final snap = await _reviews
        .where('bookingId', isEqualTo: id)
        .where('type', isEqualTo: 'service')
        .where('userId', isEqualTo: _uid)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty ? snap.docs.first : null;
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?>
  _getPetCareShopReviewForBooking(String bookingId) async {
    final id = bookingId.trim();
    if (id.isEmpty) return null;
    final snap = await _reviews
        .where('bookingId', isEqualTo: id)
        .where('type', isEqualTo: 'service_shop')
        .where('userId', isEqualTo: _uid)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty ? snap.docs.first : null;
  }

  Future<Map<String, dynamic>?> getPetCareServiceReviewForBooking(
    String bookingId,
  ) async {
    final doc = await _getPetCareServiceReviewForBooking(bookingId);
    return doc?.data();
  }

  Future<Map<String, dynamic>?> getPetCareShopReviewForBooking(
    String bookingId,
  ) async {
    final doc = await _getPetCareShopReviewForBooking(bookingId);
    return doc?.data();
  }

  Future<void> _syncPetCareServiceRatingAggregate({
    required String shopId,
    String? serviceId,
    String? serviceName,
  }) async {
    final sid = shopId.trim();
    if (sid.isEmpty) return;
    try {
      final all = await _reviews.where('shopId', isEqualTo: sid).get();
      final filtered = all.docs.where((d) {
        final m = d.data();
        final t = (m['type'] ?? '').toString();
        if (t != 'service') return false;
        if ((serviceId ?? '').trim().isNotEmpty) {
          return (m['serviceId'] ?? '').toString().trim() == serviceId!.trim();
        }
        final n = (serviceName ?? '').trim().toLowerCase();
        if (n.isEmpty) return false;
        return (m['serviceName'] ?? '').toString().trim().toLowerCase() == n;
      }).toList();

      if (filtered.isEmpty) return;
      final avg = averageStarsFromReviewDocs(filtered);
      final count = filtered.length;

      String targetServiceId = (serviceId ?? '').trim();
      if (targetServiceId.isEmpty && (serviceName ?? '').trim().isNotEmpty) {
        final byName = await _db
            .collection('service_shops')
            .doc(sid)
            .collection('services')
            .where('name', isEqualTo: serviceName!.trim())
            .limit(1)
            .get();
        if (byName.docs.isNotEmpty) {
          targetServiceId = byName.docs.first.id;
        }
      }
      if (targetServiceId.isEmpty) return;
      await _db
          .collection('service_shops')
          .doc(sid)
          .collection('services')
          .doc(targetServiceId)
          .set({
            'ratingAvg': avg,
            'ratingCount': count,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> ratePetCareService({
    required String bookingId,
    required String shopId,
    required String serviceName,
    String? serviceId,
    required int stars,
    String? comment,
    String? customerName,
  }) async {
    if (stars < 1 || stars > 5) {
      throw Exception('Rating must be between 1 and 5 stars.');
    }
    final ok = await canRatePetCareBooking(
      bookingId: bookingId,
      shopId: shopId,
    );
    if (!ok) {
      throw Exception(
        'You can only rate your own completed/confirmed booking.',
      );
    }
    final sid = shopId.trim();
    final svcId = (serviceId ?? '').trim();
    final svcName = serviceName.trim();
    if (sid.isEmpty || svcName.isEmpty) {
      throw Exception('Invalid service rating payload.');
    }
    final suffix = svcId.isNotEmpty ? svcId : svcName.toLowerCase();
    final existingReview = await _getPetCareServiceReviewForBooking(bookingId);
    final ratingId =
        existingReview?.id ?? '${_uid}_${bookingId.trim()}_service_$suffix';
    final cn = _reviewCustomerName(customerName);
    try {
      await _reviews.doc(ratingId).set({
        'id': ratingId,
        'type': 'service',
        'shopId': sid,
        if (svcId.isNotEmpty) 'serviceId': svcId,
        'serviceName': svcName,
        'bookingId': bookingId.trim(),
        'userId': _uid,
        'stars': stars,
        'comment': comment ?? '',
        if (cn.isNotEmpty) 'customerName': cn,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await _syncPetCareServiceRatingAggregate(
        shopId: sid,
        serviceId: svcId.isEmpty ? null : svcId,
        serviceName: svcName,
      );
    } catch (_) {
      throw Exception('Unable to submit service rating.');
    }
  }

  // --- Online Store: Ratings ---

  Future<bool> canRateStore(String storeId) async {
    final completedOrders = await _orders
        .where('storeId', isEqualTo: storeId)
        .where('userId', isEqualTo: _uid)
        .where('status', whereIn: ['completed', 'delivered'])
        .limit(1)
        .get();
    return completedOrders.docs.isNotEmpty;
  }

  /// Buyer may review this order after it is completed/delivered for this store.
  Future<bool> canRateOrderForReview({
    required String storeId,
    required String orderId,
  }) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return false;
    final d = doc.data();
    if (d == null) return false;
    if ((d['userId'] ?? '').toString() != _uid) return false;
    if ((d['storeId'] ?? '').toString() != storeId) return false;
    final status = (d['status'] ?? '').toString().toLowerCase();
    return status == 'completed' || status == 'delivered';
  }

  String _reviewCustomerName(String? customerName) {
    final fromArg = (customerName ?? '').trim();
    if (fromArg.isNotEmpty) return fromArg;
    final dn = (_auth.currentUser?.displayName ?? '').trim();
    if (dn.isNotEmpty) return dn;
    return '';
  }

  Future<void> rateProduct({
    required String storeId,
    required String productId,
    required int stars,
    String? comment,
    String? orderId,
    String? customerName,
  }) async {
    if (stars < 1 || stars > 5) {
      throw Exception('Rating must be between 1 and 5 stars.');
    }
    final oid = (orderId ?? '').trim();
    if (oid.isNotEmpty) {
      final ok = await canRateOrderForReview(storeId: storeId, orderId: oid);
      if (!ok) {
        throw Exception(
          'You can only review products from completed orders at this store.',
        );
      }
    }
    try {
      final ratingId = '${_uid}_$productId';
      final cn = _reviewCustomerName(customerName);
      await _reviews.doc(ratingId).set({
        'id': ratingId,
        'type': 'product',
        'storeId': storeId,
        'productId': productId,
        'userId': _uid,
        'stars': stars,
        'comment': comment ?? '',
        if (oid.isNotEmpty) 'orderId': oid,
        if (cn.isNotEmpty) 'customerName': cn,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Recompute and persist aggregate rating on the product document so that
      // ratingAvg / ratingCount shown in store cards stay up to date.
      final allReviews = await _reviews
          .where('productId', isEqualTo: productId)
          .where('type', isEqualTo: 'product')
          .get();
      final count = allReviews.docs.length;
      final avg = count > 0
          ? allReviews.docs.fold<int>(
                0,
                (acc, d) =>
                    acc + ((d.data()['stars'] as num?)?.toInt() ?? 0),
              ) /
              count
          : 0.0;
      await _products.doc(productId).update({
        'ratingAvg': avg,
        'ratingCount': count,
      });
    } catch (_) {
      throw Exception('Unable to submit product rating.');
    }
  }

  Future<void> rateStore({
    required String storeId,
    required int stars,
    String? comment,
    String? orderId,
    String? customerName,
  }) async {
    if (stars < 1 || stars > 5) {
      throw Exception('Rating must be between 1 and 5 stars.');
    }
    final oid = (orderId ?? '').trim();
    if (oid.isNotEmpty) {
      final ok = await canRateOrderForReview(storeId: storeId, orderId: oid);
      if (!ok) {
        throw Exception(
          'You can only review the store for completed orders you placed.',
        );
      }
    } else {
      final allowed = await canRateStore(storeId);
      if (!allowed) {
        throw Exception('You can rate this store only after placing an order.');
      }
    }
    try {
      final ratingId = '${_uid}_store_$storeId';
      final cn = _reviewCustomerName(customerName);
      await _reviews.doc(ratingId).set({
        'id': ratingId,
        'type': 'store',
        'storeId': storeId,
        'userId': _uid,
        'stars': stars,
        'comment': comment ?? '',
        if (oid.isNotEmpty) 'orderId': oid,
        if (cn.isNotEmpty) 'customerName': cn,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      throw Exception('Unable to submit store rating.');
    }
  }

  /// Store-only reviews for buyers. Single-field [where] on [storeId] only;
  /// filter `type == 'store'` and sort by [createdAt] in the UI (avoids composite index).
  Stream<QuerySnapshot<Map<String, dynamic>>> streamStoreReviews(
    String storeId,
  ) {
    final id = storeId.trim();
    if (id.isEmpty) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
    return _storeReviewsByStoreId.putIfAbsent(
      id,
      () => _reviews.where('storeId', isEqualTo: id).snapshots(),
    );
  }

  /// Fresh (non-cached) stream for the reviews dialog. The cached stream in
  /// [streamStoreReviews] is single-subscription; the rating chip holds the
  /// only listener, so the dialog must open its own independent Firestore listener.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamStoreReviewsDirect(
    String storeId,
  ) {
    final id = storeId.trim();
    if (id.isEmpty) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
    return _reviews.where('storeId', isEqualTo: id).snapshots();
  }

  /// All reviews for this supplier (store + product). Filter in UI if needed.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllReviewsForStore(
    String storeId,
  ) {
    return streamStoreReviews(storeId);
  }

  /// Product reviews; filter `type == 'product'` client-side.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamProductReviews(
    String productId,
  ) {
    return _reviews.where('productId', isEqualTo: productId).snapshots();
  }

  /// Live reviews for a pet care [service_shops] document (query by [shopId]).
  Stream<QuerySnapshot<Map<String, dynamic>>> streamServiceShopReviews(
    String shopId,
  ) {
    final id = shopId.trim();
    if (id.isEmpty) {
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
    return _serviceShopReviewsByShopId.putIfAbsent(
      id,
      () => _reviews.where('shopId', isEqualTo: id).snapshots(),
    );
  }

  /// One-shot rating summary for list sorting and fallbacks.
  Future<({double avg, int count})> getServiceShopRatingSummary(
    String shopId,
  ) async {
    final id = shopId.trim();
    if (id.isEmpty) return (avg: 0.0, count: 0);

    double fallbackAvg = 0;
    var fallbackCount = 0;
    try {
      final shopDoc = await _db.collection('service_shops').doc(id).get();
      if (shopDoc.exists) {
        final data = shopDoc.data() ?? {};
        fallbackAvg = ((data['ratingAvg'] as num?)?.toDouble() ?? 0);
        fallbackCount = (data['ratingCount'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}

    try {
      final snap = await _reviews.where('shopId', isEqualTo: id).get();
      final docs = _filterServiceShopReviewDocs(snap.docs);
      if (docs.isNotEmpty) {
        return (avg: averageStarsFromReviewDocs(docs), count: docs.length);
      }
    } catch (_) {}

    return (avg: fallbackAvg, count: fallbackCount);
  }

  Future<void> _syncServiceShopRatingAggregate(String shopId) async {
    final id = shopId.trim();
    if (id.isEmpty) return;
    try {
      final snap = await _reviews.where('shopId', isEqualTo: id).get();
      final docs = _filterServiceShopReviewDocs(snap.docs);
      final avg = averageStarsFromReviewDocs(docs);
      final count = docs.length;
      await _db.collection('service_shops').doc(id).set({
        'ratingAvg': avg,
        'ratingCount': count,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Submit a rating for a pet care service shop ([service_shops] document id).
  Future<void> rateServiceShop({
    required String shopId,
    required int stars,
    String? comment,
    String? bookingId,
    String? customerName,
  }) async {
    if (stars < 1 || stars > 5) {
      throw Exception('Rating must be between 1 and 5 stars.');
    }
    final id = shopId.trim();
    if (id.isEmpty) {
      throw Exception('Invalid shop.');
    }
    final oid = (bookingId ?? '').trim();
    // One review doc per user per shop — including bookingId in the key would
    // create a new doc for every booking instead of updating the existing one.
    final ratingId = '${_uid}_shop_$id';
    final cn = _reviewCustomerName(customerName);
    try {
      await _reviews.doc(ratingId).set({
        'id': ratingId,
        'type': 'service_shop',
        'shopId': id,
        'userId': _uid,
        'stars': stars,
        'comment': comment ?? '',
        if (oid.isNotEmpty) 'bookingId': oid,
        if (cn.isNotEmpty) 'customerName': cn,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await _syncServiceShopRatingAggregate(id);
    } catch (_) {
      throw Exception('Unable to submit shop rating.');
    }
  }

  // --- Online Store: Store Owner Management ---

  Future<void> createProduct({
    required String storeId,
    required Map<String, dynamic> productData,
  }) async {
    await _assertStoreOwner(storeId);
    try {
      final docRef = _products.doc();
      await docRef.set({
        ...productData,
        'id': docRef.id,
        'storeId': storeId,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Unable to add product right now.');
    }
    await appendPetStoreAuditLog(
      storeId,
      'Product added',
      (productData['title'] ?? 'New product').toString(),
    );
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    final doc = await _products.doc(productId).get();
    if (!doc.exists) throw Exception('Product not found.');
    await _assertStoreOwner(
      (doc.data() ?? const {})['storeId']?.toString() ?? '',
    );
    try {
      await _products.doc(productId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Unable to update product.');
    }
    await appendPetStoreAuditLog(
      (doc.data() ?? const {})['storeId']?.toString() ?? '',
      'Product updated',
      (data['title'] ?? doc.data()?['title'] ?? productId).toString(),
    );
  }

  Future<void> deleteProduct(String productId) async {
    final doc = await _products.doc(productId).get();
    if (!doc.exists) throw Exception('Product not found.');
    await _assertStoreOwner(
      (doc.data() ?? const {})['storeId']?.toString() ?? '',
    );
    final title = (doc.data() ?? const {})['title']?.toString() ?? productId;
    final sid = (doc.data() ?? const {})['storeId']?.toString() ?? '';
    try {
      await _products.doc(productId).delete();
    } catch (_) {
      throw Exception('Unable to delete product.');
    }
    await appendPetStoreAuditLog(sid, 'Product deleted', title);
  }

  Future<void> updateStoreProfile(
    String storeId,
    Map<String, dynamic> data,
  ) async {
    await _assertStoreOwner(storeId);
    try {
      await _db.collection('users').doc(storeId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Unable to update store profile.');
    }
    await appendPetStoreAuditLog(
      storeId,
      'Store profile updated',
      (data['businessName'] ?? '').toString(),
    );
  }

  Future<void> updateStoreStatus({
    required String storeId,
    required bool isOpen,
  }) async {
    await _assertStoreOwner(storeId);
    try {
      await _db.collection('users').doc(storeId).update({
        'status': isOpen ? 'active' : 'inactive',
        'isActive': isOpen,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Unable to update store status.');
    }
    await appendPetStoreAuditLog(
      storeId,
      isOpen ? 'Store opened' : 'Store closed',
      isOpen
          ? 'Store status changed to open'
          : 'Store status changed to closed',
    );
  }

  Stream<List<Map<String, dynamic>>> streamProductsForStoreOwner(
    String storeId, {
    bool includeInactive = true,
  }) {
    final query = _products.where('storeId', isEqualTo: storeId);
    return query.snapshots().map((snapshot) {
      var rows = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      if (!includeInactive) {
        rows = rows.where((p) => p['isActive'] != false).toList();
      }
      DateTime? ts(Map<String, dynamic> p) {
        final v = p['updatedAt'];
        if (v is Timestamp) return v.toDate();
        return null;
      }

      rows.sort((a, b) {
        final da = ts(a);
        final db = ts(b);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });
      return rows;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamOrdersForStoreOwner(
    String storeId,
  ) {
    // `where(storeId) + orderBy(createdAt)` requires a composite index. Query by
    // store only so the stream succeeds; list order is not guaranteed by Firestore.
    return _orders.where('storeId', isEqualTo: storeId).snapshots();
  }

  Future<void> markOrderAsRated(String orderId) async {
    await _orders.doc(orderId).update({'isRated': true});
  }

  /// Returns a map of existing star ratings for an order.
  /// Key 'store' = store rating; key = productId for each product.
  /// Values are star counts (0 means not yet rated).
  Future<Map<String, int>> fetchExistingOrderRatings({
    required String orderId,
    required String storeId,
    required List<String> productIds,
  }) async {
    final result = <String, int>{};
    final futures = <Future<void>>[];

    futures.add(() async {
      final doc = await _reviews
          .doc('${_uid}_${orderId}_store_$storeId')
          .get();
      if (doc.exists) {
        result['store'] =
            ((doc.data()?['stars'] as num?)?.toInt() ?? 0);
      }
    }());

    for (final pid in productIds) {
      futures.add(() async {
        final doc = await _reviews
            .doc('${_uid}_${orderId}_$pid')
            .get();
        if (doc.exists) {
          result[pid] =
              ((doc.data()?['stars'] as num?)?.toInt() ?? 0);
        }
      }());
    }

    await Future.wait(futures);
    return result;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final orderDoc = await _orders.doc(orderId).get();
    if (!orderDoc.exists) {
      throw Exception('Order not found.');
    }
    final orderData = orderDoc.data() ?? const {};
    final storeId = (orderData['storeId'] ?? '').toString();
    await _assertStoreOwner(storeId);
    await _orders.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await appendPetStoreAuditLog(
      storeId,
      'Order updated',
      'Order $orderId set to $status',
    );
    await _notifyBuyerOrderStatus(
      orderId: orderId,
      orderData: orderData,
      status: status,
    );
  }

  Future<void> _notifyBuyerOrderStatus({
    required String orderId,
    required Map<String, dynamic> orderData,
    required String status,
  }) async {
    final buyerId = (orderData['userId'] ?? '').toString().trim();
    if (buyerId.isEmpty) {
      // ignore: avoid_print
      print('[PawVera] _notifyBuyerOrderStatus: buyerId is empty, skipping');
      return;
    }
    final storeName =
        (orderData['storeName'] ?? 'the store').toString().trim();
    final (title, description) = _orderStatusNotificationText(status, storeName);
    if (title.isEmpty) {
      // ignore: avoid_print
      print('[PawVera] _notifyBuyerOrderStatus: no text for status "$status", skipping');
      return;
    }
    // ignore: avoid_print
    print('[PawVera] Writing order notification → users/$buyerId/notifications  status=$status');
    try {
      final ref = _db
          .collection('users')
          .doc(buyerId)
          .collection('notifications')
          .doc();
      await ref.set({
        'id': ref.id,
        'userId': buyerId,
        'title': title,
        'description': description,
        'type': 'order',
        'isRead': false,
        'orderId': orderId,
        'orderStatus': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // ignore: avoid_print
      print('[PawVera] Order notification written successfully (${ref.id})');
    } catch (e) {
      // ignore: avoid_print
      print('[PawVera] Failed to write order notification: $e');
    }
  }

  static (String, String) _orderStatusNotificationText(
    String status,
    String storeName,
  ) {
    return switch (status) {
      'confirmed' => (
        'Order Confirmed',
        'Your order from $storeName has been confirmed and is being processed.',
      ),
      'preparing' => (
        'Order Being Prepared',
        'Great news! $storeName is now preparing your order.',
      ),
      'out_for_delivery' => (
        'Out for Delivery',
        'Your order from $storeName is on its way to you!',
      ),
      'delivered' => (
        'Order Delivered',
        'Your order from $storeName has been delivered. Enjoy!',
      ),
      'completed' => (
        'Order Completed',
        'Your order from $storeName is complete. You can now leave a review.',
      ),
      'cancelled' => (
        'Order Cancelled',
        'Your order from $storeName has been cancelled.',
      ),
      _ => ('', ''),
    };
  }

  CollectionReference<Map<String, dynamic>> _petStoreOffersCol(
    String storeId,
  ) => _db.collection('users').doc(storeId).collection('pet_store_offers');

  CollectionReference<Map<String, dynamic>> _petStoreAuditCol(String storeId) =>
      _db.collection('users').doc(storeId).collection('pet_store_audit_logs');

  /// Best-effort activity log for the pet-supplies provider dashboard.
  Future<void> appendPetStoreAuditLog(
    String storeId,
    String title,
    String description,
  ) async {
    if (storeId.isEmpty || storeId != _uid) return;
    try {
      await _petStoreAuditCol(storeId).add({
        'title': title,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// No server-side [orderBy]: avoids composite-index / missing-field issues;
  /// sort by `createdAt` in the UI instead.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamPetStoreOffers(
    String storeId,
  ) {
    return _petStoreOffersCol(storeId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPetStoreAuditLogs(
    String storeId,
  ) {
    return _petStoreAuditCol(storeId).snapshots();
  }

  Future<String> createPetStoreOffer({
    required String storeId,
    required Map<String, dynamic> fields,
  }) async {
    await _assertStoreOwner(storeId);
    final ref = _petStoreOffersCol(storeId).doc();
    await ref.set({
      ...fields,
      'id': ref.id,
      'isActive': fields['isActive'] ?? true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await appendPetStoreAuditLog(
      storeId,
      'Offer created',
      (fields['title'] ?? '').toString(),
    );
    return ref.id;
  }

  Future<void> updatePetStoreOffer({
    required String storeId,
    required String offerId,
    required Map<String, dynamic> patch,
  }) async {
    await _assertStoreOwner(storeId);
    await _petStoreOffersCol(storeId).doc(offerId).update({
      ...patch,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePetStoreOffer(String storeId, String offerId) async {
    await _assertStoreOwner(storeId);
    await _petStoreOffersCol(storeId).doc(offerId).delete();
    await appendPetStoreAuditLog(storeId, 'Offer removed', offerId);
  }

  Future<String> fetchCurrentUserName() async {
    final uid = _auth.currentUser?.uid ?? '';
    return (await fetchUserDisplayName(uid)) ?? '';
  }

  Future<String?> fetchUserDisplayName(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final d = await _db.collection('users').doc(uid).get();
      final m = d.data();
      if (m == null) return null;
      final s =
          (m['businessName'] ?? m['fullName'] ?? m['name'] ?? m['email'] ?? '')
              .toString()
              .trim();
      return s.isEmpty ? null : s;
    } catch (_) {
      return null;
    }
  }

  /// Public fields for store-owner order detail (buyer profile).
  Future<Map<String, String?>> fetchBuyerPublicProfile(String uid) async {
    if (uid.isEmpty) {
      return {'name': null, 'email': null, 'phone': null};
    }
    try {
      final d = await _db.collection('users').doc(uid).get();
      final m = d.data();
      if (m == null) {
        return {'name': null, 'email': null, 'phone': null};
      }
      String? pick(String k) {
        final v = (m[k] ?? '').toString().trim();
        return v.isEmpty ? null : v;
      }

      final name =
          pick('businessName') ??
          pick('fullName') ??
          pick('name') ??
          pick('email');
      return {'name': name, 'email': pick('email'), 'phone': pick('phone')};
    } catch (_) {
      return {'name': null, 'email': null, 'phone': null};
    }
  }

  Future<String> uploadStoreProfileImageBytes({
    required String storeId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    await _assertStoreOwner(storeId);
    try {
      final safeFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final ref = _storage.ref().child(
        'stores/$storeId/profile/${DateTime.now().millisecondsSinceEpoch}_$safeFileName',
      );
      await ref.putData(bytes).timeout(const Duration(seconds: 15));
      return await ref.getDownloadURL();
    } catch (_) {
      return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    }
  }

  Future<String> uploadProductImageBytes({
    required String storeId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    await _assertStoreOwner(storeId);
    try {
      final safeFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final ref = _storage.ref().child(
        'stores/$storeId/products/${DateTime.now().millisecondsSinceEpoch}_$safeFileName',
      );
      await ref.putData(bytes).timeout(const Duration(seconds: 15));
      return await ref.getDownloadURL();
    } catch (_) {
      return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    }
  }

  Future<void> _assertStoreOwner(String storeId) async {
    if (storeId.isEmpty) {
      throw Exception('Invalid store.');
    }
    // The store IS the provider's user doc; storeId == provider uid.
    if (storeId != _uid) {
      throw Exception('You do not have permission to manage this store.');
    }
    final userDoc = await _db.collection('users').doc(_uid).get();
    if (!userDoc.exists) {
      throw Exception('Store not found.');
    }
    final data = userDoc.data() ?? const <String, dynamic>{};
    final isPetSuppliesProvider =
        data['role'] == 'provider' &&
        data['providerType'] == 'Pet Supplies Store';
    if (!isPetSuppliesProvider) {
      throw Exception('You do not have permission to manage this store.');
    }
  }

  // --- Conversations & Messaging ---

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection('conversations');

  Future<String> getOrCreateConversation({
    required String ownerId,
    required String petId,
    required String petName,
    String ownerName = 'Pet Owner',
  }) async {
    final convId = '${_uid}_$petId';
    final ref = _conversations.doc(convId);
    final doc = await ref.get();
    if (!doc.exists) {
      String adopterName = 'User';
      try {
        final userDoc = await _db.collection('users').doc(_uid).get();
        adopterName = (userDoc.data() ?? {})['fullName'] as String? ?? 'User';
      } catch (_) {}
      await ref.set({
        'id': convId,
        'participants': [_uid, ownerId],
        'adopterId': _uid,
        'ownerId': ownerId,
        'petId': petId,
        'petName': petName,
        'adopterName': adopterName,
        'ownerName': ownerName,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return convId;
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final msgRef = _conversations
        .doc(conversationId)
        .collection('messages')
        .doc();
    final now = FieldValue.serverTimestamp();
    final batch = _db.batch();
    batch.set(msgRef, {
      'id': msgRef.id,
      'senderId': _uid,
      'text': text,
      'timestamp': now,
    });
    batch.update(_conversations.doc(conversationId), {
      'lastMessage': text,
      'lastMessageTime': now,
    });
    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages(
    String conversationId,
  ) {
    return _conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get myConversations {
    return _conversations
        .where('participants', arrayContains: _uid)
        .snapshots();
  }

  // --- Online Store: Admin ---

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllStoresForAdmin() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'provider')
        .where('providerType', isEqualTo: 'Pet Supplies Store')
        .snapshots();
  }

  Future<void> setStoreActivation({
    required String storeId,
    required bool active,
  }) async {
    try {
      await _db.collection('users').doc(storeId).update({
        'isActive': active,
        'status': active ? 'active' : 'inactive',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Unable to update store activation.');
    }
  }

  // Fetch pet profile without requiring auth — used by the public QR profile page.
  Future<Map<String, dynamic>?> fetchPetPublicProfile(
    String ownerUid,
    String petId,
  ) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(ownerUid)
          .collection('pets')
          .doc(petId)
          .get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  // --- Adoption Posts ---

  CollectionReference<Map<String, dynamic>> get _adoptionPosts =>
      _db.collection('adoption_posts');

  Stream<QuerySnapshot<Map<String, dynamic>>> get streamAdoptionPosts =>
      _adoptionPosts.orderBy('createdAt', descending: true).snapshots();

  Future<String> postAdoptionPet({
    required String name,
    required String desc,
    required String location,
    required String price,
    required String age,
    required String gender,
    required String category,
    required bool isVaccinated,
    required bool isNeutered,
    required Uint8List imageBytes,
  }) async {
    String ownerName = 'Pet Owner';
    try {
      final userDoc = await _db.collection('users').doc(_uid).get();
      ownerName = (userDoc.data() ?? {})['fullName'] as String? ?? 'Pet Owner';
    } catch (_) {}

    final ref = _adoptionPosts.doc();
    final imageBase64 = base64Encode(imageBytes);

    await ref.set({
      'id': ref.id,
      'ownerId': _uid,
      'ownerName': ownerName,
      'name': name,
      'desc': desc,
      'location': location,
      'price': price,
      'age': age,
      'gender': gender,
      'category': category,
      'isVaccinated': isVaccinated,
      'isNeutered': isNeutered,
      'imageBase64': imageBase64,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateAdoptionPost({
    required String postId,
    required String name,
    required String desc,
    required String location,
    required String price,
    required String age,
    required String gender,
    required String category,
    required bool isVaccinated,
    required bool isNeutered,
    Uint8List? newImageBytes,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'desc': desc,
      'location': location,
      'price': price,
      'age': age,
      'gender': gender,
      'category': category,
      'isVaccinated': isVaccinated,
      'isNeutered': isNeutered,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (newImageBytes != null) {
      data['imageBase64'] = base64Encode(newImageBytes);
    }
    await _adoptionPosts.doc(postId).update(data);
  }

  Future<void> deleteAdoptionPost(String postId) async {
    await _adoptionPosts.doc(postId).update({'isActive': false});
  }

  Future<void> deleteConversation(String conversationId) async {
    final messages = await _conversations
        .doc(conversationId)
        .collection('messages')
        .get();
    final batch = _db.batch();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_conversations.doc(conversationId));
    await batch.commit();
  }
}
