import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';

class InAppMessagingService {
  // Initialize F-Msg & F-Install
  static final FirebaseInAppMessaging fiamInstance =
      FirebaseInAppMessaging.instance;
  static final FirebaseInstallations fId = FirebaseInstallations.instance;

  static Future<void> initInAppMessaging() async {
    String fid = await fId.getId();
    print('Firebase Installation FID: $fid');
  }

  // Trigger event and show feedback in Snackbar
  static void triggerEvent(String eventName) {
    fiamInstance.triggerEvent(eventName);
    // Displaying a Snackbar when the event is triggered
    // final snackBar = SnackBar(
    //   content: Text('Triggered event: $eventName'),
    //   duration: Duration(seconds: 2),
    // );
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Call the method to listen for impressions
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
