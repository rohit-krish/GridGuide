import 'package:flutter/material.dart';
import 'package:grid_guid/utils/get_corresponding_element.dart';
import 'package:grid_guid/widgets/sudoku_play_page/sudoku_board_widget.dart';
import 'package:provider/provider.dart';

import '../providers/board_provider.dart';
import '../widgets/sudoku_play_page/input_button.dart';

class SudokuPlay extends StatefulWidget {
  const SudokuPlay({super.key});

  @override
  State<SudokuPlay> createState() => _SudokuPlayState();
}

class _SudokuPlayState extends State<SudokuPlay> {
  int currentPressedCount = -1;
  bool isSolutionsShown = false;

  int getCurrentPressedCount() {
    return currentPressedCount;
  }

  updateCurrentPressedCount(int newVal) {
    currentPressedCount = newVal;
  }

  updateBoard(String value, BoardProvider boardProvider) {
    if (!isSolutionsShown) {
      boardProvider.updateBoard(
        value,
        getCorrespondingIndex(currentPressedCount),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var boardProvider = Provider.of<BoardProvider>(context, listen: false);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.all(width * .05),
      padding: EdgeInsets.only(top: height * .06),
      height: double.maxFinite,
      width: double.maxFinite,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SudokuBoardWidget(
            getCurrentPressedCount,
            updateCurrentPressedCount,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  boardProvider.getSolutions;
                  isSolutionsShown = true;
                },
                icon: const Icon(Icons.auto_fix_high_outlined),
              ),
              SizedBox(width: width * .07),
              IconButton(
                onPressed: () {
                  isSolutionsShown = false;
                  boardProvider.generateNewBoard;
                },
                icon: const Icon(Icons.refresh),
              )
            ],
          ),
          const Spacer(),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InputButton('1', () => updateBoard('1', boardProvider)),
                  InputButton('2', () => updateBoard('2', boardProvider)),
                  InputButton('3', () => updateBoard('3', boardProvider)),
                  InputButton('4', () => updateBoard('4', boardProvider)),
                  InputButton('5', () => updateBoard('5', boardProvider)),
                ],
              ),
              SizedBox(height: height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InputButton('6', () => updateBoard('6', boardProvider)),
                  InputButton('7', () => updateBoard('7', boardProvider)),
                  InputButton('8', () => updateBoard('8', boardProvider)),
                  InputButton('9', () => updateBoard('9', boardProvider)),
                  InputButton('X', () => updateBoard('X', boardProvider)),
                ],
              ),
            ],
          ),
          const Spacer()
        ],
      ),
    );
  }
}
