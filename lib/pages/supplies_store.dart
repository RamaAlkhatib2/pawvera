import 'package:flutter/material.dart';
import 'store_details.dart'; // تأكد من وجود هذا الملف في مشروعك

  class SuppliesStore extends StatefulWidget {
  const SuppliesStore({super.key});
@override
  State<SuppliesStore> createState() => _SuppliesStoreState();
}

class _SuppliesStoreState extends State<SuppliesStore> {
  // 1. المتغيرات اللي بنحتاجها للتحكم بالحالة
  String searchQuery = "";
  String selectedCategory = "All";
  String selectedSort = "Nearest"; 
  bool showOnlyFavorites = false;
  bool showOnlyOffers = false; // القيمة الافتراضية "غير مفعل"

  // 2. قائمة المتاجر الأساسية (الداتا)
  final List<Map<String, dynamic>> allStores = [
    
    {
      'name': 'Comfort Paws Store',
      'desc': 'Premium pet furniture and bedding',
      'rating': '4.8',
      'location': 'King Fahd Avenue',
      'distance': '1.5 km',
      'time': '9AM - 8PM',
      'tags': ['Furniture', 'Bedding', 'Home'],
      'isFavorite': false,
      'offer': null,
    },
    {
      'name': 'Pet Supplies Plus',
      'desc': 'Complete pet supply store with premium brands',
      'rating': '4.7',
      'offer': '20% Off on Orders Above 50 JOD',
      'location': 'Al-Jabal Street',
      'distance': '2.3 km',
      'time': '9AM - 9PM',
      'tags': ['Food', 'Toys', 'Accessories'],
      'isFavorite': false,
    },
    {
      'name': 'Furry Friends Store',
      'desc': 'Toys, treats and accessories for all pets',
      'rating': '4.6',
      'offer': '15% Off All Toys',
      'location': 'Al-Salam Road',
      'distance': '3.8 km',
      'time': '10AM - 8PM',
      'tags': ['Toys', 'Treats', 'Accessories'],
      'isFavorite': false,
    },
    {
      'name': 'Healthy Pets Market',
      'desc': 'Organic food and health products',
      'rating': '4.9',
      'offer': '10% Off Organic Products',
      'location': 'Prince Mohammed Street',
      'distance': '4.2 km',
      'time': '8AM - 10PM',
      'tags': ['Food', 'Health', 'Supplements'],
      'isFavorite': false,
    },
  ];
  void _filterStores() {
    setState(() {
      // الـ setState هون هي اللي بتخلي الشاشة تتحدث فوراً
    });
  }
  // 3. دالة الفلترة الذكية (تجمع البحث + التصنيف + المفضلات)
 List<Map<String, dynamic>> get filteredStores {
    // 1. أولاً: بنعمل الفلترة (نفس كودك القديم)
    List<Map<String, dynamic>> list = allStores.where((store) {
      final matchesSearch = store['name'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == "All" || (store['tags'] as List).contains(selectedCategory);
      final matchesFavorite = !showOnlyFavorites || store['isFavorite'] == true;
      final matchesOffer = !showOnlyOffers || (store['offer'] != null && store['offer'] != "");
      return matchesSearch && matchesCategory && matchesFavorite && matchesOffer;
    }).toList();

    // 2. ثانياً: بنضيف منطق الترتيب (الجديد) 🚀
    if (selectedSort == "Top Rated") {
      // بيرتب من أعلى تقييم للأقل
      list.sort((a, b) => b['rating'].toString().compareTo(a['rating'].toString()));
    } 
    else if (selectedSort == "Nearest") {
      // بيرتب حسب المسافة (الأصغر للأكبر)
      list.sort((a, b) => a['distance'].toString().compareTo(b['distance'].toString()));
    } 
    else if (selectedSort == "Popular") {
      // ترتيب افتراضي (حسب الاسم مثلاً أو أي معيار شهرة)
      list.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
    }

    return list;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5A3E2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pet Supplies',
                style: TextStyle(
                    color: Color(0xFF5A3E2B),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text('Choose a store',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        actions: [
          _buildTopButton(context, Icons.favorite_border, 'Wishlist'),
          _buildTopButton(context, Icons.history, 'Orders'),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // 1. شريط البحث (Search Bar)
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search products or stores...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // 2. سطر الترتيب والعروض (Sort & Offers)
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // 1. كبسة الـ Sort (المفعلة) 🔽
      PopupMenuButton<String>(
        onSelected: (value) => setState(() => selectedSort = value),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'Nearest', child: Text('Sort: Nearest')),
          const PopupMenuItem(value: 'Top Rated', child: Text('Sort: Top Rated')),
          const PopupMenuItem(value: 'Popular', child: Text('Sort: Popular')),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Text("Sort: $selectedSort", style: const TextStyle(fontSize: 13, color: Color(0xFF5A3E2B))),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),

      // 2. كبسة الـ Offers Only (المفعلة) 🏷️
      GestureDetector(
        onTap: () {
          setState(() {
            showOnlyOffers = !showOnlyOffers; // عكس الحالة (Toggle)
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            // يتغير اللون للأخضر الفاتح إذا كانت مفعلة
            color: showOnlyOffers ? const Color(0xFFE8F4F1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: showOnlyOffers ? const Color(0xFF3AA78E) : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.local_offer_outlined, size: 18, color: showOnlyOffers ? const Color(0xFF3AA78E) : const Color(0xFF5A3E2B)),
              const SizedBox(width: 6),
              const Text('Offers Only', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              // دائرة العدد (ممكن تخليها ديناميكية تحسب كم متجر عنده عرض)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Text(
                  allStores.where((s) => s['offer'] != null).length.toString(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3AA78E)),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

          // 3. زر إظهار كل المتاجر (Show All Stores)
         Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => setState(() => showOnlyFavorites = !showOnlyFavorites),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: showOnlyFavorites ? const Color(0xFFE8F4F1) : const Color(0xFFF0EFEF),
                  borderRadius: BorderRadius.circular(12),
                  border: showOnlyFavorites ? Border.all(color: const Color(0xFF5BA092)) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(showOnlyFavorites ? Icons.favorite : Icons.favorite_border, 
                         size: 18, color: showOnlyFavorites ? Colors.red : const Color(0xFF5A3E2B)),
                    const SizedBox(width: 8),
                    Text(showOnlyFavorites ? 'Showing Favorites' : 'Show All Stores', 
                         style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),

          // 4. فلاتر التصنيفات (Filter Tabs)
          // --- بداية فلاتر التصنيفات ---
const SizedBox(height: 8),
SingleChildScrollView(
  scrollDirection: Axis.horizontal, // لجعل الفلتر يتحرك بالعرض
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Row(
    // قائمة التصنيفات اللي بتظهر في التطبيق
    children: ['All', 'Food', 'Toys', 'Accessories', 'Health'].map((category) {
      // شيك إذا كان هاد التصنيف هو اللي اختاره المستخدم
      bool isSelected = selectedCategory == category;
      
      return GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = category; // تحديث الكلمة المختارة
            // ملاحظة: هون القائمة رح تتحدث تلقائياً لأننا استخدمنا setState
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            // إذا مختار (isSelected) بكون اللون أخضر، وإذا لأ بكون أبيض
            color: isSelected ? const Color(0xFF5BA092) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              // أيقونة الـ Tune بتظهر بس عند كلمة All
              if (category == 'All') ...[
                Icon(Icons.tune, 
                     size: 18, 
                     color: isSelected ? Colors.white : const Color(0xFF5BA092)),
                const SizedBox(width: 8),
              ],
              Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF5A3E2B),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  ),
),
// --- نهاية فلاتر التصنيفات ---
const SizedBox(height: 16),
          // 5. قائمة المتاجر
          Expanded(
            child: filteredStores.isEmpty
                ? const Center(child: Text("No stores found!"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredStores.length,
                    itemBuilder: (context, index) {
                      final store = filteredStores[index];
                      return _buildStoreCard(
                        context: context,
                        name: store['name'],
                        desc: store['desc'],
                        rating: store['rating'],
                        location: store['location'],
                        distance: store['distance'],
                        time: store['time'],
                        tags: List<String>.from(store['tags']),
                        offer: store['offer'],
                        isFavorite: store['isFavorite'],
                        onFavoriteToggle: () {
      setState(() {
        store['isFavorite'] = !store['isFavorite'];
      });
    },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Widgets Helpers ---

  Widget _buildTopButton(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Wishlist') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyWishlistPage()));
        } else if (label == 'Orders') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersPage()));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF5A3E2B)),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF5A3E2B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3AA78E).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_outlined, size: 18, color: Color(0xFF5A3E2B)),
          const SizedBox(width: 6),
          const Text('Offers Only',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5A3E2B))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Text('3',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3AA78E))),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, {bool isSelected = false, IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF5BA092) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF5BA092)),
            const SizedBox(width: 8),
          ],
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF5A3E2B),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildStoreCard({
    required BuildContext context,
    required String name,
    required String desc,
    required String rating,
    String? offer,
    required String location,
    required String distance,
    required String time,
    required List<String> tags,
    required bool isFavorite,
    required VoidCallback onFavoriteToggle,
  })
  
  {
    String currentStoreImage = "";

if (name.contains("Comfort")) {
  currentStoreImage = 'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7';
} else if (name.contains("Plus")) {
  currentStoreImage = 'https://www.broadreachretail.com/wp-content/uploads/2019/06/Pet-Supplies-Plus.jpg';
} else if (name.contains("Furry")) {
  currentStoreImage = 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee';
} 
else if (name.contains("Healthy")) { // تعديل لمتجر Healthy Pets Market
  // الصورة الجديدة لطعام الكلاب (WebP)
  currentStoreImage = 'https://www.intelmarketresearch.com/assets/blog-images/Nutritious_Dog_Food_Market.webp';
  
}
else {
  currentStoreImage = 'https://images.unsplash.com/photo-1522276493077-9fe5ad01add6';
}
    return GestureDetector(
      onTap: () {
        String storeImage = "";
        List<String> categories = [];
        String reviews = "";

        if (name.contains("Comfort")) {
          storeImage = 'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7';
          categories = ['Furniture', 'Bedding', 'Home'];
          reviews = '(412)';
        } else if (name.contains("Plus")) {
          storeImage = 'https://www.broadreachretail.com/wp-content/uploads/2019/06/Pet-Supplies-Plus.jpg';
          categories = ['Food', 'Accessories', 'Toys'];
          reviews = '(250)';
        } else if (name.contains("Furry")) {
          storeImage = 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee';
          categories = ['Grooming', 'Toys', 'Training'];
          reviews = '(180)';
        } else {
          storeImage = 'https://www.intelmarketresearch.com/assets/blog-images/Nutritious_Dog_Food_Market.webp';
          categories = ['Health', 'Organic', 'Care'];
          reviews = '(95)';
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreDetails(
              storeData: {
                'name': name.trim(),
                'image': storeImage,
                'location': location,
                'distance': distance,
                'time': time,
                'rating': rating,
                'reviews': reviews,
                'hours': time,
                'categories': categories,
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          image: DecorationImage(
          image: NetworkImage(currentStoreImage), // لن يعطي خطأ الآن
          fit: BoxFit.cover,
        ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         Row(
              children: [
             Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(10),
    // هنا نقوم بوضع الصورة في الخلفية لتأخذ شكل الـ BorderRadius
    image: DecorationImage(
      image: NetworkImage(currentStoreImage),
      fit: BoxFit.cover,
    ),
  ),
  // الأيقونة تظهر فقط إذا كانت الصورة فارغة (كحالة احتياطية)
  child: currentStoreImage.isEmpty 
      ? const Icon(Icons.store, color: Colors.grey) 
      : null,
),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // اسم المتجر
                          Expanded(
                            child: Text(name, 
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // حاوية القلب والتقييم مع بعض
                          Row(
                            children: [
                              // زر القلب التفاعلي
                              GestureDetector(
                                onTap: () {
                                  // استدعاء دالة التغيير اللي عرفناها فوق
                                  setState(() {
                                    allStores.firstWhere((s) => s['name'] == name)['isFavorite'] = !isFavorite;
                                  });
                                },
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 8), // مسافة بين القلب والستار
                              
                              // كادر التقييم الأخضر
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF3AA78E),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text('★ $rating', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            if (offer != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200)),
                child: Text('🏷 $offer',
                    style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
                spacing: 8,
                children: tags
                    .map((t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.grey.shade50))
                    .toList()),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$location  •  $distance', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Spacer(),
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- صفحة المفضلة ---
class MyWishlistPage extends StatelessWidget {
  const MyWishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        title: const Text("My Wishlist", style: TextStyle(color: Color(0xFF5A3E2B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text("Your wishlist is empty", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// --- صفحة الطلبات ---
class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(color: Color(0xFF5A3E2B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text("No orders yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}