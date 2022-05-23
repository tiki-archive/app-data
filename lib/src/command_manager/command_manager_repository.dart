import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';

import 'model/command_manager_model.dart';

class CommandManagerRepository{
  static const String _table = 'command_manager_meta';
  final _log = Logger('CommandManagerRepository');

  final Database _database;

  CommandManagerRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> createTable() =>
      _database.execute('CREATE TABLE IF NOT EXISTS $_table('
          'command_type STRING PRIMARY KEY, '
          'last_run DATETIME);');

  Future<void> upsertLastRun(CommandManagerModel model, DateTime lastRun, {Transaction? txn}) async{
    String type = model.runtimeType.toString();
    await (txn ?? _database).insert(
      _table,
      {
        "command_type" : type,
        "last_run" : lastRun,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future <DateTime?> getLastRun(CommandManagerModel model, {Transaction? txn}) async{
    String type = model.runtimeType.toString();
    String? lastRun = (await (txn ?? _database).query(
        _table,
        where: 'command_type = ?',
        whereArgs: [type]
    )).first['last_run']?.toString();
    return lastRun !=null ? DateTime.parse(lastRun) : null;
  }

  Future<Map<String, DateTime>> getAllLastRun({Transaction? txn}) async{
    List<Map<String, Object?>> entries = (await (txn ?? _database).query(_table));
    Map<String, DateTime> lastRuns = {};
    entries.forEach((element) {
      lastRuns[element.keys.first] = DateTime.parse(element.values.first.toString());
    });
    return lastRuns;
  }
}