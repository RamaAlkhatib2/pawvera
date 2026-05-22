import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawvera/controllers/service_provider_controller.dart';

class OverviewTab extends StatefulWidget {
  final VoidCallback? onViewAllBookings;
  final VoidCallback? onManageServices;

  const OverviewTab({super.key, this.onViewAllBookings, this.onManageServices});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  static const Color primaryTeal = Color(0xFF2D6A64);
  static const Color textGrey = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProviderController>(
      builder: (context, ctrl, _) {
        if (ctrl.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final shop = ctrl.shop;
        final recentBookings = ctrl.bookings.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Stat Cards
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
                  '${ctrl.totalBookings}',
                  Icons.calendar_today_outlined,
                  primaryTeal,
                ),
                _buildStatCard(
                  'Active Bookings',
                  '${ctrl.activeBookings}',
                  Icons.inventory_2_outlined,
                  Colors.purple[300]!,
                ),
                _buildStatCard(
                  'Total Revenue',
                  '${ctrl.totalRevenue.toStringAsFixed(2)} JOD',
                  Icons.attach_money,
                  Colors.green[400]!,
                ),
                _buildStatCard(
                  'Active Services',
                  '${ctrl.activeServicesCount}',
                  Icons.content_cut_outlined,
                  Colors.orange[300]!,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Shop Status Section
            _buildSectionCard(
              title: 'Shop Status',
              rightWidget: _buildStatusBadge(
                shop?.status ?? 'Closed',
                (shop?.status == 'Open')
                    ? Colors.green
                    : (shop?.status == 'Busy' ? Colors.orange : Colors.red),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.storefront_outlined,
                    shop?.shopName ?? '',
                  ),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    shop?.address ?? '',
                  ),
                  _buildInfoRow(Icons.access_time, shop?.workingHours ?? ''),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildShopButton(
                          text: 'Open Shop',
                          isActive: shop?.status == 'Open',
                          onPressed: () => ctrl.setShopStatus('Open'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildShopButton(
                          text: 'Close Shop',
                          isActive: shop?.status == 'Closed',
                          onPressed: () => ctrl.setShopStatus('Closed'),
                          activeColor: Colors.red[400]!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Recent Bookings
            _buildSectionCard(
              title: 'Recent Bookings',
              child: Column(
                children: [
                  if (recentBookings.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'No bookings yet',
                        style: TextStyle(color: textGrey),
                      ),
                    )
                  else
                    ...recentBookings.map(
                      (b) => _buildListItem(
                        b.serviceName,
                        '${b.userName} - ${b.petName}',
                        b.status,
                        b.status == 'confirmed'
                            ? Colors.green
                            : b.status == 'pending'
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),
                  _buildViewAllButton('View All Bookings'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Active Services
            _buildSectionCard(
              title: 'Active Services',
              child: Column(
                children: [
                  if (ctrl.activeServices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'No active services',
                        style: TextStyle(color: textGrey),
                      ),
                    )
                  else
                    ...ctrl.activeServices.map(
                      (s) => _buildServiceItem(s.name, s.duration),
                    ),
                  const SizedBox(height: 8),
                  _buildManageServicesButton('Manage Services'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceItem(String name, String duration) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.content_cut_outlined,
              color: primaryTeal,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: const TextStyle(color: textGrey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                color: Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              ?rightWidget,
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
        color: color.withValues(alpha: 0.1),
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
        onPressed: () {
          widget.onViewAllBookings?.call();
        },
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

  Widget _buildManageServicesButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          widget.onManageServices?.call();
        },
        icon: const Icon(Icons.settings_outlined, size: 16),
        label: Text(
          text,
          style: const TextStyle(color: textGrey, fontSize: 12),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE0F2F1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
