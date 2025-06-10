// const functions = require('firebase-functions');
// const admin = require('firebase-admin');
// const moment = require('moment');
// admin.initializeApp();

// // Send a notification when a medicine is 3 or 6 months away from expiry
// exports.checkMedicineExpiry = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
//   const medicinesRef = admin.firestore().collection('medicines');
//   const snapshot = await medicinesRef.get();

//   // Collect async operations in a Promise array
//   const expiryChecks = snapshot.docs.map(async (doc) => {
//     const medicine = doc.data();
//     const expiryDate = moment(medicine.expiry_date, 'MM-YYYY'); // Adjusted to use the string expiry date
//     const currentDate = moment();

//     const monthsBeforeExpiry = [3, 6];
//     const reminders = monthsBeforeExpiry.map(async (months) => {
//       const reminderDate = expiryDate.subtract(months, 'months');

//       // Check if current date is within the 3 or 6 months before expiry
//       if (reminderDate.isSameOrBefore(currentDate, 'day') && !medicine[`${months}MonthReminderSent`]) {
//         // Send notification logic
//         await sendExpiryNotification(medicine.userId, medicine.medicine_name, months);

//         // Update Firestore to mark that the reminder has been sent
//         await doc.ref.update({ [`${months}MonthReminderSent`]: true });
//       }
//     });

//     // Wait for all reminder checks to finish
//     await Promise.all(reminders);
//   });

//   // Wait for all medicines to be processed
//   await Promise.all(expiryChecks);
// });

// // Helper function to send notifications
// async function sendExpiryNotification(userId, medicineName, monthsBefore) {
//   const userDoc = await admin.firestore().collection('users').doc(userId).get();
//   const user = userDoc.data();

//   if (user && user.fcmToken) {
//     const message = {
//       notification: {
//         title: 'Medicine Expiry Reminder',
//         body: `Your medicine "${medicineName}" will expire in ${monthsBefore} months.`,
//       },
//       token: user.fcmToken,
//     };

//     try {
//       await admin.messaging().send(message);
//       console.log('Notification sent successfully');
//     } catch (error) {
//       console.error('Error sending notification', error);
//     }
//   }
// }


// firebase deploy --only functions


const functions = require("firebase-functions");
const admin = require("firebase-admin");
const moment = require("moment");

admin.initializeApp();

exports.checkMedicineReminders = functions.pubsub
  .schedule("every day 00:00")
  .timeZone("Asia/Kolkata")
  .onRun(async () => {
    const usersSnapshot = await admin.firestore().collection("users").get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const userData = userDoc.data();

      const token = userData.fcmToken;
      if (!token) continue;

      const medsSnapshot = await userDoc.ref.collection("medicine_reminders").get();

      for (const doc of medsSnapshot.docs) {
        const data = doc.data();

        if (!data.reminder_date || data.notified) continue;

        const reminderDate = moment(data.reminder_date.toDate()).format("YYYY-MM-DD");
        const today = moment().format("YYYY-MM-DD");

        if (reminderDate === today) {
          const medicineName = data.medicine_name || "your medicine";
          const monthsBefore = data.months_before || 0;

          const messageText = `Your medicine "${medicineName}" is set to expire in ${monthsBefore} month${monthsBefore > 1 ? "s" : ""}.`;

          // 1. Send push notification
          await sendReminderNotification(token, medicineName, monthsBefore);

          // 2. Save in notifications subcollection
          await userDoc.ref.collection("notifications").add({
            title: "Medicine Expiry Reminder",
            body: messageText,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            read: false,
          });

          // 3. Mark as notified
          await doc.ref.update({ notified: true });

          console.log(`Notification sent and saved for ${userId}`);
        }
      }
    }
  });

async function sendReminderNotification(token, medicineName, monthsBefore) {
  const message = {
    notification: {
      title: "Medicine Expiry Reminder",
      body: `Your medicine "${medicineName}" is set to expire in ${monthsBefore} month${monthsBefore > 1 ? "s" : ""}.`,
    },
    token: token,
  };

  try {
    await admin.messaging().send(message);
    console.log("FCM sent successfully");
  } catch (err) {
    console.error("FCM send failed:", err);
  }
}
