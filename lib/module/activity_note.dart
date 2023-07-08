import 'package:flutter/material.dart';

class ActivityNote extends StatefulWidget {
  const ActivityNote({super.key});

  @override
  State<ActivityNote> createState() => _ActivityNoteState();
}

class _ActivityNoteState extends State<ActivityNote> {
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: SizedBox(height: double.infinity, child: Icon(Icons.star)),
            title: Text('TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST'),
            subtitle: Text('"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."'),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              
            ],
          ),
        ],
      ),
    );
  }
}
