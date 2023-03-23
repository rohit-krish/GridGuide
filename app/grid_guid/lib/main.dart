import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grid_guid/pages/sudoku_play_page.dart';
import 'package:provider/provider.dart';

import './pages/camera_page.dart';
import './providers/board_provider.dart';
import './providers/camera_provider.dart';
import './theme/theme.dart';
import './pages/home_page.dart';
import './providers/progress_indicator_provider.dart';

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
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: ChangeNotifierProvider<BoardProvider>(
        child: const HomePage(),
        create: (_) => BoardProvider(),
      ),
      routes: {
        CameraPage.routeName: (_) => MultiProvider(
              providers: [
                ChangeNotifierProvider<CameraProvider>(
                  create: (_) => CameraProvider(),
                ),
                ChangeNotifierProvider<ProgressIndicatorProvider>(
                  create: (_) => ProgressIndicatorProvider(),
                ),
                ChangeNotifierProvider<BoardProvider>(
                  create: (_) => BoardProvider(),
                )
              ],
              child: CameraPage(),
            ),
      },
    );
  }
}
