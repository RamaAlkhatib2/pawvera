import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawvera/services/database_service.dart';
import 'booking_page.dart';

// نموذج بيانات الخدمة لتمكين الفلترة الديناميكية
class PetService {
  final String title;
  final String price;
  final String oldPrice;
  final String discount;
  final bool isPopular;
  final List<String> petTypes; // empty = all pets
  final String duration;
  final String subtitle;
  final bool hasOffer;
  final double ratingAvg;
  final int ratingCount;

  PetService({
    required this.title,
    required this.price,
    this.oldPrice = "",
    this.discount = "",
    this.isPopular = false,
    this.petTypes = const [],
    required this.duration,
    this.subtitle = "",
    required this.hasOffer,
    this.ratingAvg = 0,
    this.ratingCount = 0,
  });
}

class ClinicDetailsPage extends StatefulWidget {
  final dynamic provider;
  const ClinicDetailsPage({super.key, required this.provider});

  @override
  State<ClinicDetailsPage> createState() => _ClinicDetailsPageState();
}

class _ClinicDetailsPageState extends State<ClinicDetailsPage> {
  final Color primaryGreen = const Color(0xFF5B9D8E);
  final DatabaseService _db = DatabaseService();

  String _selectedPetFilter = "All Pets";
  bool _filterByOffers = false;
  String _searchQuery = '';

  final List<String> _petTypes = [
    "All Pets",
    "Dogs",
    "Cats",
    "Birds",
    "Fish",
    "Other Pets",
  ];

