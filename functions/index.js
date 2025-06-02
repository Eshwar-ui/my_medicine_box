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

// Function runs every day
exports.checkMedicineReminders = functions.pubsub.schedule("every 24 hours").onRun(async () => {
  const usersSnapshot = await admin.firestore().collection("users").get();

  for (const userDoc of usersSnapshot.docs) {
    const userId = userDoc.id;
    const userData = userDoc.data();

    const token = userData.fcmToken;
    if (!token) continue; // Skip if user has no FCM token

    const medsSnapshot = await userDoc.ref.collection("medicine_notifications").get();

    for (const doc of medsSnapshot.docs) {
      const data = doc.data();

      // Check if reminder_date exists
      if (!data.reminder_date) continue;

      const reminderDate = moment(data.reminder_date.toDate()).format("YYYY-MM-DD");
      const currentDate = moment().format("YYYY-MM-DD");

      if (reminderDate === currentDate) {
        const medicineName = data.medicine_name || "a medicine";

        // Send push notification
        await sendReminderNotification(token, medicineName);

        // Store in notifications subcollection
        await userDoc.ref.collection("notifications").add({
          title: "Medicine Reminder",
          body: `Reminder: Take your medicine "${medicineName}" today.`,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
        });

        console.log(`Notification sent and saved for ${userId}`);
      }
    }
  }
});

async function sendReminderNotification(token, medicineName) {
  const message = {
    notification: {
      title: "Medicine Reminder",
      body: `Reminder: Take your medicine "${medicineName}" today.`,
    },
    token: token,
  };

  try {
    await admin.messaging().send(message);
    console.log("Notification sent successfully");
  } catch (error) {
    console.error("Error sending FCM notification:", error);
  }
}
