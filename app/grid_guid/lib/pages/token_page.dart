import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:grid_guid/providers/token_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenPage extends StatelessWidget {
  static const routeName = '/token-page';
  const TokenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final prefs =
        ModalRoute.of(context)!.settings.arguments as SharedPreferences;

    tokenProvider.init(prefs);

    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tokens'),
      ),
      body: Column(
        children: [
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: FittedBox(
              child: Consumer<TokenProvider>(builder: (ctx, value, child) {
                log('Text rebuilds');
                return Text(
                  'Remaining Tokens: ${value.tokensAvailable}',
                  style: TextStyle(fontSize: width * .09),
                );
              }),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              tokenProvider.btnClicked();
            },
            icon: Icon(
              Icons.token_outlined,
              size: width * .08,
            ),
            label: Text(
              'Collect 3+ Tokens',
              style: TextStyle(fontSize: width * .08),
            ),
          ),
          const Spacer(),
          Consumer<TokenProvider>(builder: (ctc, value, child) {
            if (value.isBtnClicked && !value.isFailedToLoad) {
              return const CircularProgressIndicator();
            } else {
              return const SizedBox.shrink();
            }
          }),
          const Spacer(),
          Consumer<TokenProvider>(builder: (_, value, child) {
            if (value.isFailedToLoad) {
              return FittedBox(
                child: Text(
                  'Failed to load Ad, Connect To Internet...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * .05,
                    color: Colors.red,
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          const Spacer(),
          Image.asset('assets/images/treasure.png')
        ],
      ),
    );
  }
}