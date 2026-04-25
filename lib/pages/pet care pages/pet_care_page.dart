import 'package:flutter/material.dart';
import 'clinic_details_page.dart';

class ServiceProvider {
  final String id,
      name,
      description,
      distance,
      location,
      hours,
      petType,
      imageUrl;
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
    required this.petType,
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
    'Daycare',
  ];
  String _selectedCategory = 'All';

  final List<ServiceProvider> _providers = [
    ServiceProvider(
      id: "1",
      name: "Happy Tails Pet Care",
      rating: 4.9,
      description: "Professional pet sitting and dog walking services",
      tags: ["Walking", "Sitting", "Dog", "Cat"],
      distance: "2.5 km",
      location: "Westside Avenue",
      hours: "7AM - 8PM",
      petType: "Dog",
      hasOffer: true,
      isFavorite: false,
      imageUrl:
          "https://images.unsplash.com/photo-1516733725897-1aa73b87c8e8?q=80&w=1000&auto=format&fit=crop",
    ),
    ServiceProvider(
      id: "2",
      name: "Obedience Masters",
      rating: 4.9,
      description: "Expert pet training and behavior modification",
      tags: ["Training", "Behavior", "Classes"],
      distance: "3.1 km",
      location: "Pet Training Center",
      hours: "8AM - 6PM",
      petType: "Dog",
      hasOffer: true,
      imageUrl:
          "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=1000&auto=format&fit=crop",
    ),
    ServiceProvider(
      id: "3",
      name: "Pawfect Spa & Grooming",
      rating: 4.8,
      description: "Premium grooming services with certified specialists",
      tags: ["Grooming", "Spa", "Stylings"],
      distance: "1.2 km",
      location: "Downtown Mall, 2nd floor",
      hours: "9AM - 7PM",
      petType: "Dog",
      hasOffer: true,
      imageUrl:
          "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?q=80&w=1000&auto=format&fit=crop",
    ),
    ServiceProvider(
      id: "4",
      name: "Zen Pet Wellness",
      rating: 4.8,
      description: "Pet massage, aromatherapy, and wellness treatments",
      tags: ["Massage", "Wellness", "Spa"],
      distance: "1.2 km",
      location: "Pet Avenue Center",
      hours: "10AM - 6PM",
      petType: "Cat",
      hasOffer: false,
      imageUrl:
          "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?q=80&w=1000&auto=format&fit=crop",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = _providers.where((p) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          p.name.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query) ||
          p.tags.any((tag) => tag.toLowerCase().contains(query));
      final matchesOffer = !_showOffersOnly || p.hasOffer;
      final matchesFav = !_showFavoritesOnly || p.isFavorite;
      final matchesPet =
          _selectedPetType == "All Pet Types" || p.petType == _selectedPetType;
      final matchesCategory =
          _selectedCategory == "All" || p.tags.contains(_selectedCategory);

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

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(filteredList.length),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildFilterRow(),
            const SizedBox(height: 10),
            _buildFavoritesRow(),
            const SizedBox(height: 10),
            _buildCategoryFilter(),
            _buildActionButtons(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: sortedList.length,
                itemBuilder: (context, i) => _buildProviderCard(sortedList[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ويدجت شريط الفلاتر الأفقي (المطلوب) ---
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? selectedTeal : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? selectedTeal : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(int providerCount) => Padding(
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
              Text(
                "$providerCount service providers",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
            borderSide: BorderSide.none,
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
        const SizedBox(width: 10),
        Expanded(child: _buildDrop(_selectedPetType, isPetType: true)),
      ],
    ),
  );

  Widget _buildFavoritesRow() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: _toggleBtn(
      "Favorites",
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
      ),
      child: isPetType
          ? DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedPetType,
                style: const TextStyle(fontSize: 13, color: Colors.black),
                onChanged: (v) => setState(() => _selectedPetType = v!),
                items: ["All Pet Types", "Dog", "Cat"]
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

  Widget _buildActionButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    child: Row(
      children: [
        _toggleBtn(
          "Offers ${_providers.where((p) => p.hasOffer).length}",
          _showOffersOnly,
          () => setState(() => _showOffersOnly = !_showOffersOnly),
          Icons.local_offer,
        ),
      ],
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
        borderRadius: BorderRadius.circular(14),
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
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
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
        boxShadow: [
          const BoxShadow(
            color: Color(0x08000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              p.imageUrl,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
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
                            p.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => p.isFavorite = !p.isFavorite),
                      child: Icon(
                        p.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: p.isFavorite ? Colors.red : Colors.grey.shade400,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x1F3AA78E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            p.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ...p.tags
                        .take(3)
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
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
                        ),
                  ],
                ),
                const SizedBox(height: 12),
                if (p.hasOffer)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1F3AA78E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      '1 Special Offer',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2F7E70),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (p.hasOffer) const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        p.location,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      p.distance,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      p.hours,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
