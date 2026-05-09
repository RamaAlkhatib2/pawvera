import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pawvera/controllers/service_provider_controller.dart';
import 'package:pawvera/models/service_provider_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service Booking Flow for Pet Owners.
///
/// Steps:
/// 1. Select Service (only active services are shown — real-time sync)
/// 2. Enter Owner & Pet Info
/// 3. Select Date & Time
/// 4. Confirm Booking
///
/// Real-time sync demonstration:
/// When a provider deactivates a service in the Services tab,
/// it IMMEDIATELY disappears from the selection here (StreamBuilder).
class ServiceBookingFlow extends StatefulWidget {
  final ShopProfile shop;

  const ServiceBookingFlow({super.key, required this.shop});

  @override
  State<ServiceBookingFlow> createState() => _ServiceBookingFlowState();
}

class _ServiceBookingFlowState extends State<ServiceBookingFlow> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Service selection
  ServiceItem? _selectedService;

  // Step 2: Owner & Pet info
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _petNameCtrl = TextEditingController();
  final _petBreedCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Step 3: Date & Time
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 AM';

  bool _submitting = false;

  final List<String> _timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _petNameCtrl.dispose();
    _petBreedCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ───────── Step navigation ─────────
  bool get _canProceedFromStep1 => _selectedService != null;
  bool get _canProceedFromStep2 =>
      _nameCtrl.text.isNotEmpty &&
      _phoneCtrl.text.isNotEmpty &&
      _petNameCtrl.text.isNotEmpty;

  String _formatDate(DateTime dt) {
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
    return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
  }

  Future<void> _submitBooking() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final ctrl = context.read<ServiceProviderController>();
      await ctrl.createBookingForOwner(
        shopId: widget.shop.id,
        shopName: widget.shop.shopName,
        userName: _nameCtrl.text,
        userPhone: _phoneCtrl.text,
        petName: _petNameCtrl.text,
        petBreed: _petBreedCtrl.text,
        serviceId: _selectedService!.id,
        serviceName: _selectedService!.name,
        servicePrice: _selectedService!.price,
        date: _formatDate(_selectedDate),
        time: _selectedTime,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      );

      if (!context.mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Booking Submitted!'),
        content: const Text(
          'Your booking request has been sent to the provider. '
          'You will receive a status update when it is confirmed.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shop.shopName),
        backgroundColor: const Color(0xFF2D6A64),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _buildStep1Service(),
                _buildStep2Info(),
                _buildStep3DateTime(),
                _buildStep4Confirm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Service', 'Info', 'Date', 'Confirm'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: i ~/ 2 < _currentStep
                    ? const Color(0xFF2D6A64)
                    : Colors.grey[300],
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isActive = stepIndex <= _currentStep;
          return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2D6A64) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${stepIndex + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ───────── Step 1: Select Service ─────────
  Widget _buildStep1Service() {
    // Uses StreamBuilder to get real-time services from Firestore
    // When a provider deactivates a service, it disappears here instantly.
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_shops')
          .doc(widget.shop.id)
          .collection('services')
          .where('isActive', isEqualTo: true) // ← only active services
          .snapshots(),
      builder: (context, snapshot) {
        final services = snapshot.data?.docs ?? [];
        final items = services
            .map(
              (doc) => ServiceItem.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ),
            )
            .toList();

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a Service',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose from our available services below:',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          'No services currently available.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final service = items[i];
                          final isSelected = _selectedService?.id == service.id;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF2D6A64)
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              title: Text(
                                service.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${service.duration} — \$${service.price.toStringAsFixed(2)}',
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF2D6A64),
                                    )
                                  : null,
                              onTap: () {
                                setState(() => _selectedService = service);
                              },
                            ),
                          );
                        },
                      ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _canProceedFromStep1
                      ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A64),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Next', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────── Step 2: Contact & Pet Info ─────────
  Widget _buildStep2Info() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Your Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _petNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Pet Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pets),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _petBreedCtrl,
            decoration: const InputDecoration(
              labelText: 'Pet Breed (optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.info_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Special Notes (optional)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _canProceedFromStep2
                      ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A64),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────── Step 3: Date & Time ─────────
  Widget _buildStep3DateTime() {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date & Time',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Date picker
          const Text('Date:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: now,
                lastDate: now.add(const Duration(days: 60)),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF2D6A64),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF2D6A64)),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Time slots
          const Text('Time:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, i) {
                final time = _timeSlots[i];
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2D6A64)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2D6A64)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A64),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Review Booking'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────── Step 4: Confirm ─────────
  Widget _buildStep4Confirm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirm Booking',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _confirmRow('Service', _selectedService?.name ?? ''),
          _confirmRow(
            'Price',
            '\$${_selectedService?.price.toStringAsFixed(2) ?? '0'}',
          ),
          _confirmRow('Duration', _selectedService?.duration ?? ''),
          _confirmRow('Name', _nameCtrl.text),
          _confirmRow('Phone', _phoneCtrl.text),
          _confirmRow(
            'Pet',
            '${_petNameCtrl.text} (${_petBreedCtrl.text.isNotEmpty ? _petBreedCtrl.text : 'N/A'})',
          ),
          _confirmRow('Date', _formatDate(_selectedDate)),
          _confirmRow('Time', _selectedTime),
          if (_notesCtrl.text.isNotEmpty) _confirmRow('Notes', _notesCtrl.text),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A64),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Confirm & Book'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _confirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
