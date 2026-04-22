import 'package:flutter/material.dart';
import 'clinic_details_page.dart';

class ServiceProvider {
  final String id, name, description, distance, petType, imageUrl;
  final double rating;
  final List<String> tags;
  final bool hasOffer;
  bool isFavorite;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.distance,
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
  bool _showOffersOnly = false;
  bool _showFavoritesOnly = false;

  // --- الفلاتر الجديدة المستخرجة من الصورة ---
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
      tags: ["Walking", "Sitting"],
      distance: "2.5 km",
      petType: "Dog",
      hasOffer: true,
      isFavorite: false,
      imageUrl:
          "https://images.unsplash.com/photo-1516733725897-1aa73b87c8e8?w=500",
    ),
    ServiceProvider(
      id: "2",
      name: "Cat Whisperers Clinic",
      rating: 4.8,
      description: "Specialized grooming and health care for cats",
      tags: ["Grooming", "Care"],
      distance: "1.2 km",
      petType: "Cat",
      hasOffer: true,
      imageUrl:
          "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=500",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var filteredList = _providers.where((p) {
      bool matchesSearch = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesOffer = !_showOffersOnly || p.hasOffer;
      bool matchesFav = !_showFavoritesOnly || p.isFavorite;
      bool matchesPet =
          _selectedPetType == "All Pet Types" || p.petType == _selectedPetType;

      // تصفية إضافية بناءً على التاج (Category) الجديد
      bool matchesCategory =
          _selectedCategory == "All" || p.tags.contains(_selectedCategory);

      return matchesSearch &&
          matchesOffer &&
          matchesFav &&
          matchesPet &&
          matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTopFilters(),
            const SizedBox(height: 10),
            _buildCategoryFilter(), // إضافة شريط الفلاتر هنا
            _buildActionButtons(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: filteredList.length,
                itemBuilder: (context, i) =>
                    _buildProviderCard(filteredList[i]),
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

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(15),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 10),
        const Text(
          "Pet Care Services",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  Widget _buildTopFilters() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Column(
      children: [
        TextField(
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
        const SizedBox(height: 10),
        Row(
          children: [
            _buildDrop("Sort: Highest Rated"),
            const SizedBox(width: 10),
            _buildDrop(_selectedPetType, isPetType: true),
          ],
        ),
      ],
    ),
  );

  Widget _buildDrop(String label, {bool isPetType = false}) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: isPetType
          ? DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPetType,
                style: const TextStyle(fontSize: 12, color: Colors.black),
                onChanged: (v) => setState(() => _selectedPetType = v!),
                items: ["All Pet Types", "Dog", "Cat"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
    ),
  );

  Widget _buildActionButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    child: Row(
      children: [
        _toggleBtn(
          "Offers",
          _showOffersOnly,
          () => setState(() => _showOffersOnly = !_showOffersOnly),
          Icons.local_offer,
        ),
        const SizedBox(width: 10),
        _toggleBtn(
          "Favorites",
          _showFavoritesOnly,
          () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
          Icons.favorite,
        ),
      ],
    ),
  );

  Widget _toggleBtn(
    String label,
    bool active,
    VoidCallback onTap,
    IconData icon,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? selectedTeal : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: active ? Colors.white : Colors.grey),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontSize: 12,
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
                  p.imageUrl,
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
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      p.description,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  p.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: p.isFavorite ? Colors.red : Colors.grey[300],
                ),
                onPressed: () => setState(() => p.isFavorite = !p.isFavorite),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              Text(
                " ${p.rating}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                p.distance,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
