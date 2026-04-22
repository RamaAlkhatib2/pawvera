import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingPage extends StatefulWidget {
  final String serviceName, price, clinicName;
  const BookingPage({
    super.key,
    required this.serviceName,
    required this.price,
    required this.clinicName,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // متغيرات التحكم في الحالة
  DateTime _focusedDay = DateTime(2026, 4, 5);
  DateTime? _selectedDay;
  String? _selectedTime;

  final Color primaryGreen = const Color(0xFF5B9D8E);
  final Color fieldFillColor = const Color(0xFFF8FAF9);

  // قائمة الأوقات كما في التصميم
  final List<String> _timeSlots = [
    "9:00 AM",
    "9:30 AM",
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
    "12:00 PM",
    "12:30 PM",
    "1:00 PM",
    "1:30 PM",
    "2:00 PM",
    "2:30 PM",
    "3:00 PM",
    "3:30 PM",
    "4:00 PM",
    "4:30 PM",
    "5:00 PM",
    "5:30 PM",
    "6:00 PM",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Book Service",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بطاقة تفاصيل الخدمة العلوية
                  _buildServiceSummaryCard(),
                  const SizedBox(height: 20),

                  // 1. قسم اختيار التاريخ
                  _buildSectionHeader(
                    Icons.calendar_today_outlined,
                    "Select Date",
                  ),
                  const SizedBox(height: 12),
                  _buildCalendarCard(),

                  // 2. قسم اختيار الوقت (يظهر فقط عند اختيار تاريخ)
                  if (_selectedDay != null) ...[
                    const SizedBox(height: 25),
                    _buildSectionHeader(Icons.access_time, "Select Time"),
                    const SizedBox(height: 12),
                    _buildTimePickerGrid(),
                  ],

                  // 3. قسم معلومات الاتصال (يظهر فقط عند اختيار وقت)
                  if (_selectedTime != null) ...[
                    const SizedBox(height: 25),
                    _buildSectionHeader(
                      Icons.person_outline,
                      "Contact Information",
                    ),
                    const SizedBox(height: 12),
                    _buildContactForm(),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // زر التأكيد السفلي
          _buildBottomActionButton(),
        ],
      ),
    );
  }

  Widget _buildServiceSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.serviceName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                widget.clinicName,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Text(
                "Duration: 45 mins",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          Text(
            widget.price,
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black87),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _selectedTime = null;
          });
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: Color(0xFFE6A696),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          defaultTextStyle: const TextStyle(fontSize: 12),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        rowHeight: 40,
      ),
    );
  }

  Widget _buildTimePickerGrid() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _timeSlots.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedTime == _timeSlots[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedTime = _timeSlots[index]),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryGreen.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? primaryGreen : Colors.grey.shade200,
                ),
              ),
              child: Text(
                _timeSlots[index],
                style: TextStyle(
                  color: isSelected ? primaryGreen : Colors.black87,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildInputField("Your Name", "John Doe"),
          const SizedBox(height: 15),
          _buildInputField("Phone Number", "7XXXXXXXX", prefix: "+962 "),
          const SizedBox(height: 15),
          _buildInputField("Email Address", "john@example.com"),
          const SizedBox(height: 15),
          _buildDropdownField("Select Your Pet"),
          const SizedBox(height: 15),
          _buildInputField(
            "Special Requests (Optional)",
            "Any special instructions...",
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    String? prefix,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: fieldFillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: fieldFillColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text(
                "Choose a pet...",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              items: ["Buddy (Dog)", "Misty (Cat)"]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: (_selectedDay != null && _selectedTime != null)
              ? () {}
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Continue to Verification",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
