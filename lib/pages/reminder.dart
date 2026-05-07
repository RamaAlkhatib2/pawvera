import 'package:flutter/material.dart';
import 'home.dart';
import 'my_pet_page.dart';
import 'my_bookings_page.dart';
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
  int _selectedIndex = 3;

  String selectedType = "All";
  String selectedPet = "All Pets";
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReminders();
    searchController.addListener(applyFilters);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      reminders = [
        {
          'title': 'Heartworm Medication',
          'petName': 'Buddy',
          'time': '8:00 AM',
          'date': 'Jan 18, 2026',
          'dateTime': DateTime(2026, 1, 18, 8, 0),
          'description': 'Monthly heartworm prevention pill',
          'type': 'Medication',
          'repeat': 'Monthly',
          'priority': 'High Priority',
          'image': 'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
          'isLocal': false,
        },
      ];
      filteredReminders = List.from(reminders);
      isLoading = false;
    });
  }

  List<String> get petNames {
    final names = reminders.map((r) => r['petName'] as String).toSet().toList();
    return ['All Pets', ...names];
  }

  void applyFilters() {
    setState(() {
      filteredReminders = reminders.where((r) {
        final matchesType = selectedType == "All" || r['type'] == selectedType;
        final matchesPet =
            selectedPet == "All Pets" || r['petName'] == selectedPet;
        final matchesSearch = (r['title'] as String)
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        return matchesType && matchesPet && matchesSearch;
      }).toList();
    });
  }

  void _addReminder(Map<String, dynamic> reminder) {
    setState(() {
      reminders.insert(0, reminder);
      applyFilters();
    });
  }

  List<Map<String, dynamic>> get pastReminders {
    final now = DateTime.now();
    return filteredReminders
        .where((r) => (r['dateTime'] as DateTime).isBefore(now))
        .toList();
  }

  List<Map<String, dynamic>> get upcomingReminders {
    final now = DateTime.now();
    return filteredReminders
        .where((r) => !(r['dateTime'] as DateTime).isBefore(now))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
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
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search reminders...',
                hintStyle:
                    const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, size: 20, color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Type filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: ["All", "Vaccination", "Medication", "Grooming", "Checkup"]
                  .map((t) => _chip(t, selectedType == t, () {
                        setState(() {
                          selectedType = t;
                          applyFilters();
                        });
                      }))
                  .toList(),
            ),
          ),

          // Pet filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: petNames
                  .map((p) => _chip(p, selectedPet == p, () {
                        setState(() {
                          selectedPet = p;
                          applyFilters();
                        });
                      }))
                  .toList(),
            ),
          ),

          // Reminder list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      if (pastReminders.isNotEmpty) ...[
                        _sectionHeader("Past", pastReminders.length),
                        ...pastReminders.map(_buildReminderCard),
                      ],
                      if (upcomingReminders.isNotEmpty) ...[
                        _sectionHeader("Upcoming", upcomingReminders.length),
                        ...upcomingReminders.map(_buildReminderCard),
                      ],
                      if (filteredReminders.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text("No reminders found",
                                style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryTeal,
        onPressed: () => _showNewReminderSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const Home()));
          }
          if (index == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const MyPetPage()));
          }
          if (index == 3) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsPage()));
          }
          if (index == 4) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => ProfileView()));
          }
        },
        items: const [
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

  // ── Shared chip widget ─────────────────────────────────────────────────────

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037))),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: primaryTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count',
                style:
                    const TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // ── Reminder card ───────────────────────────────────────────────────────────

  Widget _buildReminderCard(Map<String, dynamic> r) {
    final priority = r['priority'] as String? ?? '';
    final isHighPriority = priority.toLowerCase().contains('high');
    final type = r['type'] as String? ?? '';
    final repeat = r['repeat'] as String? ?? 'Never';
    final desc = r['description'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored icon with optional priority badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4CFC6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFFE07B6A),
                      size: 22,
                    ),
                  ),
                  if (isHighPriority)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.priority_high,
                            color: Colors.white, size: 10),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Title + pet name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(r['title'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF333333))),
                        ),
                        if (isHighPriority)
                          const Icon(Icons.error_outline,
                              color: Color(0xFFE07B6A), size: 18),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(r['petName'],
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              // Edit / Delete
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.blue, size: 18),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 30, minHeight: 30),
                onPressed: () => _showEditReminderSheet(context, r),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 18),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 30, minHeight: 30),
                onPressed: () => setState(() {
                  reminders.remove(r);
                  applyFilters();
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Date row
          Row(children: [
            const Icon(Icons.calendar_today_outlined,
                size: 13, color: Colors.grey),
            const SizedBox(width: 5),
            Text("${r['date']} at ${r['time']}",
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
          // Repeat row
          if (repeat != 'Never') ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.repeat, size: 13, color: Colors.grey),
              const SizedBox(width: 5),
              Text("Repeats ${repeat.toLowerCase()}",
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
            ]),
          ],
          // Description
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('"$desc"',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 10),
          // Tags
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (type.isNotEmpty) _filledTag(type, primaryTeal),
              if (repeat != 'Never') _outlineTag(repeat, primaryTeal),
              if (priority.isNotEmpty)
                _filledTag(priority, const Color(0xFFE07B6A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filledTag(String text, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );

  Widget _outlineTag(String text, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );

  // ── New Reminder sheet ──────────────────────────────────────────────────────

  void _showNewReminderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewReminderSheet(
        primaryTeal: primaryTeal,
        availablePets:
            petNames.where((n) => n != 'All Pets').toList(),
        onAdd: _addReminder,
      ),
    );
  }

  // ── Edit Reminder sheet ─────────────────────────────────────────────────────

  void _showEditReminderSheet(BuildContext context, Map<String, dynamic> r) {
    final titleCtrl = TextEditingController(text: r['title']);
    final notesCtrl =
        TextEditingController(text: r['description'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF0F4F3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text("Cancel",
                        style: TextStyle(
                            color: primaryTeal, fontSize: 15)),
                  ),
                  const Text("Edit Reminder",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        r['title'] = titleCtrl.text.trim();
                        r['description'] = notesCtrl.text.trim();
                      });
                      Navigator.pop(ctx);
                    },
                    child: Text("Save",
                        style: TextStyle(
                            color: primaryTeal, fontSize: 15)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                            hintText: 'Title',
                            border: InputBorder.none),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: notesCtrl,
                        decoration: const InputDecoration(
                            hintText: 'Notes',
                            border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── New Reminder Sheet ────────────────────────────────────────────────────────

class _NewReminderSheet extends StatefulWidget {
  final Color primaryTeal;
  final List<String> availablePets;
  final void Function(Map<String, dynamic>) onAdd;

  const _NewReminderSheet({
    required this.primaryTeal,
    required this.availablePets,
    required this.onAdd,
  });

  @override
  State<_NewReminderSheet> createState() => _NewReminderSheetState();
}

class _NewReminderSheetState extends State<_NewReminderSheet> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedPet;
  DateTime _selectedDateTime =
      DateTime.now().copyWith(hour: 9, minute: 0, second: 0);
  String _repeat = 'Never';
  String _type = 'Vaccination';
  String _priority = 'Medium';

  final _repeatOptions = ['Never', 'Daily', 'Weekly', 'Monthly', 'Yearly'];
  final _typeOptions = ['Vaccination', 'Medication', 'Grooming', 'Checkup'];
  final _priorityOptions = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _formattedDateTime {
    final dt = _selectedDateTime;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year} $h:$m";
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: widget.primaryTeal),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: _selectedDateTime.hour, minute: _selectedDateTime.minute),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: widget.primaryTeal),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<String?> _showOptions(String title, List<String> options,
      String current) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        children: options
            .map((o) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, o),
                  child: Row(
                    children: [
                      Icon(
                        o == current
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: widget.primaryTeal,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(o, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Future<void> _pickPet() async {
    if (widget.availablePets.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No pets found. Add a pet first.")),
      );
      return;
    }
    final result = await _showOptions(
        'Select Pet', widget.availablePets, _selectedPet ?? '');
    if (result != null) setState(() => _selectedPet = result);
  }

  void _onAdd() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a title")),
      );
      return;
    }

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dt = _selectedDateTime;
    final hour12 = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    final amPm = dt.hour < 12 ? 'AM' : 'PM';

    widget.onAdd({
      'title': _titleCtrl.text.trim(),
      'petName': _selectedPet ?? 'Unknown',
      'time': "$hour12:${dt.minute.toString().padLeft(2, '0')} $amPm",
      'date':
          "${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}",
      'dateTime': _selectedDateTime,
      'description': _notesCtrl.text.trim(),
      'type': _type,
      'repeat': _repeat,
      'priority': _priority == 'High'
          ? 'High Priority'
          : _priority == 'Low'
              ? 'Low Priority'
              : 'Medium Priority',
      'image':
          'https://images.unsplash.com/photo-1543466835-00a7907e9de1',
      'isLocal': false,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          // Header row: Cancel | New Reminder | Add
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel",
                      style: TextStyle(
                          color: widget.primaryTeal, fontSize: 15)),
                ),
                const Text("New Reminder",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: _onAdd,
                  child: Text("Add",
                      style: TextStyle(
                          color: widget.primaryTeal, fontSize: 15)),
                ),
              ],
            ),
          ),
          // White form card
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  // Title field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    child: TextField(
                      controller: _titleCtrl,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none),
                    ),
                  ),
                  // Notes field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    child: TextField(
                      controller: _notesCtrl,
                      style: const TextStyle(
                          fontSize: 15, color: Colors.grey),
                      decoration: const InputDecoration(
                          hintText: 'Notes',
                          border: InputBorder.none),
                    ),
                  ),
                  const Divider(height: 1),
                  // Pet row
                  _row("Pet", _selectedPet ?? "Choose", _pickPet),
                  const Divider(height: 1, indent: 16),
                  // Date & Time row
                  _row("Date & Time", _formattedDateTime, _pickDateTime),
                  const Divider(height: 1, indent: 16),
                  // Repeat row
                  _row("Repeat", _repeat, () async {
                    final r = await _showOptions(
                        'Repeat', _repeatOptions, _repeat);
                    if (r != null) setState(() => _repeat = r);
                  }),
                  const Divider(height: 1, indent: 16),
                  // Type row
                  _row("Type", _type, () async {
                    final r = await _showOptions(
                        'Type', _typeOptions, _type);
                    if (r != null) setState(() => _type = r);
                  }),
                  const Divider(height: 1, indent: 16),
                  // Priority row
                  _row("Priority", _priority.toLowerCase(), () async {
                    final r = await _showOptions(
                        'Priority', _priorityOptions, _priority);
                    if (r != null) setState(() => _priority = r);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 15, color: Colors.black87)),
            Row(
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 15, color: Colors.grey)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    size: 18, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
