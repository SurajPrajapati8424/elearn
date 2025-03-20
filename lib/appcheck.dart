import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Import the firebase_app_check plugin
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> appCheckGetToken() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  try {
    String? token = await FirebaseAppCheck.instance.getToken(true);
    debugPrint("App Check token: $token");
    // Use the token as needed, e.g., for custom backend verification
  } catch (e) {
    debugPrint("Failed to get App Check token: $e");
  }
}
