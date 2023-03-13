import 'package:flutter/material.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';
import 'dart:math';

class BoardProvider with ChangeNotifier {
  void _generateNewBoard() {
    _boardData =
        Board(SudokuGenerator(emptySquares: 27 + Random().nextInt(50 - 27)));
    _getSolution = false;
    notifyListeners();
  }

  void _getSolutions() {
    // putting each cell's isDigitValid to null
    _boardData.resetIsDigitVal();

    // changing _getSolution value
    _getSolution = true;
    notifyListeners();
  }

  bool updateBoard(String value, int index) {
    if (index != -1) {
      _boardData.updateBoard(value, index);
    }

    //*: check if the board completly solved by the user
    var board = _boardData.getBoard(_getSolution);
    bool isBoardCompletelySolvedbyUser = false;

    for (int i = 0; i < 81; i++) {
      if (board[i].isSolution || board[i].digit == 0) {
        isBoardCompletelySolvedbyUser = false;
        break;
      } else {
        isBoardCompletelySolvedbyUser = true;
      }
    }

    notifyListeners();

    return isBoardCompletelySolvedbyUser;
  }

  Board _boardData = Board(SudokuGenerator(emptySquares: 27 + Random().nextInt(50 - 27)));

  bool _getSolution = false;

  void get generateNewBoard => _generateNewBoard();
  void get getSolutions => _getSolutions();
  List<BoardCell> get getBoard => _boardData.getBoard(_getSolution);
}

class BoardCell {
  int digit;
  bool isSolution;
  bool isMarked;
  bool? isDigitValid;

  BoardCell(
    this.digit, {
    this.isSolution = false,
    this.isMarked = false,
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

  void resetIsDigitVal() {
    for (int i = 0; i < 81; i++) {
      board[i].isDigitValid = null;
    }
  }

  void updateBoard(String value, int index) {
    // create a temp board copy
    var tmpBoard = [...board.map((item) => item.digit)];
    late bool isValid;

    // check if the boardCell value is given by default or not; if not default then continue else return
    if (board[index].digit == 0 || board[index].isMarked) {
      // putting the value to the tmpBoard
      if (value == 'X') {
        tmpBoard[index] = 0;
      } else {
        tmpBoard[index] = int.parse(value);
      }

      // checking if the tmpBoard configuration is correct or not
      try {
        SudokuUtilities.isValidConfiguration(SudokuUtilities.to2D(tmpBoard));
        isValid = true;
      } on InvalidSudokuConfigurationException {
        isValid = false;
      }

      // if the tmpBoard config is correct then it is valid so update the original board
      if (isValid) {
        board[index].isDigitValid = true;
      } else {
        board[index].isDigitValid = false;
      }

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

  List<BoardCell> _getNormalBoard() {
    for (int i = 0; i < 81; i++) {
      board[i].isSolution = false;
    }
    return board;
  }

  List<BoardCell> _getSolutionBoard() {
    var solutions = SudokuUtilities.to1D(generator.newSudokuSolved);

    for (int i = 0; i < 81; i++) {
      if (board[i].digit != solutions[i]) {
        board[i].digit = solutions[i];
        board[i].isSolution = true;
      }
    }
    return board;
  }

  List<BoardCell> getBoard(bool getSolution) {
    return getSolution ? _getSolutionBoard() : _getNormalBoard();
  }
}
