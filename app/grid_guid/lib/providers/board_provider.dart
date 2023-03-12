import 'package:flutter/material.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

List<int> _flatten(List<List<int>> board) {
  List<int> res = List.empty(growable: true);
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      res.add(board[i][j]);
    }
  }

  return res;
}

class BoardProvider with ChangeNotifier {
  void _generateNewBoard() {
    _boardData = Board(SudokuGenerator(emptySquares: 40));
    _getSolution = false;
    notifyListeners();
  }

  void _getSolutions() {
    _getSolution = true;
    notifyListeners();
  }

  Board _boardData = Board(SudokuGenerator(emptySquares: 40));
  bool _getSolution = false;

  void get generateNewBoard => _generateNewBoard();
  void get getSolutions => _getSolutions();

  List<BoardCell> get getBoard => _boardData.getBoard(_getSolution);
}

class BoardCell {
  bool isSolution = false;
  int digit;
  BoardCell(this.digit, this.isSolution);
}

class Board {
  SudokuGenerator generator;
  List<BoardCell>? board;
  Board(this.generator);

  List<BoardCell> _getNormalBoard() {
    board = _flatten(generator.newSudoku)
        .map((digit) => BoardCell(digit, false))
        .toList();
    return board!;
  }

  List<BoardCell> _getSolutionBoard() {
    List<BoardCell> solutions = _flatten(generator.newSudokuSolved)
        .map((digit) => BoardCell(digit, true))
        .toList();

    for (int i = 0; i < 81; i++) {
      if (board![i].digit == solutions[i].digit) {
        solutions[i].isSolution = false;
      }
    }
    return solutions;
  }

  List<BoardCell> getBoard(bool getSolution) {
    return getSolution ? _getSolutionBoard() : _getNormalBoard();
  } 
}
