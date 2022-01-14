import 'package:flutter/material.dart';
import 'package:choices/choose.dart';

class NavigationWidget extends StatefulWidget {
  const NavigationWidget({Key? key}) : super(key: key);

  @override
  _NavigationWidgetState createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, color: Colors.grey);
  static const List<Widget> _widgetOptions = <Widget>[
    ChoosePage(),
    Text(
      '未实现',
      style: optionStyle,
    ),
    Text(
      '未实现',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond),
            label: '随机',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: '现在',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
