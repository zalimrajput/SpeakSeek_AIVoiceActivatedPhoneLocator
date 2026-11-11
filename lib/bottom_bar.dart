
import 'package:flutter/cupertino.dart';

class BottomBar extends StatelessWidget{
  final double barHeight;

  const  BottomBar ({Key? key ,  required this.barHeight}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: barHeight,
          width: 25,
          decoration: BoxDecoration(
              color: Color(0xff012A4A),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
          ),
        )
      ],
    );
  }
}