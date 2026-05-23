import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'supplies_store.dart';
import 'profile_view.dart';
import 'my_pet_page.dart';
import 'notifications_page.dart';
import 'pet care pages/pet_care_page.dart';
import 'reminder.dart';
import 'adoption.dart';
import 'my_bookings_page.dart';
import 'messages_page.dart';
import 'package:pawvera/services/database_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  int _selectedIndex = 0;
  final DatabaseService _db = DatabaseService();
  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    _db.checkAndFireDueReminderNotifications().catchError((_) {});
    // Check for due reminders every 10 seconds while the app is active
    _reminderTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _db.checkAndFireDueReminderNotifications().catchError((_) {});
    });
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // تعديل منطق عرض الصفحات ليشمل صفحة الحجوزات الجديدة
      body: _buildBody(),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // دالة لتحديد أي صفحة تظهر بناءً على الاختيار
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return const MyPetPage();
      case 2:
        return const MessagesPage(showBackButton: false);
      case 3:
        return const MyBookingsPage(standalone: false);
      case 4:
        return const ProfileView();
      case 0:
      default:
        return _buildHomeContent();
    }
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
            _buildServicesGrid(context),
            const SizedBox(height: 22),
            _buildUpcomingReminderCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.userData,
      builder: (context, snapshot) {
        String userName = "...";
        if (snapshot.hasData && snapshot.data!.exists) {
          userName = (snapshot.data!.data() as Map<String, dynamic>)['fullName'] ?? "User";
        }

        return Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.pets, color: Color(0xFF5B9D8E), size: 32),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5A3E2B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
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
        StreamBuilder<QuerySnapshot>(
          stream: _db.userPets,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final pets = snapshot.data?.docs ?? [];

            return Wrap(
              spacing: 15,
              runSpacing: 10,
              children: [
                ...pets.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _petAvatar(
                    (data['name'] as String? ?? 'P')[0].toUpperCase(),
                    data['name'] ?? 'Pet',
                    Colors.teal.shade300,
                    imagePath: data['imagePath'] as String?,
                  );
                }),
                _addPetButton(),
              ],
            );
          }
        ),
      ],
    );
  }

  Widget _petAvatar(String initial, String name, Color color,
      {String? imagePath}) {
    final hasImage = imagePath != null && imagePath.isNotEmpty;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color,
          backgroundImage: hasImage
              ? (kIsWeb
                  ? NetworkImage(imagePath) as ImageProvider
                  : FileImage(File(imagePath)))
              : null,
          child: hasImage
              ? null
              : Text(
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

 Widget _buildServicesGrid(BuildContext context) {
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
        clipBehavior: Clip.none,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 130,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        children: [
          // 1. Reminders
          _buildTappableServiceCard(
            context: context,
            screen: const ReminderScreen(), 
            title: 'Reminders',
            subtitle: 'Schedule pet tasks',
            icon: Icons.calendar_today,
            color: const Color(0xFFF4CFC6),
            iconColor: const Color(0xFFCF755A),
            imagePath: 'assets/icons/reminders.icon.png',
            imageWidth: 170,
            imageHeight: 170,
            imageRight: -18,
            imageBottom: -18,
            imageOffsetX: 40,
          ),
          // 2. Adoption
          _buildTappableServiceCard(
            context: context,
            screen: AdoptionScreen(),
            title: 'Adoption',
            subtitle: 'Find new friends',
            icon: Icons.favorite_border,
            color: const Color(0xFFDFF6EF),
            iconColor: const Color(0xFF4C9B8C),
            imagePath: 'assets/icons/adoption.icon.png',
            imageWidth: 112,
            imageHeight: 112,
            imageRight: 0,
            imageBottom: -18,
          ),
          // 3. Pet Supplies
          _buildTappableServiceCard(
            context: context,
            screen: const SuppliesStore(),
            title: 'Pet Supplies',
            subtitle: 'Shop Now',
            icon: Icons.shopping_bag_outlined,
            color: const Color(0xFFF7EACD),
            iconColor: const Color(0xFFD09A3A),
            imagePath: 'assets/icons/pet_supplies.icon.png',
            imageWidth: 138,
            imageHeight: 138,
            imageRight: -16,
            imageBottom: -44,
            imageOffsetX: 20,
          ),
          // 4. Pet Care
          _buildTappableServiceCard(
            context: context,
            screen: const PetCarePage(),
            title: 'Pet Care',
            subtitle: 'Book Services',
            icon: Icons.pets_outlined,
            color: const Color(0xFFFDE0C8),
            iconColor: const Color(0xFFE08C52),
            imagePath: 'assets/icons/pet_care.icon.png',
            imageWidth: 172,
            imageHeight: 172,
            imageRight: -16,
            imageBottom: -34,
            imageOffsetX: 20,
          ),
          // 5. Doctor Appointments (بدون استجابة عند الكبس)
          _serviceCard(
            title: 'Doctor Appointments',
            subtitle: 'Book vet consults',
            icon: Icons.medical_services_outlined,
            color: const Color(0xFFD9F1F9),
            iconColor: const Color(0xFF4A9BA4),
          ),
          // 6. Health Records
          _serviceCard(
            title: 'Health Records',
            subtitle: 'Medical history',
            icon: Icons.receipt_long,
            color: const Color(0xFFD9F1F9),
            iconColor: const Color(0xFF4A9BA4),
            imagePath: 'assets/icons/health_records.icon.png',
            imageWidth: 148,
            imageHeight: 148,
            imageRight: -16,
            imageBottom: -48,
            imageOffsetX: 20,
          ),
        ],
      ),
    ],
  );
}

