import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:poc/LoginPage.dart';
import 'fcm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  runApp(FcmApp());
}

class FcmApp extends StatefulWidget {
  @override
  _FcmAppState createState() => _FcmAppState();
}

class _FcmAppState extends State<FcmApp> {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(
        alert: true,
        badge: true,
        sound: true,
      ),
    );
    firebaseMessaging.getToken().then((token) {
      if (token != null) {
        Firestore.instance.document('tokens/$token').setData(
          {
            "tokenID": token,
          },
        );
      }
      print("token2=" + token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM App',
      home: _handleAuth(),
      debugShowCheckedModeBanner: false,
    );
  }
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
GoogleSignIn googleSignIn = GoogleSignIn();

Widget _handleAuth() {
  return StreamBuilder<FirebaseUser>(
    stream: firebaseAuth.onAuthStateChanged,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.none)
        return loadingWidget();
      else if (snapshot.hasData) {
        return FcmScreen(snapshot.data, googleSignIn);
      } else {
        return LoginScreen(firebaseAuth, googleSignIn);
      }
    },
  );
}

Widget loadingWidget() {
  waiting();
  return Scaffold(
    body: Center(
      child: RefreshProgressIndicator(),
    ),
  );
}

Future<Null> waiting() async {
  await Future.delayed(Duration(seconds: 3));
}