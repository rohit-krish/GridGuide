import 'package:flutter/material.dart';
import 'package:grid_guid/utils/get_corresponding_element_utils.dart';
import 'package:grid_guid/widgets/sudoku_play_page/sudoku_board_widget.dart';
import 'package:provider/provider.dart';

import '../providers/board_provider.dart';
import '../widgets/sudoku_play_page/digit_input_button.dart';
import '../utils/sudoku_play_page/alert_dialog_sudoku_reload_button.dart';
import '../utils/sudoku_play_page/alert_dialog_user_complets_puzzle.dart';

class SudokuPlay extends StatefulWidget {
  const SudokuPlay({super.key});

  @override
  State<SudokuPlay> createState() => _SudokuPlayState();
}

class _SudokuPlayState extends State<SudokuPlay> {
  bool? _isBoardCompletelySolvedbyUser;
  int currentPressedCount = -1;

  int getCurrentPressedCount() {
    return currentPressedCount;
  }

  updateCurrentPressedCount(int newVal) {
    currentPressedCount = newVal;
  }

  updateBoard(String value, BoardProvider boardProvider) {
    _isBoardCompletelySolvedbyUser = boardProvider.updateBoard(
      value,
      getCorrespondingIndex(currentPressedCount),
    );

    if (_isBoardCompletelySolvedbyUser == true) {
      showAlertDialogWhenUserCompletesPuzzle(context, boardProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    var boardProvider = Provider.of<BoardProvider>(context, listen: false);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.all(width * .05),
      height: double.maxFinite,
      width: double.maxFinite,
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          const Spacer(),
          SudokuBoardWidget(getCurrentPressedCount, updateCurrentPressedCount),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Consumer<BoardProvider>(
                builder: (ctx, boardProvider, child) {
                  return IconButton(
                    onPressed: () {
                      if (_isBoardCompletelySolvedbyUser == true) {
                        //TODO: show a snack bar to tell that the board is already solved
                      } else {
                        boardProvider.getSolutions;
                      }
                    },
                    icon: Icon(
                      boardProvider.isNowShowingSolutions &&
                              (_isBoardCompletelySolvedbyUser == false)
                          ? Icons.lightbulb
                          : Icons.lightbulb_outline_sharp,
                    ),
                  );
                },
              ),
              SizedBox(width: width * .07),
              IconButton(
                onPressed: () {
                  showAlertDialogForRefreshingBoard(boardProvider, context);
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
                  DigitInputButton('1', () => updateBoard('1', boardProvider)),
                  DigitInputButton('2', () => updateBoard('2', boardProvider)),
                  DigitInputButton('3', () => updateBoard('3', boardProvider)),
                  DigitInputButton('4', () => updateBoard('4', boardProvider)),
                  DigitInputButton('5', () => updateBoard('5', boardProvider)),
                ],
              ),
              SizedBox(height: height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DigitInputButton('6', () => updateBoard('6', boardProvider)),
                  DigitInputButton('7', () => updateBoard('7', boardProvider)),
                  DigitInputButton('8', () => updateBoard('8', boardProvider)),
                  DigitInputButton('9', () => updateBoard('9', boardProvider)),
                  DigitInputButton('X', () => updateBoard('X', boardProvider)),
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
