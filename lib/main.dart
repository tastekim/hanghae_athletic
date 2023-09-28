import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:hanghae_athletic/tetris.dart';

void main() {
  Tetris game = Tetris();
  runApp(GameWidget(game: game));
}