import 'package:flutter/material.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<Map<String, dynamic>> reminders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReminders();
  }

  Future<void> fetchReminders() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      reminders = [
        {
          'title': 'Vaccination for Buddy',
          'petName': 'Buddy',
          'time': '10:00 AM',
          'date': '2026-04-30',
          'description': 'Annual vaccination appointment at the vet.',
        },
        {
          'title': 'Grooming for Whiskers',
          'petName': 'Whiskers',
          'time': '2:00 PM',
          'date': '2026-05-01',
          'description': 'Monthly grooming session.',
        },
        {
          'title': 'Vet Checkup for Max',
          'petName': 'Max',
          'time': '11:00 AM',
          'date': '2026-05-02',
          'description': 'Routine health checkup.',
        },
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryTeal = Color(0xFF5BA092);
    final backgroundCream = Color(0xFFF9F6EE);

    return Scaffold(
      backgroundColor: backgroundCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Reminders",
                style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            Text("${reminders.length} reminders total",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search reminders by title or pet name...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("All", isSelected: true, color: primaryTeal),
                  _buildFilterChip("Vaccination"),
                  _buildFilterChip("Medication"),
                  _buildFilterChip("Grooming"),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text("Upcoming",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037))),
            SizedBox(height: 15),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: reminders
                    .map((reminder) => _buildReminderCard(
                          title: reminder['title'] as String,
                          petName: reminder['petName'] as String,
                          date: "${reminder['date']} at ${reminder['time']}",
                          type: "Other", // placeholder
                          priority: "Medium Priority", // placeholder
                          iconColor: primaryTeal,
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderSheet(context, primaryTeal),
        backgroundColor: primaryTeal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String petName,
    required String date,
    required String type,
    required String priority,
    required Color iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(Icons.calendar_today, size: 18, color: iconColor),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(petName,
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, size: 20, color: Colors.blue[300]),
              SizedBox(width: 10),
              Icon(Icons.delete_outline, size: 20, color: Colors.red[300]),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey),
              SizedBox(width: 5),
              Text(date, style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              _buildTag(type, iconColor),
              SizedBox(width: 8),
              _buildTag(priority, Colors.orange),
            ],
          )
        ],
      ),
    );
  }

  void _showAddReminderSheet(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel")),
                Text("New Reminder",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                    onPressed: () {},
                    child: Text("Add",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            Divider(),
            TextField(
              decoration: InputDecoration(
                  hintText: "Title",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey)),
            ),
            Divider(),
            TextField(
              maxLines: 2,
              decoration: InputDecoration(
                  hintText: "Notes",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey)),
            ),
            Divider(),
            _buildModalTile(Icons.pets, "Pet", "Choose"),
            _buildModalTile(
                Icons.calendar_today, "Date & Time", "Jan 15, 2026 09:00"),
            _buildModalTile(Icons.repeat, "Repeat", "Never"),
            _buildModalTile(Icons.category, "Type", "Vaccination"),
            _buildModalTile(Icons.priority_high, "Priority", "medium"),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label,
      {bool isSelected = false, Color? color}) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade50),
      ),
      child: Text(label,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.teal, fontSize: 12)),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildModalTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(title, style: TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: Colors.grey, fontSize: 14)),
          Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
 
