import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawvera/controllers/service_provider_controller.dart';
import 'package:pawvera/pages/service%20provider%20dashboard%20pages/audit_tab.dart';
import 'package:pawvera/pages/service%20provider%20dashboard%20pages/booking_tab.dart';
import 'package:pawvera/pages/service%20provider%20dashboard%20pages/services_tab.dart';
import 'package:pawvera/pages/service%20provider%20dashboard%20pages/shop_info_tab.dart';
import 'package:pawvera/pages/service%20provider%20dashboard%20pages/offers_tab.dart';
import 'package:pawvera/pages/sign_in_page.dart';
import 'overview_tab.dart';

class ServiceProviderDashboard extends StatefulWidget {
  const ServiceProviderDashboard({super.key});

  @override
  State<ServiceProviderDashboard> createState() =>
      _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends State<ServiceProviderDashboard> {
  String _selectedTab = 'Overview';

  final Color primaryTeal = const Color(0xFF2D6A64);
  final Color bgGrey = const Color(0xFFF8FBFB);

  @override
  void initState() {
    super.initState();
    // Initialize the controller after build so Provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProviderController>().init();
    });
  }

  void _showProfileDialog() {
    final ctrl = context.read<ServiceProviderController>();
    final shop = ctrl.shop;

    final TextEditingController nameController = TextEditingController(
      text: shop?.shopName ?? "",
    );
    final TextEditingController emailController = TextEditingController(
      text: shop?.email ?? "",
    );
    final TextEditingController phoneController = TextEditingController(
      text: shop?.phone ?? "",
    );
    final TextEditingController businessController = TextEditingController(
      text: shop?.shopName ?? "",
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "My Profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Update your personal information and account details",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 15),
              _buildProfileField("Full Name", nameController),
              _buildProfileField("Email", emailController),
              _buildProfileField("Phone", phoneController),
              _buildProfileField("Business Name", businessController),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text("Change Password"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final ctrl = context.read<ServiceProviderController>();
              await ctrl.updateShopInfo(
                shopName: businessController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryTeal),
            child: const Text(
              "Save Changes",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: primaryTeal.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
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
                        Consumer<ServiceProviderController>(
                          builder: (context, ctrl, _) {
                            return Text(
                              ctrl.shop?.shopName ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF2D6A64),
                      size: 28,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    onSelected: (value) {
                      if (value == 'profile') {
                        _showProfileDialog();
                      } else if (value == 'logout') {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInPage(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 20,
                              color: Colors.black87,
                            ),
                            SizedBox(width: 10),
                            Text('Profile', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 20, color: Colors.black87),
                            SizedBox(width: 10),
                            Text('Logout', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
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
                    _buildTabItem('Offers', Icons.local_offer_outlined),
                    _buildTabItem('Audit', Icons.assignment_outlined),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Content
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

  Widget _buildCurrentTabContent() {
    switch (_selectedTab) {
      case 'Overview':
        return OverviewTab(
          onViewAllBookings: () {
            setState(() {
              _selectedTab = 'Bookings';
            });
          },
          onManageServices: () {
            setState(() {
              _selectedTab = 'Services';
            });
          },
        );
      case 'Bookings':
        return const BookingsTab();
      case 'Services':
        return const ServicesTab();
      case 'Shop Info':
        return const ShopInfoTab();
      case 'Offers':
        return const OffersTab();
      case 'Audit':
        return const AuditTab();
      default:
        return const Center(child: Text('Coming Soon...'));
    }
  }
}
