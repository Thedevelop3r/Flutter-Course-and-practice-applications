import 'dart:math';

import 'package:chatshat/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatshat/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;
User loggedUser;

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({this.SenderName});
  final String SenderName;
  static String id = 'messages_screen';

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String receiver;
  String _messageText;
  final _auth = FirebaseAuth.instance;
  bool gotcurrentuser = false;

  bool showSpinner = false;
  final msgTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    setState(() {
      receiver = widget.SenderName;
    });

    getCurrentUser();
    // getMessages(); only for test purpose print statements only;
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;

      if (user != null) {
        loggedUser = user;
        print(loggedUser);
        print(loggedUser.email);
        setState(() {
          gotcurrentuser = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (gotcurrentuser == false) {
      return Text('Loading');
    }
    return Scaffold(
      appBar: AppBar(
        //elevation: 12.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // actions: <Widget>[
        //   IconButton(
        //       icon: Icon(Icons.close),
        //       onPressed: () async {
        //         setState(() {
        //           showSpinner = true;
        //         });
        //         await _auth.signOut();
        //         setState(() {
        //           showSpinner = false;
        //         });
        //         Navigator.pop(context);
        //         //Implement logout functionality
        //       }),
        // ],
        title: Text('$receiver'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessageStream(receiver: receiver),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: msgTextController,
                        onChanged: (value) {
                          _messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_messageText != null && _messageText.length < 200) {
                          try {
                            _fireStore.collection('messages').add({
                              'text': _messageText,
                              'sender': loggedUser.email,
                              'receiver': receiver.toString(),
                              'timestamp': FieldValue.serverTimestamp()
                            });
                            msgTextController.clear();
                            _messageText = null;
                            // print('message sent');
                          } catch (e) {
                            print('send:firestore error log: ' + e);
                          }
                        }
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  MessageStream({@required this.receiver});
  final receiver;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // return a list
          return Flexible(
            child: Center(
              heightFactor: 15.0,
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
                strokeWidth: 2.0,
                backgroundColor: Colors.deepOrangeAccent,
              ),
            ),
          );
        }
        // here function after getting the data back;
        final messages = snapshot.data.docs;
        List<MessageBubbles> messageBubbles = [];
        // iteration through loop
        for (var message in messages) {
          if (message['sender'] == receiver &&
                  message['receiver'] == loggedUser.email ||
              message['sender'] == loggedUser.email &&
                  message['receiver'] == receiver) {
            final messageText = message['text'];
            final messageSender = message['sender'];
            final currentUser = loggedUser.email;

            //
            final textBubble = MessageBubbles(
                sender: messageSender,
                text: messageText,
                isMe: currentUser == messageSender);
            messageBubbles.add(textBubble);
          } // if condition met  else msg are not filtered.
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubbles extends StatelessWidget {
  MessageBubbles({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;
  //final timestamp;

  BorderRadius customBorderRadius(bool me) {
    return me
        ? BorderRadius.only(
            topLeft: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0))
        : BorderRadius.only(
            topRight: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
                color: isMe ? Colors.black38 : Colors.purpleAccent[100],
                fontSize: 13.0),
          ),
          Material(
            elevation: 5.0,
            borderRadius: customBorderRadius(isMe),
            color: isMe ? Colors.blueAccent : Colors.orangeAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
              child: Text(
                text,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
