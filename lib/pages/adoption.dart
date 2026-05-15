import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawvera/services/database_service.dart';
import 'messages_page.dart';
import 'home.dart';
import 'my_bookings_page.dart';
import 'profile_view.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  final Color primaryTeal = const Color(0xFF5BA092);
  final Color backgroundCream = const Color(0xFFF9F6EE);

  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = "All";
  String _ageFilter = "All";
  bool _filterVaccinated = false;
  bool _filterNeutered = false;
  bool _showMyPosts = false;

  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _parseAgeToYears(dynamic age) {
    if (age == null) return 0;
    final ageStr = age.toString().toLowerCase().trim();
    final number =
        double.tryParse(ageStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    if (ageStr.contains('month')) return number / 12;
    if (ageStr.contains('week')) return number / 52;
    return number;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String? currentUid,
  ) {
    final query = _searchController.text.toLowerCase();
    return docs.where((doc) {
      final pet = doc.data();
      if (pet['isActive'] == false) return false;

      if (_showMyPosts) return pet['ownerId'] == currentUid;

      final matchesSearch =
          (pet['name'] ?? '').toString().toLowerCase().contains(query);
      final matchesCategory =
          selectedCategory == "All" || pet['category'] == selectedCategory;

      final ageYears = _parseAgeToYears(pet['age']);
      bool matchesAge = _ageFilter == "All";
      if (_ageFilter == "Young") matchesAge = ageYears >= 0 && ageYears <= 2;
      if (_ageFilter == "Adult") matchesAge = ageYears >= 3 && ageYears <= 7;
      if (_ageFilter == "Senior") matchesAge = ageYears >= 8;

      final matchesHealth =
          (!_filterVaccinated || pet['isVaccinated'] == true) &&
          (!_filterNeutered || pet['isNeutered'] == true);

      return matchesSearch && matchesCategory && matchesAge && matchesHealth;
    }).toList();
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Sort By",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                      child: Text(
                        "Age Range",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: ["All", "Young", "Adult", "Senior"].map((range) {
                      final isSelected = _ageFilter == range;
                      return ChoiceChip(
                        label: Text(
                          range == "All"
                              ? "All Ages"
                              : range == "Young"
                              ? "Young (0-2y)"
                              : range == "Adult"
                              ? "Adult (3-7y)"
                              : "Senior (8+y)",
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: primaryTeal,
                        onSelected: (_) {
                          setSheetState(() => _ageFilter = range);
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const Divider(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                      child: Text(
                        "Health Status",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text("Vaccinated"),
                    value: _filterVaccinated,
                    activeColor: primaryTeal,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) {
                      setSheetState(() => _filterVaccinated = v!);
                      setState(() {});
                    },
                  ),
                  CheckboxListTile(
                    title: const Text("Neutered/Spayed"),
                    value: _filterNeutered,
                    activeColor: primaryTeal,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) {
                      setSheetState(() => _filterNeutered = v!);
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to remove this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) await _db.deleteAdoptionPost(postId);
  }

  void _editPost(Map<String, dynamic> pet, String docId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPostPage(postId: docId, existing: pet),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

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
                MaterialPageRoute(builder: (_) => const PostPetPage()),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search here...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _buildToggleTab("All Pets", !_showMyPosts, () {
                    setState(() => _showMyPosts = false);
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildToggleTab("My Posts", _showMyPosts, () {
                    setState(() => _showMyPosts = true);
                  }),
                ),
              ],
            ),
          ),
          if (!_showMyPosts)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildCategoryChip("All", Icons.grid_view),
                        _buildCategoryChip("Dog", Icons.pets),
                        _buildCategoryChip("Cat", Icons.pets_outlined),
                        _buildCategoryChip("Bird", Icons.flutter_dash),
                        _buildCategoryChip("Rabbit", Icons.cruelty_free),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showFilterMenu,
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db.streamAdoptionPosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = _applyFilters(snapshot.data?.docs ?? [], currentUid);
                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'No pets available for adoption yet.\nTap "Post" to be the first!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final pet = doc.data();
                    final isOwner = pet['ownerId'] == currentUid;
                    return _buildPetCard(pet, doc.id, isOwner, currentUid);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryTeal,
        unselectedItemColor: const Color(0xFF9E9E9E),
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Home()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Home()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MessagesPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyBookingsPage()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileView()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            label: 'My Pets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : primaryTeal),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetCard(
    Map<String, dynamic> pet,
    String docId,
    bool isOwner,
    String? currentUid,
  ) {
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
            child: _buildPetImage(pet),
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
                      pet['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          pet['price'] ?? '',
                          style: TextStyle(
                            color: primaryTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (isOwner) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _editPost(pet, docId),
                            child: Icon(
                              Icons.edit_outlined,
                              color: primaryTeal,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _deletePost(docId),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 22,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (isOwner)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Your Post',
                      style: TextStyle(
                        color: primaryTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  pet['desc'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (pet['isVaccinated'] == true)
                      _buildTag("Vaccinated", Colors.blue),
                    if (pet['isNeutered'] == true) ...[
                      const SizedBox(width: 5),
                      _buildTag("Neutered", Colors.orange),
                    ],
                    if (pet['gender'] != null) ...[
                      const SizedBox(width: 5),
                      _buildTag(pet['gender'], Colors.purple),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    Text(
                      " ${pet['location'] ?? ''}"
                      "${pet['age'] != null ? ' • ${pet['age']}' : ''}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                if (!isOwner) ...[
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: currentUid == null
                          ? null
                          : () => _contactOwner(pet, docId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Interested to Adopt",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _contactOwner(Map<String, dynamic> pet, String postId) async {
    final ownerId = pet['ownerId'] as String? ?? '';
    final ownerName = pet['ownerName'] as String? ?? 'Pet Owner';
    final petName = pet['name'] as String? ?? 'Pet';

    if (ownerId.isEmpty) return;

    try {
      final convId = await _db.getOrCreateConversation(
        ownerId: ownerId,
        petId: postId,
        petName: petName,
        ownerName: ownerName,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FirestoreChatPage(
            conversationId: convId,
            petName: petName,
            contactName: ownerName,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPetImage(Map<String, dynamic> pet) {
    final b64 = pet['imageBase64'] as String?;
    if (b64 != null && b64.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(b64),
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } catch (_) {}
    }
    final url = pet['imageUrl'] as String?;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() => Container(
        height: 200,
        color: Colors.grey.shade200,
        child: const Icon(Icons.pets, size: 60, color: Colors.grey),
      );

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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

// ─── Post Pet Page ─────────────────────────────────────────────────────────────

class PostPetPage extends StatefulWidget {
  const PostPetPage({super.key});

  @override
  State<PostPetPage> createState() => _PostPetPageState();
}

class _PostPetPageState extends State<PostPetPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locController = TextEditingController();
  final _priceController = TextEditingController();
  final _ageController = TextEditingController();
  String _ageUnit = "years";
  String _selectedGender = "Male";
  String _selectedCategory = "Dog";
  bool _isVaccinated = false;
  bool _isNeutered = false;
  bool _isLoading = false;
  XFile? _pickedFile;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  final DatabaseService _db = DatabaseService();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locController.dispose();
    _priceController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (selected != null) {
      final bytes = await selected.readAsBytes();
      setState(() {
        _pickedFile = selected;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a pet name.')),
      );
      return;
    }
    if (_pickedFile == null || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final price = _priceController.text.trim().isEmpty
          ? "Free"
          : "${_priceController.text.trim()} JD";
      await _db.postAdoptionPet(
        name: _nameController.text.trim(),
        desc: _descController.text.trim(),
        location: _locController.text.trim(),
        price: price,
        age: "${_ageController.text.trim()} $_ageUnit",
        gender: _selectedGender,
        category: _selectedCategory,
        isVaccinated: _isVaccinated,
        isNeutered: _isNeutered,
        imageBytes: _imageBytes!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet posted successfully!'),
            backgroundColor: Color(0xFF5BA092),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      appBar: AppBar(
        title: const Text("Post Your Pet"),
        backgroundColor: const Color(0xFF5BA092),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF5BA092).withValues(alpha: 0.3),
                  ),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Color(0xFF5BA092),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to add photo',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            _buildField("Pet Name", _nameController, Icons.pets_outlined),
            _buildField(
              "Description",
              _descController,
              Icons.description_outlined,
              lines: 3,
            ),
            _buildField(
              "Location",
              _locController,
              Icons.location_on_outlined,
            ),
            _buildField(
              "Price (leave empty = Free)",
              _priceController,
              Icons.monetization_on_outlined,
              inputType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    "Age",
                    _ageController,
                    Icons.calendar_today,
                    inputType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 56,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _ageUnit,
                      items: ["years", "months", "weeks"].map((v) {
                        return DropdownMenuItem(value: v, child: Text(v));
                      }).toList(),
                      onChanged: (v) => setState(() => _ageUnit = v!),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.category_outlined,
                    color: Color(0xFF5BA092),
                  ),
                  const SizedBox(width: 12),
                  const Text("Type: "),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        items: ["Dog", "Cat", "Bird", "Rabbit"].map((v) {
                          return DropdownMenuItem(value: v, child: Text(v));
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.transgender, color: Color(0xFF5BA092)),
                  const SizedBox(width: 12),
                  const Text("Gender: "),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        items: ["Male", "Female"].map((v) {
                          return DropdownMenuItem(value: v, child: Text(v));
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedGender = v!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: const Text("Vaccinated"),
              activeThumbColor: const Color(0xFF5BA092),
              value: _isVaccinated,
              onChanged: (v) => setState(() => _isVaccinated = v),
            ),
            SwitchListTile(
              title: const Text("Neutered/Spayed"),
              activeThumbColor: const Color(0xFF5BA092),
              value: _isNeutered,
              onChanged: (v) => setState(() => _isNeutered = v),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5BA092),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Post Now",
                        style: TextStyle(color: Colors.white),
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
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: lines,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF5BA092)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ─── Edit Post Page ────────────────────────────────────────────────────────────

class EditPostPage extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> existing;

  const EditPostPage({super.key, required this.postId, required this.existing});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _locController;
  late final TextEditingController _priceController;
  late final TextEditingController _ageController;
  late String _ageUnit;
  late String _selectedGender;
  late String _selectedCategory;
  late bool _isVaccinated;
  late bool _isNeutered;
  bool _isLoading = false;
  Uint8List? _newImageBytes;
  final ImagePicker _picker = ImagePicker();
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;

    // Parse price: "100 JD" → "100", "Free" → ""
    final rawPrice = (e['price'] ?? '').toString();
    final priceText = rawPrice == 'Free'
        ? ''
        : rawPrice.replaceAll(RegExp(r'\s*JD\s*$'), '').trim();

    // Parse age: "2 years" → num "2", unit "years"
    final rawAge = (e['age'] ?? '').toString().trim();
    String ageNum = '';
    String ageUnit = 'years';
    for (final unit in ['months', 'weeks', 'years']) {
      if (rawAge.toLowerCase().contains(unit)) {
        ageUnit = unit;
        ageNum = rawAge.toLowerCase().replaceAll(unit, '').trim();
        break;
      }
    }
    if (ageNum.isEmpty) ageNum = rawAge;

    _nameController = TextEditingController(text: e['name'] ?? '');
    _descController = TextEditingController(text: e['desc'] ?? '');
    _locController = TextEditingController(text: e['location'] ?? '');
    _priceController = TextEditingController(text: priceText);
    _ageController = TextEditingController(text: ageNum);
    _ageUnit = ageUnit;
    _selectedGender = e['gender'] ?? 'Male';
    _selectedCategory = e['category'] ?? 'Dog';
    _isVaccinated = e['isVaccinated'] == true;
    _isNeutered = e['isNeutered'] == true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locController.dispose();
    _priceController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (selected != null) {
      final bytes = await selected.readAsBytes();
      setState(() => _newImageBytes = bytes);
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a pet name.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final price = _priceController.text.trim().isEmpty
          ? 'Free'
          : '${_priceController.text.trim()} JD';
      await _db.updateAdoptionPost(
        postId: widget.postId,
        name: _nameController.text.trim(),
        desc: _descController.text.trim(),
        location: _locController.text.trim(),
        price: price,
        age: '${_ageController.text.trim()} $_ageUnit',
        gender: _selectedGender,
        category: _selectedCategory,
        isVaccinated: _isVaccinated,
        isNeutered: _isNeutered,
        newImageBytes: _newImageBytes,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post updated successfully!'),
            backgroundColor: Color(0xFF5BA092),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingB64 = widget.existing['imageBase64'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      appBar: AppBar(
        title: const Text('Edit Post'),
        backgroundColor: const Color(0xFF5BA092),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF5BA092).withValues(alpha: 0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _newImageBytes != null
                      ? Image.memory(
                          _newImageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                        )
                      : (existingB64 != null && existingB64.isNotEmpty)
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  base64Decode(existingB64),
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Tap to change',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo,
                                    size: 50, color: Color(0xFF5BA092)),
                                SizedBox(height: 8),
                                Text('Tap to add photo',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildField('Pet Name', _nameController, Icons.pets_outlined),
            _buildField('Description', _descController,
                Icons.description_outlined,
                lines: 3),
            _buildField(
                'Location', _locController, Icons.location_on_outlined),
            _buildField(
              'Price (leave empty = Free)',
              _priceController,
              Icons.monetization_on_outlined,
              inputType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    'Age',
                    _ageController,
                    Icons.calendar_today,
                    inputType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 56,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _ageUnit,
                      items: ['years', 'months', 'weeks'].map((v) {
                        return DropdownMenuItem(value: v, child: Text(v));
                      }).toList(),
                      onChanged: (v) => setState(() => _ageUnit = v!),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.category_outlined,
                      color: Color(0xFF5BA092)),
                  const SizedBox(width: 12),
                  const Text('Type: '),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        items: ['Dog', 'Cat', 'Bird', 'Rabbit'].map((v) {
                          return DropdownMenuItem(value: v, child: Text(v));
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.transgender, color: Color(0xFF5BA092)),
                  const SizedBox(width: 12),
                  const Text('Gender: '),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        items: ['Male', 'Female'].map((v) {
                          return DropdownMenuItem(value: v, child: Text(v));
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedGender = v!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: const Text('Vaccinated'),
              activeThumbColor: const Color(0xFF5BA092),
              value: _isVaccinated,
              onChanged: (v) => setState(() => _isVaccinated = v),
            ),
            SwitchListTile(
              title: const Text('Neutered/Spayed'),
              activeThumbColor: const Color(0xFF5BA092),
              value: _isNeutered,
              onChanged: (v) => setState(() => _isNeutered = v),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5BA092),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Changes',
                        style: TextStyle(color: Colors.white)),
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
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: lines,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF5BA092)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
