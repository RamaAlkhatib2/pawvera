import 'package:flutter/material.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final List<Map<String, dynamic>> reminders = [
    {
      'pet': 'Buddy',
      'title': 'Heartworm Medication',
      'date': 'Jan 18, 2026 at 8:00 AM',
      'type': 'Medication',
      'priority': 'High',
      'completed': false,
    },
    {
      'pet': 'Max',
      'title': 'Annual Checkup',
      'date': 'Jan 20, 2026 at 10:00 AM',
      'type': 'Vet Visit',
      'priority': 'Medium',
      'completed': false,
    },
    {
      'pet': 'Luna',
      'title': 'Grooming Appointment',
      'date': 'Jan 22, 2026 at 2:00 PM',
      'type': 'Grooming',
      'priority': 'Low',
      'completed': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B9D8E),
        title: const Text(
          'Reminders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddReminderButton(),
              const SizedBox(height: 20),
              const Text(
                'Upcoming Reminders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF634732),
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  return _buildReminderItem(reminders[index], index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddReminderButton() {
    return GestureDetector(
      onTap: () => _showNewReminderModal(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF5B9D8E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Add New Reminder',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem(Map<String, dynamic> reminder, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Checkbox(
            value: reminder['completed'],
            onChanged: (value) {
              setState(() {
                reminders[index]['completed'] = value;
              });
            },
            activeColor: const Color(0xFF5B9D8E),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder['title'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF634732),
                    decoration: reminder['completed']
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${reminder['pet']} • ${reminder['date']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        reminder['type'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF5B9D8E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(reminder['priority']),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        reminder['priority'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            color: Colors.grey,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            color: Colors.red[300],
            onPressed: () {
              setState(() {
                reminders.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showNewReminderModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const Text(
                    'New Reminder',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Color(0xFF5B9D8E)),
                    ),
                  ),
                ],
              ),
              const Divider(),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Notes',
                  border: InputBorder.none,
                ),
                maxLines: 3,
              ),
              const Divider(),
              _buildModalOption(Icons.pets, 'Pet', 'Choose'),
              _buildModalOption(
                Icons.calendar_today,
                'Date & Time',
                'Jan 15, 2026 09:00',
              ),
              _buildModalOption(Icons.repeat, 'Repeat', 'Never'),
              _buildModalOption(Icons.category, 'Type', 'Vaccination'),
              _buildModalOption(Icons.priority_high, 'Priority', 'Medium'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
