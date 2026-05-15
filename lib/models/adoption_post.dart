import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of an adoption post.
enum AdoptionStatus {
  pending,
  approved,
  rejected;

  String get value => name;

  static AdoptionStatus fromString(String? status) {
    switch (status) {
      case 'approved':
        return AdoptionStatus.approved;
      case 'rejected':
        return AdoptionStatus.rejected;
      default:
        return AdoptionStatus.pending;
    }
  }
}

/// Represents a pet adoption post stored in Firestore.
///
/// Collection: `adoption_posts/{postId}`
class PetAdoptionPost {
  final String id;
  final String ownerId;
  final String petName;
  final String petType;
  final String gender;
  final dynamic ageValue;
  final String ageUnit;
  final String location;
  final String description;
  final bool isVaccinated;
  final bool isNeutered;
  final List<String> imageUrls;
  final AdoptionStatus status;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const PetAdoptionPost({
    required this.id,
    required this.ownerId,
    required this.petName,
    required this.petType,
    required this.gender,
    required this.ageValue,
    required this.ageUnit,
    required this.location,
    required this.description,
    required this.isVaccinated,
    required this.isNeutered,
    required this.imageUrls,
    this.status = AdoptionStatus.pending,
    this.createdAt,
    this.updatedAt,
  });

  /// Convenience getters for health status.
  String get healthStatus {
    if (isVaccinated && isNeutered) return 'Vaccinated, Neutered';
    if (isVaccinated) return 'Vaccinated';
    if (isNeutered) return 'Neutered';
    return '';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'petName': petName,
    'petType': petType,
    'gender': gender,
    'ageValue': ageValue,
    'ageUnit': ageUnit,
    'location': location,
    'description': description,
    'isVaccinated': isVaccinated,
    'isNeutered': isNeutered,
    'imageUrls': imageUrls,
    'status': status.value,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
  };

  /// Creates a map suitable for Firestore creation (no id, status forced pending).
  Map<String, dynamic> toCreateJson() => {
    'ownerId': ownerId,
    'petName': petName,
    'petType': petType,
    'gender': gender,
    'ageValue': ageValue,
    'ageUnit': ageUnit,
    'location': location,
    'description': description,
    'isVaccinated': isVaccinated,
    'isNeutered': isNeutered,
    'imageUrls': imageUrls,
    'status': 'pending', // Always forced to pending
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory PetAdoptionPost.fromJson(Map<String, dynamic> map, String docId) {
    return PetAdoptionPost(
      id: docId,
      ownerId: (map['ownerId'] ?? '').toString(),
      petName: (map['petName'] ?? '').toString(),
      petType: (map['petType'] ?? '').toString(),
      gender: (map['gender'] ?? '').toString(),
      ageValue: map['ageValue'],
      ageUnit: (map['ageUnit'] ?? 'years').toString(),
      location: (map['location'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      isVaccinated: map['isVaccinated'] ?? false,
      isNeutered: map['isNeutered'] ?? false,
      imageUrls: _parseImageUrls(map['imageUrls']),
      status: AdoptionStatus.fromString(map['status']?.toString()),
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  /// Age display string e.g., "2 years", "3 months"
  String get ageDisplay {
    final numValue = (ageValue is num)
        ? ageValue as num
        : num.tryParse(ageValue?.toString() ?? '') ?? 0;
    return '$numValue $ageUnit';
  }

  PetAdoptionPost copyWith({
    String? ownerId,
    String? petName,
    String? petType,
    String? gender,
    dynamic ageValue,
    String? ageUnit,
    String? location,
    String? description,
    bool? isVaccinated,
    bool? isNeutered,
    List<String>? imageUrls,
    AdoptionStatus? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return PetAdoptionPost(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      petName: petName ?? this.petName,
      petType: petType ?? this.petType,
      gender: gender ?? this.gender,
      ageValue: ageValue ?? this.ageValue,
      ageUnit: ageUnit ?? this.ageUnit,
      location: location ?? this.location,
      description: description ?? this.description,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      isNeutered: isNeutered ?? this.isNeutered,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<String> _parseImageUrls(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return [];
  }
}
