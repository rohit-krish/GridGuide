import 'package:flutter/material.dart';

import '../../pages/token_page.dart';

showAlertDialogWhenNoToken(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: const Text("Don't have enough Tokens!"),
        content: SingleChildScrollView(
          child: ListBody(
            children: const [Text('Need atleast 3 Tokens!!\nCollect Tokens?')],
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
                    (_) => Navigator.of(context).pop(),
                  );
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}
