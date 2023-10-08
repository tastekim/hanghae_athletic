import 'package:flutter/material.dart';
import 'package:hanghae_athletic/core/board.dart';
import 'package:hanghae_athletic/util/values.dart';

class NextPiece {
  // type of tetris piece
  Mino type;

  NextPiece({required this.type});

  // the piece is just a list of integers
  List<int> position = [];

  // color of tetris piece
  Color get color {
    return minoColors[type] ?? Colors.white;
  }

  // generate the integers
  void initializePiece() {
    switch (type) {
      case Mino.L:
        position = [
          1,
          5,
          9,
          10,
        ];
        break;
      case Mino.J:
        position = [
          2,
          6,
          10,
          9,
        ];
        break;
      case Mino.I:
        position = [
          4,
          5,
          6,
          7,
        ];
        break;
      case Mino.O:
        position = [
          5,
          6,
          9,
          10,
        ];
        break;
      case Mino.S:
        position = [
          6,
          7,
          9,
          10,
        ];
        break;
      case Mino.Z:
        position = [
          5,
          6,
          10,
          11,
        ];
        break;
      case Mino.T:
        position = [
          6,
          9,
          10,
          11,
        ];
      default:
    }
  }
}