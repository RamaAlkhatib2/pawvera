import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawvera/services/database_service.dart';
import 'home.dart';
import 'my_bookings_page.dart';
import 'profile_view.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final Color primaryTeal = const Color(0xFF5BA092);
  int _selectedIndex = 0;

  String selectedType = 'All';
  String selectedPet = 'All Pets';
  final TextEditingController searchController = TextEditingController();

  final DatabaseService _db = DatabaseService();
  List<String> _firestorePetNames = [];
  List<String> _reminderTypeNames = ['Vaccination', 'Medication', 'Grooming', 'Checkup'];
  StreamSubscription<QuerySnapshot>? _petsSubscription;
  StreamSubscription<QuerySnapshot>? _typesSubscription;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() {}));
    _db.seedDefaultReminderTypesIfEmpty();
    _db.checkAndFireDueReminderNotifications().catchError((_) {});

    _petsSubscription = _db.userPets.listen((snap) {
      setState(() {
        _firestorePetNames = snap.docs
            .map((d) => (d.data() as Map)['name'] as String? ?? '')
            .where((n) => n.isNotEmpty)
            .toList();
      });
    });

    _typesSubscription = _db.streamReminderTypes().listen((snap) {
      setState(() {
        _reminderTypeNames = snap.docs
            .map((d) => d.data()['name'] as String? ?? '')
            .where((n) => n.isNotEmpty)
            .toList();
        if (_reminderTypeNames.isEmpty) {
          _reminderTypeNames = ['Vaccination', 'Medication', 'Grooming', 'Checkup'];
        }
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _petsSubscription?.cancel();
    _typesSubscription?.cancel();
    super.dispose();
  }

  List<String> get petFilterOptions => ['All Pets', ..._firestorePetNames];

  String _formatDate(DateTime dt) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour == 0 ? 12 : dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ap = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:${dt.minute.toString().padLeft(2, '0')} $ap';
  }

  void _showNewReminderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReminderFormSheet(
        primaryTeal: primaryTeal,
        availablePets: _firestorePetNames,
        availableTypes: _reminderTypeNames,
      ),
    );
  }

  void _showEditSheet(Map<String, dynamic> r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReminderFormSheet(
        primaryTeal: primaryTeal,
        availablePets: _firestorePetNames,
        availableTypes: _reminderTypeNames,
        existing: r,
      ),
    );
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
        title: const Text(
          'My Reminders',
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search reminders...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
              children: ['All', ..._reminderTypeNames].map((t) =>
                _chip(t, selectedType == t, () =>
                    setState(() => selectedType = t))).toList(),
            ),
          ),
          // Pet filter chips
          if (_firestorePetNames.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: petFilterOptions.map((p) =>
                  _chip(p, selectedPet == p, () =>
                      setState(() => selectedPet = p))).toList(),
              ),
            ),
          // Reminder list from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.reminders,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final now = DateTime.now();
                final q = searchController.text.toLowerCase();

                final all = (snapshot.data?.docs ?? []).map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final ts = data['dateTime'] as Timestamp?;
                  return {...data, 'id': doc.id, '_dt': ts?.toDate() ?? now};
                }).where((r) {
                  final matchType = selectedType == 'All' || r['type'] == selectedType;
                  final matchPet = selectedPet == 'All Pets' || r['petName'] == selectedPet;
                  final matchSearch = q.isEmpty ||
                      (r['title'] ?? '').toString().toLowerCase().contains(q);
                  return matchType && matchPet && matchSearch;
                }).toList();

                final past = all.where((r) =>
                    (r['_dt'] as DateTime).isBefore(now)).toList();
                final upcoming = all.where((r) =>
                    !(r['_dt'] as DateTime).isBefore(now)).toList();

                if (all.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No reminders found',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    if (past.isNotEmpty) ...[
                      _sectionHeader('Past', past.length),
                      ...past.map(_buildReminderCard),
                    ],
                    if (upcoming.isNotEmpty) ...[
                      _sectionHeader('Upcoming', upcoming.length),
                      ...upcoming.map(_buildReminderCard),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryTeal,
        onPressed: _showNewReminderSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryTeal,
        unselectedItemColor: const Color(0xFF9E9E9E),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const Home()));
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MyBookingsPage()));
          } else if (index == 4) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => ProfileView()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets_outlined), label: 'My Pets'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'My Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

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

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: primaryTeal, borderRadius: BorderRadius.circular(12)),
          child: Text('$count',
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
      ]),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> r) {
    final dt = r['_dt'] as DateTime;
    final priority = r['priority'] as String? ?? '';
    final isHigh = priority.toLowerCase().contains('high');
    final type = r['type'] as String? ?? '';
    final repeat = r['repeat'] as String? ?? 'Never';
    final desc = r['description'] as String? ?? '';
    final reminderId = r['id'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                  color: const Color(0xFFF4CFC6),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.calendar_today_outlined,
                  color: Color(0xFFE07B6A), size: 22),
            ),
            if (isHigh)
              Positioned(
                top: -4, right: -4,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE53935), shape: BoxShape.circle),
                  child: const Icon(Icons.priority_high,
                      color: Colors.white, size: 10),
                ),
              ),
          ]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r['title'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15,
                      color: Color(0xFF333333))),
              const SizedBox(height: 2),
              Text(r['petName'] ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            onPressed: () => _showEditSheet(r),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _db.deleteReminder(reminderId);
              } catch (e) {
                messenger.showSnackBar(SnackBar(
                    content: Text('Failed to delete: $e'),
                    backgroundColor: Colors.red));
              }
            },
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
          const SizedBox(width: 5),
          Text('${_formatDate(dt)} at ${_formatTime(dt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
        if (repeat != 'Never') ...[
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.repeat, size: 13, color: Colors.grey),
            const SizedBox(width: 5),
            Text('Repeats ${repeat.toLowerCase()}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ],
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('"$desc"',
              style: const TextStyle(
                  color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 4, children: [
          if (type.isNotEmpty) _filledTag(type, primaryTeal),
          if (repeat != 'Never') _outlineTag(repeat, primaryTeal),
          if (priority.isNotEmpty)
            _filledTag(priority, const Color(0xFFE07B6A)),
        ]),
      ]),
    );
  }

  Widget _filledTag(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
    child: Text(text,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
  );

  Widget _outlineTag(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
        border: Border.all(color: color), borderRadius: BorderRadius.circular(20)),
    child: Text(text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

// ─── Unified Create / Edit Reminder Sheet ─────────────────────────────────────

class _ReminderFormSheet extends StatefulWidget {
  final Color primaryTeal;
  final List<String> availablePets;
  final List<String> availableTypes;
  final Map<String, dynamic>? existing; // null = create, non-null = edit

  const _ReminderFormSheet({
    required this.primaryTeal,
    required this.availablePets,
    required this.availableTypes,
    this.existing,
  });

  @override
  State<_ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<_ReminderFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;

  late String? _selectedPet;
  late DateTime _selectedDateTime;
  late String _repeat;
  late String _type;
  late String _priority;
  bool _loading = false;

  final _repeatOptions = ['Never', 'Daily', 'Weekly', 'Monthly', 'Yearly'];
  final _priorityOptions = ['Low', 'Medium', 'High'];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?['title'] ?? '');
    _notesCtrl = TextEditingController(text: e?['description'] ?? '');
    _selectedPet = e?['petName'];
    final ts = e?['_dt'] as DateTime?;
    _selectedDateTime = ts ?? DateTime.now().copyWith(hour: 9, minute: 0, second: 0);
    _repeat = e?['repeat'] ?? 'Never';
    _type = e?['type'] ?? (widget.availableTypes.isNotEmpty ? widget.availableTypes.first : 'Vaccination');
    final rawPriority = (e?['priority'] ?? 'Medium') as String;
    _priority = rawPriority.replaceAll(' Priority', '');
    if (!_priorityOptions.contains(_priority)) _priority = 'Medium';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _formattedDateTime {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dt = _selectedDateTime;
    return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2,'0')}, ${dt.year} '
        '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: widget.primaryTeal)),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedDateTime.hour, minute: _selectedDateTime.minute),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: widget.primaryTeal)),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;
    setState(() {
      _selectedDateTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<String?> _showOptions(String title, List<String> options, String current) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: options.map((o) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, o),
          child: Row(children: [
            Icon(
              o == current ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: widget.primaryTeal, size: 18),
            const SizedBox(width: 10),
            Text(o, style: const TextStyle(fontSize: 15)),
          ]),
        )).toList(),
      ),
    );
  }

  Future<void> _pickPet() async {
    if (widget.availablePets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pets found. Add a pet first.')));
      return;
    }
    final result = await _showOptions('Select Pet', widget.availablePets, _selectedPet ?? '');
    if (result != null) setState(() => _selectedPet = result);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    setState(() => _loading = true);
    try {
      final data = {
        'title': _titleCtrl.text.trim(),
        'petName': _selectedPet ?? 'Unknown',
        'type': _type,
        'dateTime': Timestamp.fromDate(_selectedDateTime),
        'repeat': _repeat,
        'priority': '$_priority Priority',
        'description': _notesCtrl.text.trim(),
      };
      if (_isEdit) {
        await DatabaseService().updateReminder(widget.existing!['id'], data);
      } else {
        await DatabaseService().addReminder(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: widget.primaryTeal, fontSize: 15)),
            ),
            Text(_isEdit ? 'Edit Reminder' : 'New Reminder',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEdit ? 'Save' : 'Add',
                      style: TextStyle(color: widget.primaryTeal, fontSize: 15)),
            ),
          ]),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: 16, right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: TextField(
                  controller: _titleCtrl,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                      hintText: 'Title', border: InputBorder.none),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: TextField(
                  controller: _notesCtrl,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                  decoration: const InputDecoration(
                      hintText: 'Notes', border: InputBorder.none),
                ),
              ),
              const Divider(height: 1),
              _row('Pet', _selectedPet ?? 'Choose', _pickPet),
              const Divider(height: 1, indent: 16),
              _row('Date & Time', _formattedDateTime, _pickDateTime),
              const Divider(height: 1, indent: 16),
              _row('Repeat', _repeat, () async {
                final r = await _showOptions('Repeat', _repeatOptions, _repeat);
                if (r != null) setState(() => _repeat = r);
              }),
              const Divider(height: 1, indent: 16),
              _row('Type', _type, () async {
                final r = await _showOptions('Type', widget.availableTypes, _type);
                if (r != null) setState(() => _type = r);
              }),
              const Divider(height: 1, indent: 16),
              _row('Priority', _priority.toLowerCase(), () async {
                final r = await _showOptions('Priority', _priorityOptions, _priority);
                if (r != null) setState(() => _priority = r);
              }),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _row(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          Row(children: [
            Text(value, style: const TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ]),
        ]),
      ),
    );
  }
}
