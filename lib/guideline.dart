

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'l10n/app_localizations.dart';
import 'main.dart';

class Guideline extends StatefulWidget{
  @override
  State<Guideline> createState() => _GuidelineState();
}

void _toggleLanguage(BuildContext context) {
  final currentLang = Localizations.localeOf(context).languageCode;
  final newLang = currentLang == 'en' ? 'ur' : 'en';
  MyApp.setLocale(context, Locale(newLang));
}


class _GuidelineState extends State<Guideline> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar:AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Center(
          child: Text(loc.guideLine,style: TextStyle(fontSize: 20,
              fontFamily: "FontMain",
              color: Color(0xff012A4A)),),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(loc.gettingStarted,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",fontWeight: FontWeight.bold,
                  color: Color(0xff012A4A)),
              ),

              Text(loc.download,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",
                  color: Color(0xff012A4A)),
              ),

              SizedBox(height: 4,),

              Text(loc.wakePhrase,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",fontWeight: FontWeight.bold,
                  color: Color(0xff012A4A)),
              ),

              Text(loc.custom,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",
                  color: Color(0xff012A4A)),
              ),

              SizedBox(height: 4,),

              Text(loc.theApp,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",fontWeight: FontWeight.bold,
                  color: Color(0xff012A4A)),
              ),

              Text(loc.losePhone,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",
                  color: Color(0xff012A4A)),
              ),

              SizedBox(height: 4,),

              Text(loc.training,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",fontWeight: FontWeight.bold,
                  color: Color(0xff012A4A)),
              ),

              Text(loc.normalVoice,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",
                  color: Color(0xff012A4A)),
              ),

              SizedBox(height: 4,),

              Text(loc.safety,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",fontWeight: FontWeight.bold,
                  color: Color(0xff012A4A)),
              ),

              Text(loc.stored,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",
                  color: Color(0xff012A4A)),
              ),

              SizedBox(height: 4,),

              Text(loc.battery,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",fontWeight: FontWeight.bold,
                  color: Color(0xff012A4A)),
              ),

              Text(loc.smallAmount,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",
                  color: Color(0xff012A4A)),
              ),

              SizedBox(height: 4,),

              Text(loc.troubleshooting,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",fontWeight: FontWeight.bold,
                  color: Color(0xff012A4A)),
              ),

              Text(loc.responding,style: TextStyle(fontSize: 15,
                  fontFamily: "FontMain",
                  color: Color(0xff012A4A)),
              ),

              SizedBox(height: 50,),

            ],
          ),
        ),
      ),
    );
  }
}

