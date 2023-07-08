import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back to Rollmark!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: const Column(
        children: [
          ListTile(
            title: Text('Your Organization:'),
          ),
          Card(
            child: ListTile(
              title: Text('Welcome Back!'),
              subtitle: Text('You are logged in!'),
            ),
          ),
        ],
      ),
    );
  }
}
