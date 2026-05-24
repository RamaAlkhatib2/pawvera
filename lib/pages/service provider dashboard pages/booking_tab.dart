import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawvera/controllers/service_provider_controller.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  String selectedFilter = 'All';
  String searchQuery = '';
  DateTime? selectedDate;

  static const Color primaryTeal = Color(0xFF2D6A64);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2028),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2D6A64)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProviderController>(
      builder: (context, ctrl, _) {
        final allBookings = ctrl.bookings;

        // Filter logic
        final filteredList = allBookings.where((booking) {
          bool matchesFilter =
              selectedFilter == 'All' ||
              booking.status.toLowerCase() == selectedFilter.toLowerCase();

          bool matchesSearch =
              booking.userName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              booking.petName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              booking.serviceName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );

          bool matchesDate =
              selectedDate == null ||
              booking.date == _formatDate(selectedDate!);

          return matchesFilter && matchesSearch && matchesDate;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter buttons with live counts
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('All', allBookings.length),
                  _buildFilterButton(
                    'Pending',
                    allBookings.where((b) => b.status == 'pending').length,
                  ),
                  _buildFilterButton(
                    'Confirmed',
                    allBookings.where((b) => b.status == 'confirmed').length,
                  ),
                  _buildFilterButton(
                    'Completed',
                    allBookings.where((b) => b.status == 'completed').length,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search + Date picker
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search by owner, pet, or service...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 120),
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: selectedDate != null
                          ? const Color(0xFF2D6A64)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selectedDate != null
                            ? const Color(0xFF2D6A64)
                            : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: selectedDate != null
                              ? Colors.white
                              : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.year}'
                              : 'mm/dd/yyyy',
                          style: TextStyle(
                            color: selectedDate != null
                                ? Colors.white
                                : Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        if (selectedDate != null) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setState(() => selectedDate = null),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bookings list
            if (ctrl.loading)
              const Center(child: CircularProgressIndicator())
            else if (filteredList.isEmpty)
              const Center(child: Text("No bookings found"))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final booking = filteredList[index];
                  return _buildBookingItem(booking, ctrl);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildFilterButton(String label, int count) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '($count)',
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(dynamic booking, ServiceProviderController ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0F2F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              _buildStatusBadge(booking.status),
            ],
          ),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.pets, booking.petName),
          _buildDetailRow(Icons.content_cut, booking.serviceName),
          _buildDetailRow(Icons.phone, booking.userPhone),
          if (booking.petBreed.isNotEmpty)
            _buildDetailRow(Icons.info_outline, 'Breed: ${booking.petBreed}'),
          _buildDetailRow(
            Icons.calendar_today,
            '${booking.date} at ${booking.time}',
          ),
          if (booking.notes != null && booking.notes.isNotEmpty)
            _buildDetailRow(Icons.notes, booking.notes),

          const Divider(height: 24),

          // Action buttons
          if (booking.status == 'pending' || booking.status == 'confirmed')
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        if (booking.status == 'pending') {
                          ctrl.updateBookingStatus(booking.id, 'confirmed');
                        } else if (booking.status == 'confirmed') {
                          ctrl.updateBookingStatus(booking.id, 'completed');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        booking.status == 'pending'
                            ? 'Confirm'
                            : 'Complete & Notify',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        ctrl.updateBookingStatus(booking.id, 'cancelled');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        booking.status == 'pending' ? 'Decline' : 'Cancel',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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

  Widget _buildDetailRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
