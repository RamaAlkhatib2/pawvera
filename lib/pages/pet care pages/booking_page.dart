import 'package:flutter/material.dart';
import 'package:pawvera/pages/pet%20care%20pages/confirm_booking_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawvera/services/database_service.dart';

class BookingPage extends StatefulWidget {
  final String serviceName;
  final String providerName;
  final String price;
  final String clinicName;
  final String duration;

  const BookingPage({
    super.key,
    required this.serviceName,
    required this.providerName,
    required this.price,
    required this.clinicName,
    required this.duration,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final Color primaryGreen = const Color(0xFF5B9D8E);
  final Color bgCream = const Color(0xFFE8F4F1);
  final DatabaseService _db = DatabaseService();

  // Controllers لجمع بيانات اليوزر
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  String? _selectedPet;

  String _countryCode =
      "+962"; // default to Jordan, will be fetched from user data

  static const Map<String, String> _countryCodes = {
    "Jordan": "+962",
    "Saudi Arabia": "+966",
    "UAE": "+971",
    "Egypt": "+20",
    "Palestine": "+970",
  };

  @override
  void initState() {
    super.initState();
    _initCountryCode();
  }

  void _initCountryCode() {
    _db.userData.listen((userDoc) {
      if (!mounted) return;
      final data = userDoc.data() as Map<String, dynamic>?;
      if (data != null) {
        final country = data['country'] as String?;
        if (country != null && _countryCodes.containsKey(country)) {
          setState(() {
            _countryCode = _countryCodes[country]!;
          });
        }
      }
    });
  }

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

  // دالة لإظهار نافذة التحقق
  void _showVerificationDialog(BuildContext context, String email) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: Color(0xFF634732),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Verify Email",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter the 6-digit code sent to your email to verify your booking",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "We've sent a code to:\n$email",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter Verification Code",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "000000",
                    hintStyle: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.3),
                      fontSize: 16,
                      letterSpacing: 6,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFBFBFB),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF5B9D8E)),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Resend in 45s",
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
            const SizedBox(height: 15),
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
                    // داخل _showVerificationDialog -> ElevatedButton onPressed:
                    onPressed: () {
                      Navigator.pop(context); // إغلاق الدايلوج أولاً

                      // تجميع كافة البيانات لإرسالها لصفحة التأكيد
                      final bookingInfo = {
                        'service': widget.serviceName,
                        'provider': widget.providerName,
                        'price': widget.price,
                        'date':
                            "${_selectedDay?.day}/${_selectedDay?.month}/${_selectedDay?.year}",
                        'time': _selectedTime,
                        'pet': _selectedPet,
                        'duration': widget.duration,
                        'name': _nameController.text,
                        'phone': "$_countryCode ${_phoneController.text}",
                        'email': _emailController.text,
                      };

                      // الانتقال لصفحة التأكيد
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ConfirmBookingPage(bookingData: bookingInfo),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: bgCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Book Service",
              style: TextStyle(
                color: Color(0xFF634732),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.serviceName,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceDetailCard(),
            const SizedBox(height: 20),
            _buildSectionTitle("Select Date", Icons.calendar_today),
            _buildCalendar(),
            if (_selectedDay != null) ...[
              const SizedBox(height: 20),
              _buildSectionTitle("Select Time", Icons.access_time),
              _buildTimeGrid(),
            ],
            if (_selectedTime != null) ...[
              const SizedBox(height: 25),
              _buildContactInformation(),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    (_selectedDay != null &&
                        _selectedTime != null &&
                        _selectedPet != null)
                    ? () {
                        if (_emailController.text.isNotEmpty) {
                          _showVerificationDialog(
                            context,
                            _emailController.text,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter your email"),
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Continue to Verification",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- المكونات الداخلية ---

  Widget _buildServiceDetailCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF634732),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.clinicName,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Text(
                  "Duration: ${widget.duration}",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2FCF9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDFF4EA)),
            ),
            child: Text(
              widget.price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B7B62),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF634732)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF634732),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 60)),
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
          selectedDecoration: BoxDecoration(
            color: primaryGreen,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: primaryGreen.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildTimeGrid() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _timeSlots.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          bool isSelected = _selectedTime == _timeSlots[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedTime = _timeSlots[index]),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? primaryGreen : Colors.grey.shade200,
                ),
              ),
              child: Text(
                _timeSlots[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Contact Information", Icons.person_outline),
          _buildInputField(
            label: "Your Name",
            hint: "Full Name",
            controller: _nameController,
          ),
          Row(
            children: [
              const Text(
                "Phone Number",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFBFB),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _countryCode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "7XXXXXXXX",
                    filled: true,
                    fillColor: const Color(0xFFFBFBFB),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryGreen),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInputField(
            label: "Email Address",
            hint: "example@mail.com",
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const Divider(height: 30),
          const Text(
            "Select Your Pet",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildPetSelector(),
          const SizedBox(height: 20),
          _buildInputField(
            label: "Special Requests",
            hint: "Optional notes...",
            controller: _specialRequestsController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelector() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.userPets,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final pets = snapshot.data?.docs ?? [];

        if (pets.isEmpty) {
          return const Text(
            "No pets found. Add a pet first.",
            style: TextStyle(color: Colors.red, fontSize: 12),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFBFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPet,
              hint: const Text("Choose pet", style: TextStyle(fontSize: 13)),
              isExpanded: true,
              items: pets.map((doc) {
                final name =
                    (doc.data() as Map<String, dynamic>)['name'] as String? ??
                    '';
                return DropdownMenuItem<String>(value: name, child: Text(name));
              }).toList(),
              onChanged: (val) => setState(() => _selectedPet = val),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFFBFBFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryGreen),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
