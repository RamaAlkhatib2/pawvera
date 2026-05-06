 import 'package:flutter/material.dart';

class AdoptionScreen extends StatefulWidget {
  @override
  _AdoptionScreenState createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  final Color primaryTeal = Color(0xFF5BA092);
  final Color backgroundCream = Color(0xFFF9F6EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: () {}),
        title: Text('Adoption', style: TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold)),
        actions: [
            
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showPostPetSheet(context),
              icon: Icon(Icons.add, size: 18),
              label: Text("Post"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      hintText: 'Search pets by name, description, or location...',
                      prefixIcon: Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip("All", true),
                        _buildFilterChip("Dogs", false),
                        _buildFilterChip("Cats", false),
                        _buildFilterChip("Birds", false),
                        _buildFilterChip("Other", false),
                        SizedBox(width: 10),
                        ActionChip(
                          avatar: Icon(Icons.tune, size: 16),
                          label: Text("Filters"),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // كرت الحيوان (Luna)
            _buildPetCard(
              context,
              "Luna",
              "Cat",
              "Playful kitten, great with children. Very affectionate and loves to cuddle.",
              "West Side Rescue",
              "1 year old",
              "Female",
              "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba",
            ),
          ],
        ),
      ),
        
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) _showMessagesSheet(context);   
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: "My Pets"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "My Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
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
        onSelected: (bool value) {},
        selectedColor: primaryTeal.withValues(alpha: 0.2),
        checkmarkColor: primaryTeal,
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, String name, String type, String desc, String location, String age, String gender, String imgUrl) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(imgUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)), child: Text(type, style: TextStyle(fontSize: 12))),
                  ],
                ),
                SizedBox(height: 10),
                Text(desc, style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 12),
                Row(children: [Icon(Icons.location_on_outlined, size: 16, color: Colors.grey), Text(" $location  •  $age  •  $gender", style: TextStyle(color: Colors.grey, fontSize: 13))]),
                SizedBox(height: 15),
                  
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showChatSheet(context, name, "Mike Chen"),
                    icon: Icon(Icons.favorite_border),
                    label: Text("Interested to Adopt"),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.chat_bubble_outline, color: Colors.brown),
              title: Text("Chat with $ownerName", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("About adopting $petName"),
              trailing: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ),
            Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]), Text("Start a conversation about adopting $petName", style: TextStyle(color: Colors.grey))]))),
            // حقل الكتابة والارسال
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(hintText: "Type your message...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                    ),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(backgroundColor: primaryTeal, child: IconButton(icon: Icon(Icons.send, color: Colors.white), onPressed: () {})),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

   
  void _showPostPetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Post Pet for Adoption", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown)),
              Text("Fill in the details about the pet you want to list", style: TextStyle(color: Colors.grey, fontSize: 13)),
              SizedBox(height: 20),
              Container(height: 100, width: double.infinity, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none), borderRadius: BorderRadius.circular(15), color: Colors.teal.shade50), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.upload, color: primaryTeal), Text("Upload photos", style: TextStyle(color: primaryTeal))])),
              _buildInputLabel("Pet Name"), TextField(decoration: InputDecoration(border: OutlineInputBorder())),
              _buildInputLabel("Description"), TextField(maxLines: 3, decoration: InputDecoration(border: OutlineInputBorder())),
              SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Post for Adoption"), style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white))),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessagesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Messages", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
            TextField(decoration: InputDecoration(hintText: "Search conversations...", prefixIcon: Icon(Icons.search))),
            Expanded(
              child: ListView(
                children: [
                  _buildMessageTile("Sarah Johnson", "About: Max", "Jan 13"),
                  _buildMessageTile("Mike Chen", "About: Luna", "Jan 13"),
                  _buildMessageTile("Emma Davis", "About: Charlie", "Jan 12"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Align(alignment: Alignment.centerLeft, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))));
  Widget _buildMessageTile(String name, String sub, String date) => ListTile(leading: CircleAvatar(child: Icon(Icons.person)), title: Text(name), subtitle: Text(sub), trailing: Text(date));
}
