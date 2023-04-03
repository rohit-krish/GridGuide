import 'package:flutter/material.dart';
import 'package:grid_guide/pages/info_page.dart';
import 'package:grid_guide/pages/token_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/camera_page.dart';
import '../pages/sudoku_play_page.dart';
import '../widgets/home_page/token_widget.dart';

late Function callHomeSetState;
SharedPreferences? homePrefs;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<SharedPreferences> futurePrefs;
  @override
  void initState() {
    futurePrefs = SharedPreferences.getInstance();
    callHomeSetState = () {
      setState(() {});
    };
    super.initState();
  }

  int _selectedIndex = 1;
  double? width;
  final List<Widget> _widgetOptions = <Widget>[
    const CameraPage(),
    const SudokuPlay(),
    const InfoPage()
  ];
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context).pushNamed(CameraPage.routeName);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return FutureBuilder<SharedPreferences>(
      future: futurePrefs,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          homePrefs = snapshot.data;
          return Scaffold(
            appBar: AppBar(title: const Text('Grid Guide'), actions: [
              TokenWidget(
                width: width!,
                tokensLeft: homePrefs!.getInt('tokens') ?? 1,
                onTapFunc: () {
                  Navigator.of(context).pushNamed(TokenPage.routeName).then(
                    (_) {
                      setState(() {});
                    },
                  );
                },
              )
            ]),
            body: IndexedStack(index: _selectedIndex, children: [
              const SizedBox.shrink(),
              _widgetOptions[1],
              _widgetOptions[2]
            ]),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.photo_camera_outlined),
                  label: 'Camera',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.border_all_outlined),
                  label: 'Play',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.info_outline),
                  label: 'Info',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
