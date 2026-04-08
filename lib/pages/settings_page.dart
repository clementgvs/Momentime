import 'package:flutter/material.dart';
import 'package:momentime/backend/account_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListTile(
          title: Text("Disconnect"),
          onTap: () => AccountManager().signOut(),
        ),
      ],
    );
  }
}