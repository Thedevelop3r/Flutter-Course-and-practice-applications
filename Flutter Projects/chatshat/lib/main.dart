import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatshat/screens/welcome_screen.dart';
import 'package:chatshat/screens/login_screen.dart';
import 'package:chatshat/screens/registration_screen.dart';
import 'package:chatshat/screens/chat_screen.dart';
import 'package:chatshat/screens/conversations_page.dart';
import 'package:chatshat/screens/messages_screen.dart';

// void main() => runApp(FlashChat());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChatShat());
}

class ChatShat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: WelcomeScreen.id, routes: {
      WelcomeScreen.id: (context) => WelcomeScreen(),
      LoginScreen.id: (context) => LoginScreen(),
      RegistrationScreen.id: (context) => RegistrationScreen(),
      ChatScreen.id: (context) => ChatScreen(),
      Conversations.id: (context) => Conversations(),
      MessagesScreen.id: (context) => MessagesScreen(),
    });
  }
}

// theme: ThemeData.dark().copyWith(
// textTheme: TextTheme(
// bodyText1: TextStyle(color: Colors.black54),
