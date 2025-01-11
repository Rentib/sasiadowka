import 'package:flutter/material.dart';

void main() {
  runApp(CommunityApp());
}

class CommunityApp extends StatefulWidget {
  const CommunityApp({super.key});

  @override
  State<CommunityApp> createState() => _CommunityAppState();
}

class _CommunityAppState extends State<CommunityApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Community App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community App')),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuestListScreen()),
              );
            },
            child: Text('Browse Local Quests'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddQuestScreen()),
              );
            },
            child: Text('Add Your Initiative'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NeighborsScreen()),
              );
            },
            child: Text('View Neighbors'),
          ),
        ],
      ),
    );
  }
}

class QuestListScreen extends StatelessWidget {
  final List<String> quests = [
    'Help with grocery shopping',
    'Looking for someone to walk my dog',
    'Organizing a local park cleanup',
  ];

  QuestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Local Quests')),
      body: ListView.builder(
        itemCount: quests.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(quests[index]),
            subtitle: Text('Tap to learn more'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Details for: ${quests[index]}')),
              );
            },
          );
        },
      ),
    );
  }
}

class AddQuestScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  AddQuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Initiative')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration:
                  InputDecoration(labelText: 'Describe your initiative'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final quest = _controller.text;
                if (quest.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added initiative: $quest')),
                  );
                  _controller.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a description')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class NeighborsScreen extends StatelessWidget {
  final List<String> neighbors = [
    'Alice - Loves gardening',
    'Bob - Tech enthusiast',
    'Charlie - Dog owner',
  ];

  NeighborsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Neighbors')),
      body: ListView.builder(
        itemCount: neighbors.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(neighbors[index]),
          );
        },
      ),
    );
  }
}
