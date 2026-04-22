import 'package:flutter/material.dart';
import 'pet care pages/pet_care_page.dart'; // تأكدي من صحة المسار هنا

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  final Color primaryGreen = const Color(0xFF5B9D8E);
  final Color backgroundColor = const Color(0xFFF0F4F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان العلوي
              const Text(
                "My Bookings",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                "0 total bookings",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 60),

              // حاوية "لا توجد حجوزات"
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 40,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // أيقونة الصندوق
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "No bookings yet",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // الزر الوحيد المطلوب: Book a Service
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // الانتقال لصفحة Pet Care
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PetCarePage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.cleaning_services_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              "Book a Service",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
