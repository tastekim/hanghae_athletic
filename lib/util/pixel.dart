import 'package:flutter/material.dart';
import 'package:hanghae_athletic/util/size.dart';

class Pixel extends StatelessWidget {
  var color;

  Pixel({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    SizeConfig size = SizeConfig(context);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          size.width(5),
        ),
      ),
      margin: EdgeInsets.all(1),
    );
  }
}

class NextPixel extends StatelessWidget {
  var color;

  NextPixel({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    SizeConfig size = SizeConfig(context);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          size.width(1),
        ),
      ),
      margin: EdgeInsets.all(1),
    );
  }
}
