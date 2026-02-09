import 'package:flutter/material.dart';
import 'package:momentime/pages/calendar_page.dart';
import 'package:momentime/pages/groups_page.dart';
import 'package:momentime/pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0;

  void setCurrentIndex(int index){
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Momentime',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: [
            Text("Calendar"),
            Text("Groups"),
            Text("Settings")
          ][currentIndex],
        ),
        body: [
          CalendarPage(),
          GroupsPage(),
          SettingsPage()
        ][currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setCurrentIndex(index),
          iconSize: 32,
          elevation: 10,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: ''
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_2),
              label: ''
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: ''
              )
          ]
          ),
      ),
    );
  }
}

