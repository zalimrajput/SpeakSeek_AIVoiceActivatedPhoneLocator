import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/forgot_password.dart';
import 'package:fyp/main_page.dart';

import 'l10n/app_localizations.dart';
import 'main.dart';

class LogInScreen extends StatefulWidget {



  @override
  State<LogInScreen> createState() => _LogInScreenState();
}



class _LogInScreenState extends State<LogInScreen> {
  String password = "", email = "";
  TextEditingController emailcontroller =
      new TextEditingController();
  TextEditingController passwordcontroller =
      new TextEditingController();

  userlogin() async {
    final loc = AppLocalizations.of(context)!;
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainPage()));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user not found") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.white,
            content: Center(
                child: Text(
                 loc.noUser,
                 style: TextStyle(
                   fontFamily: "FontMain",
                   fontSize: 15,
                  color: Color(0xff012A4A)
                 ),
                )
             )
            )
        );
      } else {
        if (e.code == "wrong password") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.white,
              content: Center(
                  child: Text(
                loc.wrongEmail,
                style: TextStyle(
                    fontFamily: "FontMain",
                    fontSize: 15,
                    color: Color(0xff012A4A)),
                )
              )
             )
          );
        }
      }
    }
  }


  void _toggleLanguage(BuildContext context) {
    final currentLang = Localizations.localeOf(context).languageCode;
    final newLang = currentLang == 'en' ? 'ur' : 'en';
    MyApp.setLocale(context, Locale(newLang));
  }

  @override
  Widget build(BuildContext context) {

   final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 5, top: 30),
              child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 5),
                child: Text(
                  loc.loginHere,
                  style: TextStyle(
                      fontSize: 23,
                      fontFamily: "FontMain",
                      fontWeight: FontWeight.bold,
                      color: Color(0xff012A4A)),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 3),
              child: Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Text(
                  loc.welcomeBack,
                  style: TextStyle(
                      fontSize: 15,
                      fontFamily: "FontMain",
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Container(
              margin: EdgeInsets.only(left: 5),
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(loc.missed,
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: "FontMain",
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              margin: EdgeInsets.only(left: 5),
              width: 300,
              child: TextField(
                controller: emailcontroller,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      size: 15,
                      color: Color(0xff012A4A),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: BorderSide(
                          color: Color(0xff012A4A),
                        )),
                    hintText: loc.enterEmail),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.only(left: 5),
              width: 300,
              child: TextField(
                controller: passwordcontroller,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.password,
                      size: 15,
                      color: Color(0xff012A4A),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: BorderSide(
                          color: Color(0xff012A4A),
                        )),
                    hintText: loc.enterPassword),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.only(right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPassword()));
                      },
                      child: Text(
                        loc.forgotPassword,
                        style: TextStyle(
                            fontFamily: "FontMain",
                            fontSize: 15,
                            color: Color(0xff012A4A)
                        ),
                      )
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
            ),
            Container(
              margin: EdgeInsets.only(left: 5),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff012A4A),
                      shadowColor: Colors.blue,
                      minimumSize: Size(250, 50)),
                  onPressed: () {
                    if (emailcontroller.text != "" &&
                        passwordcontroller.text != "") {
                      setState(() {
                        email = emailcontroller.text;
                        password = passwordcontroller.text;
                      });
                    }
                    userlogin();
                  },
                  child: Text(
                    loc.login,
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: "FontMain",
                        color: Colors.white),
                  )),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
