
import 'package:flutter/cupertino.dart';

class RightBar extends StatelessWidget{
  final double barWidth;
  const RightBar ({Key? key ,  required this.barWidth}): super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: barWidth,
          height: 25,
          decoration: BoxDecoration(
              color: Color(0xff012A4A),
              borderRadius: BorderRadius.only(topRight: Radius.circular(20),bottomRight: Radius.circular(20))
          ),
        )
      ],
    );
  }
}