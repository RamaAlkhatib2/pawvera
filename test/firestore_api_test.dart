import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawvera/services/database_service.dart';

/// Firestore API tests using [FakeFirebaseFirestore] (no live Firebase).
void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  group('Firestore Reviews API', () {
    test('AT-01 write and read a service_shop review document', () async {
      await firestore.collection('reviews').doc('review_1').set({
        'type': 'service_shop',
        'shopId': 'shop_lala',
        'userId': 'user_1',
        'stars': 5,
        'comment': 'Excellent clinic',
      });

      final snap = await firestore.collection('reviews').doc('review_1').get();

      expect(snap.exists, isTrue);
      expect(snap.data()!['shopId'], 'shop_lala');
      expect(snap.data()!['stars'], 5);
      expect(
        DatabaseService.reviewDocIsServiceShop(snap.data()!),
        isTrue,
      );
    });

    test('AT-02 query reviews by shopId (Firestore where API)', () async {
      await firestore.collection('reviews').doc('r_a').set({
        'type': 'service_shop',
        'shopId': 'shop_lala',
        'stars': 4,
      });
      await firestore.collection('reviews').doc('r_b').set({
        'type': 'service_shop',
        'shopId': 'shop_lala',
        'stars': 5,
      });
      await firestore.collection('reviews').doc('r_c').set({
        'type': 'store',
        'storeId': 'store_x',
        'shopId': 'shop_lala',
        'stars': 3,
      });

      final snap = await firestore
          .collection('reviews')
          .where('shopId', isEqualTo: 'shop_lala')
          .get();

      expect(snap.docs.length, 3);

      final shopReviews = snap.docs
          .where((d) => DatabaseService.reviewDocIsServiceShop(d.data()))
          .toList();
      expect(shopReviews.length, 2);
    });
  });

  group('Firestore Pet Care Shop API', () {
    test('AT-03 write and read service_shops profile document', () async {
      await firestore.collection('service_shops').doc('shop_lala').set({
        'shopName': 'LaLa',
        'address': '123 Main St',
        'ratingAvg': 4.0,
        'ratingCount': 3,
        'isActive': true,
      });

      final snap =
          await firestore.collection('service_shops').doc('shop_lala').get();

      expect(snap.exists, isTrue);
      expect(snap.data()!['shopName'], 'LaLa');
      expect(snap.data()!['ratingAvg'], 4.0);
    });

    test('AT-04 read nested services subcollection API', () async {
      await firestore
          .collection('service_shops')
          .doc('shop_lala')
          .collection('services')
          .doc('svc_groom')
          .set({
        'name': 'Grooming',
        'price': 25.0,
        'isActive': true,
        'ratingAvg': 0.0,
        'ratingCount': 0,
      });

      final snap = await firestore
          .collection('service_shops')
          .doc('shop_lala')
          .collection('services')
          .where('isActive', isEqualTo: true)
          .get();

      expect(snap.docs.length, 1);
      expect(snap.docs.first.data()['name'], 'Grooming');
    });
  });

  group('Firestore Store & Orders API', () {
    test('AT-05 write product and query by storeId API', () async {
      await firestore.collection('products').doc('prod_1').set({
        'storeId': 'store_abc',
        'title': 'Dog Food',
        'price': 15.99,
        'isActive': true,
      });
      await firestore.collection('products').doc('prod_2').set({
        'storeId': 'store_other',
        'title': 'Cat Food',
        'price': 12.0,
        'isActive': true,
      });

      final snap = await firestore
          .collection('products')
          .where('storeId', isEqualTo: 'store_abc')
          .get();

      expect(snap.docs.length, 1);
      expect(snap.docs.first.data()['title'], 'Dog Food');
    });

    test('AT-06 create order and update status API', () async {
      await firestore.collection('orders').doc('ord_1').set({
        'storeId': 'store_abc',
        'userId': 'user_1',
        'status': 'pending',
        'total': 50.0,
      });

      await firestore.collection('orders').doc('ord_1').update({
        'status': 'delivered',
      });

      final snap = await firestore.collection('orders').doc('ord_1').get();
      expect(snap.data()!['status'], 'delivered');
    });

    test('AT-07 snapshot stream emits after write API', () async {
      await firestore.collection('service_shops').doc('shop_stream').set({
        'shopName': 'Stream Shop',
      });

      final snap = await firestore
          .collection('service_shops')
          .doc('shop_stream')
          .snapshots()
          .firstWhere((s) => s.data()?['shopName'] == 'Stream Shop');

      expect(snap.data()?['shopName'], 'Stream Shop');
    });
  });
}
