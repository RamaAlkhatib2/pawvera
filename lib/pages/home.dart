import 'package:flutter/material.dart';
import 'my_pet_page.dart'; // تأكدي من استيراد الصفحة الجديدة هنا

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // التعديل الأساسي هنا: فحص الـ Index المختار
      body: _selectedIndex == 1
          ? const MyPetPage() // إذا اخترتِ My Pets (index 1) تفتح هذه الصفحة
          : _buildHomeContent(), // غير ذلك تظهر محتويات الصفحة الرئيسية
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // قمت بنقل محتوى الصفحة الرئيسية لميثود منفصلة ليبقى الكود منظماً
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildMyPetsRow(),
            const SizedBox(height: 20),
            _buildServicesGrid(),
            const SizedBox(height: 22),
            _buildUpcomingReminderCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFDFF3EE),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pets, color: Color(0xFF3AA78E), size: 34),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PawVera',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5A3E2B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Where Every Paw Matters',
              style: TextStyle(fontSize: 12, color: Color(0xFF8A7A6C)),
            ),
          ],
        ),
        const Spacer(),
        ClipOval(
          child: Container(
            width: 38,
            height: 38,
            color: const Color(0xFFDDEEEA),
            child: const Icon(
              Icons.notifications_none,
              size: 20,
              color: Color(0xFF6B6B6B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyPetsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Pets',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 74,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _petAvatar('B', 'Buddy', Colors.brown.shade300),
              const SizedBox(width: 12),
              _petAvatar('W', 'Whiskers', Colors.orange.shade200),
              const SizedBox(width: 12),
              _addPetButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _petAvatar(String initial, String name, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color,
          child: Text(
            initial,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _addPetButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFFDFF3EE),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Color(0xFF3AA78E)),
        ),
        const SizedBox(height: 6),
        const SizedBox(
          width: 64,
          child: Text(
            'Add Pet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 120,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          children: [
            _serviceCard(
              title: 'Reminders',
              subtitle: 'Schedule pet tasks',
              icon: Icons.calendar_today,
              color: const Color(0xFFF4CFC6),
              badgeAsset: 'assets/icons/reminders.icon.png',
              illustrationAsset: 'assets/icons/reminders.icon.png',
            ),
            _serviceCard(
              title: 'Adoption',
              subtitle: 'Find new friends',
              icon: Icons.favorite_border,
              color: const Color(0xFFDFF6EF),
              badgeAsset: 'assets/icons/adoption.icon.png',
              illustrationAsset: 'assets/icons/adoption.icon.png',
            ),
            _serviceCard(
              title: 'Pet Supplies',
              subtitle: 'Shop Now',
              icon: Icons.shopping_bag_outlined,
              color: const Color(0xFFF7EACD),
              badgeAsset: 'assets/icons/pet_supplies.icon.png',
              illustrationAsset: 'assets/icons/pet_supplies.icon.png',
            ),
            _serviceCard(
              title: 'Pet Care',
              subtitle: 'Book Services',
              icon: Icons.pets_outlined,
              color: const Color(0xFFFDE0C8),
              badgeAsset: 'assets/icons/pet_care.icon.png',
              illustrationAsset: 'assets/icons/pet_care.icon.png',
            ),
            _serviceCard(
              title: 'Doctor Appointments',
              subtitle: 'Book vet consults',
              icon: Icons.medical_services_outlined,
              color: const Color(0xFFD9F1F9),
              badgeAsset: 'assets/icons/health_records.icon.png',
              illustrationAsset: 'assets/icons/health_records.icon.png',
            ),
            _serviceCard(
              title: 'Health Records',
              subtitle: 'Medical history',
              icon: Icons.receipt_long,
              color: const Color(0xFFE6F6F0),
              badgeAsset: 'assets/icons/health_records.icon.png',
              illustrationAsset: 'assets/icons/health_records.icon.png',
            ),
          ],
        ),
      ],
    );
  }

  Widget _serviceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? badgeAsset,
    String? illustrationAsset,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: badgeAsset != null
                        ? Image.asset(
                            badgeAsset,
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              icon,
                              size: 20,
                              color: const Color(0xFF6B6B6B),
                            ),
                          )
                        : Icon(icon, size: 20, color: const Color(0xFF6B6B6B)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4B3B34),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6E6E6E),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (illustrationAsset != null)
              Positioned(
                right: -6,
                bottom: -6,
                child: Image.asset(
                  illustrationAsset,
                  width: 76,
                  height: 76,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingReminderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4CFC6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Heartworm Medication',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Medication', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Pet: Buddy\nJan 18, 2026 at 8:00 AM',
            style: TextStyle(color: Color(0xFF5B4A44)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monthly heartworm prevention pill',
            style: TextStyle(color: Color(0xFF6B635E)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF3AA78E),
      unselectedItemColor: const Color(0xFF9E9E9E),
      showUnselectedLabels: true,
      onTap: (i) => setState(() => _selectedIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets_outlined),
          label: 'My Pets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'My Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
