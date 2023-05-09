import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:journal_sql/data/sql_helper.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _journals = [];


  @override
  void initState() {
    super.initState();
    _refreshJournals();
    if (kDebugMode) {
      print("... Number of items: ${_journals.length}");
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _addItem() async {
    await SQLHelper.createItem(_titleController.text, _descriptionController.text);
    return _refreshJournals();
  }
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _titleController.text, _descriptionController.text);
    return _refreshJournals();
  }
  Future<void> _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully Deleted a journal')));
    _refreshJournals();
  }

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
    });
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          // This will prevent the soft keyboard from covering the text-fields
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Enter your Description'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                if (id == null) {
                  await _addItem();
                }
                if (id != null) {
                  await _updateItem(id);
                }
                // Clear the text fields when done
                _descriptionController.clear();
                _titleController.clear();
                // Close the bottom sheet
                Navigator.of(context).pop();
              },
                  child: Text(id == null ? 'Create' : 'Update'),
              )
            ],
          ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
          centerTitle: true,
      ),
      body: ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) =>
              Card(
                color: Colors.blue.shade300,
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Text(_journals[index]['title']),
                  subtitle: Text(_journals[index]['description']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () => _showForm(_journals[index]['id']),
                              icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () => _deleteItem(_journals[index]['id']),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                  ),
                ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
