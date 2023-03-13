import 'package:flutter/material.dart';
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

  int getCurrentPressedCount() {
    return currentPressedCount;
  }

  updateCurrentPressedCount(int newVal) {
    currentPressedCount = newVal;
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
          SudokuBoardWidget(getCurrentPressedCount, updateCurrentPressedCount),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => boardProvider.getSolutions,
                icon: const Icon(Icons.auto_fix_high_outlined),
              ),
              SizedBox(width: width * .07),
              IconButton(
                onPressed: () {
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
                  InputButton('1', () {}),
                  InputButton('2', () {}),
                  InputButton('3', () {}),
                  InputButton('4', () {}),
                  InputButton('5', () {}),
                ],
              ),
              SizedBox(height: height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InputButton('6', () {}),
                  InputButton('7', () {}),
                  InputButton('8', () {}),
                  InputButton('9', () {}),
                  InputButton('X', () {
                    print(currentPressedCount);
                  }),
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
