import 'package:chatshat/screens/login_screen.dart';
import 'package:chatshat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatshat/components/roundedbutton.dart';
import 'package:chatshat/constants.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    animation = ColorTween(begin: Color(0xffE9EBFB), end: Colors.white)
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
      print(animation.value);
    });

    // controller.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     print("Animation Complete");
    //     controller.reverse(from: 1.0);
    //   } else if (status == AnimationStatus.dismissed) {
    //     controller.forward();
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      //         .withOpacity(
      // controller.value > 0.5 ? controller.value - 0.5 : controller.value)
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: heroAnimationHeight[0],
                  ),
                ),
                WellcomeScreenTextAnimation(),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
                title: "Log In",
                color: Colors.lightBlueAccent,
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                }),
            RoundedButton(
                title: "Register",
                color: Colors.blueAccent,
                onPressed: () {
                  Navigator.pushNamed(context, RegistrationScreen.id);
                })
          ],
        ),
      ),
    );
  }
}

Widget animateText() {
  return AnimatedTextKit(
    animatedTexts: [
      ScaleAnimatedText(
        'ChatShat',
        duration: Duration(milliseconds: 1900),
        textStyle: const TextStyle(
          fontFamily: 'Horizon',
          color: Colors.black54,
          fontSize: 35.0,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
    repeatForever: true,
    pause: const Duration(milliseconds: 100),
    displayFullTextOnTap: true,
    stopPauseOnTap: true,
  );
}

class WellcomeScreenTextAnimation extends StatefulWidget {
  const WellcomeScreenTextAnimation();

  @override
  State<WellcomeScreenTextAnimation> createState() =>
      _WellcomeScreenTextAnimationState();
}

class _WellcomeScreenTextAnimationState
    extends State<WellcomeScreenTextAnimation> {
  static const colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];
  static const colorizeTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 25.0,
    fontFamily: 'Horizon',
  );
  List<ColorizeAnimatedText> textListStart = [
    ColorizeAnimatedText(
      'Fast And Secure',
      textStyle: colorizeTextStyle.copyWith(fontSize: 23.0),
      colors: colorizeColors,
    ),
    ColorizeAnimatedText(
      'Encrypted',
      textStyle: colorizeTextStyle,
      colors: colorizeColors,
    ),
    ColorizeAnimatedText(
      'ChatShat',
      textStyle: colorizeTextStyle,
      colors: colorizeColors,
      speed: Duration(milliseconds: 400),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: AnimatedTextKit(
          pause: Duration(milliseconds: 300),
          animatedTexts: textListStart,
          isRepeatingAnimation: false,
          onTap: () {
            print("Tap Event");
          },
          onFinished: () {},
        ),
      ),
    );
  }
}
