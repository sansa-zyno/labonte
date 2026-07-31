import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

admin.initializeApp();

/**
 * Sends a push notification to all active devices/tokens of a specific user.
 * Prunes invalid or outdated tokens returned from messaging errors.
 */
async function sendPushNotification(
  userId: string,
  notification: { title: string; body: string }
): Promise<boolean> {
  const db = admin.firestore();

  // Fetch user's registered tokens
  const tokensSnapshot = await db
    .collection("users")
    .doc(userId)
    .collection("tokens")
    .get();

  const tokens = tokensSnapshot.docs.map((doc) => doc.data().token);

  if (tokens.length === 0) {
    console.log(`No tokens found for user ${userId}. Skipping notification.`);
    return false;
  }

  const message = {
    notification: notification,
    tokens: tokens,
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(
      `Sent notification to user ${userId}: success count = ${response.successCount}, failure count = ${response.failureCount}`
    );

    // Clean up expired or invalid tokens
    const tokensToRemove: Promise<any>[] = [];
    response.responses.forEach((resp, idx) => {
      if (!resp.success) {
        const error = resp.error;
        if (
          error &&
          (error.code === "messaging/invalid-registration-token" ||
            error.code === "messaging/registration-token-not-registered")
        ) {
          const docRef = tokensSnapshot.docs[idx].ref;
          console.log(`Pruning invalid token for user ${userId}: ${tokens[idx]}`);
          tokensToRemove.push(docRef.delete());
        } else {
          console.error(`FCM error for token ${tokens[idx]}:`, error);
        }
      }
    });

    if (tokensToRemove.length > 0) {
      await Promise.all(tokensToRemove);
    }

    return response.successCount > 0;
  } catch (error) {
    console.error(`Failed to send multicast message for user ${userId}:`, error);
    return false;
  }
}

/**
 * Triggered in real-time when lesson progress is updated.
 * Detects lesson completion and sends pass/fail push notifications.
 */
export const onLessonProgressUpdate = onDocumentWritten(
  "users/{userId}/lessonProgress/{lessonId}",
  async (event) => {
    const userId = event.params.userId;
    const lessonId = event.params.lessonId;

    if (!event.data) {
      console.log(`Progress document deleted for user ${userId}, lesson ${lessonId}.`);
      return;
    }

    const before = event.data.before ? event.data.before.data() : null;
    const after = event.data.after ? event.data.after.data() : null;

    if (!after) {
      console.log(`Progress document deleted in update for user ${userId}, lesson ${lessonId}.`);
      return;
    }

    // A lesson is complete when currentSubLessonIndex + (currentExerciseIndex || 0) === totalLessonIndex
    // AND currentExerciseIndex is not null (so it is not just the initial or intermediate sub-lesson states)
    const wasCompleted = before
      ? before.currentSubLessonIndex + (before.currentExerciseIndex || 0) === before.totalLessonIndex
      : false;

    const isCompleted =
      after.currentSubLessonIndex + (after.currentExerciseIndex || 0) === after.totalLessonIndex &&
      after.currentExerciseIndex !== null &&
      after.currentExerciseIndex !== undefined;

    if (isCompleted && !wasCompleted) {
      console.log(`User ${userId} completed lesson ${lessonId}.`);

      // 1. Calculate the score percentage
      const score = after.score || 0;
      const maxScore = after.currentExerciseIndex || 1; // Fallback to 1 if no exercises (avoid NaN)
      const percentScore = Math.round((score / maxScore) * 100);
      const passed = percentScore >= 50;

      // 2. Increment completedLessonsCount on the user document if it's the first time completing this lesson
      const db = admin.firestore();
      const userRef = db.collection("users").doc(userId);

      // Increment only if we haven't already marked this lesson completed (or if document is newly completed)
      await db.runTransaction(async (transaction) => {
        const userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          const userData = userDoc.data();
          
          const completedLessonIds = userData?.completedLessonIds || [];
          if (!completedLessonIds.includes(lessonId)) {
            completedLessonIds.push(lessonId);
            transaction.update(userRef, {
              completedLessonsCount: completedLessonIds.length,
              completedLessonIds: completedLessonIds,
            });
          }
        }
      });

      // 3. Send real-time pass/fail push notification
      let title = "";
      let body = "";

      if (passed) {
        title = "Great job! 🎉";
        body = "Great job! 🎉 You passed the lesson!";
      } else {
        title = "You almost got it! 💪";
        body = "You almost got it! Retake the lesson to improve your score 💪";
      }

      await sendPushNotification(userId, { title, body });
    }
  }
);

