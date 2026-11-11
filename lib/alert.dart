import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Alert extends StatefulWidget {
  @override
  State<Alert> createState() => _AlertState();
}

class _AlertState extends State<Alert> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Color(0xff012A4A),
        child: Stack(
          children: [
            Positioned(
              top: 160,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                height: 650,
                width: 360,
                child: Column(
                  children: [],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 100, left: 15, right: 10),
              child: Positioned(
                child: Container(
                  height: 100,
                  width: 330,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(22),
                          bottomLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                          topLeft: Radius.circular(22)),
                      border: Border.all(
                        width: 0.5,
                        color: Color(0xff012A4A),
                      )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Alert System",
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: "FontMain",
                            color: Color(0xff012A4A)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
