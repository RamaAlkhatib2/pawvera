import 'package:flutter_test/flutter_test.dart';
import 'package:pawvera/models/service_provider_models.dart';

/// Mirrors production rating average logic for unit tests (UT-11, UT-12).
double averageStarsFromReviewMaps(List<Map<String, dynamic>> maps) {
  if (maps.isEmpty) return 0;
  var sum = 0.0;
  for (final m in maps) {
    final raw = m['stars'] ?? m['rating'] ?? m['star'];
    sum += ((raw as num?)?.toDouble() ?? 0).clamp(0, 5);
  }
  return sum / maps.length;
}

void main() {
  group('ShopProfile.fromMap', () {
    test('UT-07 parses complete shop profile', () {
      final profile = ShopProfile.fromMap({
        'ownerId': 'uid1',
        'shopName': 'LaLa Clinic',
        'address': '123 Main St',
        'phone': '0790000000',
        'email': 'lala@test.com',
        'workingHours': '9-5',
        'status': 'Open',
        'isOpen': true,
        'petTypes': ['Dogs', 'Cats'],
        'totalBookings': 10,
      }, 'doc123');

      expect(profile.id, 'doc123');
      expect(profile.shopName, 'LaLa Clinic');
      expect(profile.ownerId, 'uid1');
      expect(profile.isOpen, isTrue);
      expect(profile.petTypes, ['Dogs', 'Cats']);
      expect(profile.totalBookings, 10);
    });

    test('UT-08 uses Closed default when status missing', () {
      final profile = ShopProfile.fromMap({
        'shopName': 'Test Shop',
      }, 'id1');

      expect(profile.status, 'Closed');
      expect(profile.isOpen, isFalse);
    });
  });

  group('ServiceItem.fromMap', () {
    test('UT-09 parses price and active flag', () {
      final item = ServiceItem.fromMap({
        'shopId': 'shop1',
        'name': 'Grooming',
        'description': 'Full groom',
        'price': 25.5,
        'duration': '1 hour',
        'isActive': true,
      }, 'svc1');

      expect(item.id, 'svc1');
      expect(item.name, 'Grooming');
      expect(item.price, 25.5);
      expect(item.isActive, isTrue);
    });

    test('UT-10 defaults price to 0 when null', () {
      final item = ServiceItem.fromMap({
        'shopId': 'shop1',
        'name': 'Checkup',
      }, 'svc2');

      expect(item.price, 0.0);
    });
  });

  group('averageStarsFromReviewMaps', () {
    test('UT-11 returns 0 for empty list', () {
      expect(averageStarsFromReviewMaps([]), 0.0);
    });

    test('UT-12 computes average of star values', () {
      expect(
        averageStarsFromReviewMaps([
          {'stars': 5},
          {'stars': 3},
          {'stars': 4},
        ]),
        4.0,
      );
    });
  });
}
