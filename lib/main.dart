import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:momentime/account_manager.dart';
import 'package:momentime/pages/calendar_page.dart';
import 'package:momentime/pages/groups_page.dart';
import 'package:momentime/pages/login_page.dart';
import 'package:momentime/pages/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: StreamBuilder<User?>(
        stream: AccountManager().userStatus,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                /*
                title: [
                  Text("Calendar"),
                  Text("Groups"),
                  Text("Settings")
                ][currentIndex],
                */
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
            );
          }
          return LoginPage(); 
        },
      )
    );
  }
}

