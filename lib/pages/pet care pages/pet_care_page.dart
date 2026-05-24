import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'clinic_details_page.dart';
import 'package:pawvera/services/database_service.dart';

class ServiceProvider {
  final String id,
      name,
      description,
      distance,
      location,
      hours,
      imageUrl;
  final List<String> petTypes; // empty = serves all pet types
  final double rating;
  final List<String> tags;
  final bool hasOffer;
  bool isFavorite;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.distance,
    required this.location,
    required this.hours,
    required this.petTypes,
    required this.imageUrl,
    required this.rating,
    required this.tags,
    this.hasOffer = false,
    this.isFavorite = false,
  });
}

class PetCarePage extends StatefulWidget {
  const PetCarePage({super.key});

  @override
  State<PetCarePage> createState() => _PetCarePageState();
}

class _PetCarePageState extends State<PetCarePage> {
  final Color primaryGreen = const Color(0xFF5B9D8E);
  final Color selectedTeal = const Color(0xFF3AA78E);

  String _searchQuery = "";
  String _selectedPetType = "All Pet Types";
  String _selectedSort = "Highest Rated";
  bool _showOffersOnly = false;
  bool _showFavoritesOnly = false;
  final Set<String> _favoriteIds = {};
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _db.favoritePetCareShops.listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _favoriteIds
          ..clear()
          ..addAll(snapshot.docs.map((d) => d.id));
      });
    });
  }

  void _toggleFavorite(String shopId) {
    // Optimistically update UI immediately
    setState(() {
      if (_favoriteIds.contains(shopId)) {
        _favoriteIds.remove(shopId);
      } else {
        _favoriteIds.add(shopId);
      }
    });
    _db.toggleFavoritePetCareShop(shopId);
  }

  // --- الفلاتر الجديدة المستخرجة من الصورة ---
  final List<String> _sortOptions = [
    'Highest Rated',
    'Nearest',
    'Name (A - Z)',
  ];
  final List<String> _categories = [
    'All',
    'Grooming',
    'Walking',
    'Training',
    'Spa',
    'Daycare',
    'Wellness',
  ];
  String _selectedCategory = 'All';

  /// Build a ServiceProvider from a Firestore shop document.
  /// We only show shop name, address, working hours, and a default rating.
  /// Tags are extracted from the shop's active services subcollection names.
  /// If no imageUrl is set, a placeholder is returned.
  Future<ServiceProvider> _buildProviderFromShop(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();
    final shopId = doc.id;

    // Fetch active services for tags
    final servicesSnap = await FirebaseFirestore.instance
        .collection('service_shops')
        .doc(shopId)
        .collection('services')
        .where('isActive', isEqualTo: true)
        .get();

    final serviceNames = servicesSnap.docs
        .map((d) => (d.data()['name'] ?? '').toString())
        .where((n) => n.isNotEmpty)
        .toList();

    // Fetch active offers for the hasOffer flag
    final offersSnap = await FirebaseFirestore.instance
        .collection('service_shops')
        .doc(shopId)
        .collection('offers')
        .where('isActive', isEqualTo: true)
        .get();
    final hasOffer = offersSnap.docs.isNotEmpty;

    return ServiceProvider(
      id: shopId,
      name: (data['shopName'] ?? 'Pet Shop').toString(),
      description: (data['address'] ?? 'Professional pet care services')
          .toString(),
      distance: '1.5 km', // default; could be derived from geolocation later
      location: (data['address'] ?? 'Unknown location').toString(),
      hours: (data['workingHours'] ?? '9:00 AM - 7:00 PM').toString(),
      petTypes: (data['petTypes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      rating: 4.5, // default rating; could be derived from reviews later
      tags: serviceNames.isNotEmpty
          ? serviceNames
          : ['Grooming', 'Spa', 'Wellness'],
      hasOffer: hasOffer,
      isFavorite: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildFilterRow(),
            const SizedBox(height: 10),
            _buildFavoritesRow(),
            const SizedBox(height: 10),
            _buildCategoryFilter(),
            Expanded(child: _buildProvidersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildProvidersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_shops')
          .where('isOpen', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No service providers are currently available.\nCheck back later!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return FutureBuilder<List<ServiceProvider>>(
          future: Future.wait(
            docs.map(
              (doc) => _buildProviderFromShop(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            ),
          ),
          builder: (context, providersSnapshot) {
            if (providersSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final providers = providersSnapshot.data ?? [];

            // Apply local filters (search, offers, favorites, pet type, category)
            final filteredList = providers.where((p) {
              final query = _searchQuery.toLowerCase();
              final matchesSearch =
                  p.name.toLowerCase().contains(query) ||
                  p.description.toLowerCase().contains(query) ||
                  p.tags.any((tag) => tag.toLowerCase().contains(query));
              final matchesOffer = !_showOffersOnly || p.hasOffer;
              final matchesFav = !_showFavoritesOnly || _favoriteIds.contains(p.id);
              final petTypeLower = _selectedPetType.toLowerCase();
              final matchesPet =
                  _selectedPetType == "All Pet Types" ||
                  p.petTypes.any((t) => t.toLowerCase() == petTypeLower);
              final categoryLower = _selectedCategory.toLowerCase();
              final matchesCategory =
                  _selectedCategory == "All" ||
                  p.tags.any((tag) => tag.toLowerCase().contains(categoryLower));

              return matchesSearch &&
                  matchesOffer &&
                  matchesFav &&
                  matchesPet &&
                  matchesCategory;
            }).toList();

            final sortedList = [...filteredList];
            sortedList.sort((a, b) {
              switch (_selectedSort) {
                case 'Nearest':
                  return _parseDistance(
                    a.distance,
                  ).compareTo(_parseDistance(b.distance));
                case 'Name (A - Z)':
                  return a.name.compareTo(b.name);
                case 'Highest Rated':
                default:
                  return b.rating.compareTo(a.rating);
              }
            });

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: sortedList.length,
              itemBuilder: (context, i) => _buildProviderCard(sortedList[i]),
            );
          },
        );
      },
    );
  }

  // --- ويدجت شريط الفلاتر الأفقي (المطلوب) ---
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? selectedTeal : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? selectedTeal : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_categories[index] == 'All') ...[
                      Icon(
                        Icons.tune_rounded,
                        size: 13,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF5B9D8E),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pet Care Services",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('service_shops')
                    .where('isOpen', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return Text(
                    "$count service providers",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          const BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: "Search services, pet types (e.g., cat, dog, pr)",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ),
  );

  Widget _buildSortDrop() => Container(
    height: 48,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedSort,
        isExpanded: true,
        items: _sortOptions
            .map(
              (option) => DropdownMenuItem(
                value: option,
                child: Text(option, style: const TextStyle(fontSize: 13)),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedSort = value);
          }
        },
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        style: const TextStyle(color: Colors.black87),
        dropdownColor: Colors.white,
      ),
    ),
  );

  double _parseDistance(String distance) {
    return double.tryParse(distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  Widget _buildFilterRow() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Row(
      children: [
        Expanded(child: _buildSortDrop()),
        const SizedBox(width: 8),
        Expanded(child: _buildDrop(_selectedPetType, isPetType: true)),
        const SizedBox(width: 8),
        Expanded(
          child: _toggleBtn(
            "Offers",
            _showOffersOnly,
            () => setState(() => _showOffersOnly = !_showOffersOnly),
            Icons.local_offer,
            compact: true,
          ),
        ),
      ],
    ),
  );

  Widget _buildFavoritesRow() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: _toggleBtn(
      "Show All",
      _showFavoritesOnly,
      () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
      Icons.favorite,
      fullWidth: true,
      compact: false,
    ),
  );

  Widget _buildDrop(String label, {bool isPetType = false}) => Expanded(
    child: Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: isPetType
          ? DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedPetType,
                style: const TextStyle(fontSize: 13, color: Colors.black),
                onChanged: (v) => setState(() => _selectedPetType = v!),
                items: ["All Pet Types", "Dog", "Cat", "Bird", "Fish"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
            )
          : Center(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
    ),
  );

  Widget _toggleBtn(
    String label,
    bool active,
    VoidCallback onTap,
    IconData icon, {
    bool compact = false,
    bool fullWidth = false,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: fullWidth ? double.infinity : null,
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18),
      decoration: BoxDecoration(
        color: active ? selectedTeal : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? selectedTeal : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: fullWidth
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: active ? Colors.white : Colors.grey),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? Colors.white : Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildProviderCard(ServiceProvider p) => GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => ClinicDetailsPage(provider: p)),
    ),
    child: Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9F3F2)),
        boxShadow: [
          const BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: p.imageUrl.isNotEmpty
                      ? Image.network(
                          p.imageUrl,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 96,
                                height: 96,
                                color: const Color(
                                  0xFF2D6A64,
                                ).withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.storefront,
                                  color: Color(0xFF2D6A64),
                                  size: 36,
                                ),
                              ),
                        )
                      : Container(
                          width: 96,
                          height: 96,
                          color: const Color(0xFF2D6A64).withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.storefront,
                            color: Color(0xFF2D6A64),
                            size: 36,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F7F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  p.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _toggleFavorite(p.id),
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(
                      _favoriteIds.contains(p.id) ? Icons.favorite : Icons.favorite_border,
                      color: _favoriteIds.contains(p.id) ? Colors.red : Colors.grey.shade400,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final animalTypes = {'Dog', 'Cat', 'Bird', 'Fish'};
                // Show only real pet types set by the provider
                final animalTags = p.petTypes
                    .where(animalTypes.contains)
                    .toList();
                final serviceTags = p.tags
                    .where((tag) => !animalTypes.contains(tag))
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (animalTags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: animalTags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF4FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF2567A8),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    if (animalTags.isNotEmpty) const SizedBox(height: 10),
                    if (p.hasOffer) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          '1 Special Offer',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB6691D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (serviceTags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: serviceTags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F7F6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                      children: [
                        TextSpan(text: p.location),
                        const TextSpan(text: '  •  '),
                        TextSpan(text: p.distance),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  p.hours,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
