

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/intro_page.dart';
import 'package:fyp/log_in_screen.dart';
import 'package:fyp/main_page.dart';

class Wrapper extends StatefulWidget{
  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder:(context,snapshot){
            if (snapshot.hasData){
              return MainPage();
            }else{
              return IntroPage();
            }
          },
      ),
    );

  }
}

