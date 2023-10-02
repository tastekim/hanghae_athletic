import 'package:flutter/material.dart';

class SizeConfig {
  BuildContext context;

  SizeConfig(this.context);

  double width(double number) {
    return number * (MediaQuery.of(context).size.width / 390);
  }
}
