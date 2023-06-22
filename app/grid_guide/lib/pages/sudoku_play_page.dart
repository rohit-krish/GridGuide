import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/get_corresponding_index_func.dart';
import '../utils/sudoku_play_page/alert_dialog_user_complets_puzzle.dart';
import '../utils/sudoku_play_page/alert_dialog_sudoku_reload_button.dart';
import '../widgets/sudoku_play_page/digit_input_button.dart';
import '../widgets/sudoku_play_page/sudoku_board_widget.dart';
import '../providers/board_provider.dart';

late BoardProvider BOARD_PROVIDER;

class SudokuPlay extends StatefulWidget {
  const SudokuPlay({super.key});
  @override
  State<SudokuPlay> createState() => _SudokuPlayState();
}

class _SudokuPlayState extends State<SudokuPlay> {
  int currentPressedCount = -1;
  BoardProvider? boardProvider;
  double? width;
  double? height;
  @override
  void initState() {
    super.initState();
  }

  BoardProvider? getTheBoardProvider() {
    return boardProvider;
  }

  int getCurrentPressedCount() {
    return currentPressedCount;
  }

  void updateCurrentPressedCount(int newVal) {
    currentPressedCount = newVal;
  }

  void updateBoard(String value) async {
    if (boardProvider!.isBoardCompletelySolvedbyUser) {
      boardProvider!.showSnackBar(context);
    } else {
      boardProvider!.updateBoard(
        value,
        getCorrespondingIndex(currentPressedCount),
      );
      if (boardProvider!.isBoardCompletelySolvedbyUser == true) {
        showAlertDialogWhenUserCompletesPuzzle(context, boardProvider!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    boardProvider = Provider.of<BoardProvider>(context, listen: false);
    BOARD_PROVIDER = boardProvider!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.all(width! * .05),
      height: double.maxFinite,
      width: double.maxFinite,
      alignment: Alignment.topCenter,
      child: Column(children: [
        const Spacer(),
        SudokuBoardWidget(getCurrentPressedCount, updateCurrentPressedCount),
        const Spacer(),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Consumer<BoardProvider>(builder: (ctx, boardProvider, child) {
            return IconButton(
              onPressed: () async {
                bool isAllValid = true;
                if (boardProvider.isBoardCompletelySolvedbyUser) {
                  boardProvider.showSnackBar(context);
                } else {
                  isAllValid = boardProvider.toggleSolutions;
                  if (boardProvider.getBoard
                          .map((e) => e.digit)
                          .toList()
                          .contains(0) &&
                      boardProvider.isNowShowingSolutions) {
                    boardProvider.dontShowSolutions();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "Can't Find solution!, Valid but wrong digit(s) present."),
                      duration: Duration(seconds: 2),
                    ));
                    return;
                  }
                  // log(res.toString());
                  if (!boardProvider.isNowShowingSolutions && !isAllValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Can't find solution!, Unvalid Digits Present",
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                }
              },
              icon: Icon(
                boardProvider.isNowShowingSolutions &&
                        (boardProvider.isBoardCompletelySolvedbyUser == false)
                    ? Icons.lightbulb
                    : Icons.lightbulb_outline_sharp,
              ),
            );
          }),
          SizedBox(width: width! * .07),
          IconButton(
            onPressed: () {
              showAlertDialogForRefreshingBoard(boardProvider!, context);
            },
            icon: const Icon(Icons.refresh),
          )
        ]),
        const Spacer(),
        Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            DigitInputButton('1', () => updateBoard('1')),
            DigitInputButton('2', () => updateBoard('2')),
            DigitInputButton('3', () => updateBoard('3')),
            DigitInputButton('4', () => updateBoard('4')),
            DigitInputButton('5', () => updateBoard('5')),
          ]),
          SizedBox(height: height! * .02),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            DigitInputButton('6', () => updateBoard('6')),
            DigitInputButton('7', () => updateBoard('7')),
            DigitInputButton('8', () => updateBoard('8')),
            DigitInputButton('9', () => updateBoard('9')),
            DigitInputButton('X', () => updateBoard('X')),
          ]),
        ]),
        const Spacer()
      ]),
    );
  }
}
