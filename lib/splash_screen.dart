import 'dart:async';
import 'package:flutter/src/material/icons.dart';
import 'package:flutter/material.dart';
import 'package:fyp/intro_page.dart';
import 'package:fyp/log_in_screen.dart';
import 'package:fyp/wrapper.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 10), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => IntroPage()
              //IntroPage()
              ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Image.asset(
          "assets/images/splasshscreen.gif",
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
