# PawVera Firebase & Backend Roadmap

This document outlines the complete backend architecture and implementation plan for PawVera using Firebase.

## 1. Firebase Project Setup (In Console)
- [ ] **Enable Authentication:**
    - Go to Authentication > Sign-in method.
    - Enable **Email/Password**.
    - (Optional) Enable **Google Sign-in**.
- [ ] **Create Firestore Database:**
    - Select "Start in test mode" (update rules later).
    - Choose a location close to your users.
- [ ] **Enable Firebase Storage:**
    - For storing pet images and user profile pictures.

---

## 2. Database Schema (Firestore)

### `users` (Collection)
- `uid`: String (Primary Key)
- `email`: String
- `fullName`: String
- `role`: String ('adopter', 'shelter', 'store_owner')
- `profilePic`: String (URL)
- `createdAt`: Timestamp

### `pets` (Collection)
- `petId`: String
- `name`: String
- `breed`: String
- `age`: Number
- `description`: String
- `imageUrl`: String
- `ownerId`: String (references `users.uid`)
- `status`: String ('available', 'adopted')

### `bookings` (Collection)
- `bookingId`: String
- `userId`: String
- `petId`: String (optional if clinic/grooming)
- `serviceType`: String ('adoption_visit', 'grooming', 'vet')
- `dateTime`: Timestamp
- `status`: String ('pending', 'confirmed', 'completed')

### `reminders` (Collection)
- `reminderId`: String
- `userId`: String
- `title`: String
- `description`: String
- `time`: Timestamp
- `isCompleted`: Boolean

---

## 3. Implementation Plan by Page

### Phase 1: Authentication (`register_view.dart`, `login_view.dart`)
- [ ] Import `firebase_auth`.
- [ ] Implement `signUpWithEmailpassword`.
- [ ] On sign-up, create a document in the `users` collection with the matching `uid`.
- [ ] Implement `signInWithEmailPassword`.
- [ ] Add "Forgot Password" functionality.

### Phase 2: User Profile (`profile_view.dart`)
- [ ] Fetch user data from `users/{uid}`.
- [ ] Implement profile picture upload to **Firebase Storage**.
- [ ] Update display name and bio in Firestore.

### Phase 3: Pet Management & Adoption (`adoption.dart`, `my_pet_page.dart`)
- [ ] **Display:** Stream pets from Firestore `pets` collection using `StreamBuilder`.
- [ ] **Filter:** Add queries to filter by breed or age.
- [ ] **Adoption Request:** Save a document in a `requests` collection when a user clicks "Adopt".

### Phase 4: Services & Bookings (`my_bookings_page.dart`)
- [ ] Create a form to submit a new booking.
- [ ] List user-specific bookings using a Firestore query: `.where('userId', '==', currentUser.uid)`.

### Phase 5: Notifications & Reminders (`notifications_page.dart`, `reminder.dart`)
- [ ] Sync reminders with Firestore.
- [ ] (Advanced) Setup Firebase Cloud Messaging (FCM) for push notifications.

---

## 4. Security Rules (CRITICAL)
Before launching, update your Firestore rules in the console:
```javascript
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /pets/{petId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 5. Next Steps for Developer
1. **Run** `flutter pub add firebase_auth cloud_firestore firebase_storage` in your terminal.
2. **Start** with the Register/Login logic.
3. **Follow** the schema above strictly to avoid data mismatches.
