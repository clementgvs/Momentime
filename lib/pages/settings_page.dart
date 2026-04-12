import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:momentime/pages/login_page.dart';

import '../backend/account_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionTitle("COMPTE"),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text("Changer le pseudo"),
            subtitle: const Text("Modifier votre nom d'affichage"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              TextEditingController _nameController = TextEditingController();

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Nouveau pseudo"),
                  content: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "Entrez votre pseudo...",
                    ),
                    maxLength: 20,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annuler"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_nameController.text.trim().isEmpty) return;

                        try {
                          await AccountManager().updateUsername(_nameController.text.trim());
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Pseudo mis à jour !")),
                          );
                          setState(() {});
                        } catch (e) {
                          // Affiche l'erreur si le pseudo est déjà pris
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: const Text("Enregistrer"),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Mot de passe"),
            subtitle: const Text("Réinitialiser votre sécurité"),
            onTap: () async {
              final email = FirebaseAuth.instance.currentUser?.email;
              if (email != null) {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email de réinitialisation envoyé !")),
                );
              }
            },
          ),

          const Divider(),
          _buildSectionTitle("SÉCURITÉ"),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text("Déconnexion"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Supprimer mon compte", style: TextStyle(color: Colors.red)),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le compte ?"),
        content: const Text("Cette action est irréversible. Toutes vos données seront effacées."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await AccountManager().deleteAccount();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur : $e")),
                );
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}