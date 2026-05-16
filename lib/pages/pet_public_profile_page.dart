import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetPublicProfilePage extends StatelessWidget {
  final String ownerUid;
  final String petId;

  const PetPublicProfilePage({
    super.key,
    required this.ownerUid,
    required this.petId,
  });

  Future<Map<String, dynamic>?> _loadPet() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerUid)
          .collection('pets')
          .doc(petId)
          .get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadPet(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5B9D8E)));
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _buildNotFound();
          }
          return _buildProfile(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Pet profile not found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'This QR tag may have been deactivated or removed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _pawVeraBadge(),
        ],
      ),
    );
  }

  Widget _buildProfile(Map<String, dynamic> pet) {
    final name = (pet['name'] ?? '').toString();
    final breed = (pet['breed'] ?? '').toString();
    final type = (pet['type'] ?? '').toString();
    final age = _formatAge(pet);
    final gender = (pet['gender'] ?? '').toString();
    final color = (pet['color'] ?? '').toString();
    final weight = (pet['weight'] ?? '').toString();
    final ownerName = (pet['ownerName'] ?? '').toString();
    final ownerPhone = (pet['ownerPhone'] ?? '').toString();
    final ownerEmail = (pet['ownerEmail'] ?? '').toString();
    final medicalInfo = (pet['medicalInfo'] ?? '').toString();
    final allergies = (pet['allergies'] ?? '').toString();

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF5B9D8E),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pets, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  name.isNotEmpty ? name : 'Unknown Pet',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (breed.isNotEmpty || type.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    [breed, type].where((s) => s.isNotEmpty).join(' · '),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🐾  Found this pet? Contact the owner below!',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Owner Contact ────────────────────────────────────────────────────
          _buildCard(
            icon: Icons.person_outline,
            title: 'Owner Contact',
            children: [
              if (ownerName.isNotEmpty) _buildInfoRow(Icons.badge_outlined, 'Name', ownerName),
              if (ownerPhone.isNotEmpty) _buildInfoRow(Icons.phone_outlined, 'Phone', ownerPhone, highlight: true),
              if (ownerEmail.isNotEmpty) _buildInfoRow(Icons.email_outlined, 'Email', ownerEmail, highlight: true),
              if (ownerName.isEmpty && ownerPhone.isEmpty && ownerEmail.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No contact info added yet.', style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),

          // ── Pet Details ──────────────────────────────────────────────────────
          _buildCard(
            icon: Icons.info_outline,
            title: 'Pet Details',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (type.isNotEmpty) _buildChip(type, Icons.category_outlined),
                  if (gender.isNotEmpty) _buildChip(gender, Icons.transgender),
                  if (age.isNotEmpty) _buildChip(age, Icons.calendar_today_outlined),
                  if (color.isNotEmpty) _buildChip(color, Icons.palette_outlined),
                  if (weight.isNotEmpty) _buildChip('${weight}kg', Icons.monitor_weight_outlined),
                ],
              ),
            ],
          ),

          // ── Health Info ──────────────────────────────────────────────────────
          _buildCard(
            icon: Icons.medical_information_outlined,
            title: 'Health Information',
            children: [
              if (medicalInfo.isNotEmpty && medicalInfo.toLowerCase() != 'none')
                _buildInfoRow(Icons.vaccines_outlined, 'Medical Info', medicalInfo),
              if (allergies.isNotEmpty && allergies.toLowerCase() != 'none')
                _buildInfoRow(Icons.warning_amber_outlined, 'Allergies', allergies),
              if ((medicalInfo.isEmpty || medicalInfo.toLowerCase() == 'none') &&
                  (allergies.isEmpty || allergies.toLowerCase() == 'none'))
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No health info recorded.', style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),

          const SizedBox(height: 16),
          _pawVeraBadge(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF5B9D8E), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF5B9D8E),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: highlight ? const Color(0xFF5B9D8E) : const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5B9D8E).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF5B9D8E)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5B9D8E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pawVeraBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.pets, size: 14, color: Color(0xFF5B9D8E)),
        const SizedBox(width: 6),
        const Text(
          'Powered by PawVera',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  String _formatAge(Map<String, dynamic> pet) {
    final value = (pet['ageValue'] ?? '').toString().trim();
    final unit = (pet['ageUnit'] ?? '').toString().trim();
    if (value.isNotEmpty && unit.isNotEmpty) return '$value $unit';

    final age = (pet['age'] ?? '').toString().trim();
    return age;
  }
}
