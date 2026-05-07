import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawvera/pages/sign_in_page.dart';
import 'package:pawvera/pages/home.dart';
import 'package:pawvera/pages/my_bookings_page.dart';
import 'package:pawvera/pages/notifications_page.dart';
import 'package:pawvera/services/database_service.dart';
import 'package:pawvera/pages/reminder.dart';

class ProfileView extends StatelessWidget {
  /// When provided (e.g. from [Home]), switches tab so the bottom nav stays visible.
  final VoidCallback? onOpenMyBookings;

  ProfileView({super.key, this.onOpenMyBookings});

  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    // الألوان المستخرجة من Figma
    const Color primaryTeal = Color(0xFF4FA091);
    const Color backgroundLight = Color(0xFFF7FBFB);
    const Color darkText = Color(0xFF5A3E2B);

    final bool isStandalone = onOpenMyBookings == null;

    return Scaffold(
      backgroundColor: backgroundLight,
      bottomNavigationBar: isStandalone
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: primaryTeal,
              unselectedItemColor: const Color(0xFF9E9E9E),
              currentIndex: 4,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const Home()));
                } else if (index == 1) {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const Home()));
                } else if (index == 3) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyBookingsPage()));
                }
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.pets_outlined), label: 'My Pets'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.message_outlined), label: 'Messages'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_outlined),
                    label: 'My Bookings'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            )
          : null,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _db.userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("User data not found"));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String fullName = userData['fullName'] ?? 'User';
            String email = userData['email'] ?? 'No email';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: darkText),
                  ),
                  const SizedBox(height: 20),

                  // 1. Header Card (Pet Owner Info)
                  _buildSectionCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundColor: Color(0xFFDFF3EE),
                              child: Icon(Icons.person_outline,
                                  size: 45, color: primaryTeal),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fullName,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: darkText)),
                                Text(email,
                                    style: TextStyle(
                                        color: Colors.grey.shade600)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => _EditProfileSheet(
                                  currentName: fullName,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Edit Profile',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),

              // 2. My Activity Section
              _buildSectionTitle('My Activity'),
              _buildSectionCard(
                child: Column(
                  children: [
                    _buildListTile(
                      Icons.access_time,
                      'My Bookings',
                      onTap: () {
                        if (onOpenMyBookings != null) {
                          onOpenMyBookings!();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyBookingsPage(),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(),
                    _buildListTile(
                      Icons.calendar_today_outlined,
                      'My Reminders',
                      trailingBadge: '1',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReminderScreen()),
                      ),
                    ),
                    const Divider(),
                    _buildListTile(Icons.description_outlined, 'Health Records'),
                  ],
                ),
              ),

              // 3. Settings Section
              _buildSectionTitle('Settings'),
              _buildSectionCard(
                child: Column(
                  children: [
                    _buildListTile(
                      Icons.notifications_none,
                      'Notifications',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    _buildListTile(Icons.lock_outline, 'Privacy'),
                    const Divider(),
                    _buildListTile(Icons.translate, 'Language', trailingText: 'English'),
                  ],
                ),
              ),

              // 4. Support Section
              _buildSectionTitle('Support'),
              _buildSectionCard(
                child: Column(
                  children: [
                    _buildListTile(Icons.help_outline, 'Help Center'),
                    const Divider(),
                    _buildListTile(Icons.mail_outline, 'Contact Us'),
                    const Divider(),
                    _buildListTile(Icons.info_outline, 'About'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 5. Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignInPage()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Logout',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ),
  ),
);
}

  // ويجيت لإنشاء الكرت المنحني لكل قسم
  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE0ECEB)),
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A3E2B))),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title, {
    String? trailingBadge,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF5A3E2B), size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingBadge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFE8F4F1), borderRadius: BorderRadius.circular(10)),
              child: Text(trailingBadge, style: const TextStyle(color: Color(0xFF4FA091), fontSize: 12)),
            ),
          if (trailingText != null)
            Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final String currentName;
  const _EditProfileSheet({required this.currentName});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'fullName': name});
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF4FA091);
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5A3E2B)),
          ),
          const SizedBox(height: 20),
          const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: const Color(0xFFF7FBFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: teal, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}