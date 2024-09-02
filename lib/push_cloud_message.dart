import 'package:firebase_messaging/firebase_messaging.dart';

class PushCloudMessageService {
  static final FirebaseMessaging _firebaseMessagingInstance =
      FirebaseMessaging.instance;

  // Initialize FCM and handle notifications
  Future<void> initFCM() async {
    // Request permission for notifications (iOS only, optional)
    NotificationSettings setting =
        await _firebaseMessagingInstance.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true);
    // Generating Token
    final String? token = await _firebaseMessagingInstance.getToken();
    print('Device TOKEN: $token');

    // Handle permission denied
    if (setting.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }
    if (setting.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
}
