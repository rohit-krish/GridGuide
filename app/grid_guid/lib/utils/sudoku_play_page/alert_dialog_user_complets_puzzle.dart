import 'package:flutter/material.dart';
import '../../providers/board_provider.dart';

Future<void> showAlertDialogWhenUserCompletesPuzzle(
    BuildContext context, BoardProvider boardProvider) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('You Solved it!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text(
                "Earned 1+ token\n",
                style: TextStyle(fontSize: 20),
              ),
              Text('Load new Puzzle?')
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop();
              boardProvider.generateNewBoard;
            },
          ),
        ],
      );
    },
  );
}
