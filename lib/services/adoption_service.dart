import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawvera/models/adoption_post.dart';
import 'package:pawvera/services/database_service.dart';

/// Service class for the Adoption Module.
///
/// Handles:
/// - Uploading images to Firebase Storage
/// - Submitting adoption post data to Firestore (status forced to 'pending')
/// - Querying approved posts with filters (petType, search by name/location)
/// - Admin approval workflow
/// - Pagination support (10 posts per page)
/// - Retrieving current user's posts (pending/rejected for profile)
/// - Chat initialization
class AdoptionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const int pageSize = 10;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to continue.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('adoption_pets');

  // ──────────────────────────────────────────────────────────────────────────
  // Image Upload
  // ──────────────────────────────────────────────────────────────────────────

  /// Uploads an image to Firebase Storage using raw bytes.
  /// Works on all platforms (web, mobile, desktop).
  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final ref = _storage.ref().child(
      'adoption/${_uid}/${DateTime.now().millisecondsSinceEpoch}_$safeName',
    );
    await ref.putData(bytes).timeout(const Duration(seconds: 120));
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  /// Uploads up to 5 images from [XFile] objects (cross-platform).
  /// Returns a list of download URLs.
  Future<List<String>> uploadImages(List<XFile> imageFiles) async {
    // Limit to 5 images
    final filesToUpload = imageFiles.take(5).toList();
    final List<String> urls = [];
    for (int i = 0; i < filesToUpload.length; i++) {
      final xfile = filesToUpload[i];
      final bytes = await xfile.readAsBytes().timeout(
        const Duration(seconds: 15),
      );
      final fileName = xfile.name;
      final url = await uploadImageBytes(bytes: bytes, fileName: fileName);
      urls.add(url);
    }
    return urls;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Create Adoption Post
  // ──────────────────────────────────────────────────────────────────────────

  /// Creates a new adoption post in Firestore.
  ///
  /// [imageUrls] — list of downloadable image URLs (already uploaded).
  /// The status is **forced to 'pending'** — the Security Rules enforce this.
  /// Returns the newly created document ID.
  Future<String> createAdoptionPost({
    required String petName,
    required String petType,
    required String gender,
    required dynamic ageValue,
    required String ageUnit,
    required String location,
    required String description,
    required bool isVaccinated,
    required bool isNeutered,
    required List<String> imageUrls,
  }) async {
    final docRef = _posts.doc();
    final post = PetAdoptionPost(
      id: docRef.id,
      ownerId: _uid,
      petName: petName,
      petType: petType,
      gender: gender,
      ageValue: ageValue,
      ageUnit: ageUnit,
      location: location,
      description: description,
      isVaccinated: isVaccinated,
      isNeutered: isNeutered,
      imageUrls: imageUrls,
    );
    // Use postedBy to match Firestore Security Rules (adoption_pets collection)
    final postData = {...post.toCreateJson(), 'postedBy': _uid};
    await docRef.set(postData).timeout(const Duration(seconds: 10));
    return docRef.id;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Query Approved Posts (with search & pagination)
  // ──────────────────────────────────────────────────────────────────────────

  /// Streams all **approved** adoption posts, optionally filtered by [petType].
  ///
  /// [petType] values: 'Dog', 'Cat', 'Bird', 'Rabbit', etc.
  /// Pass `null` or empty string to get all approved posts.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamApprovedPosts({
    String? petType,
  }) {
    Query<Map<String, dynamic>> query = _posts.where(
      'status',
      isEqualTo: 'approved',
    );

    if (petType != null && petType.isNotEmpty && petType != 'All') {
      query = query.where('petType', isEqualTo: petType);
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  /// Fetches **approved** posts with optional pet type filter.
  /// Does NOT use Firestore `orderBy` + `where` together to avoid needing
  /// composite indexes. Filtering and sorting are done client-side.
  Future<List<PetAdoptionPost>> fetchApprovedPostsModels({
    String? petType,
    String? searchQuery,
  }) async {
    try {
      // Fetch without status filter to avoid composite index requirement
      Query<Map<String, dynamic>> query = _posts;

      // Only apply petType filter server-side if provided
      if (petType != null && petType.isNotEmpty && petType != 'All') {
        query = query.where('petType', isEqualTo: petType);
      }

      final snapshot = await query.get();

      // Filter for approved status client-side
      var results = snapshot.docs
          .where((doc) {
            final data = doc.data();
            return (data['status'] ?? '').toString() == 'approved';
          })
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      // Sort by createdAt descending client-side
      results.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime);
        }
        return 0;
      });

      // Client-side search by petName or location
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryLower = searchQuery.trim().toLowerCase();
        results = results.where((post) {
          final name = (post['petName'] ?? '').toString().toLowerCase();
          final location = (post['location'] ?? '').toString().toLowerCase();
          return name.contains(queryLower) || location.contains(queryLower);
        }).toList();
      }

      return results.map((map) {
        final id = map['id'] as String? ?? '';
        return PetAdoptionPost.fromJson(Map<String, dynamic>.from(map), id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Search by petName or location (client-side on streamed data)
  // ──────────────────────────────────────────────────────────────────────────

  /// Applies a client-side search filter to an existing stream of approved posts.
  /// Filters by petName or location.
  static List<Map<String, dynamic>> filterBySearchQuery({
    required List<Map<String, dynamic>> posts,
    required String searchQuery,
  }) {
    if (searchQuery.trim().isEmpty) return posts;
    final query = searchQuery.trim().toLowerCase();
    return posts.where((post) {
      final name = (post['petName'] ?? '').toString().toLowerCase();
      final location = (post['location'] ?? '').toString().toLowerCase();
      return name.contains(query) || location.contains(query);
    }).toList();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Get Single Post
  // ──────────────────────────────────────────────────────────────────────────

  /// Streams a single adoption post document by [postId].
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamPost(String postId) {
    return _posts.doc(postId).snapshots();
  }

  /// Fetches a single post as a model.
  Future<PetAdoptionPost?> getPost(String postId) async {
    try {
      final doc = await _posts.doc(postId).get();
      if (!doc.exists) return null;
      return PetAdoptionPost.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get post: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Admin Approval Workflow
  // ──────────────────────────────────────────────────────────────────────────

  /// Updates a post's status. **Only Admins** should call this.
  ///
  /// The Firestore Security Rules enforce that only users with role 'admin'
  /// can update the [status] field.
  Future<void> approvePost(String postId) async {
    try {
      await _posts.doc(postId).update({
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to approve post: $e');
    }
  }

  /// Rejects a post. **Only Admins** should call this.
  Future<void> rejectPost(String postId) async {
    try {
      await _posts.doc(postId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reject post: $e');
    }
  }

  /// Streams all **pending** posts for admin review.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamPendingPosts() {
    return _posts
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Fetches pending posts (paginated) for admin review.
  Future<List<PetAdoptionPost>> fetchPendingPosts({
    DocumentSnapshot<Map<String, dynamic>>? lastDoc,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> query = _posts
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PetAdoptionPost.fromJson(doc.data(), doc.id))
        .toList();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Current User's Posts (for profile)
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns the current user's own adoption posts (all statuses).
  /// Useful for showing "My Posts" in the user's profile, including pending
  /// and rejected posts.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyPosts() {
    return _posts
        .where('ownerId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Returns the current user's own adoption posts as models.
  Future<List<PetAdoptionPost>> fetchMyPosts() async {
    try {
      final snapshot = await _posts
          .where('ownerId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => PetAdoptionPost.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch your posts: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Initiate Adoption Chat
  // ──────────────────────────────────────────────────────────────────────────

  /// Initiates a chat between the current user and the post owner.
  ///
  /// Uses the existing [DatabaseService.getOrCreateConversation] logic.
  /// Returns the chat/conversation ID.
  Future<String> initiateChat({
    required String postId,
    required String ownerId,
    required String petName,
  }) async {
    final dbService = DatabaseService();
    return await dbService.getOrCreateConversation(
      ownerId: ownerId,
      petId: postId,
      petName: petName,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Update Post (Owner edits their own non-status fields)
  // ──────────────────────────────────────────────────────────────────────────

  /// Updates an adoption post. The status field cannot be updated by non-admins
  /// (enforced by Security Rules).
  Future<void> updatePost({
    required String postId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Remove status to prevent non-admin status changes
      data.remove('status');
      await _posts.doc(postId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Delete Post
  // ──────────────────────────────────────────────────────────────────────────

  /// Deletes the adoption post. Only the owner or an admin can delete
  /// (enforced by Security Rules).
  Future<void> deletePost(String postId) async {
    try {
      await _posts.doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Utility: Check if current user is admin
  // ──────────────────────────────────────────────────────────────────────────

  /// Checks whether the currently authenticated user has admin role.
  Future<bool> isCurrentUserAdmin() async {
    try {
      final userDoc = await _db.collection('users').doc(_uid).get();
      if (!userDoc.exists) return false;
      final data = userDoc.data() ?? {};
      return (data['role'] ?? '').toString().toLowerCase() == 'admin';
    } catch (e) {
      return false;
    }
  }
}
