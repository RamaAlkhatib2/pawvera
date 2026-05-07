 import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home.dart';
import 'adoption.dart';
import 'profile_view.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final Color primaryTeal = const Color(0xFF5BA092);
  List<Map<String, dynamic>> reminders = [];
  List<Map<String, dynamic>> filteredReminders = [];
  bool isLoading = true;
  String selectedType = "All";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReminders();
    searchController.addListener(() => applyFilters());
  }

  Future<void> fetchReminders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      reminders = [
        {
          'title': 'Heartworm Medication',
          'petName': 'Buddy',
          'time': '08:00 AM',
          'date': 'Jan 18, 2026',
          'type': 'Medication',
          'image': 'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
          'isLocal': false,
        },
      ];
      filteredReminders = reminders;
      isLoading = false;
    });
  }

  void applyFilters() {
    setState(() {
      filteredReminders = reminders.where((r) {
        final matchesType = selectedType == "All" || r['type'] == selectedType;
        final matchesSearch = r['title'].toLowerCase().contains(
          searchController.text.toLowerCase(),
        );
        return matchesType && matchesSearch;
      }).toList();
    });
  }

  void _addNewReminder(Map<String, dynamic> newReminder) {
    setState(() {
      reminders.insert(0, newReminder);
      applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Reminders",
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredReminders.length,
                    itemBuilder: (context, index) =>
                        _buildReminderCard(filteredReminders[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryTeal,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddReminderPage(onAdd: _addNewReminder),
          ),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryTeal,
        currentIndex: 3,
        onTap: (index) {
          if (index == 0)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          if (index == 1)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdoptionScreen()),
            );
          if (index == 4)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileView()),
            );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: "My Pets",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: "My Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: r['isLocal'] == true
                ? Image.file(
                    File(r['image']),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    r['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Pet: ${r['petName']}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: primaryTeal),
                    Text(
                      " ${r['time']} | ${r['date']}",
                      style: TextStyle(
                        color: primaryTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

class AddReminderPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  const AddReminderPage({super.key, required this.onAdd});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _titleController = TextEditingController();
  final _petController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _selectedImage = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      appBar: AppBar(
        title: const Text("New Reminder"),
        backgroundColor: const Color(0xFF5BA092),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.withOpacity(0.3)),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? const Icon(
                        Icons.camera_alt_outlined,
                        size: 40,
                        color: Color(0xFF5BA092),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildInput(
              "Reminder Title",
              _titleController,
              Icons.notifications_none,
            ),
            _buildInput("Pet Name", _petController, Icons.pets),
            _buildInput(
              "Date (e.g. May 10, 2026)",
              _dateController,
              Icons.calendar_today,
            ),
            _buildInput(
              "Time (e.g. 10:00 AM)",
              _timeController,
              Icons.access_time,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5BA092),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (_titleController.text.isEmpty || _selectedImage == null)
                    return;
                  widget.onAdd({
                    'title': _titleController.text,
                    'petName': _petController.text,
                    'time': _timeController.text,
                    'date': _dateController.text,
                    'type': 'General',
                    'image': _selectedImage!.path,
                    'isLocal': true,
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  "Save Reminder",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF5BA092)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

