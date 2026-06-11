import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawvera/services/database_service.dart';
import 'home.dart';
import 'profile_view.dart';

class MyBookingsPage extends StatefulWidget {
  final bool standalone;
  const MyBookingsPage({super.key, this.standalone = true});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryGreen = const Color(0xFF5B9D8E);
  final DatabaseService _db = DatabaseService();

  List<DocumentSnapshot> _allDocs = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _bookingsSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  void _loadBookings() {
    _bookingsSubscription = _db.myBookings.listen(
      (snapshot) {
        if (!mounted) return;
        setState(() {
          _allDocs = snapshot.docs;
          _isLoading = false;
          _errorMessage = null;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Could not load bookings. Please check your connection.";
        });
      },
    );
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _confirmDeletion(String bookingId) async {
    await _db.deleteBooking(bookingId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking cancelled successfully")),
      );
    }
  }

  void _showCancelDialog(
    BuildContext context,
    Map<String, dynamic> bookingData,
    String bookingId,
  ) {
    String selectedReason = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final reasons = [
              "Change of plans",
              "Found another service",
              "Pet is not feeling well",
              "Other",
            ];
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F6F7),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.red,
                                  size: 13,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Cancel Booking",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "×",
                                style: TextStyle(
                                  color: Color(0xFF9A9A9A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F5F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Current Booking:",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF565656),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${bookingData['date']} at ${bookingData['time']}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6E6E6E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${bookingData['service']}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6E6E6E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Reason for Cancellation *",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...reasons.map((reason) {
                            final isSelected = selectedReason == reason;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => selectedReason = reason),
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFFF2F2)
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFE07E7E)
                                        : const Color(0xFFD7DDE3),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  reason,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? const Color(0xFFC84949)
                                        : const Color(0xFF333333),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                    backgroundColor: const Color(0xFFECF8F7),
                                    side: const BorderSide(
                                      color: Color(0xFFBDE2DF),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    "Keep Booking",
                                    style: TextStyle(
                                      color: Color(0xFF4D5C59),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: selectedReason.isEmpty
                                      ? null
                                      : () {
                                          _confirmDeletion(bookingId);
                                          Navigator.pop(context);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: const Color(0xFFE79393),
                                    disabledBackgroundColor: const Color(
                                      0xFFF4C7C7,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                  ),
                                  child: const Text(
                                    "Yes, Cancel",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  DateTime _parseBookingDate(String? value) {
    if (value == null || value.trim().isEmpty) return DateTime.now();
    final months = <String, int>{
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final parts = value
        .replaceAll(',', '')
        .split(' ')
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length >= 3) {
      final month = months[parts[0].toLowerCase().substring(0, 3)];
      final day = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (month != null && day != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.now();
  }

  // --- (Reschedule) ---
  void _showRescheduleSheet(Map<String, dynamic> data, String bookingId) {
    // Parse initial date — handle both "d/M/yyyy" and "Month D, YYYY" formats
    DateTime selectedDate =
        _parseBookingDateFromDMY(data['date']?.toString() ?? '') ??
        _parseBookingDate(data['date']?.toString());
    String tempTime = (data['time'] ?? "9:30 AM").toString();
    Set<String> bookedSlots = {};
    final shopId = (data['shopId'] ?? '').toString();
    final shopBookingId = (data['shopBookingId'] ?? '').toString();

    // Callback reference so async slot loader can trigger dialog rebuild
    void Function(void Function())? dialogSetState;

    void loadBookedSlots(DateTime date) {
      if (shopId.isEmpty) return;
      final dateStr = '${date.day}/${date.month}/${date.year}';
      FirebaseFirestore.instance
          .collection('service_shops')
          .doc(shopId)
          .collection('bookings')
          .where('date', isEqualTo: dateStr)
          .get()
          .then((snap) {
            final booked = snap.docs
                .where((doc) {
                  final d = doc.data();
                  final status = (d['status'] ?? '').toString().toLowerCase();
                  // Exclude cancelled and the booking being rescheduled
                  if (status == 'cancelled') return false;
                  if (shopBookingId.isNotEmpty && doc.id == shopBookingId) {
                    return false;
                  }
                  return true;
                })
                .map((doc) => (doc.data()['time'] ?? '').toString())
                .where((t) => t.isNotEmpty)
                .toSet();
            dialogSetState?.call(() => bookedSlots = booked);
          })
          .catchError((_) {});
    }

    const timeSlots = [
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
    ];

    // Kick off initial slot load
    loadBookedSlots(selectedDate);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          dialogSetState = setSheetState;
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.82,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F6F7),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.radio_button_checked_outlined,
                                size: 14,
                                color: Color(0xFF1E5BFF),
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Reschedule Booking",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E5BFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "×",
                              style: TextStyle(
                                color: Color(0xFF9A9A9A),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F6F8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Current Booking:",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF505050),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${data['date']} at ${data['time']}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6A6A6A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  data['service'] ?? "Daily Dog Walking",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6A6A6A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Select New Date *",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFB7D8CF),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CalendarDatePicker(
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 1),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              onDateChanged: (picked) {
                                setSheetState(() {
                                  selectedDate = picked;
                                  bookedSlots = {};
                                });
                                loadBookedSlots(picked);
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Select New Time *",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFB7D8CF),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Wrap(
                              spacing: 7,
                              runSpacing: 7,
                              children: timeSlots.map((slot) {
                                final isSelected = tempTime == slot;
                                final isBooked = bookedSlots.contains(slot);
                                return SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width - 78) /
                                      3,
                                  child: OutlinedButton(
                                    onPressed: isBooked
                                        ? null
                                        : () => setSheetState(
                                            () => tempTime = slot,
                                          ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 9,
                                      ),
                                      side: BorderSide(
                                        color: isSelected
                                            ? const Color(0xFF2F72FF)
                                            : isBooked
                                            ? Colors.grey.shade200
                                            : const Color(0xFFD5D9DE),
                                      ),
                                      backgroundColor: isSelected
                                          ? const Color(0xFFE9F0FF)
                                          : isBooked
                                          ? Colors.grey.shade100
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      slot,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected
                                            ? const Color(0xFF2F72FF)
                                            : isBooked
                                            ? Colors.grey.shade400
                                            : const Color(0xFF444444),
                                        fontWeight: FontWeight.w500,
                                        decoration: isBooked
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF3FF),
                              border: Border.all(
                                color: const Color(0xFF9EBEF2),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "New Appointment:",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF356BC5),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at $tempTime",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF2459B2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFFBFC9C5),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF616A67),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final newDate =
                                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
                                    await _db.rescheduleBooking(
                                      userBookingId: bookingId,
                                      shopId: shopId,
                                      shopBookingId: shopBookingId,
                                      newDate: newDate,
                                      newTime: tempTime,
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E5BFF),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Confirm Reschedule",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStarSelector({
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: List.generate(5, (i) {
        final star = i + 1;
        return IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(
            star <= value ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => onChanged(star),
        );
      }),
    );
  }

  void _showRateDialog(Map<String, dynamic> data, String bookingId) {
    final serviceComment = TextEditingController();
    final shopComment = TextEditingController();
    var serviceStars = 0;
    var shopStars = 0;
    var submitting = false;

    final shopId = (data['shopId'] ?? '').toString().trim();
    final serviceName = (data['serviceName'] ?? data['service'] ?? '')
        .toString()
        .trim();
    final serviceId = (data['serviceId'] ?? '').toString().trim();
    final customerName = (data['name'] ?? data['userName'] ?? '')
        .toString()
        .trim();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => AlertDialog(
          title: const Text('Rate your experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Service Rating',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                _buildStarSelector(
                  value: serviceStars,
                  onChanged: (v) => setSheetState(() => serviceStars = v),
                ),
                TextField(
                  controller: serviceComment,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Comment about the service (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Shop Rating',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                _buildStarSelector(
                  value: shopStars,
                  onChanged: (v) => setSheetState(() => shopStars = v),
                ),
                TextField(
                  controller: shopComment,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Comment about the shop (optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (serviceStars < 1 || shopStars < 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please rate both service and shop.'),
                          ),
                        );
                        return;
                      }
                      if (shopId.isEmpty || serviceName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Missing booking data for rating.'),
                          ),
                        );
                        return;
                      }

                      setSheetState(() => submitting = true);
                      try {
                        await _db.ratePetCareService(
                          bookingId: bookingId,
                          shopId: shopId,
                          serviceName: serviceName,
                          serviceId: serviceId.isEmpty ? null : serviceId,
                          stars: serviceStars,
                          comment: serviceComment.text.trim(),
                          customerName: customerName.isEmpty
                              ? null
                              : customerName,
                        );
                        await _db.rateServiceShop(
                          shopId: shopId,
                          stars: shopStars,
                          comment: shopComment.text.trim(),
                          bookingId: bookingId,
                          customerName: customerName.isEmpty
                              ? null
                              : customerName,
                        );
                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Thanks! Your ratings were submitted.',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(
                          ctx,
                        ).showSnackBar(SnackBar(content: Text('$e')));
                        setSheetState(() => submitting = false);
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    ).then((_) {
      serviceComment.dispose();
      shopComment.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5F1),
      bottomNavigationBar: widget.standalone
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF5B9D8E),
              unselectedItemColor: const Color(0xFF9E9E9E),
              currentIndex: 3,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Home()),
                  );
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Home()),
                  );
                } else if (index == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileView()),
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.pets_outlined),
                  label: 'My Pets',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message_outlined),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  label: 'My Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                            _isLoading = true;
                          });
                          _loadBookings();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "My Bookings",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6F4A3F),
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${_allDocs.length} total bookings",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF8F9A99),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: const Color(0xFFE6EFEA)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: primaryGreen,
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF7A7A7A),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(text: "Current Bookings"),
                          Tab(text: "Past Bookings"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBookingsList(true),
                        _buildBookingsList(false),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBookingsList(bool isCurrent) {
    final now = DateTime.now();

    final filtered = _allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final dateStr = data['date']?.toString() ?? '';
      final bookingDate = _parseBookingDateFromDMY(dateStr);
      if (bookingDate == null) {
        return isCurrent; // show in current if unparsable
      }
      return isCurrent
          ? bookingDate.isAfter(now.subtract(const Duration(days: 1)))
          : bookingDate.isBefore(now);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(isCurrent ? "No current bookings." : "No past bookings."),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final doc = filtered[i];
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final bookingId = doc.id;
        return _buildBookingCard(data, bookingId, isCurrent: isCurrent);
      },
    );
  }

  DateTime? _parseBookingDateFromDMY(String value) {
    if (value.trim().isEmpty) return null;
    final parts = value.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  Widget _buildBookingCard(
    Map<String, dynamic> data,
    String bookingId, {
    required bool isCurrent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3EEE7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data['service'] ?? "Service",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8EF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Confirmed",
                  style: TextStyle(
                    color: Color(0xFF239761),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data['provider'] ?? data['shop'] ?? "Pet Care Service",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            "${data['date']} at ${data['time']}",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            "Pet: ${data['pet']}",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          Text(
            data['phone'] != null && data['phone'].toString().isNotEmpty
                ? data['phone']
                : "No phone",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                () {
                  final p = (data['price'] ?? '').toString();
                  return p.toUpperCase().contains('JOD') ? p : '$p JOD';
                }(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (isCurrent)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRescheduleSheet(data, bookingId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryGreen,
                      side: BorderSide(
                        color: primaryGreen.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Reschedule",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _showCancelDialog(context, data, bookingId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Cancel", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showRateDialog(data, bookingId),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.star_outline),
                label: const Text('Rate Service & Shop'),
              ),
            ),
        ],
      ),
    );
  }
}
