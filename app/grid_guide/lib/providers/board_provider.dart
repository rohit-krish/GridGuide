import 'package:flutter/material.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';
import 'dart:math';

import './board_provider_models.dart';

class BoardProvider with ChangeNotifier {
  void dontShowSolutions() {
    _getSolution = false;
    notifyListeners();
  }

  void _generateNewBoard() {
    _boardData = Board(
      SudokuGenerator(emptySquares: 27 + Random().nextInt(54 - 27)),
    );
    _getSolution = false;
    _detectedBoard = null;
    notifyListeners();
  }

  bool _toggleSolutions() {
    _boardData.resetIsDigitVal();
    try {
      SudokuUtilities.to2D(_boardData
          .getBoard(_getSolution, _detectedBoard)
          .map((e) => e.digit)
          .toList());
    } on InvalidSudokuConfigurationException {
      return false;
    }

    _getSolution = !_getSolution;
    notifyListeners();
    return true;
  }

  void updateBoard(String value, int index) {
    if (index != -1) {
      _boardData.updateBoard(value, index);
    }
    var board = _boardData.getBoard(_getSolution, _detectedBoard);
    isBoardCompletelySolvedbyUser = false;
    for (int i = 0; i < 81; i++) {
      if (board[i].isSolution || board[i].digit == 0) {
        isBoardCompletelySolvedbyUser = false;
        break;
      } else if (board[i].isDigitValid == false) {
        isBoardCompletelySolvedbyUser = false;
        break;
      } else {
        isBoardCompletelySolvedbyUser = true;
      }
    }
    notifyListeners();
  }

  void updateDetectedBoard(List<BoardCell>? board) {
    if (board != null) {
      if (isNowShowingSolutions) {
        _toggleSolutions();
      }
      _detectedBoard = board;
      notifyListeners();
    }
  }

  Board _boardData =
      Board(SudokuGenerator(emptySquares: 27 + Random().nextInt(50 - 27)));
  bool _getSolution = false;
  bool isBoardCompletelySolvedbyUser = false;
  List<BoardCell>? _detectedBoard;
  void get generateNewBoard => _generateNewBoard();
  bool get toggleSolutions => _toggleSolutions();
  bool get isNowShowingSolutions => _getSolution;
  List<BoardCell> get getBoard =>
      _boardData.getBoard(_getSolution, _detectedBoard);
  final _snackBar = const SnackBar(
    content: Text('Puzzle is already solved!'),
    duration: Duration(milliseconds: 500),
  );
  void showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
  }
}
