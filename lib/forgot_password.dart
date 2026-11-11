
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fyp/log_in_screen.dart';
import 'package:fyp/top_bar.dart';
import 'package:fyp/utils.dart';

import 'bottom_bar.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';

class ForgotPassword extends StatefulWidget{
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  //@override

  final emailController=TextEditingController();
  final auth=FirebaseAuth.instance;

  void _toggleLanguage(BuildContext context) {
    final currentLang = Localizations.localeOf(context).languageCode;
    final newLang = currentLang == 'en' ? 'ur' : 'en';
    MyApp.setLocale(context, Locale(newLang));
  }


  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            Container(
              height: 200,
              width: 360,
              color: Color(0xff012A4A),
            ),
            Container(
              margin: EdgeInsets.only(top: 35),
              child: IconButton(icon: Icon(
                FontAwesomeIcons.arrowLeft, color:Colors.white,),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LogInScreen()
                      )
                  );
                },
              ),
            ),

            Positioned(
              top: 100,left: 30,right: 30,
              child: Container(
                height: 400,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                  border: Border.all(
                      width: 0.5,
                      color: Colors.black
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right:30),
                      child: TopBar( barHeight:40 ),
                    ),


                    SizedBox(
                        height: 30
                    ),

                    Padding(
                      padding: const EdgeInsets.all(11),
                      child: Text(loc.resetPassword,style: TextStyle(fontSize: 20,fontFamily: "FontMain",fontWeight: FontWeight.bold,color: Color(0xff012A4A)),),
                    ),

                    SizedBox(
                      height: 35,
                    ),

                    Container(
                      child: Column(
                        children: [
                          Text(loc.pleaseEnter,style: TextStyle(fontSize: 16,fontFamily: "FontMain",color: Color(0xff012A4A)),),
                          Text(loc.resetYourPassword,style: TextStyle(fontSize: 16,fontFamily: "FontMain",color: Color(0xff012A4A)),),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 35,
                    ),


                    Container(
                      margin: EdgeInsets.only(left: 20,right: 20),
                      width: 300,
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                            prefixIcon:Icon( Icons.alternate_email,size: 15,color: Color(0xff012A4A),),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: BorderSide(
                                  color: Color(0xff012A4A),
                                )
                            ),
                            hintText: loc.enterEmail
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left:55,right: 15,top: 550),
              child: ElevatedButton(
                  style:ElevatedButton.styleFrom(
                      backgroundColor:Color(0xff012A4A),shadowColor: Colors.blue,minimumSize: Size(250, 50)),
                  onPressed:()
                  {
                    auth.sendPasswordResetEmail(email:emailController.text.toString()).then((value){
                      Utils().toastMessage(loc.checkInbox);
                    }).onError((error,stackTrace){
                      Utils().toastMessage(error.toString());
                    });
                  },
                  child: Text(loc.sendEmail,style: TextStyle(fontSize: 18,fontFamily: "FontMain",color: Colors.white),)),
            ),
          ],
        ),
      ),
    );
  }
}

