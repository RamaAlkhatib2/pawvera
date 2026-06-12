import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pawvera/pages/home.dart';
import 'package:pawvera/pages/my_bookings_page.dart';
import 'package:pawvera/services/database_service.dart';

class ConfirmBookingPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  ConfirmBookingPage({super.key, required this.bookingData});

  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  final Color primaryGreen = const Color(0xFF5B9D8E);
  final DatabaseService _db = DatabaseService();
  bool _isProcessing = false;

  double _parsePriceValue() {
    final match = RegExp(r'[\d.]+').firstMatch(_textValue('price'));
    return match != null ? double.tryParse(match.group(0)!) ?? 0 : 0;
  }

  String _priceCurrency() {
    final suffix = _textValue('price').replaceAll(RegExp(r'[\d.\s]'), '').trim();
    return suffix.isNotEmpty ? suffix : 'JOD';
  }

  String _textValue(String key, {String fallback = "-"}) {
    final value = widget.bookingData[key];
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  // Save booking to both Hive and Firestore
  Future<void> _saveBooking() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final shopId = (widget.bookingData['shopId'] ?? '').toString();
      final date = (widget.bookingData['date'] ?? '').toString();
      final time = (widget.bookingData['time'] ?? '').toString();
      final pet = (widget.bookingData['pet'] ?? '').toString();

      // Confirm the shop's time slot hasn't been taken since the user selected it
      if (shopId.isNotEmpty) {
        final slotTaken = await _db.isShopTimeslotBooked(shopId, date, time);
        if (slotTaken) {
          if (!mounted) return;
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This time slot was just booked. Please go back and choose a different time.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Prevent booking the same pet at the same date & time in any other shop
      if (pet.isNotEmpty) {
        final petConflict = await _db.hasPetBookingConflict(
          petName: pet,
          date: date,
          time: time,
        );
        if (petConflict) {
          if (!mounted) return;
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$pet already has a booking at $time on $date. Please choose a different time.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      // Save to Hive (local)
      var box = Hive.box('myBox');
      List<dynamic> currentBookings = box.get('all_bookings', defaultValue: []);
      List<Map<String, dynamic>> updatedList = currentBookings
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      updatedList.add(widget.bookingData);
      await box.put('all_bookings', updatedList);

      // Save to Firestore
      await _db.createBooking(widget.bookingData);

      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showSuccessDialog(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save booking: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Success dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF5B9D8E), size: 80),
            const SizedBox(height: 16),
            const Text(
              "Booking Confirmed!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Your booking for ${_textValue('pet')} has been confirmed.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Mini booking details card inside dialog
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDialogRow("Booking ID:", "#927928"),
                  _buildDialogRow("Service:", _textValue('service')),
                  _buildDialogRow(
                    "Date & Time:",
                    "${_textValue('date')} at ${_textValue('time')}",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyBookingsPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "View My Bookings",
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Back to Home",
                      style: TextStyle(color: Colors.white, fontSize: 11),
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

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Confirm Booking",
          style: TextStyle(
            color: Color(0xFF634732),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatusCard(
              icon: Icons.check_circle_outline,
              title: "Email Verified!",
              subtitle: "Your booking is ready to be confirmed",
              color: Colors.green,
            ),
            const SizedBox(height: 12),

            _buildStatusCard(
              icon: Icons.percent,
              title: "Discount Applied!",
              subtitle: "You're saving ${(_parsePriceValue() * 0.15).toStringAsFixed(2)} ${_priceCurrency()} with 15% off",
              color: Colors.green,
            ),
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Booking Summary",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryRow("Service", _textValue('service')),
                  _buildSummaryRow("Provider", _textValue('provider')),
                  _buildSummaryRow("Date", _textValue('date')),
                  _buildSummaryRow("Time", _textValue('time')),
                  _buildSummaryRow(
                    "Duration",
                    _textValue('duration', fallback: "45 mins"),
                  ),
                  _buildSummaryRow("Pet", _textValue('pet')),
                  const Divider(height: 30),
                  _buildSummaryRow("Original Price", _textValue('price')),
                  _buildSummaryRow(
                    "Discount (15%)",
                    "-${(_parsePriceValue() * 0.15).toStringAsFixed(2)} ${_priceCurrency()}",
                    isDiscount: true,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${(_parsePriceValue() * 0.85).toStringAsFixed(2)} ${_priceCurrency()}",
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Contact Information",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  _buildContactRow(Icons.person_outline, _textValue('name')),
                  _buildContactRow(Icons.phone_outlined, _textValue('phone')),
                  _buildContactRow(Icons.email_outlined, _textValue('email')),
                ],
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _saveBooking(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        "Confirm Booking (${(_parsePriceValue() * 0.85).toStringAsFixed(2)} ${_priceCurrency()})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