// دالة بناء الكرت الأساسية (تأكدي أن هذه الدالة موجودة تحت الدالة السابقة مباشرة)
Widget _serviceCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  Color iconColor = const Color(0xFF6B6B6B),
  String? imagePath,
  double imageWidth = 92,
  double imageHeight = 92,
  double imageRight = -10,
  double imageBottom = -8,
  double imageOffsetX = 0,
  double imageOffsetY = 0,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
        ),
        if (imagePath != null)
          Positioned(
            bottom: imageBottom,
            right: imageRight,
            child: Transform.translate(
              offset: Offset(imageOffsetX, imageOffsetY),
              child: Image.asset(
                imagePath,
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6A4529),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6E5C4D)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// دالة المساعدة لجعل الكرت قابلاً للضغط
Widget _buildTappableServiceCard({
  required BuildContext context,
  required Widget screen,
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  Color iconColor = const Color(0xFF6B6B6B),
  String? imagePath,
  double imageWidth = 92,
  double imageHeight = 92,
  double imageRight = -10,
  double imageBottom = -8,
  double imageOffsetX = 0,
  double imageOffsetY = 0,
}) {
  return GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
    child: _serviceCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      iconColor: iconColor,
      imagePath: imagePath,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      imageRight: imageRight,
      imageBottom: imageBottom,
      imageOffsetX: imageOffsetX,
      imageOffsetY: imageOffsetY,
    ),
  );
}
  Widget _buildUpcomingReminderCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.reminders,
      builder: (context, snapshot) {
        final now = DateTime.now();
        final docs = snapshot.data?.docs ?? [];

        // Find the first upcoming reminder (dateTime >= now), sorted ascending
        final upcoming = docs
            .map((d) {
              final data = d.data() as Map<String, dynamic>;
              final ts = data['dateTime'] as Timestamp?;
              return {...data, '_dt': ts?.toDate() ?? now};
            })
            .where((r) => !(r['_dt'] as DateTime).isBefore(now))
            .toList()
          ..sort((a, b) =>
              (a['_dt'] as DateTime).compareTo(b['_dt'] as DateTime));

        final next = upcoming.isNotEmpty ? upcoming.first : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Reminders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5A3E2B),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReminderScreen()),
              ),
              child: next == null
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4CFC6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'No upcoming reminders',
                        style: TextStyle(
                          color: Color(0xFF5B4A44),
                          fontSize: 13,
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4CFC6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  next['title']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF5B4A44),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Pet: ${next['petName'] ?? ''}',
                                  style: const TextStyle(
                                    color: Color(0xFF5B4A44),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatReminderDate(next['_dt'] as DateTime),
                                  style: TextStyle(
                                    color: Colors.brown[600],
                                    fontSize: 11,
                                  ),
                                ),
                                if ((next['notes'] ?? '').toString().isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    next['notes'].toString(),
                                    style: const TextStyle(
                                      color: Color(0xFF5B4A44),
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if ((next['type'] ?? '').toString().isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                next['type'].toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5B4A44),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  String _formatReminderDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$minute $ampm';
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
