
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/intro_page.dart';
import 'package:fyp/log_in_screen.dart';
import 'package:fyp/main_page.dart';
import 'package:fyp/services/auth.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'firebase_auth_services.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';

class SignUpScreen extends StatefulWidget{

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  // final FirebaseAuthService _auth= FirebaseAuthService();
   String firstname="",lastname="",password="", email="";
   TextEditingController firstnamecontroller = new TextEditingController();
   TextEditingController lastnamecontroller = new TextEditingController();
    TextEditingController emailcontroller = new TextEditingController();
    TextEditingController passwordcontroller = new TextEditingController();

    regristration() async{
      final loc = AppLocalizations.of(context)!;
      if (password!="" && email!="" && password!=""){
        try{
          UserCredential userCredential= await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.white,
              content: Center(child: Text(loc.registerSuccessfully,style: TextStyle(fontFamily: "FontMain",fontSize: 15,color: Color(0xff012A4A)),))));
             Navigator.push(context, MaterialPageRoute(builder:(context)=>IntroPage()));
        }on FirebaseAuthException catch(e){
          if (e.code=="weak-password"){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.white,
                content: Center(child: Text(loc.weekPassword,style: TextStyle(fontFamily: "FontMain",fontSize: 15,color: Color(0xff012A4A)),))));
          }else{
            if (e.code=="email-already-in-use"){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.white,
                  content: Center(child: Text(loc.accountExit,style: TextStyle(fontFamily: "FontMain",fontSize: 15,color: Color(0xff012A4A)),))));

            }
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
                margin: EdgeInsets.only(left: 2, top: 30),
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, left: 2),
                  child: Text(loc.createAccount, style: TextStyle(fontSize: 23,
                      fontFamily: "FontMain",
                      fontWeight: FontWeight.bold,
                      color: Color(0xff012A4A)),),
                ),
              ),

              SizedBox(
                height: 10,
              ),

              Container(
                margin: EdgeInsets.only(left: 5),
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(loc.account,
                    style: TextStyle(fontSize: 15,
                        fontFamily: "FontMain",
                        fontWeight: FontWeight.bold,
                        color: Colors.black),),
                ),
              ),

              SizedBox(
                height: 2,
              ),

              Container(
                margin: EdgeInsets.only(left: 10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(loc.advantage, style: TextStyle(
                      fontSize: 15,
                      fontFamily: "FontMain",
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
                ),
              ),

              SizedBox(
                height: 30,
              ),

              Container(
                margin: EdgeInsets.only(left: 5),
                width: 300,
                child: TextField(
                  controller: firstnamecontroller,
                  decoration: InputDecoration(
                      prefixIcon:Icon( Icons.person_2_outlined,size: 15,color: Color(0xff012A4A),),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(
                            color: Color(0xff012A4A),
                          )
                      ),
                      hintText: loc.firstName
                  ),
                ),
              ),

              SizedBox(
                height: 15,
              ),

              Container(
                margin: EdgeInsets.only(left: 5),
                width: 300,
                child: TextField(
                  controller: lastnamecontroller,
                  decoration: InputDecoration(
                      prefixIcon:Icon( Icons.person_2_outlined,size: 15,color: Color(0xff012A4A),),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(
                            color: Color(0xff012A4A),
                          )
                      ),
                      hintText: loc.lastName
                  ),
                ),
              ),

              SizedBox(
                height: 15,
              ),

              Container(
                margin: EdgeInsets.only(left: 5),
                width: 300,
                child: TextField(
                 controller: emailcontroller,
                  decoration: InputDecoration(
                      prefixIcon:Icon( Icons.email_outlined,size: 15,color: Color(0xff012A4A),),
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

              SizedBox(
                height: 15,
              ),

              Container(
                margin: EdgeInsets.only(left: 5),
                width: 300,
                child: TextField(
                  controller: passwordcontroller,
                  decoration: InputDecoration(
                      prefixIcon:Icon( Icons.password,size: 15,color: Color(0xff012A4A),),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(
                            color: Color(0xff012A4A),
                          )
                      ),
                      hintText: loc.enterPassword
                  ),
                ),
              ),

              SizedBox(
                height: 40,
              ),

              Container(
                margin: EdgeInsets.only(left: 10),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff012A4A),
                        shadowColor: Colors.blue,
                        minimumSize: Size(250, 50)),
                    onPressed:(){
                      if(firstnamecontroller.text!="" && lastnamecontroller.text!="" && emailcontroller.text!="" && passwordcontroller.text!=""){
                        setState(() {
                          firstname=firstnamecontroller.text;
                          lastname=lastnamecontroller.text;
                          email=emailcontroller.text;
                          password=passwordcontroller.text;
                        });
                      }
                      regristration();
                    },
                    child: Text(loc.signup, style: TextStyle(fontSize: 18,
                        fontFamily: "FontMain",
                        color: Colors.white),)),
              ),

              SizedBox(
                height: 20,
              ),

              Container(
                margin: EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider(
                      thickness: 0.7,
                      color: Color(0xff012A4A),
                    ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(
                        vertical: 0, horizontal: 10),
                      child: Text(loc.signupWith, style: TextStyle(fontSize: 10,
                          fontFamily: "FontMain",
                          color: Colors.black),),
                    ),
                    Expanded(child: Divider(
                      thickness: 0.7,
                      color: Color(0xff012A4A),
                    ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 40,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(icon: Icon(
                    FontAwesomeIcons.facebookF, color: Color(0xff012A4A),),
                    onPressed: () async{
                    await AuthMethods().signInWithFacebook();
                    },
                  ),
                  IconButton(icon: Icon(
                    FontAwesomeIcons.google, color: Color(0xff012A4A),),
                    onPressed: () {
                   AuthMethods().signInWithGoogle(context);
                    },
                  ),
                  IconButton(icon: Icon(
                    FontAwesomeIcons.apple, color: Color(0xff012A4A),),
                    onPressed: () {
                   // AuthMethods().signInWithApple();
                    },
                  ),

                ],
              ),
            ],
          ),
        )
    );

  }

}





