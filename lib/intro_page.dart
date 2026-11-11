
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/log_in_screen.dart';
import 'package:fyp/main.dart';
import 'package:fyp/sign_up_screen.dart';

import 'l10n/app_localizations.dart';

class IntroPage extends StatelessWidget{

  void _toggleLanguage(BuildContext context) {
    final currentLang = Localizations.localeOf(context).languageCode;
    final newLang = currentLang == 'en' ? 'ur' : 'en';
    MyApp.setLocale(context, Locale(newLang));
  }


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;


    return Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: Column(
              children:[
                SizedBox(height: 20,),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  height: 350,
                  width: 455,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage("assets/images/Voice_Recognition.webp"),
                      //fit:BoxFit.cover,
                    ),
                  ),
                ),
                Text(loc.hello,style: TextStyle(fontSize: 25,fontFamily: "FontMain",color: Color(0xff012A4A),fontWeight: FontWeight.bold),),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.only(left:1,right: 1,top: 3),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text(loc.thisApplication,style: TextStyle(fontFamily:"FontMain",fontSize: 15,color: Colors.black ),),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left:2,right: 2),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text(loc.specificVoice,style: TextStyle(fontFamily:"FontMain",fontSize: 15,color: Colors.black ),),
                  ),
                ),
                Container(
                  margin:EdgeInsets.only(left: 4,right: 4) ,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text(loc.unknownPerson,style: TextStyle(fontFamily:"FontMain",fontSize: 15,color: Colors.black ),),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 200,
                  width: 500,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                          ElevatedButton(
                            style:ElevatedButton.styleFrom(
                                backgroundColor:Color(0xff012A4A),shadowColor: Colors.blue,minimumSize: Size(250, 50)),
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>LogInScreen()));

                            },
                            child: Text(loc.login,style: TextStyle(fontSize: 18,fontFamily: "FontMain",color: Colors.white),)
                          ),
                          SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(style:ElevatedButton.styleFrom(
                            backgroundColor:Color(0xff012A4A),shadowColor: Colors.blue,minimumSize: Size(250, 50)),
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));

                            }, child:Text(loc.signup,style: TextStyle(fontSize: 18,fontFamily: "FontMain",color: Colors.white),)
                        ),
                      ]
                  ),
                ),
              ]
          ),
        )
    );
  }
}

