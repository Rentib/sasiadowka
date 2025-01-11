import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
      appBar: AppBar(
          title: Text('Aplikacja Społecznościowa',
              style: TextStyle(fontSize: 24))),
      body: ListView(
        padding: EdgeInsets.all(24.0),
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuestListScreen()),
              );
            },
            child: Text('Przeglądaj zlecenia', style: TextStyle(fontSize: 20)),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddQuestScreen()),
              );
            },
            child: Text('Dodaj inicjatywę', style: TextStyle(fontSize: 20)),
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
      try {
        final loadedQuests =
            List<Map<String, dynamic>>.from(json.decode(questsString));
        setState(() {
          // Filtrujemy tylko poprawne dane
          _quests = loadedQuests.where((quest) {
            return quest['description'] is String &&
                quest['author'] is String &&
                quest['location'] is String &&
                quest['expires'] is String &&
                quest['accepted'] is bool;
          }).toList();
        });
      } catch (e) {
        // Jeśli dane są uszkodzone, pomijamy je
        setState(() {
          _quests = [];
        });
      }
    }
  }

  Future<void> _saveQuests() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('quests', json.encode(_quests));
    } catch (e) {}
  }

  void _toggleQuestStatus(int index) {
    setState(() {
      _quests[index]['accepted'] = !_quests[index]['accepted'];
    });
    _saveQuests();
  }

  // Funkcja pomocnicza do formatowania daty
  String formatExpiryDate(String dateStr) {
    try {
      final date =
          DateTime.parse(dateStr); // Parsowanie daty z formatu ISO 8601
      return DateFormat('yyyy-MM-dd')
          .format(date); // Formatowanie do "YYYY-MM-DD"
    } catch (e) {
      return dateStr; // Jeśli wystąpi błąd, zwracamy oryginalny string
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Lista Zleceń', style: TextStyle(fontSize: 24))),
      body: _quests.isEmpty
          ? Center(child: Text('Brak zleceń.', style: TextStyle(fontSize: 20)))
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: _quests.length,
              itemBuilder: (context, index) {
                final quest = _quests[index];
                final expirationDate = DateTime.parse(quest['expires']);
                final isExpired = DateTime.now().isAfter(expirationDate);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      quest['description'],
                      style: TextStyle(fontSize: 22),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Autor: ${quest['author']}',
                            style: TextStyle(fontSize: 18)),
                        Text('Lokalizacja: ${quest['location']}',
                            style: TextStyle(fontSize: 18)),
                        Text(
                          'Wygasa: ${formatExpiryDate(quest['expires'])}',
                          style: TextStyle(
                            fontSize: 18,
                            color: isExpired ? Colors.red : Colors.black,
                          ),
                        ),
                        Text(
                          quest['accepted'] ? 'Zaakceptowano' : 'Oczekuje',
                          style: TextStyle(
                              fontSize: 18,
                              color: quest['accepted']
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      ],
                    ),
                    trailing: Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            quest['accepted']
                                ? Icons.cancel
                                : Icons.check_circle,
                            color:
                                quest['accepted'] ? Colors.red : Colors.green,
                          ),
                          onPressed: () => _toggleQuestStatus(index),
                        ),
                        // IconButton(
                        //   icon: Icon(Icons.delete, color: Colors.grey),
                        //   onPressed: () => _deleteQuest(index),
                        // ),
                      ],
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
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(Duration(days: 7));

  Future<void> _addQuest() async {
    final description = _descriptionController.text;
    final author = _authorController.text;
    final location = _locationController.text;

    if (description.isNotEmpty && author.isNotEmpty && location.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final questsString = prefs.getString('quests');
      final quests = questsString != null
          ? List<Map<String, dynamic>>.from(json.decode(questsString))
          : [];
      quests.add({
        'description': description,
        'author': author,
        'location': location,
        'expires': _selectedDate.toIso8601String(),
        'accepted': false,
      });
      await prefs.setString('quests', json.encode(quests));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wszystkie pola są wymagane!')),
      );
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Dodaj Zlecenie', style: TextStyle(fontSize: 24))),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                  labelText: 'Opis zlecenia',
                  labelStyle: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _authorController,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                  labelText: 'Autor', labelStyle: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _locationController,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                  labelText: 'Lokalizacja',
                  labelStyle: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickDate,
              child: Text('Wybierz datę wygaśnięcia',
                  style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 8),
            Text(
                'Wygasa: ${_selectedDate.toLocal().toIso8601String().split("T").first}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addQuest,
              child: Text('Dodaj', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
