import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- User Profile ---

  // Get current user data
  Stream<DocumentSnapshot> get userData {
    String uid = _auth.currentUser!.uid;
    return _db.collection('users').doc(uid).snapshots();
  }

  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    String uid = _auth.currentUser!.uid;
    return await _db.collection('users').doc(uid).update(data);
  }

  // --- Pets ---

  // Add a new pet
  Future<void> addPet(Map<String, dynamic> petData) async {
    String uid = _auth.currentUser!.uid;
    await _db.collection('users').doc(uid).collection('pets').add({
      ...petData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get list of pets for current user
  Stream<QuerySnapshot> get userPets {
    String uid = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(uid)
        .collection('pets')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // --- Bookings & Appointments ---

  // Create a booking
  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    await _db.collection('bookings').add({
      ...bookingData,
      'userId': _auth.currentUser!.uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get my bookings
  Stream<QuerySnapshot> get myBookings {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // --- Reminders ---

  // Add reminder
  Future<void> addReminder(Map<String, dynamic> reminderData) async {
    String uid = _auth.currentUser!.uid;
    await _db.collection('users').doc(uid).collection('reminders').add({
      ...reminderData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get reminders
  Stream<QuerySnapshot> get reminders {
    String uid = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .orderBy('dateTime', descending: false)
        .snapshots();
  }

  // Update a pet's metadata
  Future<void> updatePet(String petId, Map<String, dynamic> data) async {
    String uid = _auth.currentUser!.uid;
    await _db.collection('users').doc(uid).collection('pets').doc(petId).update(data);
  }

  // Delete a pet
  Future<void> deletePet(String petId) async {
    String uid = _auth.currentUser!.uid;
    await _db.collection('users').doc(uid).collection('pets').doc(petId).delete();
  }
}
