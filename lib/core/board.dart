import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hanghae_athletic/service/firestore.dart';
import 'package:hanghae_athletic/util/next_piece.dart';
import 'package:hanghae_athletic/util/piece.dart';
import 'package:hanghae_athletic/util/pixel.dart';
import 'package:hanghae_athletic/util/size.dart';
import 'package:hanghae_athletic/util/values.dart';
import 'package:hanghae_athletic/view/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// GAME BOARD
/// This is a 2x2 grid with null representing an empty space.
/// A non empty space will have the color to represent the landed pieces

// create game board
List<List<Mino?>> gameBoard = List.generate(
  colLength,
  (i) => List.generate(
    rowLength,
    (j) => null,
  ),
);

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // Timer
  Timer? _timer;

  // grid dimensions
  int rowLength = 10;
  int colLength = 15;

  // current tetris piece
  Piece currentPiece = Piece(type: Mino.L);
  NextPiece nextPiece = NextPiece(type: Mino.L);

  Mino? nextType;

  // current score
  int currentScore = 0;

  // game over state
  bool gameOver = false;

  // pan points
  double startDx = 0;
  double moveDx = 0;

  // game pause & resume state
  bool isPaused = false;
  bool isLocked = false;

  @override
  void initState() {
    super.initState();

    // start game when app starts
    startGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> setPoints() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var currRecord = prefs.getInt('points');
    if (currRecord != null && currRecord < currentScore) {
      prefs.setInt('points', currentScore);
      var uid = prefs.getString('uid');
      var nickname = prefs.getString('nickname');
      Record().updateRecord(uid!, nickname!, currentScore);
    }
  }

  // game loop
  void gameLoop(Duration frameRate) {
    _timer = Timer.periodic(
      frameRate,
      (timer) {
        if (isPaused) {
          return;
        } else {
          setState(() {
            // clear lines
            clearLines();

            // check landing
            checkLanding();

            // check if game is over
            if (gameOver) {
              timer.cancel();
              showGameOverDialog();
            }

            // move current piece down
            if (!isLocked) {
              currentPiece.movePiece(Direction.down);
            }
          });
        }
      },
    );
  }

  // game over message
  void showGameOverDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        SizeConfig size = SizeConfig(context);
        return AlertDialog(
          title: Center(
            child: Text(
              "끗",
              style: TextStyle(
                fontFamily: 'BM',
                fontSize: size.width(26),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          alignment: Alignment.center,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '내 점수: $currentScore',
                style: TextStyle(
                  fontFamily: 'BM',
                  fontSize: size.width(18),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () async {
                await setPoints();

                // reset game
                resetGame();

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ),
                    (route) => false);
              },
              child: Text(
                '나가기',
                style: TextStyle(
                  fontFamily: 'BM',
                  color: Colors.black,
                  fontSize: size.width(20),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await setPoints();
                // restart game
                restartGame();

                Navigator.pop(context);
              },
              child: Text(
                '다시하기',
                style: TextStyle(
                  fontFamily: 'BM',
                  color: Colors.black,
                  fontSize: size.width(20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // restart game
  void restartGame() {
    // clear the game board
    gameBoard = List.generate(
      colLength,
      (i) => List.generate(rowLength, (j) => null),
    );

    // new game
    gameOver = false;
    currentScore = 0;

    // create new piece
    createNewPiece();

    // start game again
    startGame();
  }

  // reset game
  void resetGame() {
    // clear the game board
    gameBoard = List.generate(
      colLength,
      (i) => List.generate(rowLength, (j) => null),
    );

    // new game
    gameOver = false;
    currentScore = 0;

    // create new piece
    createNewPiece();
  }

  // check for collision in a future position
  // return true -> there is a collision
  // return false -> there is no collision
  bool checkCollision(Direction direction) {
    // loop through each position of the current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      // calculate the row and column of the current position
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      // adjust the row and col based on the direction
      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      // check if the piece is out of bounds (either too low or too far to the left or right)
      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }

      // check if the current position is already occupied by another piece in the game board
      if (row >= 0 && col >= 0) {
        if (gameBoard[row][col] != null) {
          return true;
        }
      }
    }

    // if no collisions are detected, return false
    return false;
  }

  void checkLanding() {
    // if going down is occupied
    if (checkCollision(Direction.down)) {
      // mark position as occupied on the gameboard
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;

        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }

      // one landed, create the next piece
      createNewPiece();
    }
  }

  // move left
  void moveLeft() {
    // make sure the move is valid before moving there
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  // move right
  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  // move down fast
  void moveDownFast() {
    if (isLocked) return; // 잠겨있는 경우 아무것도 하지 않음
    isLocked = true; // 잠금 상태로 변경

    while (!checkCollision(Direction.down)) {
      currentPiece.movePiece(Direction.down);
    }

    isLocked = false; // 잠금 해제
  }

  // rotate piece
  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  // clear lines
  void clearLines() {
    // Loop through each row of the game board from bottom to top
    for (int row = colLength - 1; row >= 0; row--) {
      // Initialize a variable to track if the row is full
      bool rowIsFull = true;

      // Check if the row if full (all columns in the row are filled with pieces)
      for (int col = 0; col < rowLength; col++) {
        // if there's an empty column, set rowIsFull to false and break the loop
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }

      // if the row is full, clear the row and shift rows down
      if (rowIsFull) {
        // move all rows above the cleared row down by one position
        for (int r = row; r > 0; r--) {
          // copy the above row to the current row
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }

        // set the top row to empty
        gameBoard[0] = List.generate(rowLength, (index) => null);

        // Increase the score
        currentScore++;
      }
    }
  }

  // game over method
  bool isGameOver() {
    // check if any columns in the top row are filled
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }

    // if the top row is empty, the game is not over
    return false;
  }

  Mino initializeRandomType() {
    Random rand = Random();

    return Mino.values[rand.nextInt(Mino.values.length)];
  }

  void createNewPiece() {
    // // create a random object to generate random mino types
    // Random rand = Random();
    //
    // // create a new piece with random type
    // Mino randomType = Mino.values[rand.nextInt(Mino.values.length)];
    // currentPiece = Piece(type: randomType);
    // currentPiece.initializePiece();
    //
    // nextPiece = NextPiece(type: randomType);
    // nextPiece.initializePiece();
    if (nextType == null) {
      nextType = initializeRandomType();
      currentPiece = Piece(type: nextType!);
      currentPiece.initializePiece();
      nextType = initializeRandomType();
      nextPiece = NextPiece(type: nextType!);
      nextPiece.initializePiece();
    } else {
      currentPiece = Piece(type: nextType!);
      currentPiece.initializePiece();
      nextType = initializeRandomType();
      nextPiece = NextPiece(type: nextType!);
      nextPiece.initializePiece();
    }

    // Since our game over condition is if there is a piece at the top level,
    // you want to check if the game is over when you create a new piece
    // instead of checking every frame, because new pieces are allowed to go through the top level
    // but if there is already a piece in the top level then the new piece is created,
    // then game is over.
    if (isGameOver()) {
      gameOver = true;
    }
  }

  void startGame() {
    currentPiece.initializePiece();
    nextType = initializeRandomType();
    nextPiece = NextPiece(type: nextType!);
    nextPiece.initializePiece();

    // frame refresh rate
    Duration frameRate = const Duration(milliseconds: 400);
    gameLoop(frameRate);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig size = SizeConfig(context);
    double deviceWidth = MediaQuery.of(context).size.shortestSide;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // SizedBox(
              //   height: size.width(30),
              // ),

              /// Score
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: GridView.builder(
                        clipBehavior: Clip.hardEdge,
                          itemCount: 16,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                          ),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            // current piece
                            if (nextPiece.position.contains(index)) {
                              return NextPixel(
                                color: nextPiece.color,
                              );
                            } else {
                              return NextPixel(
                                color: Colors.grey[900],
                              );
                            }
                          }),
                    ),
                    Text(
                      currentScore.toString(),
                      style: TextStyle(
                        fontFamily: 'BM',
                        color: Colors.white,
                        fontSize: size.width(40),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isPaused = !isPaused;
                        });
                      },
                      child: Icon(
                        isPaused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: size.width(40),
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(
              //   height: size.width(40),
              // ),
              Expanded(
                child: SizedBox(
                  width: deviceWidth <= FormFactor.handset
                      ? deviceWidth
                      : size.width(300),
                  child: GestureDetector(
                    onVerticalDragEnd: (detail) {
                      if (detail.primaryVelocity! > 0) {
                        moveDownFast();
                      }
                    },
                    onPanUpdate: (detail) {
                      if (isPaused) {
                        return;
                      } else {
                        setState(() {
                          moveDx += detail.delta.dx;
                          if (moveDx >= 43) {
                            moveRight();
                            moveDx = 0;
                          } else if (moveDx <= -43) {
                            moveLeft();
                            moveDx = 0;
                          }
                        });
                      }
                    },
                    onTap: () {
                      if (isPaused) {
                        return;
                      } else {
                        rotatePiece();
                      }
                    },
                    child: GridView.builder(
                      itemCount: rowLength * colLength,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowLength,
                      ),
                      itemBuilder: (context, index) {
                        // get row and col of each index
                        int row = (index / rowLength).floor();
                        int col = index % rowLength;

                        // current piece
                        if (currentPiece.position.contains(index)) {
                          return Pixel(
                            color: currentPiece.color,
                          );
                        }

                        // landed pieces
                        else if (gameBoard[row][col] != null) {
                          final Mino? minoType = gameBoard[row][col];
                          return Pixel(
                            color: minoColors[minoType],
                          );
                        }

                        // blank pixel
                        else {
                          return Pixel(
                            color: Colors.grey[900],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
