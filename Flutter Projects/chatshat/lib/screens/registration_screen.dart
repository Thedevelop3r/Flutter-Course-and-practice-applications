import 'package:chatshat/components/roundedbutton.dart';
import 'package:chatshat/screens/chat_screen.dart';
import 'package:chatshat/screens/conversations_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatshat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String email;
  String password = null;
  bool spinerShow = false;
  bool warningVisible = false;
  bool passwarningVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: spinerShow,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: heroAnimationHeight[1],
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                //properties
                textAlign: TextAlign.center,
                style: KtextFieldTextStyle,
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter Your Email'),
                //functions
                onChanged: (value) {
                  email = value;
                },
              ),
              SizedBox(
                height: 8.0,
              ),
              Visibility(
                visible: passwarningVisible,
                child: Center(
                  child: Text('Empty Password !',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
              TextField(
                //properties
                textAlign: TextAlign.center,
                obscureText: true,
                style: KtextFieldTextStyle,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter New Password - *min 6 char'),
                //function
                onChanged: (value) {
                  password = value;
                },
              ),
              SizedBox(
                height: 24.0,
              ),
              Visibility(
                visible: warningVisible,
                child: Center(
                  child: Text('Username already taken ! try new one.',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
              RoundedButton(
                title: "Register",
                color: Colors.blueAccent,
                onPressed: () async {
                  var newUser;
                  var queryy;

                  if (password == null) {
                    setState(() {
                      passwarningVisible = true;
                    });
                    return;
                  } else {
                    setState(() {
                      passwarningVisible = false;
                    });
                  }

                  if (password != null && password.length >= 6) {
                    setState(() {
                      spinerShow = true;
                    });
                    try {
                      setState(() {
                        warningVisible = false;
                      });
                      newUser = await _auth.createUserWithEmailAndPassword(
                          email: email, password: password);

                      if (newUser != null) {
                        await _firestore
                            .collection('users/${email}/username')
                            .add({'username': email});
                        Navigator.pushNamed(context, Conversations.id);
                      }

                      // try {
                      //   queryy = await _firestore
                      //       .collection('users/${email}/username')
                      //       .where('username', isEqualTo: email)
                      //       .get();
                      //
                      //
                      // } catch (e) {
                      //   print(e);
                      //
                      //   if (newUser != null) {
                      //     Navigator.pushNamed(context, Conversations.id);
                      //   }
                      // }
                    } catch (e) {
                      print(e);
                    }
                  } else {
                    setState(() {
                      spinerShow = false;
                    });
                    print('Password length must be greater than 6 characters');
                  }
                  setState(() {
                    spinerShow = false;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
