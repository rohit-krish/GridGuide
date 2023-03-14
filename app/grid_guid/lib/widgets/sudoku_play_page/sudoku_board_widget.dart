import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/board_provider.dart';
import '../../providers/board_provider_models.dart';
import '../../utils/get_corresponding_element_utils.dart';
import '../../theme/sudoku_board_widget_theme.dart';

class SudokuBoardWidget extends StatefulWidget {
  final Function getCurrentPressedCount;
  final Function(int) updateCurrentPressedCount;

  const SudokuBoardWidget(
    this.getCurrentPressedCount,
    this.updateCurrentPressedCount, {
    super.key,
  });

  @override
  State<SudokuBoardWidget> createState() => _SudokuBoardWidgetState();
}

class _SudokuBoardWidgetState extends State<SudokuBoardWidget> {
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;
    int boardCellCount = 0;

    return GridView.builder(
      itemCount: 9,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: width * .01,
        mainAxisSpacing: width * .01,
      ),
      physics: const ScrollPhysics(),
      itemBuilder: (ctx_, boxIdx) {
        return Container(
          color: getWhichBoardBoxColorToDisplay(boxIdx, isDarkMode),
          alignment: Alignment.center,
          child: GridView.builder(
            itemCount: 9,
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            physics: const ScrollPhysics(),
            itemBuilder: (ctx_, cellIdx_) {
              int count = boardCellCount++;
              // print('cell $count built');

              var boardProvider = Provider.of<BoardProvider>(context);
              var board = boardProvider.getBoard;

              BoardCell currentWidget = board[getCorrespondingIndex(count)];
              return InkWell(
                onTap: () {
                  // when we press to a cell which is not yet pressed
                  if (count != widget.getCurrentPressedCount()) {
                    setState(() {
                      widget.updateCurrentPressedCount(count);
                    });
                  }
                  // when we press a cell which is already presssed
                  else {
                    setState(() {
                      widget.updateCurrentPressedCount(-1);
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: getWhichCellBorderWidthToDisplay(
                        count,
                        widget.getCurrentPressedCount,
                        currentWidget.isDigitValid,
                      ),
                      color: getWhichCellBorderColorToDisplay(
                        currentWidget,
                        count,
                        widget.getCurrentPressedCount,
                        isDarkMode,
                      ),
                    ),
                    color: Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: LayoutBuilder(
                    builder: (ctx, constrains) {
                      return Text(
                        getWhichDigitToDisplay(currentWidget, count),
                        style: TextStyle(
                          color: getWhichTextColorToDisplay(
                            currentWidget,
                            isDarkMode,
                          ),
                          fontSize: constrains.maxWidth * .8,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
