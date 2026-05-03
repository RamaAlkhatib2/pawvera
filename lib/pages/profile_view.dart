import 'package:flutter/material.dart';
import 'package:pawvera/pages/login_view.dart';
import 'package:pawvera/pages/my_bookings_page.dart';
import 'package:pawvera/pages/notifications_page.dart';

class ProfileView extends StatelessWidget {
  /// When provided (e.g. from [Home]), switches tab so the bottom nav stays visible.
  final VoidCallback? onOpenMyBookings;

  const ProfileView({super.key, this.onOpenMyBookings});

  @override
  Widget build(BuildContext context) {
    // الألوان المستخرجة من Figma
    const Color primaryTeal = Color(0xFF4FA091);
    const Color backgroundLight = Color(0xFFF7FBFB);
    const Color darkText = Color(0xFF5A3E2B);

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkText),
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
                          child: Icon(Icons.person_outline, size: 45, color: primaryTeal),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pet Owner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                            Text('hhh@gmail.com', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                    _buildListTile(Icons.calendar_today_outlined, 'My Reminders', trailingBadge: '1'),
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
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginView()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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