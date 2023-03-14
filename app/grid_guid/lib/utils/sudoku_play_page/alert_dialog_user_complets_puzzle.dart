import 'package:flutter/material.dart';
import '../../providers/board_provider.dart';


Future<void> showAlertDialogWhenUserCompletesPuzzle(BuildContext context, BoardProvider boardProvider) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('You Solved it! (~^⌣^)~'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
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
