import 'package:flutter/material.dart';
import 'clinic_details_page.dart';

class ServiceProvider {
  final String id;
  final String name;
  final double rating;
  final String description;
  final List<String> tags;
  final String distance;
  final String petType;
  final String imageUrl;
  final bool hasOffer;
  bool isFavorite;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.rating,
    required this.description,
    required this.tags,
    required this.distance,
    required this.petType,
    required this.imageUrl,
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
  final TextEditingController _searchController = TextEditingController();

  final List<ServiceProvider> _allProviders = [
    ServiceProvider(
      id: "1",
      name: "Happy Tails Pet Care",
      rating: 4.9,
      description: "Professional pet sitting and dog walking services",
      tags: ["Walking", "Sitting", "Daycare"],
      distance: "2.5 km",
      petType: "Dog",
      imageUrl:
          "https://images.unsplash.com/photo-1516733725897-1aa73b87c8e8?w=500",
      hasOffer: true,
      isFavorite: true,
    ),
    ServiceProvider(
      id: "2",
      name: "Cat Whisperers Clinic",
      rating: 4.8,
      description: "Specialized grooming and health care for cats",
      tags: ["Grooming", "Care"],
      distance: "1.2 km",
      petType: "Cat",
      imageUrl:
          "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=500",
      hasOffer: true,
    ),
    ServiceProvider(
      id: "3",
      name: "Obedience Masters",
      rating: 4.7,
      description: "Expert pet training and behavior modification",
      tags: ["Training", "Behavior"],
      distance: "4.1 km",
      petType: "Dog",
      imageUrl:
          "https://images.unsplash.com/photo-1541591415600-61e6279c0050?w=500",
    ),
  ];

  // متغيرات الفلاتر
  String _searchQuery = "";
  String _selectedSort = "Highest Rated";
  String _selectedPetType = "All Pet Types";
  String _selectedCategory = "All";
  bool _showOffersOnly = false;
  bool _showFavoritesOnly = false;

  List<ServiceProvider> get _filteredProviders {
    List<ServiceProvider> list = _allProviders.where((p) {
      bool matchesSearch = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesOffer = !_showOffersOnly || p.hasOffer;
      bool matchesFav = !_showFavoritesOnly || p.isFavorite;
      bool matchesPet =
          _selectedPetType == "All Pet Types" || p.petType == _selectedPetType;
      bool matchesCat =
          _selectedCategory == "All" || p.tags.contains(_selectedCategory);
      return matchesSearch &&
          matchesOffer &&
          matchesFav &&
          matchesPet &&
          matchesCat;
    }).toList();

    if (_selectedSort == "Highest Rated") {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_selectedSort == "Nearest") {
      list.sort((a, b) => a.distance.compareTo(b.distance));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    var displayList = _filteredProviders;
    int offerCount = _allProviders.where((p) => p.hasOffer).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFiltersSection(offerCount),
            _buildCategoryChips(),
            Expanded(
              child: displayList.isEmpty
                  ? const Center(child: Text("No providers found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) =>
                          _buildProviderCard(displayList[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () {},
          ),
          const Text(
            "Pet Care Services",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(int offerCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          // البحث
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: "Search services...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildDropdown(
                value: _selectedSort,
                items: ["Highest Rated", "Nearest"],
                onChanged: (v) => setState(() => _selectedSort = v!),
                prefix: "Sort: ",
              ),
              const SizedBox(width: 10),
              _buildDropdown(
                value: _selectedPetType,
                items: ["All Pet Types", "Dog", "Cat", "Bird"],
                onChanged: (v) => setState(() => _selectedPetType = v!),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // أزرار العروض والمفضلة
          Row(
            children: [
              _buildOffersButton(offerCount),
              const SizedBox(width: 10),
              _buildFavoritesButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String prefix = "",
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            style: const TextStyle(fontSize: 12, color: Colors.black),
            onChanged: onChanged,
            items: items
                .map(
                  (String item) =>
                      DropdownMenuItem(value: item, child: Text(prefix + item)),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildOffersButton(int count) {
    return GestureDetector(
      onTap: () => setState(() => _showOffersOnly = !_showOffersOnly),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _showOffersOnly ? selectedTeal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _showOffersOnly ? selectedTeal : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _showOffersOnly ? Icons.check_circle : Icons.local_offer_outlined,
              size: 16,
              color: _showOffersOnly ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              "Offers",
              style: TextStyle(
                color: _showOffersOnly ? Colors.white : Colors.black,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 9,
              backgroundColor: _showOffersOnly
                  ? Colors.white24
                  : Colors.grey[200],
              child: Text(
                "$count",
                style: TextStyle(
                  fontSize: 9,
                  color: _showOffersOnly ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _showFavoritesOnly ? primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _showFavoritesOnly ? primaryGreen : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: 16,
                color: _showFavoritesOnly ? Colors.white : Colors.grey[300],
              ),
              const SizedBox(width: 8),
              const Text("Favorites", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Row(
        children: ["All", "Grooming", "Walking", "Training"]
            .map(
              (cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (s) => setState(() => _selectedCategory = cat),
                  selectedColor: primaryGreen,
                  labelStyle: TextStyle(
                    color: _selectedCategory == cat
                        ? Colors.white
                        : Colors.black,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildProviderCard(ServiceProvider provider) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClinicDetailsPage(provider: provider),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    provider.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        provider.description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    provider.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: provider.isFavorite ? Colors.red : Colors.grey[300],
                  ),
                  onPressed: () => setState(
                    () => provider.isFavorite = !provider.isFavorite,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                Text(
                  " ${provider.rating}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  provider.distance,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
