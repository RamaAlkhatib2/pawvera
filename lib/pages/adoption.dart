import 'package:flutter/material.dart';

class AdoptionScreen extends StatelessWidget {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search pets by name, description, or location...',
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
            _buildPetCard(
              context,
              'https://images.unsplash.com/photo-1552053831-71594a27632d',
              'Max',
              'Dog',
              'Friendly golden retriever looking for a loving home. Great with kids and other pets!',
              'Downtown Shelter',
              '2 years old',
              'Male',
              primaryTeal,
              'Sarah Johnson', // اسم الشخص المتبنى
            ),
            _buildPetCard(
              context,
              'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba',
              'Luna',
              'Cat',
              'Playful kitten, great with children. Very affectionate and loves to cuddle.',
              'West Side Rescue',
              '1 year old',
              'Female',
              primaryTeal,
              'Mike Chen',
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)),
        side: BorderSide(color: Colors.grey.shade300),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
    String adopterName,
  ) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade50),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(petName,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[900])),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(petType,
                          style: TextStyle(color: Colors.teal, fontSize: 11)),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(description,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 13, height: 1.4)),
                SizedBox(height: 12),
                _buildInfoRow(Icons.location_on_outlined, location),
                _buildInfoRow(Icons.access_time_outlined, age),
                _buildInfoRow(Icons.transgender, gender),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showChatModal(context, petName, adopterName),
                    icon: Icon(Icons.favorite_border, size: 18),
                    label: Text('Interested to Adopt',
                        style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 6),
          Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
    );
  }

  void _showChatModal(
      BuildContext context, String petName, String adopterName) {
    final chatBackground = Color(0xFFEDFBF9);
    final primaryTeal = Color(0xFF5BA092);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: chatBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                color: Colors.brown, size: 20),
                            SizedBox(width: 8),
                            Text('Chat with $adopterName',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                    fontSize: 16)),
                          ],
                        ),
                        IconButton(
                            icon: Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Text('About adopting $petName',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.teal[700])),
                        )),
                  ],
                ),
              ),
              Divider(height: 1),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 50, color: Colors.teal.withOpacity(0.3)),
                      SizedBox(height: 10),
                      Text('Start a conversation about adopting $petName',
                          style:
                              TextStyle(color: Colors.teal[300], fontSize: 12)),
                    ],
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 10),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(fontSize: 13),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: primaryTeal.withOpacity(0.4),
                      child: Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
 
