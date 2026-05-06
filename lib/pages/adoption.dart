 import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home.dart';
import 'my_bookings_page.dart';
import 'profile_view.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  _AdoptionScreenState createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  final Color primaryTeal = const Color(0xFF5BA092);
  final Color backgroundCream = const Color(0xFFF9F6EE);

  List<Map<String, dynamic>> allPets = [
    {
      "name": "Boby",
      "desc": "Friendly dog looking for a home.",
      "location": "Amman",
      "price": "Free",
      "isVaccinated": true,
      "isNeutered": true,
      "image": "https://images.unsplash.com/photo-1543466835-00a7907e9de1",
      "isLocal": false,
    },
  ];

  void _addPet(Map<String, dynamic> pet) {
    setState(() {
      allPets.insert(0, pet);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Adoption',
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostPetPage(onSubmit: _addPet),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Post"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: allPets.length,
        itemBuilder: (context, index) => _buildPetCard(allPets[index]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryTeal,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          if (index == 3)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyBookingsPage()),
            );
          if (index == 4)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileView()),
            );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: "My Pets",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: "My Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: pet["isLocal"] == true
                ? Image.file(
                    File(pet["image"]),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    pet["image"],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                    Text(
                      pet["name"],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pet["price"],
                      style: TextStyle(
                        color: primaryTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(pet["desc"], style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (pet["isVaccinated"])
                      _buildTag("Vaccinated", Colors.blue),
                    if (pet["isNeutered"]) const SizedBox(width: 5),
                    if (pet["isNeutered"]) _buildTag("Neutered", Colors.orange),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    Text(
                      " ${pet["location"]}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PostPetPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  const PostPetPage({super.key, required this.onSubmit});

  @override
  _PostPetPageState createState() => _PostPetPageState();
}

class _PostPetPageState extends State<PostPetPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isVaccinated = false;
  bool _isNeutered = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (selected != null) {
      setState(() {
        _imageFile = File(selected.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5BA092),
        title: const Text(
          "Post Your Pet",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF5BA092).withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 50,
                            color: const Color(0xFF5BA092),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Upload Pet Photo",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 25),
            _buildField("Pet Name", _nameController, Icons.pets_outlined),
            _buildField(
              "Description",
              _descController,
              Icons.notes_outlined,
              lines: 4,
            ),
            _buildField("Location", _locController, Icons.location_on_outlined),
            _buildField(
              "Price / Adopt Fee",
              _priceController,
              Icons.monetization_on_outlined,
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      "Is your pet Vaccinated?",
                      style: TextStyle(fontSize: 14),
                    ),
                    secondary: const Icon(
                      Icons.shield_outlined,
                      color: Colors.blue,
                    ),
                    activeColor: const Color(0xFF5BA092),
                    value: _isVaccinated,
                    onChanged: (v) => setState(() => _isVaccinated = v),
                  ),
                  const Divider(height: 1, indent: 50),
                  SwitchListTile(
                    title: const Text(
                      "Is your pet Neutered?",
                      style: TextStyle(fontSize: 14),
                    ),
                    secondary: const Icon(
                      Icons.content_cut_outlined,
                      color: Colors.orange,
                    ),
                    activeColor: const Color(0xFF5BA092),
                    value: _isNeutered,
                    onChanged: (v) => setState(() => _isNeutered = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5BA092),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  if (_imageFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please add a photo first!"),
                      ),
                    );
                    return;
                  }
                  widget.onSubmit({
                    "name": _nameController.text,
                    "desc": _descController.text,
                    "location": _locController.text,
                    "price": _priceController.text.isEmpty
                        ? "Free"
                        : "${_priceController.text} JD",
                    "isVaccinated": _isVaccinated,
                    "isNeutered": _isNeutered,
                    "image": _imageFile!.path,
                    "isLocal": true,
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  "Post Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF5BA092)),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF5BA092)),
          ),
        ),
      ),
    );
  }
}


