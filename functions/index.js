const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');

admin.initializeApp();
const db = admin.firestore();

// On user creation: seed users/{uid}
exports.onAuthCreate = functions.auth.user().onCreate(async (user) => {
  const { uid, email, displayName } = user;
  const doc = {
    uid,
    email: email || null,
    fullName: displayName || null,
    role: 'adopter',
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  };
  await db.collection('users').doc(uid).set(doc);
  return null;
});

// On requests creation: notify pet owner
exports.onRequestCreate = functions.firestore
  .document('requests/{requestId}')
  .onCreate(async (snap, context) => {
    const req = snap.data();
    if (!req) return null;
    const ownerId = req.toOwnerId;
    const notification = {
      id: uuidv4(),
      userId: ownerId,
      type: 'adoption_request',
      payload: { requestId: snap.id, petId: req.petId, fromUserId: req.fromUserId },
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    };
    await db.collection('notifications').doc(notification.id).set(notification);
      // Send FCM if owner has tokens
      try {
        const ownerDoc = await db.collection('users').doc(ownerId).get();
        const ownerData = ownerDoc.data() || {};
        const tokens = ownerData.fcmTokens || [];
        if (tokens.length > 0) {
          const message = {
            notification: { title: 'New adoption request', body: `You have a new adoption request for pet ${req.petId}` },
            data: { requestId: snap.id, type: 'adoption_request', petId: req.petId },
          };
          await admin.messaging().sendMulticast({ tokens: tokens, ...message });
        }
      } catch (err) {
        console.error('FCM send error', err);
      }
    return null;
  });

// Booking creation: check conflicts and notify
exports.onBookingCreate = functions.firestore
  .document('bookings/{bookingId}')
  .onCreate(async (snap, context) => {
    const booking = snap.data();
    if (!booking) return null;
    // Basic conflict check example: naive, replace with transaction if needed
    const start = booking.startAt;
    const end = booking.endAt;
    if (booking.storeId) {
        const snap = await db.collection('bookings')
          .where('storeId', '==', booking.storeId)
          .where('status', 'in', ['pending','confirmed'])
          .get();
        const conflicts = [];
        snap.forEach(d => {
          const b = d.data();
          // assume startAt/endAt stored as Firestore Timestamps
          if (b.startAt && b.endAt) {
            const s = b.startAt.toMillis ? b.startAt.toMillis() : new Date(b.startAt).getTime();
            const e = b.endAt.toMillis ? b.endAt.toMillis() : new Date(b.endAt).getTime();
            const ns = start.toMillis ? start.toMillis() : new Date(start).getTime();
            const ne = end.toMillis ? end.toMillis() : new Date(end).getTime();
            const overlap = Math.max(s, ns) < Math.min(e, ne);
            if (overlap) conflicts.push(d.id);
          }
        });
        if (conflicts.length > 0) {
          // mark this booking as conflicted
          await db.collection('bookings').doc(context.params.bookingId).update({ status: 'conflict', conflictWith: conflicts });
          // notify user
          try {
            const userDoc = await db.collection('users').doc(booking.userId).get();
            const userData = userDoc.data() || {};
            const tokens = userData.fcmTokens || [];
            if (tokens.length > 0) {
              await admin.messaging().sendMulticast({ tokens: tokens, notification: { title: 'Booking conflict', body: 'Your booking time conflicts with another booking.' } });
            }
          } catch (err) { console.error('notify user error', err); }
        }
    }
    // create notification for provider
    return null;
  });

// HTTP callable example: create pet (validates auth)
exports.createPet = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  const uid = context.auth.uid;
  const ownerId = data.ownerId || uid;
  if (ownerId !== uid && !context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'ownerId mismatch');
  }
  const pet = {
    name: data.name || '',
    breed: data.breed || null,
    age: data.age || null,
    description: data.description || null,
    ownerId,
    status: 'available',
    imageUrls: data.imageUrls || [],
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  };
  const ref = await db.collection('pets').add(pet);
  return { success: true, id: ref.id };
});

// Scheduled: send due reminders (runs every 5 minutes)
exports.sendDueReminders = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const windowMillis = 5 * 60 * 1000; // 5 minutes
    const cutoff = admin.firestore.Timestamp.fromMillis(now.toMillis() + windowMillis);

    const q = db.collection('reminders')
      .where('time', '<=', cutoff)
      .where('isCompleted', '==', false)
      .where('notified', '==', false);

    const snap = await q.get();
    const batch = db.batch();
    const sends = [];

    snap.forEach(doc => {
      const r = doc.data();
      const userId = r.userId;
      sends.push((async () => {
        try {
          const userDoc = await db.collection('users').doc(userId).get();
          const tokens = (userDoc.data() && userDoc.data().fcmTokens) || [];
          if (tokens.length > 0) {
            const message = {
              notification: { title: r.title || 'Reminder', body: r.description || '' },
              data: { reminderId: doc.id, type: 'reminder' }
            };
            await admin.messaging().sendMulticast({ tokens: tokens, ...message });
          }
        } catch (err) {
          console.error('Error sending reminder', err);
        }
      })());

      // mark notified
      batch.update(db.collection('reminders').doc(doc.id), { notified: true, notifiedAt: admin.firestore.FieldValue.serverTimestamp() });
    });

    await Promise.all(sends);
    await batch.commit();
    return null;
  });

// Scheduled: delete expired reminders older than 30 days (runs daily)
exports.deleteExpiredReminders = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const nowMillis = Date.now();
    const threshold = admin.firestore.Timestamp.fromMillis(nowMillis - (30 * 24 * 60 * 60 * 1000));
    const q = db.collection('reminders')
      .where('time', '<=', threshold);
    const snap = await q.get();
    const batch = db.batch();
    snap.forEach(d => batch.delete(db.collection('reminders').doc(d.id)));
    await batch.commit();
    return null;
  });
