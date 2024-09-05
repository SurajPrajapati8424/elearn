import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';

class InAppMessagingService {
  // Initialize F-Msg & F-Install
  static final FirebaseInAppMessaging _fiamInstance =
      FirebaseInAppMessaging.instance;
  static final FirebaseInstallations fId = FirebaseInstallations.instance;

  static Future<void> initInAppMessaging() async {
    String fid = await fId.getId();
    print('Firebase Installation FID: $fid');
  }

  // trigger Event for in-app-msg
  static void triggerEvent(String eventName) {
    _fiamInstance.triggerEvent(eventName);
  }
  // // Temporary disable In-app Message
  // Future disableFirebaseInAppMessaging() async {
  //   await _firebaseInAppMessaging.setMessagesSuppressed(true);
  // }

  // // Enable in-app message
  // Future enableFirebaseInAppMessaging() async {
  //   await _firebaseInAppMessaging.setMessagesSuppressed(false);
  // }

  // To get the Firebase Installation ID (FID) required for testing and previewing Firebase In-App Messaging
  // // To get the Firebase Installation ID (FID) required for testing and previewing Firebase In-App Messaging
  // String fid = await FirebaseInstallations.instance.getId();
  // print('Firebase Installation ID: $fid');
}
