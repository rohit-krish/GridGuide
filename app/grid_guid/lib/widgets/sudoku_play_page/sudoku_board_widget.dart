import 'package:flutter/material.dart';
import 'package:grid_guid/providers/board_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/get_corresponding_element.dart';

class SudokuBoardWidget extends StatelessWidget {
  const SudokuBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int count = 0;

    var board = Provider.of<BoardProvider>(context).getBoard;

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
      itemBuilder: (ctx, boxIdx) {
        return Container(
          color: (boxIdx % 2 == 0)
              ? Colors.grey.shade100
              : Colors.blueGrey.shade50,
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
            itemBuilder: (ctx, cellIdx) {
              var currentWidget = board[count];
              int digit = getCorrespondingElement(
                board.map((cell) => cell.digit).toList(),
                count,
              );
              count++;
              return InkWell(
                onTap: () {
                  print(currentWidget.digit);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey.shade200),
                  ),
                  alignment: Alignment.center,
                  child: LayoutBuilder(
                    builder: (ctx, constrains) {
                      return Text(
                        digit == 0 ? '' : '$digit',
                        style: TextStyle(
                          color: currentWidget.isSolution
                              ? Colors.lightGreen
                              : Colors.black,
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
