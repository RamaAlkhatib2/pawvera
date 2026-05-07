import 'package:flutter/material.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  // الحالة الحالية للفلتر والبحث
  String selectedFilter = 'All';
  String searchQuery = '';

  // قائمة الحجوزات التفاعلية
  List<Map<String, dynamic>> allBookings = [
    {
      'name': 'Sarah Johnson',
      'pet': 'Max',
      'service': 'Full Grooming Package',
      'date': 'Jan 05, 2026',
      'time': '10:00 AM',
      'status': 'confirmed',
    },
    {
      'name': 'Mike Brown',
      'pet': 'Luna',
      'service': 'Basic Bath & Brush',
      'date': 'Jan 05, 2026',
      'time': '02:00 PM',
      'status': 'pending',
    },
    {
      'name': 'Emily Davis',
      'pet': 'Charlie',
      'service': 'Nail Trim Only',
      'date': 'Jan 06, 2026',
      'time': '11:00 AM',
      'status': 'confirmed',
    },
    {
      'name': 'David Wilson',
      'pet': 'Bella',
      'service': 'Full Grooming Package',
      'date': 'Jan 03, 2026',
      'time': '03:00 PM',
      'status': 'completed',
    },
  ];

  static const Color primaryTeal = Color(0xFF2D6A64);

  @override
  Widget build(BuildContext context) {
    // منطق التصفية (فلتر الحالة + نص البحث)
    final filteredList = allBookings.where((booking) {
      bool matchesFilter =
          selectedFilter == 'All' ||
          booking['status'].toLowerCase() == selectedFilter.toLowerCase();

      bool matchesSearch =
          booking['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          booking['pet'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          booking['service'].toLowerCase().contains(searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. أزرار الفلترة العلوية مع الأعداد التفاعلية
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterButton('All', allBookings.length),
              _buildFilterButton(
                'Pending',
                allBookings.where((b) => b['status'] == 'pending').length,
              ),
              _buildFilterButton(
                'Confirmed',
                allBookings.where((b) => b['status'] == 'confirmed').length,
              ),
              _buildFilterButton(
                'Completed',
                allBookings.where((b) => b['status'] == 'completed').length,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. خانة البحث
        TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search by owner, pet, or service...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
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
        const SizedBox(height: 20),

        // 3. قائمة الحجوزات التفاعلية
        filteredList.isEmpty
            ? const Center(child: Text("No bookings found"))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final booking = filteredList[index];
                  // نحتاج نلاقي الاندكس الحقيقي في القائمة الأصلية عشان نعدل الحالة
                  int originalIndex = allBookings.indexOf(booking);
                  return _buildBookingItem(booking, originalIndex);
                },
              ),
      ],
    );
  }

  // ويدجت زر الفلتر
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

  // ويدجت الحجز الفردي مع الأزرار التفاعلية
  // ويدجت الحجز الفردي مع الأزرار التفاعلية المحدثة
  Widget _buildBookingItem(Map<String, dynamic> booking, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0F2F1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${booking['pet']} - ${booking['service']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              _buildStatusBadge(booking['status']),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                booking['date'],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(width: 12),
              Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                booking['time'],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),

          // منطقة الأزرار التفاعلية المحدثة
          if (booking['status'] == 'pending' ||
              booking['status'] == 'confirmed')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  // الزر الأساسي (Confirm أو Complete)
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (booking['status'] == 'pending') {
                              allBookings[index]['status'] = 'confirmed';
                            } else if (booking['status'] == 'confirmed') {
                              allBookings[index]['status'] = 'completed';
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          booking['status'] == 'pending'
                              ? 'Confirm'
                              : 'Complete',
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
                  // الزر الثانوي (Decline أو Cancel)
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            allBookings[index]['status'] = 'cancelled';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          booking['status'] == 'pending' ? 'Decline' : 'Cancel',
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
