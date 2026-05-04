import 'package:flutter/material.dart';

/// Opened from the home header bell ([Home] → NotificationsPage via [Navigator.push]).
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  /// Header / accents — muted sage teal from design.
  static const Color _teal = Color(0xFF66A592);

  /// List background — cool light grey.
  static const Color _bodyBg = Color(0xFFEEF2F3);

  static const Color _titleColor = Color(0xFF1A1A1A);
  static const Color _bodyTextColor = Color(0xFF666666);
  static const Color _timestampColor = Color(0xFF999999);

  final List<NotificationEntry> notifications = [
    // Purple outline calendar on soft lilac tile
    NotificationEntry(
      id: '1',
      title: 'Upcoming Appointment',
      description: 'Grooming appointment for Bella at 3:00 PM today',
      timeAgo: '4 hours ago',
      icon: Icons.calendar_today_outlined,
      iconAccent: Color(0xFF8B6BC9),
      iconBg: Color(0xFFF2EBFA),
      isRead: false,
    ),
    // Bright green outline shopping bag on mint tile
    NotificationEntry(
      id: '2',
      title: 'Order Shipped',
      description: 'Your order of Premium Dog Food is on the way',
      timeAgo: '1 day ago',
      icon: Icons.shopping_bag_outlined,
      iconAccent: Color(0xFF2ECC71),
      iconBg: Color(0xFFE8F8EF),
      isRead: true,
    ),
    // Red outline heart on blush tile
    NotificationEntry(
      id: '3',
      title: 'New Adoption Listing',
      description:
          'A Golden Retriever puppy is available for adoption near you',
      timeAgo: '1 day ago',
      icon: Icons.favorite_outline_rounded,
      iconAccent: Color(0xFFE54D62),
      iconBg: Color(0xFFFCEBED),
      isRead: true,
    ),
    // Blue outline clock on ice-blue tile
    NotificationEntry(
      id: '4',
      title: 'Walking Time',
      description: 'Time for Charlie\'s evening walk',
      timeAgo: '2 days ago',
      icon: Icons.schedule_outlined,
      iconAccent: Color(0xFF5B8FD9),
      iconBg: Color(0xFFEAF2FC),
      isRead: true,
    ),
    // Same purple calendar treatment as appointments
    NotificationEntry(
      id: '5',
      title: 'Appointment Confirmed',
      description: 'Your appointment has been confirmed',
      timeAgo: '3 days ago',
      icon: Icons.calendar_today_outlined,
      iconAccent: Color(0xFF8B6BC9),
      iconBg: Color(0xFFF2EBFA),
      isRead: false,
    ),
  ];

  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  int get _unreadCount => notifications.where((n) => !n.isRead).length;
  int get _selectedCount => _selectedIds.length;

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds.clear();
      _selectedIds.addAll(notifications.map((e) => e.id));
    });
  }

  void _deleteById(String id) {
    setState(() {
      notifications.removeWhere((e) => e.id == id);
      _selectedIds.remove(id);
    });
  }

  void _deleteSelected() {
    setState(() {
      notifications.removeWhere((e) => _selectedIds.contains(e.id));
      _selectedIds.clear();
      _selectionMode = false;
    });
  }

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    });
  }

  void _markOneRead(String id) {
    setState(() {
      final i = notifications.indexWhere((e) => e.id == id);
      if (i >= 0) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bodyBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGreenHeader(context),
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) =>
                        _buildCard(notifications[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreenHeader(BuildContext context) {
    final curved = ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: Container(
        color: _teal,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        if (_selectionMode) {
                          _exitSelectionMode();
                        } else {
                          Navigator.maybePop(context);
                        }
                      },
                    ),
                    if (_selectionMode) ...[
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_selectedCount Selected',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_unreadCount new',
                          style: const TextStyle(
                            color: Color(0xFF3D3D3D),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                if (_selectionMode)
                  Row(
                    children: [
                      Expanded(
                        child: _glassChip(
                          icon: Icons.check_box_outlined,
                          label: 'Select All',
                          onTap: _selectAll,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Material(
                          color: const Color(0xFF558F7F),
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: _selectedCount > 0 ? _deleteSelected : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Delete ($_selectedCount)',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _glassChip(
                          icon: Icons.done_all_rounded,
                          label: 'Mark all as read',
                          onTap: notifications.isEmpty ? null : _markAllRead,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _glassChip(
                          icon: Icons.checklist_rtl_rounded,
                          label: 'Select',
                          onTap: notifications.isEmpty
                              ? null
                              : () => setState(() => _selectionMode = true),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return curved;
  }

  Widget _glassChip({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    return Material(
      color: Colors.white.withValues(alpha: disabled ? 0.08 : 0.22),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white.withValues(alpha: disabled ? 0.5 : 1),
                size: 16,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: disabled ? 0.55 : 1),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(NotificationEntry n) {
    final selected = _selectedIds.contains(n.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectionMode
              ? (selected ? _teal : const Color(0xFFE0E4E3))
              : const Color(0xFFE4EAE8),
          width: _selectionMode && selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _selectionMode
              ? () => _toggleSelect(n.id)
              : () => _markOneRead(n.id),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectionMode) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 8, top: 4),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: selected,
                            onChanged: (_) => _toggleSelect(n.id),
                            side: const BorderSide(color: _teal, width: 1.8),
                            fillColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return _teal;
                              }
                              return Colors.transparent;
                            }),
                            checkColor: Colors.white,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: n.iconBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: n.iconAccent.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Icon(n.icon, color: n.iconAccent, size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        n.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _titleColor,
                        ),
                      ),
                    ),
                    if (!_selectionMode && !n.isRead)
                      Padding(
                        padding: const EdgeInsets.only(right: 4, top: 2),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _teal,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    if (!_selectionMode)
                      Material(
                        color: const Color(0xFFECEFF0),
                        borderRadius: BorderRadius.circular(6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => _deleteById(n.id),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: _selectionMode ? 30 : 0),
                  child: Text(
                    n.description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: _bodyTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: _selectionMode ? 30 : 0),
                        child: Text(
                          n.timeAgo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _timestampColor,
                          ),
                        ),
                      ),
                    ),
                    if (!_selectionMode && !n.isRead)
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _markOneRead(n.id),
                        child: Text(
                          'Mark as read',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationEntry {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final IconData icon;

  /// Outline icon color (purple / green / red / blue).
  final Color iconAccent;

  /// Soft tile behind the icon.
  final Color iconBg;
  final bool isRead;

  NotificationEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.iconAccent,
    required this.iconBg,
    required this.isRead,
  });

  NotificationEntry copyWith({bool? isRead}) {
    return NotificationEntry(
      id: id,
      title: title,
      description: description,
      timeAgo: timeAgo,
      icon: icon,
      iconAccent: iconAccent,
      iconBg: iconBg,
      isRead: isRead ?? this.isRead,
    );
  }
}
