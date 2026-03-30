Widget _buildPetAdoptionCard() {
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
          child: Image.network(
            'https://images.unsplash.com/photo-1552053831-71594a27632d', 
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Max', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10)),
                    child: Text('Dog', style: TextStyle(color: Colors.teal, fontSize: 12)),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text('Friendly golden retriever looking for a loving home...', style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  Text(' Downtown Shelter • 2 years old', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              SizedBox(height: 15),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showChatModal(context), 
                  icon: Icon(Icons.favorite_border, size: 20),
                  label: Text('Interested to Adopt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5BA092),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 12),
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
void _showChatModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, 
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Color(0xFFE0F2F1), 
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
                          Icon(Icons.chat_bubble_outline, color: Colors.brown),
                          SizedBox(width: 8),
                          Text('Chat with Sarah Johnson', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                        ],
                      ),
                      IconButton(icon: Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  Text('About adopting Max', style: TextStyle(fontSize: 12, color: Colors.teal[700])),
                ],
              ),
            ),
            Divider(height: 1),
          
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 60, color: Colors.teal.withOpacity(0.3)),
                    SizedBox(height: 10),
                    Text('Start a conversation about adopting Max', style: TextStyle(color: Colors.teal[300])),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Color(0xFF5BA092).withOpacity(0.4),
                    child: Icon(Icons.send, color: Colors.white, size: 20),
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
