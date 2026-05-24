/// Firestore data models for the Service Provider (Pet Care Shop) system.
///
/// Collections in Firestore:
///   - service_shops/{shopId} — Shop profile
///   - service_shops/{shopId}/services/{serviceId} — Services
///   - service_shops/{shopId}/offers/{offerId} — Promotions
///   - service_shops/{shopId}/bookings/{bookingId} — Bookings (part of the shop)
///   - service_shops/{shopId}/audit_logs/{logId} — Activity logs
///
/// The shop owner is identified by `shop.ownerId == auth.currentUser.uid`.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore field helpers
class Fs {
  static final now = FieldValue.serverTimestamp();
  static const updatedAt = 'updatedAt';
  static const createdAt = 'createdAt';
}

// ──────────────────────────────────────────────
// Shop Profile
// ──────────────────────────────────────────────

class ShopProfile {
  final String id;
  final String ownerId;
  final String shopName;
  final String address;
  final String phone;
  final String email;
  final String workingHours;
  final String status; // 'Open' | 'Busy' | 'Closed'
  final bool isOpen; // derived bool for easy query
  final String? imageUrl;
  final List<String> petTypes;
  final int totalBookings;
  final int activeBookings;
  final double totalRevenue;
  final int activeServicesCount;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const ShopProfile({
    required this.id,
    required this.ownerId,
    required this.shopName,
    required this.address,
    required this.phone,
    required this.email,
    required this.workingHours,
    required this.status,
    required this.isOpen,
    this.imageUrl,
    this.petTypes = const [],
    this.totalBookings = 0,
    this.activeBookings = 0,
    this.totalRevenue = 0.0,
    this.activeServicesCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'shopName': shopName,
    'address': address,
    'phone': phone,
    'email': email,
    'workingHours': workingHours,
    'status': status,
    'isOpen': isOpen,
    'imageUrl': imageUrl,
    'petTypes': petTypes,
    'totalBookings': totalBookings,
    'activeBookings': activeBookings,
    'totalRevenue': totalRevenue,
    'activeServicesCount': activeServicesCount,
    Fs.createdAt: createdAt,
    Fs.updatedAt: updatedAt,
  };

  factory ShopProfile.fromMap(Map<String, dynamic> map, String docId) {
    return ShopProfile(
      id: docId,
      ownerId: (map['ownerId'] ?? '').toString(),
      shopName: (map['shopName'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      workingHours: (map['workingHours'] ?? '').toString(),
      status: (map['status'] ?? 'Closed').toString(),
      isOpen: map['isOpen'] ?? false,
      imageUrl: map['imageUrl']?.toString(),
      petTypes: (map['petTypes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      totalBookings: (map['totalBookings'] as num?)?.toInt() ?? 0,
      activeBookings: (map['activeBookings'] as num?)?.toInt() ?? 0,
      totalRevenue: (map['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      activeServicesCount: (map['activeServicesCount'] as num?)?.toInt() ?? 0,
      createdAt: map[Fs.createdAt] as Timestamp?,
      updatedAt: map[Fs.updatedAt] as Timestamp?,
    );
  }

  ShopProfile copyWith({
    String? shopName,
    String? address,
    String? phone,
    String? email,
    String? workingHours,
    String? status,
    bool? isOpen,
    String? imageUrl,
    int? totalBookings,
    int? activeBookings,
    double? totalRevenue,
    int? activeServicesCount,
  }) => ShopProfile(
    id: id,
    ownerId: ownerId,
    shopName: shopName ?? this.shopName,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    workingHours: workingHours ?? this.workingHours,
    status: status ?? this.status,
    isOpen: isOpen ?? this.isOpen,
    imageUrl: imageUrl ?? this.imageUrl,
    totalBookings: totalBookings ?? this.totalBookings,
    activeBookings: activeBookings ?? this.activeBookings,
    totalRevenue: totalRevenue ?? this.totalRevenue,
    activeServicesCount: activeServicesCount ?? this.activeServicesCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

// ──────────────────────────────────────────────
// Service
// ──────────────────────────────────────────────

class ServiceItem {
  final String id;
  final String shopId;
  final String name;
  final String description;
  final double price;
  final String duration;
  final bool isActive;
  final List<String> petTypes; // empty = available for all pets
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const ServiceItem({
    required this.id,
    required this.shopId,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    this.isActive = true,
    this.petTypes = const [],
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'shopId': shopId,
    'name': name,
    'description': description,
    'price': price,
    'duration': duration,
    'isActive': isActive,
    'petTypes': petTypes,
    Fs.createdAt: createdAt,
    Fs.updatedAt: updatedAt,
  };

  factory ServiceItem.fromMap(Map<String, dynamic> map, String docId) {
    return ServiceItem(
      id: docId,
      shopId: (map['shopId'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      duration: (map['duration'] ?? '').toString(),
      isActive: map['isActive'] ?? true,
      petTypes: (map['petTypes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt: map[Fs.createdAt] as Timestamp?,
      updatedAt: map[Fs.updatedAt] as Timestamp?,
    );
  }

  ServiceItem copyWith({
    String? name,
    String? description,
    double? price,
    String? duration,
    bool? isActive,
  }) => ServiceItem(
    id: id,
    shopId: shopId,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    duration: duration ?? this.duration,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

// ──────────────────────────────────────────────
// Offer / Promotion
// ──────────────────────────────────────────────

class ShopOffer {
  final String id;
  final String shopId;
  final String? serviceId; // null = shop-wide offer
  final String? serviceName;
  final int discountPercent;
  final String expiryDate;
  final bool isActive;
  final bool isShopWide;
  final double? minPrice;
  final double? maxPrice;
  final double? minBookingAmount;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const ShopOffer({
    required this.id,
    required this.shopId,
    this.serviceId,
    this.serviceName,
    required this.discountPercent,
    required this.expiryDate,
    this.isActive = true,
    this.isShopWide = true,
    this.minPrice,
    this.maxPrice,
    this.minBookingAmount,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'shopId': shopId,
    'serviceId': serviceId,
    'serviceName': serviceName,
    'discountPercent': discountPercent,
    'expiryDate': expiryDate,
    'isActive': isActive,
    'isShopWide': isShopWide,
    'minPrice': minPrice,
    'maxPrice': maxPrice,
    'minBookingAmount': minBookingAmount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory ShopOffer.fromMap(Map<String, dynamic> map, String docId) {
    return ShopOffer(
      id: docId,
      shopId: (map['shopId'] ?? '').toString(),
      serviceId: map['serviceId']?.toString(),
      serviceName: map['serviceName']?.toString(),
      discountPercent: (map['discountPercent'] as num?)?.toInt() ?? 0,
      expiryDate: (map['expiryDate'] ?? '').toString(),
      isActive: map['isActive'] ?? true,
      isShopWide: map['isShopWide'] ?? true,
      minPrice: (map['minPrice'] as num?)?.toDouble(),
      maxPrice: (map['maxPrice'] as num?)?.toDouble(),
      minBookingAmount: (map['minBookingAmount'] as num?)?.toDouble(),
      createdAt: map[Fs.createdAt] as Timestamp?,
      updatedAt: map[Fs.updatedAt] as Timestamp?,
    );
  }
}

// ──────────────────────────────────────────────
// Service Booking (stored as subcollection under each shop)
// ──────────────────────────────────────────────

class ServiceBooking {
  final String id;
  final String shopId;
  final String shopName;
  final String userId;
  final String userName;
  final String userPhone;
  final String petName;
  final String petBreed;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final String date; // "Jan 05, 2026"
  final String time; // "10:00 AM"
  final String status; // pending | confirmed | completed | cancelled
  final String? notes;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const ServiceBooking({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.petName,
    required this.petBreed,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.date,
    required this.time,
    this.status = 'pending',
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'shopId': shopId,
    'shopName': shopName,
    'userId': userId,
    'userName': userName,
    'userPhone': userPhone,
    'petName': petName,
    'petBreed': petBreed,
    'serviceId': serviceId,
    'serviceName': serviceName,
    'servicePrice': servicePrice,
    'date': date,
    'time': time,
    'status': status,
    'notes': notes,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory ServiceBooking.fromMap(Map<String, dynamic> map, String docId) {
    return ServiceBooking(
      id: docId,
      shopId: (map['shopId'] ?? '').toString(),
      shopName: (map['shopName'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      userName: (map['userName'] ?? '').toString(),
      userPhone: (map['userPhone'] ?? '').toString(),
      petName: (map['petName'] ?? '').toString(),
      petBreed: (map['petBreed'] ?? '').toString(),
      serviceId: (map['serviceId'] ?? '').toString(),
      serviceName: (map['serviceName'] ?? '').toString(),
      servicePrice: (map['servicePrice'] as num?)?.toDouble() ?? 0.0,
      date: (map['date'] ?? '').toString(),
      time: (map['time'] ?? '').toString(),
      status: (map['status'] ?? 'pending').toString(),
      notes: map['notes']?.toString(),
      createdAt: map[Fs.createdAt] as Timestamp?,
      updatedAt: map[Fs.updatedAt] as Timestamp?,
    );
  }
}

// ──────────────────────────────────────────────
// Audit Log
// ──────────────────────────────────────────────

class AuditLog {
  final String id;
  final String shopId;
  final String action;
  final String details;
  final String displayDate;
  final Timestamp? createdAt;

  const AuditLog({
    required this.id,
    required this.shopId,
    required this.action,
    required this.details,
    required this.displayDate,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'shopId': shopId,
    'action': action,
    'details': details,
    'displayDate': displayDate,
    Fs.createdAt: createdAt,
  };

  factory AuditLog.fromMap(Map<String, dynamic> map, String docId) {
    return AuditLog(
      id: docId,
      shopId: (map['shopId'] ?? '').toString(),
      action: (map['action'] ?? '').toString(),
      details: (map['details'] ?? '').toString(),
      displayDate: (map['displayDate'] ?? '').toString(),
      createdAt: map[Fs.createdAt] as Timestamp?,
    );
  }
}
