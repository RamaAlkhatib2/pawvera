import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawvera/pages/sign_in_page.dart';
import 'package:pawvera/pages/my_bookings_page.dart';
import 'package:pawvera/pages/notifications_page.dart';
import 'package:pawvera/pages/reminder.dart';
import 'package:pawvera/services/database_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  static const Color primaryTeal = Color(0xFF4FA091);
  static const Color darkText = Color(0xFF5A3E2B);
  static const Color backgroundLight = Color(0xFFF7FBFB);

  final DatabaseService _db = DatabaseService();

  // ── Edit Profile ──────────────────────────────────────────────────────────
  void _showEditProfile(Map<String, dynamic> userData) {
    final nameCtrl = TextEditingController(text: userData['fullName'] ?? '');
    final phoneCtrl = TextEditingController(text: userData['phone'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF7FBFB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (ctx, setSheet) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel',
                            style: TextStyle(color: primaryTeal)),
                      ),
                      const Text('Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      TextButton(
                        onPressed: saving
                            ? null
                            : () async {
                                setSheet(() => saving = true);
                                try {
                                  final uid = FirebaseAuth.instance.currentUser!.uid;
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .update({
                                    'fullName': nameCtrl.text.trim(),
                                    'phone': phoneCtrl.text.trim(),
                                  });
                                  if (ctx.mounted) Navigator.pop(ctx);
                                } catch (_) {
                                  setSheet(() => saving = false);
                                }
                              },
                        child: saving
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Save',
                                style: TextStyle(
                                    color: primaryTeal,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _sheetField('Full Name', nameCtrl, TextInputType.name),
                        const Divider(height: 1, indent: 16),
                        _sheetField('Phone', phoneCtrl, TextInputType.phone),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetField(String label, TextEditingController ctrl,
      TextInputType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Language',
            style: TextStyle(fontWeight: FontWeight.bold)),
        children: ['English', 'العربية'].map((lang) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx),
          child: Row(children: [
            Icon(
              lang == 'English'
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: primaryTeal, size: 18),
            const SizedBox(width: 10),
            Text(lang),
          ]),
        )).toList(),
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Privacy Policy',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            'PawVera collects only the information needed to provide pet care '
            'services. Your data is stored securely and never shared with third '
            'parties without your consent. You may request deletion of your '
            'account and data at any time by contacting support.',
            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: primaryTeal)),
          ),
        ],
      ),
    );
  }

  void _showHelpCenterDialog() {
    const faqs = [
      ('How do I book a service?',
          'Go to Pet Care → select a provider → choose a service and time.'),
      ('Can I cancel a booking?',
          'Visit My Bookings and tap the booking to manage it.'),
      ('How do I add a pet?',
          'Go to My Pets and tap the + button.'),
      ('How does the QR tag work?',
          'Open a pet profile, enable the QR code, and print or share it.'),
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Help Center',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: faqs.map((faq) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(faq.$1,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(faq.$2,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87, height: 1.4)),
                ],
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: primaryTeal)),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Contact Us',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _contactRow(Icons.email_outlined, 'support@pawvera.com'),
            const SizedBox(height: 10),
            _contactRow(Icons.phone_outlined, '+962 7X XXX XXXX'),
            const SizedBox(height: 10),
            _contactRow(Icons.access_time, 'Sun – Thu, 9 AM – 6 PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: primaryTeal)),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 18, color: primaryTeal),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _db.userData,
          builder: (context, snap) {
            final data =
                (snap.data?.data() as Map<String, dynamic>?) ?? {};
            final name = data['fullName'] as String? ?? 'Pet Owner';
            final email =
                FirebaseAuth.instance.currentUser?.email ?? '';

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

                  // Header card
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: darkText)),
                                  Text(email,
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showEditProfile(data),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Edit Profile',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // My Activity
                  _buildSectionTitle('My Activity'),
                  _buildSectionCard(
                    child: Column(
                      children: [
                        _buildListTile(
                          Icons.access_time, 'My Bookings',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const MyBookingsPage())),
                        ),
                        const Divider(),
                        _buildListTile(
                          Icons.calendar_today_outlined, 'My Reminders',
                          trailingBadge: '1',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const ReminderScreen())),
                        ),
                        const Divider(),
                        _buildListTile(
                            Icons.description_outlined, 'Health Records'),
                      ],
                    ),
                  ),

                  // Settings
                  _buildSectionTitle('Settings'),
                  _buildSectionCard(
                    child: Column(
                      children: [
                        _buildListTile(
                          Icons.notifications_none, 'Notifications',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const NotificationsPage())),
                        ),
                        const Divider(),
                        _buildListTile(Icons.lock_outline, 'Privacy',
                            onTap: _showPrivacyDialog),
                        const Divider(),
                        _buildListTile(Icons.translate, 'Language',
                            trailingText: 'English',
                            onTap: _showLanguageDialog),
                      ],
                    ),
                  ),

                  // Support
                  _buildSectionTitle('Support'),
                  _buildSectionCard(
                    child: Column(
                      children: [
                        _buildListTile(Icons.help_outline, 'Help Center',
                            onTap: _showHelpCenterDialog),
                        const Divider(),
                        _buildListTile(Icons.mail_outline, 'Contact Us',
                            onTap: _showContactDialog),
                        const Divider(),
                        _buildListTile(
                          Icons.info_outline, 'About',
                          onTap: () => showAboutDialog(
                            context: context,
                            applicationName: 'PawVera',
                            applicationVersion: '1.0.0',
                            applicationIcon: const Icon(Icons.pets,
                                color: primaryTeal, size: 40),
                            children: [
                              const Text(
                                'PawVera is your all-in-one pet care companion — '
                                'manage your pets, book services, set reminders, and more.',
                                style: TextStyle(fontSize: 13, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignInPage()),
                          (route) => false,
                        );
                        FirebaseAuth.instance.signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Logout',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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
      child: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkText)),
    );
  }

  Widget _buildListTile(IconData icon, String title,
      {String? trailingBadge, String? trailingText, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: darkText, size: 22),
      title: Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingBadge != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F4F1),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(trailingBadge,
                  style:
                      const TextStyle(color: primaryTeal, fontSize: 12)),
            ),
          if (trailingText != null)
            Text(trailingText,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 5),
          Icon(Icons.arrow_forward_ios,
              size: 14,
              color: onTap != null
                  ? Colors.grey
                  : Colors.grey.shade300),
        ],
      ),
      onTap: onTap,
    );
  }
}
