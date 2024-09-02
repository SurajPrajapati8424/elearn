import 'dart:convert';

import 'package:elearn/analytics.dart';
import 'package:elearn/message_screen.dart';
import 'package:elearn/performancestats.dart';
import 'package:elearn/push_cloud_message.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

final globalNavigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Crashlytics
  // Log non-fatal errors to Crashlytics
  FlutterError.onError = (FlutterErrorDetails errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics (for Native Platform)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance
        .recordError(error, stack, fatal: true, reason: 'Test #101');
    return true;
  };
  // Initialize Firebase Performance
  FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

  // Initialize Push Notification
  PushCloudMessageService.initFCM();
  // Handle background FCM & Listen to bg notification
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Handle background FCM when Clicked on
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msgFCM) {
    if (msgFCM.notification != null) {
      print('Some FCM Notification Received!');
      globalNavigatorKey.currentState!
          .pushNamed('/screenFCM', arguments: msgFCM);
    }
  });
  // to handle Foreground notification
  PushCloudMessageService.localNotiInit();
  // to handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage _message) {
    String payloadData = jsonEncode(_message.data);
    print('received on Foreground !');
    if (_message.notification != null) {
      PushCloudMessageService.showSimpleNotification(
          title: _message.notification!.title!,
          body: _message.notification!.body!,
          payload: payloadData);
    }
  });
  runApp(const MyApp());
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    print('Received Cloud Message!');
    print('Handling a background message: ${message.messageId}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Analytics'),
      debugShowCheckedModeBanner: true,
      // initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Analytics'),
        '/screenFCM': (context) => const MessageScreen(),
      },
      navigatorKey: globalNavigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  void triggerCrash() {
    // FirebaseCrashlytics.instance.log('This is Test Crash!');
    throw Exception('This is a test crash for Firebase Crashlytics. #404');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              // for C R A S H L Y T I C S
              onPressed: triggerCrash,
              child: const Text('Trigger crash'),
            ),
            // P E R F O R M A N C E
            ElevatedButton(
              onPressed: () {
                Performancestats.performanceOperation()
                    .then((value) => print('This is Performance Test!'));
              },
              child: const Text('Perform Operation'),
            ),
            ElevatedButton(
              onPressed: () {
                RemoteMessage msg = const RemoteMessage(
                  notification: RemoteNotification(
                      title: 'Test Notification',
                      body: 'This is a test notification.'),
                  data: {
                    'sub': 'DM',
                    'rsn': 'Extended',
                  },
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builder) => MessageScreen(),
                    settings: RouteSettings(
                      arguments: msg,
                    ),
                  ),
                );
              },
              child: const Text('Message Screen without FCM'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => const MessageScreen()));
                // );
              },
              child: const Text('Message Screen with FCM'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('onPressed');
          await AnalyticsService().logButtonPressed().then((value) =>
              print('clicked event is ADDED')); // Log the button press event
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
