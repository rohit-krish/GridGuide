import 'dart:developer';

import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

class BoardCell {
  int digit;
  bool isSolution;
  bool isMarked;
  bool? isDigitValid;
  bool isDetection;

  BoardCell(
    this.digit, {
    this.isSolution = false,
    this.isMarked = false,
    this.isDetection = false,
    this.isDigitValid,
  });
}

class Board {
  SudokuGenerator generator;
  late List<BoardCell> board;

  Board(this.generator) {
    board = SudokuUtilities.to1D(generator.newSudoku)
        .map((digit) => BoardCell(digit))
        .toList();
  }

  // void resetIsDigitVal() {
  //   for (int i = 0; i < 81; i++) {
  //     board[i].isDigitValid = null;
  //   }
  // }

  void updateBoard(String value, int index) {
    // create a temp board copy
    var tmpBoard = [...board.map((item) => item.digit)];
    bool isDigitValid = true;

    // check if the boardCell value is given by default or not; if not default then continue else return
    if (board[index].digit == 0 || board[index].isMarked || board[index].isDetection) {
      // putting the value to the tmpBoard
      if (value == 'X') {
        tmpBoard[index] = 0;
      } else {
        tmpBoard[index] = int.parse(value);
      }

      // checking if the tmpBoard configuration is correct or not
      try {
        SudokuUtilities.isValidConfiguration(SudokuUtilities.to2D(tmpBoard));
      } on InvalidSudokuConfigurationException {
        isDigitValid = false;
      }

      // if the tmpBoard config is correct then it is valid so update the original board
      board[index].isDigitValid = isDigitValid;

      // even if it is valid or not we have to show the digit
      if (value == 'X') {
        board[index].digit = 0;
        board[index].isSolution = false;
        board[index].isDigitValid = true;
      } else {
        board[index].digit = int.parse(value);
      }

      board[index].isMarked = true;
    }
  }

  List<BoardCell> _getDefaultBoard() {
    for (int i = 0; i < 81; i++) {
      if (board[i].isSolution == true) {
        board[i].digit = 0;
      }

      board[i].isSolution = false;
    }
    return board;
  }

  List<BoardCell> _getSolutionBoard() {
    var solutions = SudokuUtilities.to1D(
      SudokuSolver.solve(
        SudokuUtilities.to2D(board.map((item) => item.digit).toList()),
      ),
    );

    var hasProblem = false;

    for (int i = 0; i < 81; i++) {
      // TODO: if the bord is not completely solved by the user and in all the loops if the condition written below didn't met then the detected cells has some problems; and show a snackbar to user that to edit the detection to clear the clashes
      if (board[i].digit != solutions[i]) {
        board[i].digit = solutions[i];
        board[i].isSolution = true;
        board[i].isMarked = false;
      } else {
        if (hasProblem == false) hasProblem = true;
      }
    }

    // log("hasProblem: $hasProblem");
    return board;
  }

  List<BoardCell> getBoard(bool getSolution, List<BoardCell>? detectedBoard) {
    if (detectedBoard != null) {
      board = detectedBoard;
    }
    return getSolution ? _getSolutionBoard() : _getDefaultBoard();
  }
}
