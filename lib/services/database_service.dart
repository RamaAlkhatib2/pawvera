import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

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

  CollectionReference<Map<String, dynamic>> get _stores =>
      _db.collection('stores');
  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');
  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');
  CollectionReference<Map<String, dynamic>> get _usersCart =>
      _db.collection('users_cart');
  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection('reviews');

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
    await _db.collection('bookings').add({
      ...bookingData,
      'userId': _auth.currentUser!.uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get my bookings
  Stream<QuerySnapshot> get myBookings {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .snapshots();
  }

  // --- Reminders ---

  // Add reminder
  Future<void> addReminder(Map<String, dynamic> reminderData) async {
    String uid = _auth.currentUser!.uid;
    await _db.collection('users').doc(uid).collection('reminders').add({
      ...reminderData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get reminders
  Stream<QuerySnapshot> get reminders {
    String uid = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .orderBy('dateTime', descending: false)
        .snapshots();
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
    await _db.collection('bookings').doc(bookingId).update(data);
  }

  // Delete a booking
  Future<void> deleteBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).delete();
  }

  // --- Online Store: Data Initialization ---

  Future<void> ensureStoreCollectionsInitialized() async {
    try {
      final storesSnapshot = await _stores.limit(1).get();
      if (storesSnapshot.docs.isNotEmpty) return;

      final now = FieldValue.serverTimestamp();
      final batch = _db.batch();

      final defaultStores = <Map<String, dynamic>>[
        {
          'name': 'Pet Supplies Plus',
          'description': 'Complete pet supply store with premium brands',
          'ownerId': _uid,
          'location': 'Al-Jabal Street',
          'contactInfo': '+962790000000',
          'status': 'active',
          'isActive': true,
          'ratingAvg': 0.0,
          'ratingCount': 0,
          'createdAt': now,
          'updatedAt': now,
        },
        {
          'name': 'Comfort Paws Store',
          'description': 'Premium pet furniture and bedding',
          'ownerId': _uid,
          'location': 'King Fahd Avenue',
          'contactInfo': '+962791111111',
          'status': 'active',
          'isActive': true,
          'ratingAvg': 0.0,
          'ratingCount': 0,
          'createdAt': now,
          'updatedAt': now,
        },
      ];

      for (final store in defaultStores) {
        final storeRef = _stores.doc();
        batch.set(storeRef, {...store, 'id': storeRef.id});
      }

      await batch.commit();
    } catch (_) {
      rethrow;
    }
  }

  // --- Online Store: Browsing & Discovery ---

  Stream<List<Map<String, dynamic>>> streamStores({
    String? searchQuery,
    String? category,
    bool offersOnly = false,
    bool onlyActive = true,
  }) {
    Query<Map<String, dynamic>> query = _stores;
    if (onlyActive) {
      query = query.where('isActive', isEqualTo: true);
    }
    query = query.orderBy('name');

    return query.snapshots().map((snapshot) {
      final normalizedQuery = (searchQuery ?? '').trim().toLowerCase();
      final normalizedCategory = (category ?? 'all').trim().toLowerCase();

      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        final name = (data['name'] ?? '').toString().toLowerCase();
        final description =
            (data['description'] ?? '').toString().toLowerCase();
        final tags = (data['tags'] as List?)?.cast<String>() ?? <String>[];
        final hasOffers = (data['offer'] ?? '').toString().trim().isNotEmpty;

        final matchesSearch = normalizedQuery.isEmpty ||
            name.contains(normalizedQuery) ||
            description.contains(normalizedQuery);
        final matchesCategory = normalizedCategory == 'all' ||
            tags.map((e) => e.toLowerCase()).contains(normalizedCategory);
        final matchesOffer = !offersOnly || hasOffers;

        return matchesSearch && matchesCategory && matchesOffer;
      }).map((doc) => {'id': doc.id, ...doc.data()}).toList();

      return filteredDocs;
    });
  }

  Stream<List<Map<String, dynamic>>> streamStoreProducts(
    String storeId, {
    String searchQuery = '',
    String category = 'All',
    bool onSaleOnly = false,
  }) {
    Query<Map<String, dynamic>> query = _products
        .where('storeId', isEqualTo: storeId)
        .where('isActive', isEqualTo: true);

    return query.snapshots().map((snapshot) {
      final normalizedQuery = searchQuery.trim().toLowerCase();
      final normalizedCategory = category.trim().toLowerCase();

      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        final title = (data['title'] ?? '').toString().toLowerCase();
        final desc = (data['description'] ?? '').toString().toLowerCase();
        final productCategory =
            (data['category'] ?? '').toString().toLowerCase();
        final hasOffer = (data['offer'] ?? '').toString().trim().isNotEmpty;

        final matchesSearch = normalizedQuery.isEmpty ||
            title.contains(normalizedQuery) ||
            desc.contains(normalizedQuery);
        final matchesCategory =
            normalizedCategory == 'all' || productCategory == normalizedCategory;
        final matchesSale = !onSaleOnly || hasOffer;
        return matchesSearch && matchesCategory && matchesSale;
      }).map((doc) => {'id': doc.id, ...doc.data()}).toList();

      return filteredDocs;
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamProductById(
    String productId,
  ) {
    return _products.doc(productId).snapshots();
  }

  // --- Online Store: Cart & Wishlist ---

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyCart() {
    return _usersCart
        .doc(_uid)
        .collection('cart_items')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  Future<void> addOrUpdateCartItem({
    required String storeId,
    required String productId,
    required int quantity,
    required Map<String, dynamic> productSnapshot,
  }) async {
    try {
      final itemRef =
          _usersCart.doc(_uid).collection('cart_items').doc(productId);
      final now = FieldValue.serverTimestamp();
      await itemRef.set({
        'id': productId,
        'storeId': storeId,
        'productId': productId,
        'userId': _uid,
        'title': productSnapshot['title'],
        'price': productSnapshot['price'],
        'image': productSnapshot['image'],
        'quantity': quantity,
        'updatedAt': now,
        'createdAt': now,
      }, SetOptions(merge: true));
    } catch (_) {
      throw Exception('Unable to update cart item. Please try again.');
    }
  }

  Future<void> removeCartItem(String productId) async {
    try {
      await _usersCart.doc(_uid).collection('cart_items').doc(productId).delete();
    } catch (_) {
      throw Exception('Unable to remove cart item right now.');
    }
  }

  Future<void> clearMyCart() async {
    try {
      final cartSnapshot =
          await _usersCart.doc(_uid).collection('cart_items').get();
      final batch = _db.batch();
      for (final doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {
      throw Exception('Unable to clear your cart at the moment.');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyWishlist() {
    return _usersCart
        .doc(_uid)
        .collection('wishlist_items')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  Future<void> toggleWishlistItem({
    required String storeId,
    required String productId,
    required Map<String, dynamic> productSnapshot,
  }) async {
    try {
      final ref =
          _usersCart.doc(_uid).collection('wishlist_items').doc(productId);
      final existing = await ref.get();
      if (existing.exists) {
        await ref.delete();
      } else {
        await ref.set({
          'id': productId,
          'storeId': storeId,
          'productId': productId,
          'userId': _uid,
          'title': productSnapshot['title'],
          'price': productSnapshot['price'],
          'image': productSnapshot['image'],
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

  // --- Online Store: Ordering & Checkout ---

  Future<String> setOrder({
    required String storeId,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
    required String paymentMethod, // cash | credit
  }) async {
    if (items.isEmpty) {
      throw Exception('Your cart is empty.');
    }
    if (paymentMethod != 'cash' && paymentMethod != 'credit') {
      throw Exception('Unsupported payment method.');
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
      final total = subtotal + deliveryFee;
      final orderRef = _orders.doc();

      await orderRef.set({
        'id': orderRef.id,
        'storeId': storeId,
        'userId': _uid,
        'items': items,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentMethod == 'credit' ? 'paid' : 'pending',
        'status': 'pending',
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await clearMyCart();
      return orderRef.id;
    } catch (_) {
      throw Exception('Could not place order. Please try again.');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyOrders() {
    return _orders
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
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

  Future<void> rateProduct({
    required String storeId,
    required String productId,
    required int stars,
    String? comment,
  }) async {
    if (stars < 1 || stars > 5) {
      throw Exception('Rating must be between 1 and 5 stars.');
    }
    try {
      final ratingId = '${_uid}_$productId';
      await _reviews.doc(ratingId).set({
        'id': ratingId,
        'type': 'product',
        'storeId': storeId,
        'productId': productId,
        'userId': _uid,
        'stars': stars,
        'comment': comment ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      throw Exception('Unable to submit product rating.');
    }
  }

  Future<void> rateStore({
    required String storeId,
    required int stars,
    String? comment,
  }) async {
    if (stars < 1 || stars > 5) {
      throw Exception('Rating must be between 1 and 5 stars.');
    }
    final allowed = await canRateStore(storeId);
    if (!allowed) {
      throw Exception('You can rate this store only after placing an order.');
    }
    try {
      final ratingId = '${_uid}_store_$storeId';
      await _reviews.doc(ratingId).set({
        'id': ratingId,
        'type': 'store',
        'storeId': storeId,
        'userId': _uid,
        'stars': stars,
        'comment': comment ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      throw Exception('Unable to submit store rating.');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamStoreReviews(String storeId) {
    return _reviews
        .where('storeId', isEqualTo: storeId)
        .where('type', isEqualTo: 'store')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamProductReviews(
    String productId,
  ) {
    return _reviews
        .where('productId', isEqualTo: productId)
        .where('type', isEqualTo: 'product')
        .orderBy('createdAt', descending: true)
        .snapshots();
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
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    final doc = await _products.doc(productId).get();
    if (!doc.exists) throw Exception('Product not found.');
    await _assertStoreOwner((doc.data() ?? const {})['storeId']?.toString() ?? '');
    try {
      await _products.doc(productId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Unable to update product.');
    }
  }

  Future<void> deleteProduct(String productId) async {
    final doc = await _products.doc(productId).get();
    if (!doc.exists) throw Exception('Product not found.');
    await _assertStoreOwner((doc.data() ?? const {})['storeId']?.toString() ?? '');
    try {
      await _products.doc(productId).delete();
    } catch (_) {
      throw Exception('Unable to delete product.');
    }
  }

  Future<void> updateStoreProfile(
    String storeId,
    Map<String, dynamic> data,
  ) async {
    await _assertStoreOwner(storeId);
    try {
      await _stores.doc(storeId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Unable to update store profile.');
    }
  }

  Future<void> updateStoreStatus({
    required String storeId,
    required bool isOpen,
  }) async {
    await _assertStoreOwner(storeId);
    try {
      await _stores.doc(storeId).update({
        'status': isOpen ? 'active' : 'inactive',
        'isActive': isOpen,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Unable to update store status.');
    }
  }

  Stream<List<Map<String, dynamic>>> streamProductsForStoreOwner(
    String storeId, {
    bool includeInactive = true,
  }) {
    Query<Map<String, dynamic>> query = _products.where(
      'storeId',
      isEqualTo: storeId,
    );
    if (!includeInactive) {
      query = query.where('isActive', isEqualTo: true);
    }
    query = query.orderBy('updatedAt', descending: true);
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList(),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamOrdersForStoreOwner(
    String storeId,
  ) {
    return _orders
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true)
        .snapshots();
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
  }

  Future<String> uploadProductImageBytes({
    required String storeId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    await _assertStoreOwner(storeId);
    final safeFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final ref = _storage.ref().child(
      'stores/$storeId/products/${DateTime.now().millisecondsSinceEpoch}_$safeFileName',
    );
    await ref.putData(bytes);
    return ref.getDownloadURL();
  }

  Future<void> _assertStoreOwner(String storeId) async {
    if (storeId.isEmpty) {
      throw Exception('Invalid store.');
    }
    final storeDoc = await _stores.doc(storeId).get();
    if (!storeDoc.exists) {
      throw Exception('Store not found.');
    }
    final ownerId = (storeDoc.data() ?? const {})['ownerId']?.toString();
    if (ownerId != _uid) {
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
        adopterName =
            (userDoc.data() ?? {})['fullName'] as String? ?? 'User';
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
    final msgRef =
        _conversations.doc(conversationId).collection('messages').doc();
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
      String conversationId) {
    return _conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> get myConversations {
    return _conversations
        .where('participants', arrayContains: _uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // --- Online Store: Admin ---

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllStoresForAdmin() {
    return _stores.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> setStoreActivation({
    required String storeId,
    required bool active,
  }) async {
    try {
      await _stores.doc(storeId).update({
        'isActive': active,
        'status': active ? 'active' : 'inactive',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Unable to update store activation.');
    }
  }
}
