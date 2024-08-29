import 'package:firebase_performance/firebase_performance.dart';

class Performancestats {
  static Future<void> performanceOperation() async {
    final Trace trace =
        FirebasePerformance.instance.newTrace('my_performance_trace_delay');
    trace.start();
    try {
      // Simulate a network request or heavy computation
      await Future.delayed(const Duration(seconds: 3));
    } catch (e, stackTrace) {
      // Log the error and stack trace
      print('Error during performance operation: $e');
      print('Stack trace: $stackTrace');

      // You might also want to log this error to Crashlytics or another monitoring service
      // FirebaseCrashlytics.instance.recordError(e, stackTrace);
    } finally {
      print('trace stopped');
      trace.stop();
    }
  }
}
