import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grid_guid/pages/camera_page.dart';
import 'package:grid_guid/providers/board_provider.dart';
import 'package:grid_guid/theme/theme.dart';
import 'package:grid_guid/pages/home_page.dart';
import 'package:provider/provider.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  return runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Grid Guid",
      debugShowCheckedModeBanner: false,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      // initialRoute: '/',
      home: ChangeNotifierProvider<BoardProvider>(
        child: const HomePage(),
        create: (_) => BoardProvider(),
      ),
      routes: {
        // '/': (_) => const HomePage(),
        CameraPage.routeName: (_) => const CameraPage()
      },
    );
  }
}
