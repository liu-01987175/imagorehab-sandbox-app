import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static late final Db _db;
  static late final DbCollection tasksCollection;

  /// Initialize & open the connection.
  /// Call this once at app startup
  static Future<void> init(String connectionString) async {
    _db = await Db.create(connectionString);
    await _db.open();
    tasksCollection = _db.collection('tasks');
  }

  /// Fetch all tasks
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

  /// Close the DB when the app shuts down
  static Future<void> close() async => _db.close();
}
