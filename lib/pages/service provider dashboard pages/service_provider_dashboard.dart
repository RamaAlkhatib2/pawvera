import 'package:flutter/material.dart';
import 'package:pawvera/pages/service%20provider%20dashboard%20pages/audit_tab.dart';
import 'package:pawvera/pages/service%20provider%20dashboard%20pages/booking_tab.dart';
import 'package:pawvera/pages/service%20provider%20dashboard%20pages/services_tab.dart';
import 'package:pawvera/pages/service%20provider%20dashboard%20pages/shop_info_tab.dart';
import 'package:pawvera/pages/service%20provider%20dashboard%20pages/offers_tab.dart'; // 1. استيراد ملف العروض
import 'overview_tab.dart';

class ServiceProviderDashboard extends StatefulWidget {
  const ServiceProviderDashboard({super.key, required String providerType});

  @override
  State<ServiceProviderDashboard> createState() =>
      _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends State<ServiceProviderDashboard> {
  String _selectedTab = 'Overview';

  final Color primaryTeal = const Color(0xFF2D6A64);
  final Color bgGrey = const Color(0xFFF8FBFB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. العنوان الثابت العلوي وأزرار الملف الشخصي
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Provider',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D6A64),
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D6A64),
                        ),
                      ),
                      Text(
                        'Pawfect Spa',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildHeaderButton(Icons.person_outline, 'Profile'),
                      const SizedBox(width: 8),
                      _buildHeaderButton(Icons.logout, 'Logout'),
                    ],
                  ),
                ],
              ),
            ),

            // 2. شريط التبويبات (Tabs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabItem('Overview', Icons.grid_view),
                    _buildTabItem('Bookings', Icons.calendar_today),
                    _buildTabItem('Services', Icons.content_cut),
                    _buildTabItem('Shop Info', Icons.storefront_outlined),
                    _buildTabItem(
                      'Offers',
                      Icons.local_offer_outlined,
                    ), // هذا التبويب أصبح فعالاً الآن
                    _buildTabItem('Audit', Icons.assignment_outlined),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. المحتوى (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCurrentTabContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, IconData icon) {
    bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryTeal : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // الميثود المسؤولة عن عرض المحتوى - تم ربط Offers هنا
  Widget _buildCurrentTabContent() {
    switch (_selectedTab) {
      case 'Overview':
        return const OverviewTab();
      case 'Bookings':
        return const BookingsTab();
      case 'Services':
        return const ServicesTab();
      case 'Shop Info':
        return const ShopInfoTab();
      case 'Offers':
        return const OffersTab();
      case 'Audit': // إضافة الحالة هنا
        return const AuditTab();
      default:
        return const Center(child: Text('Coming Soon...'));
    }
  }
}
