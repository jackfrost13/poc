import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print("token is === $_homeScreenText");
      Firestore.instance.document('tokens/$token').setData(
        {
          "tokenID": token,
        },
      );
    });
  }
  String _homeScreenText = "Waiting for token...";


  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: <Widget>[
            Text(_homeScreenText),
            Divider(
              height: 20.0,
            ),
            showChat(context),
            Divider(
              height: 20.0,
            ),
            keyboardInput(context),
            Text('ChatScreen'),
          ],
        ),
      ),
    );
  }

  final reference = Firestore.instance
      .collection("messages")
      .orderBy('timestamp', descending: true);
  Widget showChat(BuildContext context) {
    return Flexible(
      child: StreamBuilder(
          stream: reference.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return snapshot.hasData
                ? ListView(
                    reverse: true,
                    children: snapshot.data.documents
                        .map((DocumentSnapshot docSnaphot) =>
                            messageCard(docSnaphot.data))
                        .toList(),
                  )
                : Container();
          }),
    );
  }

  Widget messageCard(Map message) => Card(
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 25.0,
              backgroundImage: NetworkImage(message['photoUrl']),
            ),
            Column(
              children: <Widget>[
                Text(message['email']),
                message['text'] != null ? Text(message['text']) : Container(),
                message['uploadUrl'] != null
                    ? Image.network(
                        message['uploadUrl'],
                        height: 100.0,
                        width: 100.0,
                        semanticLabel: 'xyzzz',
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      );

  Widget keyboardInput(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            child: IconButton(
                icon: Icon(Icons.camera_enhance),
                onPressed: () async {
                  File imageFile =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  int time = DateTime.now().millisecondsSinceEpoch;
                  StorageReference storage =
                      FirebaseStorage.instance.ref().child("img$time.jpg");
                  StorageUploadTask uploadTask = storage.putFile(imageFile);
                  StorageTaskSnapshot t = await uploadTask.onComplete;
                  String url = await t.ref.getDownloadURL();
                  storeMessage(null, url);
                }),
          ),
          Flexible(
            child: TextField(
              textInputAction: TextInputAction.newline,
              controller: textEditingController,
              decoration:
                  new InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          Container(
            child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  String msg = textEditingController.text.trim();
                  if (msg.length > 0) {
                    storeMessage(msg, null);
                    textEditingController.clear();
                  }
                }),
          ),
        ],
      ),
    );
  }

  void storeMessage(String text, String url) {
    print("inside store");
    int time = DateTime.now().millisecondsSinceEpoch;

    print("time = $time");
    Firestore.instance.collection('messages').document().setData({
      'name': firebaseUser.displayName,
      'userid': firebaseUser.uid,
      'text': text,
      'timestamp': time,
      'photoUrl': firebaseUser.photoUrl,
      'email': firebaseUser.email,
      'uploadUrl': url,
    });
  }
}
