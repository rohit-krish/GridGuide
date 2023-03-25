import 'package:flutter/material.dart';

showAlertDialogWhenNoToken(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: const Text("Don't have enough Tokens!"),
        content: SingleChildScrollView(
          child: ListBody(
            children: const [Text('Collect Tokens?')],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}
