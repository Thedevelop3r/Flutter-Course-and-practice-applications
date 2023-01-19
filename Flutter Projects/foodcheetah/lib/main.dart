import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const WellcomeBody());
  }
}

class WellcomeBody extends StatefulWidget {
  const WellcomeBody();

  @override
  State<WellcomeBody> createState() => _WellcomeBodyState();
}

class _WellcomeBodyState extends State<WellcomeBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Container(
        height: 50.0,
        width: 50.0,
        child: CircleAvatar(
          backgroundImage: AssetImage('images/pidzaavatar.jpg'),
          radius: 20.0,
        ),
      ),
      width: double.infinity,
      height: 400.0,
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(180.0),
          bottomRight: Radius.circular(180.0),
        ),
      ),
    ));
  }
}
