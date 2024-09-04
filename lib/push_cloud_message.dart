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
  }) async {
    // If there's an image URL, try to download it
    String? largeIconPath;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        largeIconPath = await _downloadAndSaveFile(imageUrl, 'bigImage');
      } catch (e, stackTrace) {
        print('Failed to download image: $e\n$stackTrace');
        largeIconPath = null;
      }
    }

    // Create Big Picture Style Information if an image was downloaded
    BigPictureStyleInformation? bigPictureStyleInformation;
    // only assign when big picture is present otherwise no need
    if (largeIconPath != null) {
      bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(largeIconPath),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
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
      //     largeIconPath != null ? FilePathAndroidBitmap(largeIconPath) : null,
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
    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print('done saving...');
        return filePath;
      } else {
        print('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
    return null;
  }
}
