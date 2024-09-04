import 'dart:async';
import 'dart:io';
import 'package:elearn/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PushCloudMessageService {
  static final FirebaseMessaging _firebaseMessagingInstance =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize FCM and handle notifications
  static Future<void> initFCM() async {
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
    } else if (setting.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // initalize local notifications
  static Future localNotiInit() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // for ios
    // final DarwinInitializationSettings initializationSettingsDarwin =
    //     DarwinInitializationSettings(
    //   onDidReceiveLocalNotification: (id, title, body, payload) => null,
    // );
    // final LinuxInitializationSettings initializationSettingsLinux =
    //     LinuxInitializationSettings(defaultActionName: 'Open notification');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsDarwin,
      // linux: initializationSettingsLinux,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  // on tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    globalNavigatorKey.currentState!
        .pushNamed("/screenFCM", arguments: notificationResponse);
  }

  // show a simple notification + Big Image
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
    String? imageUrl, // make this optional
    String? iconUrl, // optional Large Icon URL
  }) async {
    // If there's an image URL, try to download it
    String? largeIconPath;
    String? smallImagePath;
    // imageUrl -> largeIconPath
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        largeIconPath = await _downloadAndSaveFile(imageUrl, 'bigImage');
      } catch (e, stackTrace) {
        print('Failed to download image: $e\n$stackTrace');
        largeIconPath = null;
      }
    }
    // iconUrl -> bigImagePath
    if (iconUrl != null && iconUrl.isNotEmpty) {
      try {
        smallImagePath = await _downloadAndSaveFile(iconUrl, 'smallIcon');
      } catch (e, stackTrace) {
        print('Failed to download big image: $e\n$stackTrace');
        smallImagePath = null;
      }
    }

    // Create Big Picture Style Information if an image was downloaded
    BigPictureStyleInformation? bigPictureStyleInformation;
    // only assign when big picture is present otherwise no need
    if (largeIconPath != null) {
      bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(largeIconPath),
        // largeIcon: FilePathAndroidBitmap(largeIconPath),
        largeIcon: smallImagePath != null
            ? FilePathAndroidBitmap(smallImagePath)
            : null,
        contentTitle: title,
        summaryText: body,
        htmlFormatContent: true,
        htmlFormatContentTitle: true,
      );
    }
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: bigPictureStyleInformation,
      // largeIcon:
      //     smallImagePath != null ? FilePathAndroidBitmap(smallImagePath) : null,
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _flutterLocalNotificationsPlugin.show(
        notificationId, title, body, notificationDetails,
        payload: payload);
  }

  // Download and save the file locally
  static Future<String?> _downloadAndSaveFile(
      String? url, String fileName) async {
    if (url == null || url.isEmpty) {
      print('Invalid URL provided.');
      return null;
    }
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final File file = File(filePath);
    // Check if the file already exists
    // if (await file.exists()) {
    //   print('File already exists at $filePath');
    //   return filePath;
    // }
    try {
      // Set a timeout for the HTTP request to prevent it from hanging indefinitely
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: {"Accept": "image/*"},
      ).timeout(
        const Duration(seconds: 10), // Adjust the duration as needed
        // onTimeout: () {
        //   throw TimeoutException(
        //       'The connection has timed out, Please try again!');
        // },
      );
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print('done saving...');
        return filePath;
      } else {
        print('Failed to download file: ${response.statusCode} \n $fileName');
      }
    } on SocketException catch (e) {
      print('Network error: $e');
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
    } catch (e) {
      print('Error downloading file: $e');
    }
    return null;
  }
}
/**
  {
  "to": "device_token",
  "notification": {
    "android": {
      "imageUrl": "https://example.com/path/to/your/image.jpg"
    }
    "title": "Notification Title",
    "body": "This is the notification body",
  },
  "data": {
    "iconURL": 'path/file/.png\.jpg'
    "key": "val"
  }
}

 */