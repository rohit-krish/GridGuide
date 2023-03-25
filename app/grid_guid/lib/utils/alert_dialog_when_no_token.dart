import 'package:flutter/material.dart';

import '../pages/token_page.dart';

showAlertDialogWhenNoToken(
  BuildContext context,
  int tokenLimit,
  Function callHomeSetState,
) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: const Text("Don't have enough Tokens!"),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(
                "Need atleast $tokenLimit ${tokenLimit == 1 ? 'Token' : 'Tokens'}!!\nCollect Tokens?",
              )
            ],
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
              Navigator.of(context).pushNamed(TokenPage.routeName).then(
                (_) {
                  Navigator.of(context).pop();
                  callHomeSetState();
                },
              );
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}
