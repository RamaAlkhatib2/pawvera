import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ستحتاج لإضافة intl في pubspec.yaml لتنسيق التاريخ

class AuditTab extends StatefulWidget {
  const AuditTab({super.key});

  @override
  State<AuditTab> createState() => _AuditTabState();
}

class _AuditTabState extends State<AuditTab> {
  final Color primaryTeal = const Color(0xFF2D6A64);
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  // قائمة البيانات (في الواقع ستأتي من قاعدة البيانات)
  final List<Map<String, String>> allLogs = [
    {
      'action': 'Shop Opened',
      'details': 'Shop status changed to open',
      'date': '04/25/2026', // تنسيق موحد للبحث
      'displayDate': 'Apr 25, 2026 at 14:48',
    },
    {
      'action': 'Service Added',
      'details': 'New service "Full Grooming" added',
      'date': '04/24/2026',
      'displayDate': 'Apr 24, 2026 at 10:30',
    },
  ];

  // دالة لاختيار التاريخ
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryTeal, // لون الرأس والدائرة المختارة
              onPrimary: Colors.white,
              onSurface: Colors.black, // لون الأرقام
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // تصفية القائمة بناءً على التاريخ المختار
    List<Map<String, String>> filteredLogs = allLogs.where((log) {
      if (_selectedDate == null) return true;
      String formattedSelected = DateFormat(
        'MM/dd/yyyy',
      ).format(_selectedDate!);
      return log['date'] == formattedSelected;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search audit logs...",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // زر اختيار التاريخ
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDate == null
                          ? "mm/dd/yyyy"
                          : DateFormat('MM/dd/yyyy').format(_selectedDate!),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => setState(() => _selectedDate = null),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.red,
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

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Activity Log",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${filteredLogs.length}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        filteredLogs.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("No logs found for this date"),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredLogs.length,
                itemBuilder: (context, index) {
                  return _buildAuditCard(filteredLogs[index]);
                },
              ),
      ],
    );
  }

  Widget _buildAuditCard(Map<String, String> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            children: [
              Icon(Icons.storefront, size: 18, color: primaryTeal),
              const SizedBox(width: 8),
              Text(
                log['action']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            log['details']!,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                log['displayDate']!,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
