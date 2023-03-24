import 'package:flutter/material.dart';

import '../pages/camera_page.dart';
import '../pages/sudoku_play_page.dart';
import '../widgets/home_page/token_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  double? width;
  final List<Widget> _widgetOptions = <Widget>[
    const CameraPage(),
    const SudokuPlay(),
    const Center(child: Text('Info'))
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid Guid'),
        actions: [
          TokenWidget(
            width: width!,
            tokensLeft: 100,
            onTapFunc: () {},
          )
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const SizedBox.shrink(),
          _widgetOptions[1],
          _widgetOptions[2],
        ],
      ),
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
  }
}
