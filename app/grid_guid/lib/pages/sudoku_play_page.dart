import 'package:flutter/material.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

import '../widgets/sudoku_play_page/input_button.dart';

class SudokuPlay extends StatelessWidget {
  SudokuPlay({super.key});

  @override
  Widget build(BuildContext context) {
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
          GridView.builder(
            itemCount: 9,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: width * .01,
              mainAxisSpacing: width * .01,
            ),
            physics: const ScrollPhysics(),
            itemBuilder: (ctx, idx) {
              return Container(
                color: (idx % 2 == 0)
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
                  itemBuilder: (ctx, idx) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey.shade200),
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(fontSize: width * .1),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.auto_fix_high_outlined),
              ),
              SizedBox(width: width * .07),
              IconButton(
                onPressed: () {
                  var sudokuGenerator = SudokuGenerator();
                  print(sudokuGenerator.newSudoku);
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
                children: const [
                  InputButton('1'),
                  InputButton('2'),
                  InputButton('3'),
                  InputButton('4'),
                  InputButton('5'),
                ],
              ),
              SizedBox(height: height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  InputButton('6'),
                  InputButton('7'),
                  InputButton('8'),
                  InputButton('9'),
                  InputButton('X'),
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