import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .05),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How To Use?',
                    style: TextStyle(fontSize: width * .07),
                  ),
                  Text(
                    '1. Take a picture of the Sudoku Board.\n2. Press the tick (✓) Button.\n3. Then the screen will change automatically, then you can play with the detected board however you want.',
                    style: TextStyle(fontSize: width * .05),
                  ),
                ],
              ),
              SizedBox(height: height * .05),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remember!',
                    style: TextStyle(fontSize: width * .07),
                  ),
                  Text(
                    "1. Scratches and Black spaces in the cell is considered Zero.\n2. Can Detect Handwritten Digits aswell.\n3. Can't Guarentee what will detect if two digits are present in one cell.\n4. Won't detect unvalid digits in the cells.\n5. More clearer the picture more accurate the detection.\n6. Since Zero is not a valid digit in sudoku game, so if any cell contians Zero the detection will be unpredictable\n7. Don't support Sudoku Board on Computer Screens.",
                    style: TextStyle(fontSize: width * .05),
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
