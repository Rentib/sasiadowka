import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(CommunityApp());
}

class CommunityApp extends StatelessWidget {
  const CommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikacja Społecznościowa',
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
      appBar: AppBar(title: Text('Aplikacja Społecznościowa')),
      body: ListView(
        padding: EdgeInsets.all(24.0),
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuestListScreen()),
              );
            },
            child: Text('Przeglądaj zlecenia'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddQuestScreen()),
              );
            },
            child: Text('Dodaj inicjatywę'),
          ),
        ],
      ),
    );
  }
}

class QuestListScreen extends StatefulWidget {
  const QuestListScreen({super.key});

  @override
  QuestListScreenState createState() => QuestListScreenState();
}

class QuestListScreenState extends State<QuestListScreen> {
  List<Map<String, dynamic>> _quests = [];

  @override
  void initState() {
    super.initState();
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final questsString = prefs.getString('quests');
    if (questsString != null) {
      setState(() {
        _quests = List<Map<String, dynamic>>.from(json.decode(questsString));
      });
    }
  }

  Future<void> _saveQuests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quests', json.encode(_quests));
  }

  void _toggleQuestStatus(int index) {
    setState(() {
      _quests[index]['accepted'] = !_quests[index]['accepted'];
    });
    _saveQuests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista Zleceń')),
      body: _quests.isEmpty
          ? Center(child: Text('Brak zleceń.'))
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: _quests.length,
              itemBuilder: (context, index) {
                final quest = _quests[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      quest['description'],
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text(
                      quest['accepted'] ? 'Zaakceptowano' : 'Oczekuje',
                      style: TextStyle(
                        color: quest['accepted'] ? Colors.green : Colors.red,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        quest['accepted'] ? Icons.cancel : Icons.check_circle,
                        color: quest['accepted'] ? Colors.red : Colors.green,
                      ),
                      onPressed: () => _toggleQuestStatus(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AddQuestScreen extends StatefulWidget {
  const AddQuestScreen({super.key});

  @override
  AddQuestScreenState createState() => AddQuestScreenState();
}

class AddQuestScreenState extends State<AddQuestScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _addQuest(String description) async {
    final prefs = await SharedPreferences.getInstance();
    final questsString = prefs.getString('quests');
    final quests = questsString != null
        ? List<Map<String, dynamic>>.from(json.decode(questsString))
        : [];
    quests.add({'description': description, 'accepted': false});
    await prefs.setString('quests', json.encode(quests));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj Zlecenie')),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Opis zlecenia',
                labelStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final description = _controller.text;
                if (description.isNotEmpty) {
                  _addQuest(description);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Proszę wpisać opis')),
                  );
                }
              },
              child: Text('Dodaj'),
            ),
          ],
        ),
      ),
    );
  }
}
