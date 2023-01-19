import 'package:chatshat/screens/messages_screen.dart';
import 'package:chatshat/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatshat/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;
User loggedUser;

class Conversations extends StatefulWidget {
  //const Conversations({Key? key}) : super(key: key);

  static String id = 'conversations_page';

  @override
  State<Conversations> createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
  final _auth = FirebaseAuth.instance;
  bool showAddContactWidget = false;
  String addUserName;

  /// for build method error resolving
  bool gotCurrentUser = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  /// this is current signed in user
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;

      if (user != null) {
        setState(() {
          loggedUser = user;
        });
        print('CONVERSATION:::::>>>  $loggedUser ');
        print('CONVERSATION:::::>>> ${loggedUser.email}');
        setState(() {
          gotCurrentUser = true;
        });
      }
    } catch (e) {
      print('CONVERSATION:::::>>> $e');
    }
  }

  /// add users through this function getuserbyemail
  void getUserByEmail() async {
    var usersQuery = _fireStore.collection('users/${addUserName}/username');
    var doneQuery;
    try {
      doneQuery = await usersQuery
          .where('username', isEqualTo: addUserName.toString())
          .get();
      print('DOne Query docs Single > ' + doneQuery.docs.single.toString());
    } catch (e) {
      print('finding query )> ' + e.toString());
    }
    try {
      if (doneQuery.docs.single['username'] == loggedUser.email) {
        print('You cannot add yourself as a freind');
        return;
      }
    } catch (e) {
      print('Matching query )> ' + e.toString());
    }

    if (doneQuery.docs.isEmpty) {
      print('User Not Found');
      return;
    } else if (doneQuery != null) {
      for (var doc in doneQuery.docs) {
        print('Query Result' + doc.data().toString());

        /// we got a user;
        /// now we add it to our friends list
        try {
          await _fireStore
              .collection('users/${loggedUser.email}/friends')
              .add({'friend': doc.get('username')});
        } catch (e) {
          print('add query )> ' + e.toString());
        }
      }
    }

    /// query try complete here
    ///
  }

  @override
  Widget build(BuildContext context) {
    if (gotCurrentUser == false) {
      return Scaffold(
        body: Text("User Not Found"),
      );
    }
    return Scaffold(
      appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () async {
                  // Scaffold.of(context).openDrawer();
                  await _auth.signOut();
                  Navigator.popAndPushNamed(context, WelcomeScreen.id);
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          title: loggedUser != null
              ? Text('${loggedUser.email}')
              : Text('Connecting...')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fireStore
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  // return a list
                  return Center(
                    heightFactor: 15.0,
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                      strokeWidth: 2.0,
                      backgroundColor: Colors.deepOrangeAccent,
                    ),
                  );
                }
                // here function after getting the data back;
                final NewMsg = snapshot.data.docs;
                List<Widget> NewMsgList = [];
                // iteration through loop
                for (var newmsg in NewMsg) {
                  if (newmsg['receiver'] == loggedUser.email) {
                    String sendername = newmsg['sender'];
                    NewMsgList.add(ChatBox(
                        userName: newmsg['sender'],
                        textMessage: newmsg['text']));
                  }
                }
                return ListView(
                  children: NewMsgList,
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fireStore
                  .collection('users/${loggedUser.email}/friends')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  // return a list
                  return Center(
                    heightFactor: 15.0,
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                      strokeWidth: 2.0,
                      backgroundColor: Colors.deepOrangeAccent,
                    ),
                  );
                }
                // here function after getting the data back;
                final friends = snapshot.data.docs;
                List<Widget> Friends = [];
                // iteration through loop
                for (var friend in friends) {
                  final friendname = friend['friend'];
                  // print('Friend Name:' + friendname);
                  Friends.add(ChatBox(userName: friendname, textMessage: ' '));
                }
                return ListView(
                  children: Friends,
                );
              },
            ),
          ),
          Visibility(
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  flex: 3,
                  child: TextField(
                    //properties
                    textAlign: TextAlign.center,
                    style: KtextFieldTextStyle,
                    decoration:
                        kTextFieldDecoration.copyWith(hintText: 'Enter Email'),
                    //function
                    onChanged: (value) {
                      /// add user by email to start chat and retrive it in chatbox

                      addUserName = value;
                    },
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0))),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blue[50]),
                      fixedSize: MaterialStateProperty.all(
                        Size(0.0, 40.0),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        /// here we implement add contact
                        getUserByEmail();
                        showAddContactWidget = false;
                      });
                    },
                    child: Text('Add'),
                  ),
                )
              ],
            ),
            visible: showAddContactWidget,
          ),
          SizedBox(
            height: 5.0,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton(
              elevation: 3.0,
              child: Icon(Icons.contacts_outlined, size: 30.0),
              onPressed: () {
                setState(() {
                  if (showAddContactWidget) {
                    showAddContactWidget = false;
                  } else {
                    showAddContactWidget = true;
                  }
                });
              },
            ),
          )
        ],
      ),
    );
  }
}

class ChatBox extends StatelessWidget {
  const ChatBox({this.userName, this.textMessage});
  final userName;
  final textMessage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MessagesScreen(SenderName: userName)));
      },
      child: Material(
        //elevation: 2.0,
        child: Container(
          margin: EdgeInsets.only(top: 4.0),
          height: 60.0,
          padding: EdgeInsets.only(top: 3.0, left: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userName,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 3.0,
              ),
              Flexible(
                child: Text(
                  textMessage == null ? 'Empty' : textMessage,
                  //maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
