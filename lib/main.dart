import 'package:flutter/material.dart';

void main() {
  runApp(CommunityApp());
}

class CommunityApp extends StatelessWidget {
  const CommunityApp({super.key});

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
      appBar: AppBar(
        title: Text(
          'Community App',
          style: TextStyle(fontSize: 24), // Większy rozmiar czcionki w tytule
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(24.0), // Większe marginesy
        children: [
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20), // Większe przyciski
              textStyle: TextStyle(fontSize: 18), // Większy tekst
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuestListScreen()),
              );
            },
            child: Text('Browse Local Quests'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20),
              textStyle: TextStyle(fontSize: 18),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddQuestScreen()),
              );
            },
            child: Text('Add Your Initiative'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20),
              textStyle: TextStyle(fontSize: 18),
            ),
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
      appBar: AppBar(
        title: Text(
          'Local Quests',
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0), // Dodajemy marginesy dla listy
        itemCount: quests.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10), // Większe odstępy
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0), // Większe wnętrze kafelka
              title: Text(
                quests[index],
                style: TextStyle(fontSize: 20), // Większy tekst w kafelku
              ),
              subtitle: Text(
                'Tap to learn more',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Details for: ${quests[index]}')),
                );
              },
            ),
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
      appBar: AppBar(
        title: Text(
          'Add Initiative',
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0), // Większe marginesy dla formularza
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(fontSize: 18), // Większy tekst w polu tekstowym
              decoration: InputDecoration(
                labelText: 'Describe your initiative',
                labelStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20),
                textStyle: TextStyle(fontSize: 18),
              ),
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
      appBar: AppBar(
        title: Text(
          'Neighbors',
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: neighbors.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                neighbors[index],
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        },
      ),
    );
  }
}
