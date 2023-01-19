import 'package:chatshat/components/roundedbutton.dart';
import 'package:chatshat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:chatshat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:chatshat/screens/conversations_page.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email = 'bilal@email.com', password = '123456';
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
              Flexible(
                child: SizedBox(
                  height: 48.0,
                ),
              ),
              Visibility(
                visible: warningVisible,
                child: Center(
                  child: Text('Username or Password Incorrect',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
              TextField(
                //properties
                textAlign: TextAlign.center,
                style: KtextFieldTextStyle,
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter You Email'),
                //function
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
                style: KtextFieldTextStyle,
                obscureText: true,
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter Your Password'),
                //function
                onChanged: (value) {
                  password = value;
                },
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Arslan',
                color: Colors.purpleAccent,
                onPressed: () {
                  email = 'arslan@email.com';
                  password = '123456';
                },
              ),
              RoundedButton(
                title: 'Bilal',
                color: Colors.green,
                onPressed: () {
                  email = 'bilal@email.com';
                  password = '123456';
                },
              ),
              RoundedButton(
                title: "Log In",
                color: Colors.lightBlueAccent,
                onPressed: () async {
                  setState(() {
                    spinerShow = true;
                  });

                  if (password != null && password.length >= 6) {
                    setState(() {
                      passwarningVisible = false;
                    });
                    try {
                      final signUserIn = await _auth.signInWithEmailAndPassword(
                          email: email, password: password);

                      if (signUserIn != null) {
                        print('Login Successful');
                        print(signUserIn.additionalUserInfo);

                        Navigator.pushNamed(context, Conversations.id);
                      } else {
                        setState(() {
                          spinerShow = false;
                          warningVisible = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      warningVisible = true;
                    }
                  } else {
                    setState(() {
                      passwarningVisible = true;
                      spinerShow = false;
                    });
                    print('Password length must be greater than 6 characters');
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
