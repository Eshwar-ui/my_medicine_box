const functions = require('firebase-functions');
const admin = require('firebase-admin');
const moment = require('moment');
admin.initializeApp();

// Send a notification when a medicine is 3 or 6 months away from expiry
exports.checkMedicineExpiry = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  const medicinesRef = admin.firestore().collection('medicines');
  const snapshot = await medicinesRef.get();

  // Collect async operations in a Promise array
  const expiryChecks = snapshot.docs.map(async (doc) => {
    const medicine = doc.data();
    const expiryDate = moment(medicine.expiry_date, 'MM-YYYY'); // Adjusted to use the string expiry date
    const currentDate = moment();

    const monthsBeforeExpiry = [3, 6];
    const reminders = monthsBeforeExpiry.map(async (months) => {
      const reminderDate = expiryDate.subtract(months, 'months');
      
      // Check if current date is within the 3 or 6 months before expiry
      if (reminderDate.isSameOrBefore(currentDate, 'day') && !medicine[`${months}MonthReminderSent`]) {
        // Send notification logic
        await sendExpiryNotification(medicine.userId, medicine.medicine_name, months);
        
        // Update Firestore to mark that the reminder has been sent
        await doc.ref.update({ [`${months}MonthReminderSent`]: true });
      }
    });

    // Wait for all reminder checks to finish
    await Promise.all(reminders);
  });

  // Wait for all medicines to be processed
  await Promise.all(expiryChecks);
});

// Helper function to send notifications
async function sendExpiryNotification(userId, medicineName, monthsBefore) {
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  const user = userDoc.data();

  if (user && user.fcmToken) {
    const message = {
      notification: {
        title: 'Medicine Expiry Reminder',
        body: `Your medicine "${medicineName}" will expire in ${monthsBefore} months.`,
      },
      token: user.fcmToken,
    };

    try {
      await admin.messaging().send(message);
      console.log('Notification sent successfully');
    } catch (error) {
      console.error('Error sending notification', error);
    }
  }
}
