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
      drawer: Drawer(child: ListView(
    padding: EdgeInsets.zero,
    children: [
      const DrawerHeader(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Color.fromARGB(255, 53, 94, 59), Color.fromARGB(255, 196, 30, 58)], begin: Alignment.bottomLeft, end: Alignment.bottomRight),
        color: Colors.blue,
        ),
        child: Text('Rollmark Bitch!',style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),  
      ),
      ListTile(
        title: const Text('Item 1'),
        onTap: () {
          // Update the state of the app.
          // ...
        },
      ),
      ListTile(
        title: const Text('Item 2'),
        onTap: () {
          // Update the state of the app.
          // ...
        },
      ),
    ],
  )),
    );
  }
}
