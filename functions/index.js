const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

// ────────────────────────────────────────────────────────────────────────────
// 1. handleAdoptionApproval
//    Triggered when an admin updates a post status to 'approved'.
//    Sends an FCM notification to the ownerId.
// ────────────────────────────────────────────────────────────────────────────
exports.handleAdoptionApproval = functions.firestore
  .document('adoption_posts/{postId}')
  .onUpdate(async (change, context) => {
    const { postId } = context.params;
    const beforeData = change.before.data();
    const afterData = change.after.data();

    if (!afterData || beforeData?.status === afterData.status) {
      return null;
    }

    if (afterData.status !== 'approved') {
      return null;
    }

    const ownerId = afterData.ownerId;
    const petName = afterData.petName;

    if (!ownerId) {
      functions.logger.warn(`[handleAdoptionApproval] post ${postId} has no ownerId`);
      return null;
    }

    try {
      const ownerDoc = await db.collection('users').doc(ownerId).get();
      const ownerData = ownerDoc.data();

      if (!ownerData) {
        functions.logger.warn(`[handleAdoptionApproval] owner ${ownerId} not found`);
        return null;
      }

      const fcmToken = ownerData.fcmToken;

      if (!fcmToken) {
        functions.logger.info(`[handleAdoptionApproval] No FCM token for owner ${ownerId}`);
      }

      const notifRef = db.collection('notifications').doc();
      await notifRef.set({
        id: notifRef.id,
        userId: ownerId,
        title: 'Adoption Post Approved',
        description: `Your adoption post for "${petName || ''}" has been approved and is now visible to everyone!`,
        type: 'adoption_approved',
        postId: postId,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      if (fcmToken) {
        const message = {
          token: fcmToken,
          notification: {
            title: 'Adoption Post Approved',
            body: `Your adoption post for "${petName || ''}" has been approved!`,
          },
          data: {
            type: 'adoption_approved',
            postId: postId,
            screen: 'adoption',
          },
        };

        await fcm.send(message);
        functions.logger.info(`[handleAdoptionApproval] FCM sent to owner ${ownerId} for post ${postId}`);
      }

      return { success: true };
    } catch (error) {
      functions.logger.error(`[handleAdoptionApproval] Error notifying owner ${ownerId}:`, error);
      return null;
    }
  });

// ────────────────────────────────────────────────────────────────────────────
// 2. initiateAdoptionChat
//    Callable function: when a user clicks "Interested to Adopt", check if a
//    chat already exists for this postId between these two users. If not,
//    create a new document in the chats collection and return the chatId.
// ────────────────────────────────────────────────────────────────────────────
exports.initiateAdoptionChat = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'You must be logged in to initiate a chat.');
  }

  const adopterId = context.auth.uid;
  const { postId, ownerId, petName } = data;

  if (!postId || !ownerId || !petName) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields: postId, ownerId, petName');
  }

  if (adopterId === ownerId) {
    throw new functions.https.HttpsError('failed-precondition', 'You cannot initiate a chat with yourself.');
  }

  try {
    // Check if the post exists and is approved
    const postDoc = await db.collection('adoption_posts').doc(postId).get();
    if (!postDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Adoption post not found.');
    }

    const postData = postDoc.data();
    if (postData && postData.status !== 'approved') {
      throw new functions.https.HttpsError('failed-precondition', 'This adoption post is not yet approved.');
    }

    // Generate a deterministic chatId
    const participantIds = [adopterId, ownerId].sort();
    const chatId = `${postId}_${participantIds[0]}_${participantIds[1]}`;

    const chatRef = db.collection('chats').doc(chatId);
    const chatDoc = await chatRef.get();

    if (chatDoc.exists) {
      functions.logger.info(`[initiateAdoptionChat] Existing chat found: ${chatId}`);
      return { chatId: chatId, isNew: false };
    }

    const now = admin.firestore.FieldValue.serverTimestamp();

    await chatRef.set({
      id: chatId,
      participants: [adopterId, ownerId],
      adopterId: adopterId,
      ownerId: ownerId,
      postId: postId,
      petName: petName,
      lastMessage: '',
      lastMessageTime: now,
      createdAt: now,
      updatedAt: now,
    });

    // Notification for the owner
    const notifRef = db.collection('notifications').doc();
    await notifRef.set({
      id: notifRef.id,
      userId: ownerId,
      title: 'New Adoption Interest',
      description: `Someone is interested in adopting "${petName}"!`,
      type: 'adoption_chat',
      postId: postId,
      chatId: chatId,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info(`[initiateAdoptionChat] New chat created: ${chatId}`);

    return { chatId: chatId, isNew: true };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    functions.logger.error('[initiateAdoptionChat] Error:', error);
    throw new functions.https.HttpsError('internal', 'Unable to initiate chat. Please try again.');
  }
});