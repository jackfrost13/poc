import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FcmScreen extends StatefulWidget {
  final FirebaseUser firebaseUser;
  final GoogleSignIn googleSignIn;

  FcmScreen(this.firebaseUser, this.googleSignIn);

  @override
  _FcmScreenState createState() => _FcmScreenState(firebaseUser);
}

class _FcmScreenState extends State<FcmScreen> {
  FirebaseUser firebaseUser;

  _FcmScreenState(this.firebaseUser);

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    String token;
    _firebaseMessaging.getToken().then((String t){token=t;});
      print("token = $token");
    return Scaffold(
      appBar: AppBar(
        title: Text('FcmScreen'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              widget.googleSignIn.disconnect();
              FirebaseAuth.instance.signOut();
            },
            tooltip: 'SignOut',
          )
        ],
      ),
      body: Container(
        child: Center(
          child: Text('logged in'),
        ),
      ),
    );
  }
}
