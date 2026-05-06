 import 'package:flutter/material.dart';
import 'home.dart';
import 'adoption.dart';
import 'profile_view.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<Map<String, dynamic>> reminders = [];
  List<Map<String, dynamic>> filteredReminders = [];
  bool isLoading = true;
  String selectedType = "All";
  String selectedPet = "All Pets";
  TextEditingController searchController = TextEditingController();
  int currentIndex = 3;

  @override
  void initState() {
    super.initState();
    fetchReminders();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    applyFilters();
  }

  Future<void> fetchReminders() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      reminders = [
        {
          'title': 'Heartworm Medication',
          'petName': 'Buddy',
          'time': '8:00 AM',
          'date': 'Jan 18, 2026',
          'description': 'Monthly heartworm prevention pill',
          'type': 'Medication',
          'repeat': 'Repeats monthly',
          'priority': 'High Priority',
        },
      ];
      filteredReminders = reminders;
      isLoading = false;
    });
  }

  void applyFilters() {
    setState(() {
      filteredReminders = reminders.where((reminder) {
        final matchesType =
            selectedType == "All" || reminder['type'] == selectedType;
        final matchesPet =
            selectedPet == "All Pets" || reminder['petName'] == selectedPet;
        final matchesSearch = reminder['title']
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            reminder['petName']
                .toLowerCase()
                .contains(searchController.text.toLowerCase());
        return matchesType && matchesPet && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryTeal = const Color(0xFF5BA092);
    final softRed = const Color(0xFFFF8A8A);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F9F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("My Reminders",
                style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text("${filteredReminders.length} reminder total",
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search reminders...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // Main filter row with icon buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildIconFilterChip(
                  'All',
                  Icons.grid_view,
                  isSelected: selectedType == 'All',
                  onTap: () {
                    selectedType = 'All';
                    applyFilters();
                  },
                ),
                _buildIconFilterChip(
                  'Vaccination',
                  Icons.vaccines,
                  isSelected: selectedType == 'Vaccination',
                  onTap: () {
                    selectedType = 'Vaccination';
                    applyFilters();
                  },
                ),
                _buildIconFilterChip(
                  'Medication',
                  Icons.medication,
                  isSelected: selectedType == 'Medication',
                  onTap: () {
                    selectedType = 'Medication';
                    applyFilters();
                  },
                ),
                _buildIconFilterChip(
                  'Grooming',
                  Icons.content_cut,
                  isSelected: selectedType == 'Grooming',
                  onTap: () {
                    selectedType = 'Grooming';
                    applyFilters();
                  },
                ),
                _buildIconFilterChip(
                  'Checkup',
                  Icons.medical_services,
                  isSelected: selectedType == 'Checkup',
                  onTap: () {
                    selectedType = 'Checkup';
                    applyFilters();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Pet filter row with icons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildIconFilterChip(
                  'All Pets',
                  Icons.pets,
                  isSelected: selectedPet == 'All Pets',
                  onTap: () {
                    selectedPet = 'All Pets';
                    applyFilters();
                  },
                ),
                _buildIconFilterChip(
                  'Buddy',
                  Icons.pets,
                  isSelected: selectedPet == 'Buddy',
                  onTap: () {
                    selectedPet = 'Buddy';
                    applyFilters();
                  },
                ),
                _buildIconFilterChip(
                  'Whiskers',
                  Icons.pets,
                  isSelected: selectedPet == 'Whiskers',
                  onTap: () {
                    selectedPet = 'Whiskers';
                    applyFilters();
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 30, indent: 16, endIndent: 16),

          // List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Past",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037))),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.grey[200], shape: BoxShape.circle),
                  child: Text("${filteredReminders.length}",
                      style: const TextStyle(fontSize: 10)),
                )
              ],
            ),
          ),

          // Reminders List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredReminders.isEmpty
                    ? _buildEmptyState(primaryTeal)
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: filteredReminders
                            .map((r) => _buildReminderCard(r, softRed))
                            .toList(),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
              break;
            case 1:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AdoptionScreen()));
              break;
            case 2:
              // Messages - placeholder
              break;
            case 3:
              // Already on My Bookings/Reminders page
              break;
            case 4:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileView()));
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline), label: "My Pets"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: "Messages"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined), label: "My Bookings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label,
      {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5BA092) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF5BA092).withOpacity(0.2)),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF5D4037),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildIconFilterChip(String label, IconData icon,
      {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5BA092) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF5BA092).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF5D4037)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF5D4037),
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> r, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: iconColor.withOpacity(0.5),
                    child: const Icon(Icons.calendar_today_outlined,
                        color: Colors.white, size: 24),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child:
                          const Icon(Icons.error, color: Colors.red, size: 14),
                    ),
                  )
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(r['title'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey)),
                        const SizedBox(width: 5),
                        const Icon(Icons.error,
                            color: Colors.redAccent, size: 16),
                      ],
                    ),
                    Text(r['petName'],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showEditReminderDialog(r),
                child: const Icon(Icons.edit_outlined,
                    color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _deleteReminder(r),
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _iconText(
              Icons.calendar_month_outlined, "${r['date']} at ${r['time']}"),
          const SizedBox(height: 4),
          _iconText(Icons.repeat, r['repeat']),
          const SizedBox(height: 12),
          Text("\"${r['description']}\"",
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTag(r['type'], Colors.redAccent),
              const SizedBox(width: 8),
              _buildTag("Monthly", Colors.grey),
              const SizedBox(width: 8),
              _buildTag(r['priority'], Colors.redAccent.withOpacity(0.6)),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildEmptyState(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No reminders found",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037))),
          const Text("Try adjusting your search or filters",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddReminderDialog(),
            icon: const Icon(Icons.add),
            label: const Text("Add Reminder"),
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          )
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  void _showEditReminderDialog(Map<String, dynamic> reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Reminder"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: TextEditingController(text: reminder['title']),
                decoration: InputDecoration(labelText: "Title")),
            SizedBox(height: 10),
            TextField(
                controller:
                    TextEditingController(text: reminder['description']),
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 2),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Save")),
        ],
      ),
    );
  }

  void _deleteReminder(Map<String, dynamic> reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Reminder?"),
        content: Text("Are you sure you want to delete this reminder?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                reminders.remove(reminder);
                filteredReminders.remove(reminder);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Reminder deleted")));
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Reminder"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                decoration: InputDecoration(labelText: "Reminder Title"),
                controller: TextEditingController()),
            SizedBox(height: 10),
            TextField(
                decoration: InputDecoration(labelText: "Pet Name"),
                controller: TextEditingController()),
            SizedBox(height: 10),
            TextField(
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 2,
                controller: TextEditingController()),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Add")),
        ],
      ),
    );
  }
}
