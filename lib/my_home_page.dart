import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  void _insertTodo() {
    if (_todoController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      userCollection.add({
        'todo': _todoController.text,
        'description': _descriptionController.text,
      });
      _todoController.clear();
      _descriptionController.clear();
    }
  }

  void _showInsertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Todo"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _todoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Todo",
                ),
              ),
              SizedBox(height: 7),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Description",
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _insertTodo();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _updateTodo(String id, Map<String, String> updatedTodo) {
    userCollection.doc(id).update(updatedTodo);
  }

  void _showUpdateDialog(String id, String todo, String description) {
    final TextEditingController _updatedTodoController =
        TextEditingController(text: todo);
    final TextEditingController _updatedDescriptionController =
        TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Todo"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _updatedTodoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Todo",
                ),
              ),
              SizedBox(height: 7),
              TextField(
                controller: _updatedDescriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Description",
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateTodo(
                  id,
                  {
                    'todo': _updatedTodoController.text,
                    'description': _updatedDescriptionController.text
                  },
                );
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _deleteTodo(String id) {
    userCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo with Firebase'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(7),
        child: StreamBuilder(
          stream: userCollection.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text("No Data Found."),
              );
            }
            final documents = snapshot.data!.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                final data = document.data() as Map<String, dynamic>;

                final todo = data.containsKey('todo') ? data['todo'] : '';
                final description =
                    data.containsKey('description') ? data['description'] : '';

                return ListTile(
                  title: Text(todo),
                  subtitle: Text(description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTodo(document.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.red),
                        onPressed: () {
                          _showUpdateDialog(document.id, todo, description);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showInsertDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
