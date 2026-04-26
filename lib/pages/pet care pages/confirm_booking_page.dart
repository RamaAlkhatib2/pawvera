import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pawvera/pages/home.dart';
import 'package:pawvera/pages/my_bookings_page.dart';

class ConfirmBookingPage extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const ConfirmBookingPage({super.key, required this.bookingData});

  final Color primaryGreen = const Color(0xFF5B9D8E);
  // 1. دالة لإظهار نافذة نجاح الحجز
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
              "Your booking for ${bookingData['pet']} has been confirmed.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // بطاقة تفاصيل الحجز المصغرة داخل الدايلوج
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDialogRow("Booking ID:", "#927928"),
                  _buildDialogRow("Service:", bookingData['service']),
                  _buildDialogRow(
                    "Date & Time:",
                    "${bookingData['date']} at ${bookingData['time']}",
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
                      // هاد الكود برجعك للهوم وبنظف كل الصفحات اللي قبلها (عشان ما يرجع لورا للحجز)
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

  // دالة مساعدة لتنسيق الأسطر داخل النافذة
  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
          // داخل زر Confirm Booking
          onPressed: () async {
            var box = Hive.box(
              'myBox',
            ); // التأكد من استخدام نفس اسم الـ Box المفتوح في الماين

            // 1. جلب القائمة الحالية (أو إنشاء قائمة فارغة إذا كانت أول مرة)
            List<dynamic> currentBookings = box.get(
              'all_bookings',
              defaultValue: [],
            );

            // 2. تحويلها لـ List قابلة للتعديل وإضافة الحجز الجديد
            List<Map<String, dynamic>> updatedList =
                List<Map<String, dynamic>>.from(currentBookings);
            updatedList.add(bookingData);

            // 3. حفظ القائمة المحدثة
            await box.put('all_bookings', updatedList);

            // 4. إظهار نافذة النجاح
            _showSuccessDialog(context);
          },
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
            // بطاقة نجاح التحقق (Email Verified)
            _buildStatusCard(
              icon: Icons.check_circle_outline,
              title: "Email Verified!",
              subtitle: "Your booking is ready to be confirmed",
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            // بطاقة الخصم (Discount Applied)
            _buildStatusCard(
              icon: Icons.percent,
              title: "Discount Applied!",
              subtitle: "You're saving \$3.75 with 15% off",
              color: Colors.green,
            ),
            const SizedBox(height: 25),

            // ملخص الحجز (Booking Summary)
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
                  _buildSummaryRow("Service", bookingData['service']),
                  _buildSummaryRow("Provider", bookingData['provider']),
                  _buildSummaryRow("Date", bookingData['date']),
                  _buildSummaryRow("Time", bookingData['time']),
                  _buildSummaryRow(
                    "Duration",
                    bookingData['duration'] ?? "45 mins",
                  ),
                  _buildSummaryRow("Pet", bookingData['pet']),
                  const Divider(height: 30),
                  _buildSummaryRow("Original Price", "25.00 JOD"),
                  _buildSummaryRow(
                    "Discount (15%)",
                    "-3.75 JOD",
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
                        "${bookingData['price']} JOD",
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

            // معلومات الاتصال
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
                  _buildContactRow(Icons.person_outline, bookingData['name']),
                  _buildContactRow(Icons.phone_outlined, bookingData['phone']),
                  _buildContactRow(Icons.email_outlined, bookingData['email']),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // زر التأكيد النهائي
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // ابحث عن زر Confirm Booking في كودك الأصلي وعدله ليصبح هكذا:
                onPressed: () {
                  // هنا نقوم بحفظ الحجز في Hive قبل إظهار النجاح
                  final bookingsBox = Hive.box('myBox');
                  List currentBookings = bookingsBox.get(
                    'all_bookings',
                    defaultValue: [],
                  );
                  currentBookings.add(
                    bookingData,
                  ); // إضافة الحجز الحالي للقائمة
                  bookingsBox.put('all_bookings', currentBookings);

                  _showSuccessDialog(context); // إظهار النافذة
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Confirm Booking (${bookingData['price']} JOD)",
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
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 15),
          Column(
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
                style: TextStyle(color: color.withOpacity(0.7), fontSize: 11),
              ),
            ],
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