  @override
  Widget build(BuildContext context) {
    final shopImageUrl = _getProviderImageUrl();
    final shopDescription = _getProviderDescription();
    final shopLocation = _getProviderLocation();
    final shopHours = _getProviderHours();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.provider.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Shop Info Card ---
            _buildShopInfoCard(
              shopImageUrl,
              shopDescription,
              shopLocation,
              shopHours,
            ),
            const SizedBox(height: 20),
            // --- Search Bar ---
            _buildSearchBar(),
            const SizedBox(height: 16),
            // --- Filter Row (pet type dropdown + offers toggle) ---
            _buildFilterRow(),
            // --- Offers Section ---
            const SizedBox(height: 24),
            _buildOffersSection(),
            const SizedBox(height: 24),
            // --- Services Header ---
            _buildAllServicesHeader(),
            const SizedBox(height: 16),
            // --- Service Items ---
            _buildServiceItemsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildShopInfoCard(
    String? shopImageUrl,
    String shopDescription,
    String shopLocation,
    String shopHours,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: shopImageUrl != null
                ? Image.network(
                    shopImageUrl,
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 170,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.store,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    height: 170,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.store, size: 50, color: Colors.grey),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.provider.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF274C4B),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showShopReviewsDialog,
                      child: _buildLiveShopRatingBadge(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildLiveShopRatingSummaryLine(),
                const SizedBox(height: 6),
                Text(
                  shopDescription,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoBubble(Icons.location_on_outlined, shopLocation),
                    const SizedBox(width: 8),
                    _buildInfoBubble(Icons.access_time, shopHours),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: "Search services...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_shops')
          .doc(widget.provider.id)
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, offersSnapshot) {
        final hasActiveOffers = (offersSnapshot.data?.docs.length ?? 0) > 0;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              const BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.03),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPetFilter,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: _petTypes.map((String type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPetFilter = value!);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _filterByOffers = !_filterByOffers),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _filterByOffers ? primaryGreen : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _filterByOffers
                            ? primaryGreen
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 16,
                          color: _filterByOffers ? Colors.white : Colors.black,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Offers ${hasActiveOffers ? '1' : '0'}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _filterByOffers
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOffersSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_shops')
          .doc(widget.provider.id)
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        final offerDocs = snapshot.data?.docs ?? [];
        if (offerDocs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: offerDocs.map((offerDoc) {
            final offerData = offerDoc.data() as Map<String, dynamic>;
            final discountPercent = offerData['discountPercent'] ?? 0;
            final expiryDate = offerData['expiryDate'] ?? '';
            final serviceName = offerData['serviceName'] as String?;
            final isShopWide = offerData['isShopWide'] ?? true;
            final title = isShopWide == true
                ? 'Shop-Wide Offer'
                : (serviceName ?? 'Special Offer');

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBEE9D5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9D8E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.percent,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF274C4B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            expiryDate.isNotEmpty
                                ? 'Valid until $expiryDate'
                                : 'Limited time offer',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9D8E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$discountPercent% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAllServicesHeader() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_shops')
          .doc(widget.provider.id)
          .collection('services')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Row(
          children: [
            const Icon(Icons.pets, size: 20, color: Color(0xFF5B9D8E)),
            const SizedBox(width: 8),
            Text(
              "All Services ($count)",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceItemsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_shops')
          .doc(widget.provider.id)
          .collection('services')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, servicesSnapshot) {
        if (servicesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final serviceDocs = servicesSnapshot.data?.docs ?? [];

        // Build PetService list from Firestore data
        final allServices = serviceDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? 'Service').toString();
          final priceVal = (data['price'] as num?)?.toDouble() ?? 0.0;
          final duration = (data['duration'] ?? '1 hour').toString();
          final description = (data['description'] ?? '').toString();
          final ratingAvg =
              ((data['ratingAvg'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 5.0);
          final ratingCount = (data['ratingCount'] as num?)?.toInt() ?? 0;

          final rawPetTypes = data['petTypes'] as List<dynamic>? ?? [];
          return PetService(
            title: name,
            price: '${priceVal.toStringAsFixed(2)} JOD',
            petTypes: rawPetTypes.map((e) => e.toString()).toList(),
            duration: duration,
            subtitle: description.isNotEmpty
                ? description
                : 'Professional $name service',
            hasOffer: false,
            ratingAvg: ratingAvg,
            ratingCount: ratingCount,
          );
        }).toList();

        // Check offers
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('service_shops')
              .doc(widget.provider.id)
              .collection('offers')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, offersSnapshot) {
            final servicesWithOffer = <String>{};
            for (final offerDoc in offersSnapshot.data?.docs ?? []) {
              final offerData = offerDoc.data() as Map<String, dynamic>;
              final sid = offerData['serviceId'] as String?;
              if (sid != null && sid.isNotEmpty) {
                servicesWithOffer.add(sid);
              }
            }

            // Mark offers on services
            for (int i = 0; i < allServices.length; i++) {
              final svcDoc = serviceDocs[i];
              if (servicesWithOffer.contains(svcDoc.id)) {
                allServices[i] = PetService(
                  title: allServices[i].title,
                  price: allServices[i].price,
                  oldPrice: allServices[i].oldPrice,
                  discount: allServices[i].discount,
                  isPopular: allServices[i].isPopular,
                  petTypes: allServices[i].petTypes,
                  duration: allServices[i].duration,
                  subtitle: allServices[i].subtitle,
                  hasOffer: true,
                );
              }
            }

            // Apply filters
            final filteredServices = allServices.where((service) {
              final matchesType = _selectedPetFilter == "All Pets" ||
                  service.petTypes.isEmpty ||
                  service.petTypes.contains(_selectedPetFilter);
              final matchesOffer = !_filterByOffers || service.hasOffer;
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  service.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  service.subtitle.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
              return matchesType && matchesOffer && matchesSearch;
            }).toList();

            if (filteredServices.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("No services found for this filter."),
                ),
              );
            }

            return Column(
              children: filteredServices
                  .map((service) => _buildServiceItem(context, service))
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildServiceItem(BuildContext context, PetService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
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
                      service.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF274C4B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.ratingAvg.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF274C4B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${service.ratingCount})',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (service.isPopular)
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Popular",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (service.petTypes.isEmpty)
                _buildTag('All Pets', Colors.blue.shade50, Colors.blue)
              else
                ...service.petTypes.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildTag(t, Colors.blue.shade50, Colors.blue),
                  ),
                ),
              _buildTag(service.duration, Colors.grey.shade200, Colors.black54),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    service.price,
                    style: TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (service.oldPrice.isNotEmpty)
                    Text(
                      service.oldPrice,
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (service.discount.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    service.discount,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => BookingPage(
                      serviceName: service.title,
                      price: service.price,
                      clinicName: widget.provider.name,
                      providerName: widget.provider.name,
                      duration: service.duration,
                      shopId: widget.provider.id,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Book Now",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _getProviderImageUrl() {
    try {
      final imageUrl = widget.provider.imageUrl;
      if (imageUrl is String && imageUrl.isNotEmpty) return imageUrl;
    } catch (_) {}
    try {
      final imageUrl = widget.provider['imageUrl'];
      if (imageUrl is String && imageUrl.isNotEmpty) return imageUrl;
    } catch (_) {}
    return null;
  }

  String _getProviderDescription() {
    try {
      final description = widget.provider.description;
      if (description is String && description.isNotEmpty) return description;
    } catch (_) {}
    return 'Professional pet care with trusted services.';
  }

  String _getProviderLocation() {
    try {
      final location = widget.provider.location;
      if (location is String && location.isNotEmpty) return location;
    } catch (_) {}
    return 'Unknown location';
  }

  String _getProviderHours() {
    try {
      final hours = widget.provider.hours;
      if (hours is String && hours.isNotEmpty) return hours;
    } catch (_) {}
    return 'Hours unavailable';
  }

  String _getProviderShopId() {
    try {
      final id = widget.provider.id;
      if (id is String && id.isNotEmpty) return id;
    } catch (_) {}
    try {
      final id = widget.provider['id'];
      if (id is String && id.isNotEmpty) return id;
    } catch (_) {}
    return '';
  }

  double _fallbackRatingAvg() {
    try {
      final r = widget.provider.rating;
      if (r is num) return r.toDouble();
    } catch (_) {}
    return 0;
  }

  int _fallbackRatingCount() {
    try {
      final c = widget.provider.ratingCount;
      if (c is int) return c;
      if (c is num) return c.toInt();
    } catch (_) {}
    return 0;
  }

  String _shopRatingLabel(double fallbackAvg, int fallbackCount) {
    if (fallbackCount > 0) return fallbackAvg.toStringAsFixed(1);
    return '0.0';
  }

  Widget _buildLiveShopRatingBadge() {
    final shopId = _getProviderShopId();
    final fallbackAvg = _fallbackRatingAvg();
    final fallbackCount = _fallbackRatingCount();

    if (shopId.isEmpty) {
      return _shopRatingBadgeChip(
        _shopRatingLabel(fallbackAvg, fallbackCount),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      key: ValueKey<String>('clinic_shop_rating_$shopId'),
      stream: _db.streamServiceShopReviews(shopId),
      builder: (context, snap) {
        if (snap.hasError) {
          return _shopRatingBadgeChip(
            _shopRatingLabel(fallbackAvg, fallbackCount),
          );
        }
        if (!snap.hasData) {
          return _shopRatingBadgeChip('…');
        }
        final docs = snap.data!.docs
            .where((d) => DatabaseService.reviewDocIsServiceShop(d.data()))
            .toList();
        if (docs.isEmpty) {
          return _shopRatingBadgeChip(
            _shopRatingLabel(fallbackAvg, fallbackCount),
          );
        }
        final avg = DatabaseService.averageStarsFromReviewDocs(docs);
        return _shopRatingBadgeChip(avg.toStringAsFixed(1));
      },
    );
  }

  Widget _buildLiveShopRatingSummaryLine() {
    final shopId = _getProviderShopId();
    final fallbackCount = _fallbackRatingCount();

    if (shopId.isEmpty) {
      final n = fallbackCount > 0 ? fallbackCount : 0;
      final avg = fallbackCount > 0 ? _fallbackRatingAvg() : 0.0;
      return Text(
        '${avg.toStringAsFixed(1)} · $n review${n == 1 ? '' : 's'}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.streamServiceShopReviews(shopId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Text(
            'Loading reviews…',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          );
        }
        final docs = snap.data!.docs
            .where((d) => DatabaseService.reviewDocIsServiceShop(d.data()))
            .toList();
        if (docs.isEmpty) {
          final n = fallbackCount > 0 ? fallbackCount : 0;
          final avg = fallbackCount > 0 ? _fallbackRatingAvg() : 0.0;
          return Text(
            '${avg.toStringAsFixed(1)} · $n review${n == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          );
        }
        final avg = DatabaseService.averageStarsFromReviewDocs(docs);
        final n = docs.length;
        return Text(
          '${avg.toStringAsFixed(1)} · $n review${n == 1 ? '' : 's'}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }

  Widget _shopRatingBadgeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF274C4B),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showShopReviewsDialog() async {
    final shopId = _getProviderShopId();
    if (shopId.isEmpty) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFF0F9F9),
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: 520,
            height: 560,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
                  child: Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Shop Reviews',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.brown.shade900,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'See what customers are saying about ${widget.provider.name}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('shopId', isEqualTo: shopId)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4FA294),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Could not load reviews.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        );
                      }

                      final docs = (snapshot.data?.docs ?? [])
                          .where(
                            (d) =>
                                DatabaseService.reviewDocIsServiceShop(d.data()),
                          )
                          .toList()
                        ..sort((a, b) {
                          final ta = a.data()['createdAt'];
                          final tb = b.data()['createdAt'];
                          if (ta is Timestamp && tb is Timestamp) {
                            return tb.compareTo(ta);
                          }
                          if (ta is Timestamp) return -1;
                          if (tb is Timestamp) return 1;
                          return 0;
                        });

                      final avg = docs.isEmpty
                          ? 0.0
                          : DatabaseService.averageStarsFromReviewDocs(docs);
                      final count = docs.length;

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    avg.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: Colors.brown.shade900,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Based on $count customer ${count == 1 ? 'review' : 'reviews'}',
                                      style: TextStyle(
                                        color: Colors.blueGrey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (docs.isEmpty)
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'No reviews yet.',
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade600,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: ListView.separated(
                                  itemCount: docs.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final data = docs[index].data();
                                    final name =
                                        (data['customerName'] ?? 'Customer')
                                            .toString()
                                            .trim();
                                    final comment =
                                        (data['comment'] ?? '').toString().trim();
                                    final stars =
                                        ((data['stars'] as num?)?.toInt() ?? 0)
                                            .clamp(0, 5);
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name.isEmpty ? 'Customer' : name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF274C4B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: List.generate(5, (i) {
                                              return Icon(
                                                i < stars
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                size: 16,
                                                color: Colors.amber,
                                              );
                                            }),
                                          ),
                                          if (comment.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              comment,
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoBubble(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color background, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
