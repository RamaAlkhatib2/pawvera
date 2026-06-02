import 'package:flutter_test/flutter_test.dart';
import 'package:pawvera/services/database_service.dart';

void main() {
  group('reviewDocIsServiceShop', () {
    test('UT-01 returns true for valid service_shop review', () {
      expect(
        DatabaseService.reviewDocIsServiceShop({
          'type': 'service_shop',
          'shopId': 'shop_abc',
        }),
        isTrue,
      );
    });

    test('UT-02 returns false for pet-supplies store review', () {
      expect(
        DatabaseService.reviewDocIsServiceShop({
          'type': 'store',
          'shopId': 'shop_abc',
        }),
        isFalse,
      );
    });

    test('UT-03 returns false for product review', () {
      expect(
        DatabaseService.reviewDocIsServiceShop({
          'type': 'product',
          'shopId': 'shop_abc',
        }),
        isFalse,
      );
    });

    test('UT-04 returns true for legacy shop type', () {
      expect(
        DatabaseService.reviewDocIsServiceShop({
          'type': 'shop',
          'shopId': 'shop_abc',
        }),
        isTrue,
      );
    });

    test('UT-05 returns false when shopId is empty (inferred type)', () {
      expect(
        DatabaseService.reviewDocIsServiceShop({
          'shopId': '',
        }),
        isFalse,
      );
    });

    test('UT-06 returns false when storeId is present (inferred type)', () {
      expect(
        DatabaseService.reviewDocIsServiceShop({
          'shopId': 'shop_abc',
          'storeId': 'store_xyz',
        }),
        isFalse,
      );
    });
  });
}
