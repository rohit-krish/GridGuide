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
    _getSolution = true;
    notifyListeners();
  }

  void updateBoard(String value, int index) {
    if (index != -1) {
      _boardData.updateBoard(int.parse(value), index);
      notifyListeners();
    }
  }

  Board _boardData =
      Board(SudokuGenerator(emptySquares: 27 + Random().nextInt(50 - 27)));

  bool _getSolution = false;

  void get generateNewBoard => _generateNewBoard();
  void get getSolutions => _getSolutions();
  List<BoardCell> get getBoard => _boardData.getBoard(_getSolution);
}

class BoardCell {
  int digit;
  bool isSolution;
  bool isDigitValid;

  BoardCell(
    this.digit, {
    this.isSolution = false,
    this.isDigitValid = true,
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

  void updateBoard(int value, int index) {
    // NOTE: when updating the board check if the inputs are valid or not
    board[index] = BoardCell(value);
  }

  List<BoardCell> _getNormalBoard() {
    for (int i = 0; i < 81; i++) {
      board[i].isSolution = false;
    }
    return board;
  }

  List<BoardCell> _getSolutionBoard() {
    var solutions = SudokuUtilities.to1D(generator.newSudokuSolved);
    board = SudokuUtilities.to1D(generator.newSudoku)
        .map((digit) => BoardCell(digit))
        .toList();

    for (int i = 0; i < 81; i++) {
      // print('${board[i].digit} ${solutions[i]}');
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
