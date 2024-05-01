import 'package:hive/hive.dart';
import 'package:Todo/main.dart';

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
