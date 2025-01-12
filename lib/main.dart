import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(CommunityApp());
}

/// A custom "Sparkle" theme, just to add some playful color! 
final ThemeData sparkleTheme = ThemeData(
  primarySwatch: Colors.purple,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  textTheme: TextTheme(
    bodyMedium: TextStyle(fontSize: 18.0),
  ),
);

/// The root widget of the application.
/// We check if a user is already logged in. If yes, go to [HomeScreen].
/// Otherwise, go to [LoginScreen].
class CommunityApp extends StatefulWidget {
  const CommunityApp({Key? key}) : super(key: key);

  @override
  _CommunityAppState createState() => _CommunityAppState();
}

class _CommunityAppState extends State<CommunityApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoggedInStatus();
  }

  Future<void> _checkLoggedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('currentUser');
    setState(() {
      _isLoggedIn = currentUser != null && currentUser.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikacja Społecznościowa',
      theme: sparkleTheme,
      home: _isLoggedIn ? HomeScreen() : LoginScreen(),
    );
  }
}

/// The screen after logging in:
///  - Shows a welcome message
///  - Buttons to browse or add Quests
///  - A logout action
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _loggedInUser = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('currentUser');
    setState(() {
      _loggedInUser = currentUser ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    // After logout, go back to the LoginScreen.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false, 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aplikacja Społecznościowa',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout),
            tooltip: 'Wyloguj',
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(24.0),
        children: [
          Center(
            child: Text(
              'Witaj, $_loggedInUser!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            ),
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
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            ),
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

/// Lists all Quests and lets you:
///  - Toggle "accepted" status
///  - Delete (cancel) a Quest if you are the author
class QuestListScreen extends StatefulWidget {
  const QuestListScreen({Key? key}) : super(key: key);

  @override
  QuestListScreenState createState() => QuestListScreenState();
}

class QuestListScreenState extends State<QuestListScreen> {
  List<Map<String, dynamic>> _quests = [];
  String _currentUser = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadQuests();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUser = prefs.getString('currentUser') ?? '';
    });
  }

  Future<void> _loadQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final questsString = prefs.getString('quests');
    if (questsString != null) {
      try {
        final loadedQuests =
            List<Map<String, dynamic>>.from(json.decode(questsString));
        setState(() {
          _quests = loadedQuests.where((quest) {
            return quest['description'] is String &&
                quest['author'] is String &&
                quest['location'] is String &&
                quest['expires'] is String &&
                quest['accepted'] is bool;
          }).toList();
        });
      } catch (e) {
        // If data is corrupted, ignore
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
    } catch (e) {
      // Handle error if needed
    }
  }

  void _toggleQuestStatus(int index) {
    setState(() {
      _quests[index]['accepted'] = !_quests[index]['accepted'];
    });
    _saveQuests();
  }

  void _deleteQuest(int index) async {
    setState(() {
      _quests.removeAt(index);
    });
    await _saveQuests();
  }

  String formatExpiryDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr); 
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return dateStr; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista Zleceń',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: _quests.isEmpty
          ? Center(
              child: Text(
                'Brak zleceń.',
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: _quests.length,
              itemBuilder: (context, index) {
                final quest = _quests[index];
                final expirationDate = DateTime.parse(quest['expires']);
                final isExpired = DateTime.now().isAfter(expirationDate);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  elevation: 3.0,
                  child: ListTile(
                    /// Show the delete button on the left if the current user is the author
                    leading: quest['author'] == _currentUser
                        ? IconButton(
                            icon: Icon(Icons.delete, color: Colors.grey),
                            onPressed: () => _deleteQuest(index),
                            tooltip: 'Anuluj zlecenie',
                          )
                        : null,

                    /// Main content
                    title: Text(
                      quest['description'],
                      style: TextStyle(fontSize: 22),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Autor: ${quest['author']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Lokalizacja: ${quest['location']}',
                            style: TextStyle(fontSize: 18),
                          ),
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
                              color:
                                  quest['accepted'] ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Toggle quest status button on the right
                    trailing: IconButton(
                      icon: Icon(
                        quest['accepted'] ? Icons.cancel : Icons.check_circle,
                        color: quest['accepted'] ? Colors.red : Colors.green,
                      ),
                      onPressed: () => _toggleQuestStatus(index),
                      tooltip: quest['accepted']
                          ? 'Odrzuć zaakceptowanie'
                          : 'Zaakceptuj',
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// Screen for adding new Quests.  
///  - Automatically sets 'author' to current logged-in user
///  - Defaults location to user's last-used location if available
class AddQuestScreen extends StatefulWidget {
  const AddQuestScreen({Key? key}) : super(key: key);

  @override
  AddQuestScreenState createState() => AddQuestScreenState();
}

class AddQuestScreenState extends State<AddQuestScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(Duration(days: 7));
  String _currentUser = '';

  @override
  void initState() {
    super.initState();
    _initUserAndLocation();
  }

  /// 1. Load current user
  /// 2. Fetch that user's last Quest
  /// 3. Pre-fill location if found
  Future<void> _initUserAndLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('currentUser') ?? '';
    setState(() {
      _currentUser = currentUser;
    });

    if (_currentUser.isNotEmpty) {
      await _prefillLocationIfPossible();
    }
  }

  Future<void> _prefillLocationIfPossible() async {
    final prefs = await SharedPreferences.getInstance();
    final questsString = prefs.getString('quests');

    if (questsString != null) {
      final List<Map<String, dynamic>> quests = List<Map<String, dynamic>>.from(
        json.decode(questsString),
      );

      // Filter by current user
      final userQuests = quests.where((quest) {
        return quest['author'] == _currentUser;
      }).toList();

      // If user has created at least one quest, take the last one in the list
      if (userQuests.isNotEmpty) {
        final lastQuest = userQuests.last;
        _locationController.text = lastQuest['location'] ?? '';
      }
    }
  }

  Future<void> _addQuest() async {
    final description = _descriptionController.text.trim();
    final location = _locationController.text.trim();

    if (description.isNotEmpty && _currentUser.isNotEmpty && location.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final questsString = prefs.getString('quests');
      final quests = questsString != null
          ? List<Map<String, dynamic>>.from(json.decode(questsString))
          : [];

      quests.add({
        'description': description,
        'author': _currentUser,
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
      appBar: AppBar(
        title: Text(
          'Dodaj Zlecenie',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Opis zlecenia
            TextField(
              controller: _descriptionController,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Opis zlecenia',
                labelStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 16),

            // Lokalizacja (auto-filled with last used, if any)
            TextField(
              controller: _locationController,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Lokalizacja',
                labelStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 16),

            // Button to pick expiry date
            ElevatedButton(
              onPressed: _pickDate,
              child: Text(
                'Wybierz datę wygaśnięcia',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 8),

            // Display the chosen date
            Text(
              'Wygasa: ${_selectedDate.toLocal().toIso8601String().split("T").first}',
              style: TextStyle(fontSize: 18),
            ),
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

/// Screen that handles both login and registration.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoginMode = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _toggleFormMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString('users');
    if (usersString != null) {
      final List usersList = json.decode(usersString);
      final user = usersList.firstWhere(
        (u) => u['username'] == username && u['password'] == password,
        orElse: () => null,
      );

      if (user != null) {
        await prefs.setString('currentUser', username);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Niepoprawny login lub hasło!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Brak zarejestrowanych użytkowników.')),
      );
    }
  }

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wprowadź nazwę użytkownika i hasło.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString('users');
    List usersList = usersString != null ? json.decode(usersString) : [];

    // Check if username already exists
    final existingUser = usersList.firstWhere(
      (u) => u['username'] == username,
      orElse: () => null,
    );

    if (existingUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nazwa użytkownika jest już zajęta.')),
      );
      return;
    }

    // Register the new user
    usersList.add({
      'username': username,
      'password': password,
    });

    await prefs.setString('users', json.encode(usersList));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Konto zostało utworzone. Możesz się zalogować.')),
    );

    // Switch to login mode automatically
    setState(() {
      _isLoginMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLoginMode ? 'Zaloguj się ' : 'Zarejestruj się ';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(24.0),
        children: [
          SizedBox(height: 16),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Nazwa użytkownika',
              labelStyle: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Hasło',
              labelStyle: TextStyle(fontSize: 18),
            ),
            obscureText: true,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoginMode ? _login : _register,
            child: Text(title, style: TextStyle(fontSize: 18)),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: _toggleFormMode,
            child: Text(
              _isLoginMode
                  ? 'Nie masz konta? Zarejestruj się'
                  : 'Masz już konto? Zaloguj się',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
