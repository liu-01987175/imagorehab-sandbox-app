import 'package:mongo_dart/mongo_dart.dart';

/*
  todo:
  1. 
 */

class MongoService {
  static late final Db _db;
  static late final DbCollection tasksCollection;

  /// Initializes & open the connection.
  static Future<void> init(String connectionString) async {
    _db = await Db.create(connectionString);
    await _db.open();
    tasksCollection = _db.collection('tasks');
  }

  /// Fetchss all the tasks in databse
  static Future<List<Map<String, dynamic>>> getAllTasks() =>
      tasksCollection.find().toList();

  /// Insert one new task
  static Future<void> addTask({
    required String name,
    required String description,
    required DateTime date,
  }) {
    return tasksCollection.insertOne({
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
    });
  }

  /// Closes the database when app closes
  static Future<void> close() async => _db.close();
}
