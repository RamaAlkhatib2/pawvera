import 'dart:async';
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
  DateTime _focusedDay = DateTime(2026, 4, 22);
  DateTime? _selectedDay;
  String? _selectedTime;
  String? _selectedPet;

  // Controllers للتحكم في الحقول والتأكد من تعبئتها
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _specialRequestsController =
      TextEditingController();

  // قائمة الحيوانات (يمكنك تعبئتها من الـ Database لاحقاً)
  final List<String> _myPets = [
    "Buddy (Dog)",
    "Whiskers (Cat)",
    "Luna (Rabbit)",
  ];

  final Color primaryGreen = const Color(0xFF5B9D8E);
  final Color darkGreen = const Color(0xFF2D5A4F);
  final Color fieldFillColor = const Color(0xFFF8FAF9);

  // دالة إظهار نافذة التوثيق مع تمرير الإيميل المكتوب
  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          VerificationDialog(userEmail: _emailController.text),
    );
  }

  // التحقق من أن جميع المعلومات المطلوبة تم إدخالها
  bool _isFormValid() {
    return _selectedDay != null &&
        _selectedTime != null &&
        _nameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _emailController.text.contains('@') &&
        _selectedPet != null;
  }

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
                  _buildServiceSummaryCard(),
                  const SizedBox(height: 20),

                  _buildSectionHeader(
                    Icons.calendar_today_outlined,
                    "Select Date",
                  ),
                  const SizedBox(height: 12),
                  _buildCalendarCard(),

                  if (_selectedDay != null) ...[
                    const SizedBox(height: 25),
                    _buildSectionHeader(Icons.access_time, "Select Time"),
                    const SizedBox(height: 12),
                    _buildTimePickerGrid(),
                  ],

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
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
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
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        rowHeight: 40,
      ),
    );
  }

  Widget _buildTimePickerGrid() {
    final List<String> times = [
      "9:00 AM",
      "9:30 AM",
      "10:00 AM",
      "10:30 AM",
      "11:00 AM",
      "11:30 AM",
      "12:00 PM",
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: times.length,
      itemBuilder: (context, index) {
        bool isSelected = _selectedTime == times[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedTime = times[index]),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? primaryGreen : Colors.grey.shade200,
              ),
            ),
            child: Text(
              times[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Your Name"),
          _buildTextField(_nameController, "John Doe"),
          const SizedBox(height: 15),

          _buildFieldLabel("Phone Number"),
          Row(
            children: [
              Container(
                width: 70,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fieldFillColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text("+962", style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField(_phoneController, "7XXXXXXXX")),
            ],
          ),
          const SizedBox(height: 15),

          _buildFieldLabel("Email Address"),
          _buildTextField(_emailController, "user@example.com"),
          const SizedBox(height: 15),

          _buildFieldLabel("Select Your Pet"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: fieldFillColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedPet,
                hint: const Text(
                  "Choose a pet...",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                items: _myPets
                    .map(
                      (pet) => DropdownMenuItem(value: pet, child: Text(pet)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedPet = val),
              ),
            ),
          ),
          const SizedBox(height: 15),

          _buildFieldLabel("Special Requests (Optional)"),
          _buildTextField(
            _specialRequestsController,
            "Any special instructions...",
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: fieldFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildBottomActionButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isFormValid() ? _showVerificationDialog : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: darkGreen,
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

// --- نافذة التوثيق (Verification Dialog) ---

class VerificationDialog extends StatefulWidget {
  final String userEmail;
  const VerificationDialog({super.key, required this.userEmail});

  @override
  State<VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<VerificationDialog> {
  int _seconds = 42;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0)
        setState(() => _seconds--);
      else
        _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.email_outlined, color: Color(0xFF8B5E3C)),
                  SizedBox(width: 8),
                  Text(
                    "Verify Email Address",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Enter the 6 digit code sent to your email to verify your booking",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Text(
                  "We've sent a 6-digit verification code to:",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userEmail.isEmpty ? "your email" : widget.userEmail,
                  style: const TextStyle(
                    color: Color(0xFF2D6A5D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "00:${_seconds.toString().padLeft(2, '0')}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "000000",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9D8E),
                  ),
                  child: const Text(
                    "Verify",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