/**
 * Scheduled cron job running daily at 9:00 AM.
 * Checks for:
 * 1. Inactive users (7 days since lastActive)
 * 2. Unsubscribed users upsell (every 7 days, completed >= 1 free lesson)
 */
export const dailyNotificationCheck = onSchedule(
  "0 9 * * *",
  async (event) => {
    const db = admin.firestore();
    const now = new Date();

    console.log("Starting daily notification checker...");

    // 1. Process Inactive Users
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    // Query users inactive for 7+ days
    const inactiveUsersSnapshot = await db
      .collection("users")
      .where("lastActive", "<=", sevenDaysAgo)
      .get();

    console.log(`Found ${inactiveUsersSnapshot.size} potentially inactive users.`);

    for (const doc of inactiveUsersSnapshot.docs) {
      const userData = doc.data();
      const userId = doc.id;

      // Ensure we don't send re-engagement notifications more than once every 7 days
      const lastReengagementSent = userData.lastReengagementSent
        ? userData.lastReengagementSent.toDate()
        : null;

      if (
        lastReengagementSent &&
        now.getTime() - lastReengagementSent.getTime() < 7 * 24 * 60 * 60 * 1000
      ) {
        console.log(`User ${userId} was already sent a re-engagement notification recently. Skipping.`);
        continue;
      }

      const sent = await sendPushNotification(userId, {
        title: "We miss you! ❤️",
        body: "We miss you! Come back and continue your French learning journey.",
      });

      if (sent) {
        await doc.ref.update({
          lastReengagementSent: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    // 2. Process Free Users Upsell
    const freeUsersSnapshot = await db
      .collection("users")
      .where("isSubscribed", "==", false)
      .get();

    console.log(`Found ${freeUsersSnapshot.size} unsubscribed users to check for upsell.`);

    for (const doc of freeUsersSnapshot.docs) {
      const userData = doc.data();
      const userId = doc.id;
      let completedLessonsCount = userData.completedLessonsCount;

      // Dynamic fallback/migration for existing users:
      // If completedLessonsCount is missing, we check their lessonProgress/1 (Lesson 1 is the only free lesson)
    if (completedLessonsCount === undefined) {
      const lessonProgressSnapshot = await db
        .collection("users")
        .doc(userId)
        .collection("lessonProgress")
        .get();

      const completedLessonIds: string[] = [];

      lessonProgressSnapshot.forEach((lessonDoc) => {
        const progress = lessonDoc.data();

        const isCompleted =
          progress &&
          progress.currentExerciseIndex !== null &&
          progress.currentExerciseIndex !== undefined &&
          progress.currentSubLessonIndex + (progress.currentExerciseIndex || 0) ===
            progress.totalLessonIndex;

        if (isCompleted) {
          completedLessonIds.push(lessonDoc.id);
        }
      });

      completedLessonsCount = completedLessonIds.length;

      await doc.ref.update({
      completedLessonsCount: completedLessonsCount,
        completedLessonIds: completedLessonIds
      });

      console.log(
        `Migrated existing user ${userId}: ${completedLessonsCount} completed lessons.`
      );
    }

      if (completedLessonsCount && completedLessonsCount >= 1) {
        const lastUpsellSent = userData.lastUpsellSent
          ? userData.lastUpsellSent.toDate()
          : null;

        // Ensure upsell notifications are sent only once every 7 days
        if (
          lastUpsellSent &&
          now.getTime() - lastUpsellSent.getTime() < 7 * 24 * 60 * 60 * 1000
        ) {
          console.log(`User ${userId} was already sent an upsell notification recently. Skipping.`);
          continue;
        }

        const sent = await sendPushNotification(userId, {
          title: "Unlock Premium Fluency",
          body: "Unlock full French fluency with premium lessons",
        });

        if (sent) {
          await doc.ref.update({
            lastUpsellSent: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
    }

    console.log("Daily notification checker finished.");
  }
);
