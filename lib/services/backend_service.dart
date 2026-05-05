import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class BackendService {
  static final BackendService _instance = BackendService._();
  BackendService._();
  factory BackendService() => _instance;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Auth helpers
  Future<User?> signIn(String email, String password) async {
    final cred = await auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  // Initialize Firebase Messaging: request permissions, obtain token and save to user doc
  Future<void> initMessaging() async {
    try {
      // Request permissions for iOS
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Get token and save
      final token = await messaging.getToken();
      final user = auth.currentUser;
      if (token != null && user != null) {
        final userRef = firestore.collection('users').doc(user.uid);
        await userRef.set({
          'fcmTokens': FieldValue.arrayUnion([token])
        }, SetOptions(merge: true));
      }

      // refresh token handler
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final usr = auth.currentUser;
        if (usr != null) {
          await firestore.collection('users').doc(usr.uid).set({
            'fcmTokens': FieldValue.arrayUnion([newToken])
          }, SetOptions(merge: true));
        }
      });

      // foreground message handler (optional: show local UI)
      FirebaseMessaging.onMessage.listen((RemoteMessage event) {
        // handle foreground messages if needed
        // e.g., show a dialog or update local state
        print('FCM foreground message: ${event.notification?.title}');
      });
    } catch (e) {
      print('FCM init error: $e');
    }
  }

  Future<User?> signUp(String email, String password, String fullName) async {
    final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.updateDisplayName(fullName);
    // Seed user doc; Cloud Function also does this but writing here ensures immediate data
    final uid = cred.user?.uid;
    if (uid != null) {
      await firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'role': 'adopter',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return cred.user;
  }

  // Pet creation (uploads images to storage first)
  Future<String> createPet(Map<String, dynamic> petData) async {
    final docRef = await firestore.collection('pets').add({
      ...petData,
      'createdAt': FieldValue.serverTimestamp(),
      'status': petData['status'] ?? 'available',
    });
    return docRef.id;
  }

  // Stream pets for UI
  Stream<List<Map<String, dynamic>>> petsStream({String? status, int limit = 50}) {
    Query q = firestore.collection('pets').orderBy('createdAt', descending: true).limit(limit);
    if (status != null) q = q.where('status', isEqualTo: status);
    return q.snapshots().map((snap) => snap.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {...data, 'id': d.id};
        }).toList());
  }

  // Create adoption request
  Future<String> createAdoptionRequest({required String petId, required String fromUserId, required String toOwnerId, String? message}) async {
    final doc = {
      'petId': petId,
      'fromUserId': fromUserId,
      'toOwnerId': toOwnerId,
      'message': message ?? '',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };
    final ref = await firestore.collection('requests').add(doc);
    return ref.id;
  }

  // Basic booking creation using server-side callable is recommended.
  Future<String> createBooking(Map<String, dynamic> booking) async {
    final ref = await firestore.collection('bookings').add({
      ...booking,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // Reminders
  Future<String> createReminder(Map<String, dynamic> reminder) async {
    final ref = await firestore.collection('reminders').add({
      ...reminder,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
