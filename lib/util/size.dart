import 'package:flutter/material.dart';

class SizeConfig {
  BuildContext context;

  SizeConfig(this.context);

  double width(double number) {
    return number * (MediaQuery.of(context).size.width / 390);
  }
}

class FormFactor {
  static double desktop = 900;
  static double tablet = 600;
  static double handset = 414;
}