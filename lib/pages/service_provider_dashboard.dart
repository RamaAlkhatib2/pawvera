import 'package:flutter/material.dart';
import 'login_view.dart';

class ServiceProviderDashboard extends StatefulWidget {
  final String providerType;

  const ServiceProviderDashboard({super.key, required this.providerType});

  @override
  State<ServiceProviderDashboard> createState() =>
      _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends State<ServiceProviderDashboard> {
  int _selectedTabIndex = 0;
  bool _isShopOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 25),
                _buildTabBar(),
                const SizedBox(height: 20),
                _buildTabContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Provider',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dashboard',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF634732),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.providerType,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'profile') {
              // Navigate to profile page
            } else if (value == 'logout') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, size: 20, color: Color(0xFF634732)),
                  SizedBox(width: 8),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFDFF3EE),
            ),
            child: const Icon(Icons.more_vert, color: Color(0xFF5B9D8E)),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Overview', 'Bookings', 'Services', 'Shop'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5B9D8E) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey[300]!),
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _getTabIcon(index),
                      size: 18,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  IconData _getTabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.calendar_today;
      case 2:
        return Icons.miscellaneous_services;
      case 3:
        return Icons.store;
      default:
        return Icons.dashboard;
    }
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildBookingsTab();
      case 2:
        return _buildServicesTab();
      case 3:
        return _buildShopTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Bookings',
                value: '4',
                icon: Icons.calendar_today,
                backgroundColor: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Active Bookings',
                value: '3',
                icon: Icons.check_circle,
                backgroundColor: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Revenue',
                value: '\$45.00',
                icon: Icons.attach_money,
                backgroundColor: const Color(0xFFF0F4F3),
                iconColor: const Color(0xFF5B9D8E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Active Services',
                value: '3/3',
                icon: Icons.miscellaneous_services,
                backgroundColor: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Shop Status Card
        _buildShopStatusCard(),
        const SizedBox(height: 20),
        // Recent Bookings
        _buildRecentBookingsSection(),
        const SizedBox(height: 20),
        // Active Services
        _buildActiveServicesSection(),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF634732),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shop Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF634732),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isShopOpen ? const Color(0xFF4CAF50) : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isShopOpen ? 'OPEN' : 'CLOSED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Pawfect Spa',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                '123 Main St, Downtown',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                '9:00 AM - 7:00 PM',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isShopOpen = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF5B9D8E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Open Shop',
                    style: TextStyle(
                      color: Color(0xFF5B9D8E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isShopOpen = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9D8E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Close Shop',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookingsSection() {
    final bookings = [
      {
        'service': 'Full Grooming Package',
        'client': 'Sarah Johnson - Max',
        'status': 'confirmed',
      },
      {
        'service': 'Basic Bath & Brush',
        'client': 'Mike Brown - Luna',
        'status': 'pending',
      },
      {
        'service': 'Nail Trim Only',
        'client': 'Emily Davis - Charlie',
        'status': 'confirmed',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Bookings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF634732),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
              child: const Text(
                'View All Bookings',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5B9D8E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: List.generate(
              bookings.length,
              (index) {
                final booking = bookings[index];
                final isConfirmed = booking['status'] == 'confirmed';
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < bookings.length - 1 ? 12 : 0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking['service']!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF634732),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  booking['client']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isConfirmed
                                  ? const Color(0xFF4CAF50)
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isConfirmed ? 'confirmed' : 'pending',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (index < bookings.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Divider(color: Colors.grey[200]),
                        ),
                    ],
                  ),
                );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveServicesSection() {
    final services = [
      {'name': 'Full Grooming Package', 'duration': '2 hours', 'price': '\$45'},
      {'name': 'Basic Bath & Brush', 'duration': '1 hour', 'price': '\$30'},
      {'name': 'Nail Trim Only', 'duration': '30 minutes', 'price': '\$15'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Services',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF634732),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 2;
                });
              },
              child: const Text(
                'Manage Services',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5B9D8E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: List.generate(
              services.length,
              (index) {
                final service = services[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < services.length - 1 ? 12 : 0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['name']!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF634732),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  service['duration']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            service['price']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                      if (index < services.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Divider(color: Colors.grey[200]),
                        ),
                    ],
                  ),
                );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Center(
            child: Text(
              'Bookings management coming soon',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Center(
            child: Text(
              'Services management coming soon',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Center(
            child: Text(
              'Shop management coming soon',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
