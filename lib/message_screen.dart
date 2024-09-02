import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    Map payload = {};
    final recievedData = ModalRoute.of(context)!.settings.arguments;
    if (recievedData is RemoteMessage) {
      payload = recievedData.data;
    }
    if (recievedData is NotificationResponse) {
      payload = jsonDecode(recievedData.payload!);
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Message'),
        ),
        body: Container(
          height: 300,
          width: 300,
          // how to style font
          margin: const EdgeInsetsDirectional.only(start: 20, top: 50),
          padding: const EdgeInsetsDirectional.only(start: 20),
          decoration: BoxDecoration(
            color: Colors.green[100],
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(25),
          ),
          // display two text
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'payload: ${payload.toString()}\n'
                'subject: ${payload['sub']}\n'
                'reason: ${payload['rsn']}\n',
                style: TextStyle(fontSize: 16, color: Colors.red[400]),
              ),
              const Text('2] Another Message'),
              // Text(
              //   'title: ${recievedData.notification.title ?? 'No Title'}\n'
              //   'body: ${recievedData.notification!.body ?? 'No body'}\n'
              //   'data: ${recievedData.data.toString()}\n'
              //   'subject: ${recievedData.data['sub'] ?? 'No sub'}\n'
              //   'reason: ${recievedData.data['rsn'] ?? 'No rsn'}\n',
              //   style: TextStyle(fontSize: 16, color: Colors.red[400]),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
