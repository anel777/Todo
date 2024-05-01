import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter()); // Registering the TodoAdapter
  runApp(MyApp());
}

class Todo {
  String title;
  bool isDone;

  Todo({
    required this.title,
    this.isDone = false,
  });
}

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0; // Unique identifier for this type

  @override
  Todo read(BinaryReader reader) {
    return Todo(
      title: reader.readString(),
      isDone: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.writeString(obj.title);
    writer.writeBool(obj.isDone);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      home: FutureBuilder(
        future:
            Hive.openBox<Todo>('todos'), // Opening the box with the type Todo
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return TodoListScreen();
            }
          } else {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Box<Todo> todoBox;

  @override
  void initState() {
    super.initState();
    todoBox = Hive.box<Todo>('todos');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf7fff7),
      appBar: AppBar(
        backgroundColor: Color(0xFF1a535c),
        centerTitle: true,
        title: Text(
          'Todo List',
          style: TextStyle(
              letterSpacing: 6, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: todoBox.listenable(),
        builder: (context, Box<Todo> todos, _) {
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              Todo todo = todos.getAt(index)!;
              Color _containerColor =
                  todo.isDone ? Color(0xFFff6b6b) : Color(0xFF4ecdc4);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      todo.isDone = !todo.isDone;
                      todos.putAt(index, todo);
                    });
                  },
                  onDoubleTap: () {
                    todos.deleteAt(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _containerColor,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Center(
                      child: Text(
                        todo.title.toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          decoration:
                              todo.isDone ? TextDecoration.lineThrough : null,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFffe66d),
        onPressed: () {
          _addTodoDialog(context);
        },
        child: Icon(
          Icons.add,
          size: 32,
        ),
      ),
    );
  }

  void _addTodoDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Color(0xFFf7fff7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Todo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a535c),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter todo title',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String title = controller.text.trim();
                    if (title.isNotEmpty) {
                      Todo newTodo = Todo(title: title);
                      todoBox.add(newTodo);
                      Navigator.pop(context);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xFF4ecdc4)),
                    padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                  ),
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFf7fff7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
