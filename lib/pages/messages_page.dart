import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawvera/services/database_service.dart';
import 'home.dart';
import 'my_bookings_page.dart';
import 'profile_view.dart';

class MessagesPage extends StatefulWidget {
  final bool showBackButton;
  const MessagesPage({super.key, this.showBackButton = true});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final Color primaryTeal = const Color(0xFF5BA092);
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
        () => setState(() => _searchQuery = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Messages',
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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
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
          Expanded(
            child: currentUid == null
                ? const Center(child: Text('Log in to see your messages.'))
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _db.myConversations,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red)));
                      }
                      final rawDocs = snapshot.data?.docs ?? [];
                      rawDocs.sort((a, b) {
                        final at = a.data()['lastMessageTime'] as Timestamp?;
                        final bt = b.data()['lastMessageTime'] as Timestamp?;
                        if (at == null) return 1;
                        if (bt == null) return -1;
                        return bt.compareTo(at);
                      });
                      final docs = rawDocs;
                      final filtered = _searchQuery.isEmpty
                          ? docs
                          : docs.where((doc) {
                              final data = doc.data();
                              final petName =
                                  (data['petName'] ?? '').toString().toLowerCase();
                              final adopterName = (data['adopterName'] ?? '')
                                  .toString()
                                  .toLowerCase();
                              final ownerName = (data['ownerName'] ?? '')
                                  .toString()
                                  .toLowerCase();
                              final q = _searchQuery.toLowerCase();
                              return petName.contains(q) ||
                                  adopterName.contains(q) ||
                                  ownerName.contains(q);
                            }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text(
                              'No conversations yet.\nTap "Interested to Adopt" on any pet to start chatting.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 0),
                        itemBuilder: (context, index) {
                          final data = filtered[index].data();
                          final convId = filtered[index].id;
                          final isAdopter = data['adopterId'] == currentUid;
                          final contactName = isAdopter
                              ? (data['ownerName'] ?? 'Pet Owner')
                              : (data['adopterName'] ?? 'User');
                          final petName = data['petName'] ?? '';
                          final lastMessage = data['lastMessage'] ?? '';
                          final dateStr = _formatDate(
                              data['lastMessageTime'] as Timestamp?);

                          return _ConversationTile(
                            contactName: contactName,
                            petName: petName,
                            lastMessage: lastMessage,
                            date: dateStr,
                            primaryTeal: primaryTeal,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FirestoreChatPage(
                                    conversationId: convId,
                                    petName: petName,
                                    contactName: contactName,
                                  ),
                                ),
                              );
                            },
                            onDelete: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Conversation'),
                                  content: const Text(
                                    'This will permanently delete the conversation and all its messages.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await _db.deleteConversation(convId);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBackButton
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: primaryTeal,
              unselectedItemColor: const Color(0xFF9E9E9E),
              currentIndex: 2,
              onTap: (index) {
                if (index == 0 || index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Home()),
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyBookingsPage()),
                  );
                } else if (index == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileView()),
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.pets_outlined), label: 'My Pets'),
                BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: 'Messages'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'My Bookings'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            )
          : null,
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String contactName;
  final String petName;
  final String lastMessage;
  final String date;
  final Color primaryTeal;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ConversationTile({
    required this.contactName,
    required this.petName,
    required this.lastMessage,
    required this.date,
    required this.primaryTeal,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: primaryTeal.withValues(alpha: 0.15),
              child: Icon(Icons.person, color: primaryTeal, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        contactName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF333333),
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'About: $petName',
                    style: TextStyle(
                      color: primaryTeal,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage.isEmpty ? 'Start a conversation...' : lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Firestore-backed Chat Page ────────────────────────────────────────────────

class FirestoreChatPage extends StatefulWidget {
  final String conversationId;
  final String petName;
  final String contactName;

  const FirestoreChatPage({
    super.key,
    required this.conversationId,
    required this.petName,
    required this.contactName,
  });

  @override
  State<FirestoreChatPage> createState() => _FirestoreChatPageState();
}

class _FirestoreChatPageState extends State<FirestoreChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  final String? _currentUid = FirebaseAuth.instance.currentUser?.uid;
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _messageController.clear();
    try {
      await _db.sendMessage(widget.conversationId, text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Text(
              widget.contactName,
              style: const TextStyle(
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'About: ${widget.petName}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db.streamMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Say hello! 👋',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = docs[index].data();
                    final isMe = msg['senderId'] == _currentUid;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF5BA092)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _send,
                  mini: true,
                  backgroundColor: const Color(0xFF5BA092),
                  child: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
