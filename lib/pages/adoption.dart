import 'package:flutter/material.dart';

// 1. ميثود بناء الكارد (تأكدي إنك بتبعتي الـ context لما تناديها)
Widget _buildPetAdoptionCard(BuildContext context) { 
  return Container(
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.teal.shade50),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // صورة الحيوان
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Image.network(
            'https://images.unsplash.com/photo-1552053831-71594a27632d', 
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            // هاد الجزء عشان لو الصورة ما حملت ما يطلع Error
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              color: Colors.grey[200],
              child: const Icon(Icons.pets, size: 50, color: Colors.grey),
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Max', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50, 
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: const Text('Dog', style: TextStyle(color: Colors.teal, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Friendly golden retriever looking for a loving home...', 
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  Text(' Downtown Shelter • 2 years old', 
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 15),
              
              // زر الاهتمام بالتبني
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showChatModal(context), 
                  icon: const Icon(Icons.favorite_border, size: 20),
                  label: const Text('Interested to Adopt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5BA092),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

// 2. ميثود إظهار نافذة الدردشة
void _showChatModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, 
    builder: (context) {
      return Container(
        // MediaQuery عشان نضمن إنها تغطي جزء من الشاشة وتتأثر بالكيبرد
        height: MediaQuery.of(context).size.height * 0.75, 
        decoration: const BoxDecoration(
          color: Color(0xFFE0F2F1), 
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // الهيدر تبع الشات
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.chat_bubble_outline, color: Color(0xFF5A3E2B)), // لون بني متناسق
                          SizedBox(width: 8),
                          Text('Chat with Sarah Johnson', 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A3E2B))),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20), 
                        onPressed: () => Navigator.pop(context)
                      ),
                    ],
                  ),
                  Text('About adopting Max', 
                      style: TextStyle(fontSize: 12, color: Colors.teal[700])),
                ],
              ),
            ),
            const Divider(height: 1),
          
            // منطقة الرسائل (الفارغة حالياً)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 60, color: Colors.teal.withOpacity(0.3)),
                    const SizedBox(height: 10),
                    Text('Start a conversation about adopting Max', 
                        style: TextStyle(color: Colors.teal[300])),
                  ],
                ),
              ),
            ),
            
            // حقل إدخال الرسالة (أسفل الصفحة)
            Container(
              padding: EdgeInsets.only(
                left: 16, 
                right: 16, 
                bottom: MediaQuery.of(context).viewInsets.bottom + 24, // عشان ترفع مع الكيبرد
                top: 10
              ),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    backgroundColor: Color(0xFF5BA092),
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
