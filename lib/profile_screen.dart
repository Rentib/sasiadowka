import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _questsCreated = 0;
  int _questsAccepted = 0;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final questsString = prefs.getString('quests');
    if (questsString != null) {
      final List<Map<String, dynamic>> quests = List<Map<String, dynamic>>.from(
        json.decode(questsString),
      );

      setState(() {
        _questsCreated = quests.where((quest) => quest['author'] == widget.username).length;
        _questsAccepted = quests.where((quest) => quest['acceptedBy'] == widget.username).length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil użytkownika'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nazwa użytkownika: ${widget.username}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Liczba aktywnych zleceń: $_questsCreated',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Liczba zaakceptowanych zleceń: $_questsAccepted',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}