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


// // Copyright 2017 The Flutter Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.

// import 'dart:async';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// final Map<String, Item> _items = <String, Item>{};
// Item _itemForMessage(Map<String, dynamic> message) {
//   final String itemId = message['data']['id'];
//   final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
//     ..status = message['data']['status'];
//   return item;
// }

// class Item {
//   Item({this.itemId});
//   final String itemId;

//   StreamController<Item> _controller = StreamController<Item>.broadcast();
//   Stream<Item> get onChanged => _controller.stream;

//   String _status;
//   String get status => _status;
//   set status(String value) {
//     _status = value;
//     _controller.add(this);
//   }

//   static final Map<String, Route<void>> routes = <String, Route<void>>{};
//   Route<void> get route {
//     final String routeName = '/detail/$itemId';
//     return routes.putIfAbsent(
//       routeName,
//           () => MaterialPageRoute<void>(
//         settings: RouteSettings(name: routeName),
//         builder: (BuildContext context) => DetailPage(itemId),
//       ),
//     );
//   }
// }

// class DetailPage extends StatefulWidget {
//   DetailPage(this.itemId);
//   final String itemId;
//   @override
//   _DetailPageState createState() => _DetailPageState();
// }

// class _DetailPageState extends State<DetailPage> {
//   Item _item;
//   StreamSubscription<Item> _subscription;

//   @override
//   void initState() {
//     super.initState();
//     _item = _items[widget.itemId];
//     _subscription = _item.onChanged.listen((Item item) {
//       if (!mounted) {
//         _subscription.cancel();
//       } else {
//         setState(() {
//           _item = item;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Item ${_item.itemId}"),
//       ),
//       body: Material(
//         child: Center(child: Text("Item status: ${_item.status}")),
//       ),
//     );
//   }
// }

// class PushMessagingExample extends StatefulWidget {
//   @override
//   _PushMessagingExampleState createState() => _PushMessagingExampleState();
// }

// class _PushMessagingExampleState extends State<PushMessagingExample> {
//   String _homeScreenText = "Waiting for token...";
//   bool _topicButtonsDisabled = false;

//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//   final TextEditingController _topicController =
//   TextEditingController(text: 'topic');

//   Widget _buildDialog(BuildContext context, Item item) {
//     return AlertDialog(
//       content: Text("Item ${item.itemId} has been updated"),
//       actions: <Widget>[
//         FlatButton(
//           child: const Text('CLOSE'),
//           onPressed: () {
//             Navigator.pop(context, false);
//           },
//         ),
//         FlatButton(
//           child: const Text('SHOW'),
//           onPressed: () {
//             Navigator.pop(context, true);
//           },
//         ),
//       ],
//     );
//   }

//   void _showItemDialog(Map<String, dynamic> message) {
//     showDialog<bool>(
//       context: context,
//       builder: (_) => _buildDialog(context, _itemForMessage(message)),
//     ).then((bool shouldNavigate) {
//       if (shouldNavigate == true) {
//         _navigateToItemDetail(message);
//       }
//     });
//   }

//   void _navigateToItemDetail(Map<String, dynamic> message) {
//     final Item item = _itemForMessage(message);
//     // Clear away dialogs
//     Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
//     if (!item.route.isCurrent) {
//       Navigator.push(context, item.route);
//     }
//   }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Push Messaging Demo'),
//         ),
//         // For testing -- simulate a message being received
//         floatingActionButton: FloatingActionButton(
//           onPressed: () => _showItemDialog(<String, dynamic>{
//             "id": "2",
//             "status": "out of stock",
//           }),
//           tooltip: 'Simulate Message',
//           child: const Icon(Icons.message),
//         ),
//         body: Material(
//           child: Column(
//             children: <Widget>[
//               Center(
//                 child: Text(_homeScreenText),
//               ),
//               Row(children: <Widget>[
//                 Expanded(
//                   child: TextField(
//                       controller: _topicController,
//                       onChanged: (String v) {
//                         setState(() {
//                           _topicButtonsDisabled = v.isEmpty;
//                         });
//                       }),
//                 ),
//                 FlatButton(
//                   child: const Text("subscribe"),
//                   onPressed: _topicButtonsDisabled
//                       ? null
//                       : () {
//                     _firebaseMessaging
//                         .subscribeToTopic(_topicController.text);
//                     _clearTopicText();
//                   },
//                 ),
//                 FlatButton(
//                   child: const Text("unsubscribe"),
//                   onPressed: _topicButtonsDisabled
//                       ? null
//                       : () {
//                     _firebaseMessaging
//                         .unsubscribeFromTopic(_topicController.text);
//                     _clearTopicText();
//                   },
//                 ),
//               ])
//             ],
//           ),
//         ));
//   }

//   void _clearTopicText() {
//     setState(() {
//       _topicController.text = "";
//       _topicButtonsDisabled = true;
//     });
//   }
// }

// void main() {
//   runApp(
//     MaterialApp(
//       home: PushMessagingExample(),
//     ),
//   );
// }
