import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'l10n/app_localizations.dart';
import 'main.dart';

class Security extends StatefulWidget{
  @override
  State<Security> createState() => _SecurityState();
}

void _toggleLanguage(BuildContext context) {
  final currentLang = Localizations.localeOf(context).languageCode;
  final newLang = currentLang == 'en' ? 'ur' : 'en';
  MyApp.setLocale(context, Locale(newLang));
}


class _SecurityState extends State<Security> {



  @override
  Widget build(BuildContext context) {

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar:AppBar(
        title: Center(
          child: Text(loc.security,style: TextStyle(fontSize: 20,
              fontFamily: "FontMain",
              color: Color(0xff012A4A)),),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 6,right: 6,left: 6),
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(loc.privacy,style: TextStyle(fontSize: 15,
                fontFamily: "FontMain",
                color: Color(0xff012A4A)),),

            Text(loc.thankYou,style: TextStyle(fontSize: 15,
                fontFamily: "FontMain",
                color: Color(0xff012A4A)),),
          ],
        ),
      ),
    );
  }
}