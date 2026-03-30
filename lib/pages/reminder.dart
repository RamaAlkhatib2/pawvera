 Widget _buildReminderCard(BuildContext context) {
  return GestureDetector(
    onTap: () => _showNewReminderModal(context), 
    child: Container(
      width: 160, 
      height: 120,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF8BBD0), 
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.calendar_month_outlined, color: Colors.brown[700], size: 28),
              SizedBox(height: 15),
              Text(
                'Reminders',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.brown[900],
                ),
              ),
              Text(
                'Schedule pet tasks',
                style: TextStyle(fontSize: 11, color: Colors.brown[600]),
              ),
            ],
          ),
          
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(Icons.pets, size: 40, color: Colors.white.withOpacity(0.5)), 
            
          ),
        ],
      ),
    ),
  );
}
 void _showNewReminderModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.75, 
        child: Column(
          children: [
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.blue))),
                Text('New Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(onPressed: () {}, child: Text('Add', style: TextStyle(color: Colors.grey))),
              ],
            ),
            Divider(),
            
            TextField(
              decoration: InputDecoration(hintText: 'Title', border: InputBorder.none),
            ),
            TextField(
              decoration: InputDecoration(hintText: 'Notes', border: InputBorder.none),
              maxLines: 3,
            ),
            Divider(),
            
            _buildModalOption(Icons.pets, 'Pet', 'Choose'),
            _buildModalOption(Icons.calendar_today, 'Date & Time', 'Jan 15, 2026 09:00'),
            _buildModalOption(Icons.repeat, 'Repeat', 'Never'),
            _buildModalOption(Icons.category, 'Type', 'Vaccination'),
            _buildModalOption(Icons.priority_high, 'Priority', 'medium'),
          ],
        ),
      );
    },
  );
}

Widget _buildModalOption(IconData icon, String title, String value) {
  return ListTile(
    leading: Icon(icon, color: Colors.grey),
    title: Text(title, style: TextStyle(fontSize: 14)),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(color: Colors.grey, fontSize: 14)),
        Icon(Icons.chevron_right, color: Colors.grey),
      ],
    ),
  );
}
 
