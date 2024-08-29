// Once installed, you can access the firebase_analytics plugin by importing it in your Dart code:
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  // Create a new Firebase Analytics instance by accessing the instance property on FirebaseAnalytics:
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> logButtonPressed() async {
    print('Logging event to Firebase Analytics...');
    try {
      await analytics.logEvent(
        name: 'button_pressed',
        parameters: <String, Object>{
          'button_name': 'FloatingActionButton',
          'action': 'pressed',
        },
      );
      print('Event logged successfully.');
    } catch (e) {
      print('Failed to log event: $e');
    }
  }
}

/** N O T E S
 * Future<void> Return Type:
 * The Future<void> return type indicates that the method logButtonPressed performs an 
      asynchronous operation but doesn't return any value (hence void).
 * This allows you to use await when calling this method to wait for the operation to complete, 
      ensuring that subsequent code runs only after the event has been logged successfully.
 * If you didn't use Future<void>, the method wouldn't handle the asynchronous nature of 
      logEvent properly, potentially leading to issues where the event might not be logged before the function finishes.
 */

/**
 * Why Use async and await?
 * async Keyword: This keyword is used to indicate that a function contains asynchronous code.
      It allows the function to use the await keyword to pause execution until the Future completes.
 * await Keyword: The await keyword is used to wait for the completion of a Future. 
      When you use await _analytics.logEvent(...), you're telling Dart to wait for the 
      logging operation to complete before moving on to the next line of code. 
      This ensures that the event is fully logged before any subsequent operations are performed.
 */