import 'package:flutter/material.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  // حالة المحل (مفتوح أو مغلق)
  bool isShopOpen = true;

  static const Color primaryTeal = Color(0xFF2D6A64);
  static const Color textGrey = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. الكروت الأربعة العلوية
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(
              'Total Bookings',
              '4',
              Icons.calendar_today_outlined,
              primaryTeal,
            ),
            _buildStatCard(
              'Active Bookings',
              '3',
              Icons.inventory_2_outlined,
              Colors.purple[300]!,
            ),
            _buildStatCard(
              'Total Revenue',
              '\$45.00',
              Icons.attach_money,
              Colors.green[400]!,
            ),
            _buildStatCard(
              'Active Services',
              '3/3',
              Icons.content_cut_outlined,
              Colors.orange[300]!,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2. قسم حالة المحل (Shop Status)
        _buildSectionCard(
          title: 'Shop Status',
          rightWidget: _buildStatusBadge(
            isShopOpen ? 'OPEN' : 'CLOSED',
            isShopOpen ? Colors.green : Colors.red,
          ),
          child: Column(
            children: [
              _buildInfoRow(Icons.storefront_outlined, 'Pawfect Spa'),
              _buildInfoRow(
                Icons.location_on_outlined,
                '123 Main St, Downtown',
              ),
              _buildInfoRow(Icons.access_time, '9:00 AM - 7:00 PM'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildShopButton(
                      text: 'Open Shop',
                      isActive: isShopOpen,
                      onPressed: () => setState(() => isShopOpen = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildShopButton(
                      text: 'Close Shop',
                      isActive: !isShopOpen,
                      onPressed: () => setState(() => isShopOpen = false),
                      activeColor: Colors.red[400]!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. الحجوزات الأخيرة
        _buildSectionCard(
          title: 'Recent Bookings',
          child: Column(
            children: [
              _buildListItem(
                'Full Grooming Package',
                'Sarah Johnson - Max',
                'Confirmed',
                Colors.green,
              ),
              _buildListItem(
                'Basic Bath & Brush',
                'Mike Brown - Luna',
                'Pending',
                Colors.orange,
              ),
              _buildViewAllButton('View All Bookings'),
            ],
          ),
        ),
      ],
    );
  }

  // --- الويدجت الفرعية (الميثودات) ---

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: textGrey, fontSize: 12),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    Widget? rightWidget,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (rightWidget != null) rightWidget,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildShopButton({
    required String text,
    required bool isActive,
    required VoidCallback onPressed,
    Color activeColor = const Color(0xFF2D6A64),
  }) {
    return SizedBox(
      height: 40,
      child: isActive
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(color: textGrey, fontSize: 13),
              ),
            ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: textGrey)),
        ],
      ),
    );
  }

  Widget _buildListItem(
    String title,
    String subTitle,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                subTitle,
                style: const TextStyle(color: textGrey, fontSize: 11),
              ),
            ],
          ),
          _buildStatusBadge(status, statusColor),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE0F2F1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: textGrey, fontSize: 12),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE0F2F1)),
    );
  }
}
