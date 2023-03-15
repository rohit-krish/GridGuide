import 'package:flutter/material.dart';

import '../../providers/board_provider.dart';

Future<void> showAlertDialogForRefreshingBoard(
  BoardProvider boardProvider,
  BuildContext context,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Load new Sudoku Board?'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('You can\'t reverse this action.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'No',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              'Yes',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              boardProvider.generateNewBoard;
              boardProvider.isBoardCompletelySolvedbyUser = false;
            },
          ),
        ],
      );
    },
  );
}
