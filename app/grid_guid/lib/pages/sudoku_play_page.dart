import 'package:flutter/material.dart';
import 'package:grid_guid/utils/alert_dialog_when_no_token.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/get_corresponding_index_func.dart';
import '../utils/sudoku_play_page/alert_dialog_user_complets_puzzle.dart';
import '../utils/sudoku_play_page/alert_dialog_sudoku_reload_button.dart';
import '../widgets/sudoku_play_page/digit_input_button.dart';
import '../widgets/sudoku_play_page/sudoku_board_widget.dart';
import '../providers/board_provider.dart';
import '../pages/home_page.dart' show callHomeSetState, homePrefs;

// ignore: non_constant_identifier_names
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
        var prefs = await SharedPreferences.getInstance();
        prefs.setInt('tokens', (prefs.getInt('tokens') ?? 1) + 1);

        callHomeSetState();
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
                    onPressed: () async {
                      if (boardProvider.isBoardCompletelySolvedbyUser) {
                        boardProvider.showSnackBar(context);
                      } else {
                        if (((homePrefs?.getInt('tokens') ?? 1) > 0) ||
                            boardProvider.isSolutionShowing) {
                          boardProvider.getSolutions;
                        } else {
                          showAlertDialogWhenNoToken(context, 1, callHomeSetState);
                        }

                        if (boardProvider.isNowShowingSolutions &&
                            !boardProvider.isBoardCompletelySolvedbyUser) {
                          homePrefs!.setInt(
                            'tokens',
                            (homePrefs?.getInt('tokens') ?? 1) - 1,
                          );

                          callHomeSetState();
                        }
                      }
                    },
                    icon: Icon(
                      boardProvider.isNowShowingSolutions &&
                              (boardProvider.isBoardCompletelySolvedbyUser ==
                                  false)
                          ? Icons.lightbulb
                          : Icons.lightbulb_outline_sharp,
                    ),
                  );
                },
              ),
              SizedBox(width: width! * .07),
              IconButton(
                onPressed: () {
                  showAlertDialogForRefreshingBoard(boardProvider!, context);
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
                  DigitInputButton('1', () => updateBoard('1')),
                  DigitInputButton('2', () => updateBoard('2')),
                  DigitInputButton('3', () => updateBoard('3')),
                  DigitInputButton('4', () => updateBoard('4')),
                  DigitInputButton('5', () => updateBoard('5')),
                ],
              ),
              SizedBox(height: height! * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DigitInputButton('6', () => updateBoard('6')),
                  DigitInputButton('7', () => updateBoard('7')),
                  DigitInputButton('8', () => updateBoard('8')),
                  DigitInputButton('9', () => updateBoard('9')),
                  DigitInputButton('X', () => updateBoard('X')),
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
