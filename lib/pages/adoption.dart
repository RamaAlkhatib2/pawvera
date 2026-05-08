 import 'package:flutter/material.dart';
import 'home.dart';
import 'my_bookings_page.dart';
import 'profile_view.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  _AdoptionScreenState createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  final Color primaryTeal = Color(0xFF5BA092);
  final Color backgroundCream = Color(0xFFF9F6EE);

  // Messages/Conversations storage
  Map<String, List<Map<String, dynamic>>> conversations = {};
  final TextEditingController _messageController = TextEditingController();
  String selectedFilter = "All";
  List<Map<String, dynamic>> allPets = [
    {
      "name": "Luna",
      "type": "Cat",
      "desc":
          "Playful kitten, great with children. Very affectionate and loves to cuddle.",
      "location": "West Side Rescue",
      "age": "1 year old",
      "gender": "Female",
      "image": "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba"
    },
  ];
  List<Map<String, dynamic>> filteredPets = [];

  @override
  void initState() {
    super.initState();
    filteredPets = allPets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        title: Text('Adoption',
            style: TextStyle(
                color: Color(0xFF5D4037), fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PostPetPage(onSubmit: _addPet)),
              ),
              icon: Icon(Icons.add, size: 18),
              label: Text("Post"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // شريط البحث والفلاتر
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText:
                          'Search pets by name, description, or location...',
                      prefixIcon: Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip("All", selectedFilter == "All"),
                        _buildFilterChip("Dogs", selectedFilter == "Dogs"),
                        _buildFilterChip("Cats", selectedFilter == "Cats"),
                        _buildFilterChip("Birds", selectedFilter == "Birds"),
                        _buildFilterChip("Other", selectedFilter == "Other"),
                        SizedBox(width: 10),
                        ActionChip(
                          avatar: Icon(Icons.tune, size: 16),
                          label: Text("Filters"),
                          onPressed: () => _showAdvancedFilters(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Display filtered pets
            ...filteredPets
                .map((pet) => _buildPetCard(
                      context,
                      pet["name"],
                      pet["type"],
                      pet["desc"],
                      pet["location"],
                      pet["age"],
                      pet["gender"],
                      pet["image"],
                    ))
                ,
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
              break;
            case 1:
              // Already on adoption/home page
              break;
            case 2:
              _showMessagesSheet(context);
              break;
            case 3:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyBookingsPage()));
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

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool value) {
          setState(() {
            selectedFilter = label;
            if (label == "All") {
              filteredPets = allPets;
            } else {
              filteredPets =
                  allPets.where((pet) => pet["type"] == label).toList();
            }
          });
        },
        selectedColor: primaryTeal.withOpacity(0.2),
        checkmarkColor: primaryTeal,
      ),
    );
  }

  void _showAdvancedFilters(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Advanced Filters"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Filter options",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            CheckboxListTile(
              title: Text("Show only available"),
              value: true,
              onChanged: (val) {},
            ),
            CheckboxListTile(
              title: Text("Distance: 10 km"),
              value: true,
              onChanged: (val) {},
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Apply")),
        ],
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, String name, String type,
      String desc, String location, String age, String gender, String imgUrl) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(imgUrl,
                height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(type, style: TextStyle(fontSize: 12))),
                  ],
                ),
                SizedBox(height: 10),
                Text(desc, style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey),
                  Text(" $location  •  $age  •  $gender",
                      style: TextStyle(color: Colors.grey, fontSize: 13))
                ]),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showChatSheet(context, name, "Mike Chen"),
                    icon: Icon(Icons.favorite_border),
                    label: Text("Interested to Adopt"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showChatSheet(BuildContext context, String petName, String ownerName) {
    String conversationKey = "$ownerName - $petName";

    // Initialize conversation if it doesn't exist
    if (!conversations.containsKey(conversationKey)) {
      conversations[conversationKey] = [];
    }

    _messageController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.chat_bubble_outline, color: Colors.brown),
              title: Text("Chat with $ownerName",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("About adopting $petName"),
              trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ),
            Expanded(
              child: StatefulBuilder(
                builder: (context, setState) => ListView.builder(
                  itemCount: conversations[conversationKey]!.length,
                  itemBuilder: (context, index) {
                    var msg = conversations[conversationKey]![index];
                    bool isUser = msg['isUser'] ?? false;
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isUser ? primaryTeal : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Message input field
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                          hintText: "Type your message...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: primaryTeal,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          setState(() {
                            conversations[conversationKey]!.add({
                              'text': _messageController.text,
                              'isUser': true,
                            });
                          });
                          _messageController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _addPet(Map<String, dynamic> pet) {
    setState(() {
      allPets.add(pet);
      if (selectedFilter == "All") {
        filteredPets = allPets;
      } else {
        filteredPets =
            allPets.where((item) => item["type"] == selectedFilter).toList();
      }
    });
  }

  void _showMessagesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Messages",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown)),
            TextField(
                decoration: InputDecoration(
                    hintText: "Search conversations...",
                    prefixIcon: Icon(Icons.search))),
            Expanded(
              child: conversations.isEmpty
                  ? Center(
                      child: Text("No messages yet",
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        String key = conversations.keys.elementAt(index);
                        List<Map<String, dynamic>> messages =
                            conversations[key]!;
                        String lastMessage = messages.isNotEmpty
                            ? messages.last['text'] ?? ""
                            : "No messages";
                        String preview = lastMessage.length > 30
                            ? "${lastMessage.substring(0, 30)}..."
                            : lastMessage;

                        return ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text(key),
                          subtitle: Text(preview,
                              style: TextStyle(color: Colors.grey)),
                          trailing: Text(
                              "${messages.length} message${messages.length != 1 ? 's' : ''}",
                              style: TextStyle(fontSize: 12)),
                          onTap: () {
                            Navigator.pop(context);
                            // Re-open the chat for this conversation
                            List<String> parts = key.split(" - ");
                            if (parts.length == 2) {
                              _showChatSheet(context, parts[1], parts[0]);
                            }
                          },
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))));
  Widget _buildMessageTile(String name, String sub, String date) => ListTile(
      leading: CircleAvatar(child: Icon(Icons.person)),
      title: Text(name),
      subtitle: Text(sub),
      trailing: Text(date));
}

class PostPetPage extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;

  const PostPetPage({super.key, required this.onSubmit});

  @override
  State<PostPetPage> createState() => _PostPetPageState();
}

class _PostPetPageState extends State<PostPetPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _behaviorController = TextEditingController();
  bool _vaccinated = false;
  String _type = 'Cat';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _behaviorController.dispose();
    super.dispose();
  }

  void _submitPet() {
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _behaviorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final ageText = _ageController.text.trim();
    final age = int.tryParse(ageText);
    if (age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid age in years.')),
      );
      return;
    }

    widget.onSubmit({
      'name': _nameController.text.trim(),
      'type': _type,
      'desc': _behaviorController.text.trim(),
      'location': 'User Posted',
      'age': '$age year${age == 1 ? '' : 's'} old',
      'gender': 'Unknown',
      'image': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba',
      'vaccinated': _vaccinated ? 'Yes' : 'No',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pet posted successfully.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Your Pet'),
        backgroundColor: Color(0xFF5BA092),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pet Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Pet Name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Age (years)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Type',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _type,
                  items: ['Cat', 'Dog', 'Bird', 'Other']
                      .map((value) =>
                          DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _type = value);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Vaccinated'),
              value: _vaccinated,
              onChanged: (value) => setState(() => _vaccinated = value),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _behaviorController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Behaviors',
                alignLabelWithHint: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitPet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5BA092),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

