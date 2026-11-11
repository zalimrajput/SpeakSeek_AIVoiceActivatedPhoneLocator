
import 'package:flutter/cupertino.dart';

class TopBar extends StatelessWidget{
  final double barHeight;

  const TopBar ({Key? key ,  required this.barHeight}): super(key: key);

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
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
          ),
        )
      ],
    );
  }
}