import 'package:flutter/material.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';
import 'dart:math';

class BoardProvider with ChangeNotifier {
  void _generateNewBoard() {
    _boardData = Board(SudokuGenerator(emptySquares: 27 + Random().nextInt(50 - 27)));
    _getSolution = false;
    notifyListeners();
  }

  void _getSolutions() {
    _getSolution = true;
    notifyListeners();
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

  BoardCell(this.digit, {this.isSolution = false});
}

class Board {
  SudokuGenerator generator;
  List<BoardCell>? board;
  Board(this.generator);

  List<BoardCell> _getNormalBoard() {
    board = SudokuUtilities.to1D(generator.newSudoku)
        .map((digit) => BoardCell(digit))
        .toList();
    return board!;
  }

  List<BoardCell> _getSolutionBoard() {
    List<BoardCell> solutions = SudokuUtilities.to1D(generator.newSudokuSolved)
        .map((digit) => BoardCell(digit, isSolution: true))
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
