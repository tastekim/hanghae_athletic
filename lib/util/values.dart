// grid dimensions
import 'package:flutter/material.dart';

int rowLength = 10;
int colLength = 15;

enum Direction {
  left,
  right,
  down,
}

enum Mino {
  L,
  J,
  I,
  O,
  S,
  Z,
  T,
}

const Map<Mino, Color> minoColors = {
  Mino.L: Colors.orangeAccent,
  Mino.J: Colors.lightBlue,
  Mino.I: Colors.pinkAccent,
  Mino.O: Colors.amber,
  Mino.S: Colors.green,
  Mino.Z: Colors.redAccent,
  Mino.T: Colors.purpleAccent,
};