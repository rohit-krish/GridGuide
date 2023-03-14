import 'package:flutter/material.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';
import 'dart:math';

import './board_provider_models.dart';

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
    _getSolution = !_getSolution;
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

  Board _boardData =
      Board(SudokuGenerator(emptySquares: 27 + Random().nextInt(50 - 27)));

  bool _getSolution = false;

  void get generateNewBoard => _generateNewBoard();
  void get getSolutions => _getSolutions();
  bool get isNowShowingSolutions => _getSolution;
  List<BoardCell> get getBoard => _boardData.getBoard(_getSolution);
}

