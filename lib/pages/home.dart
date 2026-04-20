import 'package:flutter/material.dart';
import 'supplies_store.dart';
import 'profile_view.dart';
import 'my_pet_page.dart';
import 'notifications_page.dart';
import 'pet care pages/pet_care_page.dart';
import 'reminder.dart';
import 'adoption.dart';

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
      body: _selectedIndex == 4
          ? const ProfileView()
          : (_selectedIndex == 1 ? const MyPetPage() : _buildHomeContent()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

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
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsPage(),
              ),
            );
          },
          child: ClipOval(
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 15,
          runSpacing: 10,
          children: [
            _petAvatar('B', 'Buddy', Colors.brown.shade300),
            _petAvatar('W', 'Whiskers', Colors.orange.shade200),
            _addPetButton(),
          ],
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
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = 1;
        });
      },
      child: Column(
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
      ),
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReminderPage()),
                );
              },
              child: _serviceCard(
                title: 'Reminders',
                subtitle: 'Schedule pet tasks',
                icon: Icons.calendar_today,
                color: const Color(0xFFF4CFC6),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdoptionPage()),
                );
              },
              child: _serviceCard(
                title: 'Adoption',
                subtitle: 'Find new friends',
                icon: Icons.favorite_border,
                color: const Color(0xFFDFF6EF),
              ),
            ),

            // زر Pet Supplies
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SuppliesStore(),
                  ),
                );
              },
              child: _serviceCard(
                title: 'Pet Supplies',
                subtitle: 'Shop Now',
                icon: Icons.shopping_bag_outlined,
                color: const Color(0xFFF7EACD),
              ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PetCarePage()),
                );
              },
              child: _serviceCard(
                title: 'Pet Care',
                subtitle: 'Book Services',
                icon: Icons.pets_outlined,
                color: const Color(0xFFFDE0C8),
              ),
            ),

            _serviceCard(
              title: 'Doctor Appointments',
              subtitle: 'Book vet consults',
              icon: Icons.medical_services_outlined,
              color: const Color(0xFFD9F1F9),
            ),
            _serviceCard(
              title: 'Health Records',
              subtitle: 'Medical history',
              icon: Icons.receipt_long,
              color: const Color(0xFFE6F6F0),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF6B6B6B)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B3B34),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6E6E6E)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingReminderCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReminderPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4CFC6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Heartworm Medication',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Pet: Buddy\nJan 18, 2026 at 8:00 AM',
              style: TextStyle(color: Color(0xFF5B4A44)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF3AA78E),
      unselectedItemColor: const Color(0xFF9E9E9E),
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
