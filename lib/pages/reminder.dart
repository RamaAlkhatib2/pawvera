 import 'dart:io';
import 'package:flutter/material.dart';
import 'home.dart';
import 'my_pets_page.dart';
import 'my_bookings_page.dart';
import 'profile_view.dart';
import 'edit_info_page.dart';
import 'qr_page.dart';
import 'add_pet_page.dart';

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
  int _selectedIndex = 3;

  String selectedType = "All";
  String selectedPet = "All Pets";
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
          'description': 'Monthly heartworm prevention pill',
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
        final matchesPet =
            selectedPet == "All Pets" || r['petName'] == selectedPet;
        final matchesSearch = r['title'].toLowerCase().contains(
          searchController.text.toLowerCase(),
        );
        return matchesType && matchesPet && matchesSearch;
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Reminders",
              style: TextStyle(
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              "${filteredReminders.length} reminder total",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search reminders...',
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

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildIconFilter("All", Icons.grid_view, "All"),
                _buildIconFilter("Vaccination", Icons.vaccines, "Vaccination"),
                _buildIconFilter("Medication", Icons.medication, "Medication"),
                _buildIconFilter("Grooming", Icons.content_cut, "Grooming"),
                _buildIconFilter("Checkup", Icons.medical_services, "Checkup"),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
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
            builder: (context) => AddPetPage(onAdd: _addNewReminder),
          ),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryTeal,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyPetsPage()),
            );
          }
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeWithMessages()),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyBookingsPage()),
            );
          }
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileView()),
            );
          }
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

  Widget _buildIconFilter(String label, IconData icon, String type) {
    bool isSelected = selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
          applyFilters();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color.fromRGBO(91, 160, 146, 0.1)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : primaryTeal,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: r['isLocal'] == true
                    ? Image.file(
                        File(r['image']),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        r['image'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
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
                    Text(
                      r['petName'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.blue,
                  size: 20,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditInfoPage()),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    reminders.remove(r);
                    applyFilters();
                  });
                },
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  Text(
                    " ${r['date']} at ${r['time']}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QrPage()),
                ),
                child: _buildTag(r['type'], primaryTeal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          color.r.round(),
          color.g.round(),
          color.b.round(),
          0.1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}



