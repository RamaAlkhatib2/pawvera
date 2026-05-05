import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  List<Map<String, dynamic>> pets = [];
  bool isLoading = true;
  final backend = BackendService();

  // ✅ chat
  TextEditingController messageController = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    // subscribe to pets stream
    backend.petsStream().listen((list) {
      setState(() {
        pets = list;
        isLoading = false;
      });
    });
  }

  

  @override
  Widget build(BuildContext context) {
    final primaryTeal = Color(0xFF5BA092);
    final backgroundCream = Color(0xFFF9F6EE);

    return Scaffold(
      backgroundColor: backgroundCream,
      appBar: AppBar(
        title: Text('Adoption',
            style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {}),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add, size: 16),
              label: Text("Post"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),

      // ✅ Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "My Pets"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Messages"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "My Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText:
                      'Search pets by name, description, or location...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip("All", primaryTeal, Colors.white),
                  _buildFilterChip("Dogs", Colors.white, Colors.brown),
                  _buildFilterChip("Cats", Colors.white, Colors.brown),
                  _buildFilterChip("Birds", Colors.white, Colors.brown),
                  _buildFilterChip("Other", Colors.white, Colors.brown),
                  SizedBox(width: 10),
                  _buildFilterIcon(primaryTeal),
                ],
              ),
            ),
            SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: pets
                    .map((pet) => _buildPetCard(
                          context,
                          pet['image'] ?? '',
                          pet['name'] ?? '',
                          pet['breed'] ?? '',
                          pet['description'] ?? '',
                          pet['location'] ?? '',
                          pet['age']?.toString() ?? '',
                          'Female',
                          primaryTeal,
                          pet['id'] ?? '',
                          pet['ownerId'] ?? '',
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, Color bgColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: TextStyle(color: textColor, fontSize: 12)),
        backgroundColor: bgColor,
      ),
    );
  }

  Widget _buildFilterIcon(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300)),
      child: Icon(Icons.tune, color: primaryColor, size: 20),
    );
  }

  Widget _buildPetCard(
    BuildContext context,
    String imageUrl,
    String petName,
    String petType,
    String description,
    String location,
    String age,
    String gender,
    Color primaryColor,
    String petId,
    String ownerId,
  ) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(imageUrl,
                height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(petName,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(description),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => _showChatModal(context, petName, 'Owner', petId: petId, ownerId: ownerId),
                  child: Text("Interested to Adopt"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showChatModal(
      BuildContext context, String petName, String adopterName,
      {required String petId, required String ownerId}) {
    final primaryTeal = Color(0xFF5BA092);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              SizedBox(height: 10),
              Text("Chat with $adopterName"),
              Text("About adopting $petName"),

              // ✅ messages
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryTeal,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(messages[index],
                            style: TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                ),
              ),

              // ✅ input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration:
                          InputDecoration(hintText: "Type your message..."),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (messageController.text.isNotEmpty) {
                        final text = messageController.text;
                        setState(() {
                          messages.add(text);
                          messageController.clear();
                        });
                        _sendAdoptionRequest(petId, ownerId, text);
                      }
                    },
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendAdoptionRequest(String petId, String ownerId, String message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please log in to send requests')));
      return;
    }
    try {
      await backend.createAdoptionRequest(petId: petId, fromUserId: user.uid, toOwnerId: ownerId, message: message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Adoption request sent')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send request')));
    }
  }
}