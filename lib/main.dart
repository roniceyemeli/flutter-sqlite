import 'package:flutter/material.dart';
import 'sql_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final items = await SQLHelper.runDbTestSequence();
    setState(() {
      _journals = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLHelper Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _journals.isEmpty
          ? const Center(child: Text("Database is empty."))
          : ListView.builder(
        itemCount: _journals.length,
        itemBuilder: (context, index) {
          final item = _journals[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(item['title']),
              subtitle: Text('ID: ${item['id']} • ${item['description']}'),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,   // runs the entire DB test sequence again
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
