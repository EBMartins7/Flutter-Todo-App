import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  TextEditingController todoTxtController = TextEditingController();

  List<String> todos = [];

  int? editIndex;

  @override
  void initState() {
    super.initState();
    loadTodos(); // Load todos when the app starts
  }

  // Load todos from shared preferences
  Future<void> loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTodos = prefs.getString('todos');
    if (savedTodos != null) {
      setState(() {
        todos = List<String>.from(jsonDecode(savedTodos));
      });
    }
  }

  // Save todos to shared preferences
  Future<void> saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('todos', jsonEncode(todos));
  }

  // Function to delete a todo item by text
  void deleteTodoAtIndex(int index) {
    setState(() {
      todos.removeAt(index);
    });
    saveTodos();
  }

  void editTodo(int index) {
    setState(() {
      todoTxtController.text = todos[index];
      editIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App', style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
        ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    return Todo(
                        text: todos[index],
                        onDelete: () => deleteTodoAtIndex(index),
                      onEdit: () => editTodo(index),
                    );
                  }
              )
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      controller: todoTxtController,
                      decoration: const InputDecoration(
                        labelText: 'Enter task',
                        labelStyle: TextStyle(
                            color: Colors.blue
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blue, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blue, width: 2.0),
                        ),
                      ),
                    )
                ),
                const SizedBox(width: 30),
                FilledButton(
                  onPressed: () {
                    if (todoTxtController.text.isEmpty) {
                      return;
                    }

                    setState(() {
                      if (editIndex == null) {
                        todos.add(todoTxtController.text);
                      } else {
                        todos[editIndex!] = todoTxtController.text;
                        editIndex = null;
                      }
                      saveTodos();
                      todoTxtController.clear();
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                        Colors.blue),
                  ),
                  child: Text(
                    editIndex == null ? 'Add' : 'Update'
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Todo extends StatelessWidget {

  final String text;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const Todo({
    super.key,
    required this.text,
    required this.onDelete,
    required this.onEdit
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(text,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              ),
              softWrap: true,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            color: Colors.blue,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
            color: Colors.blue,
          )
        ],
      ),
    );
  }
}



