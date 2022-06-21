import 'package:sqflite_sqlcipher/sqlite_api.dart';

class CmdMgrLastRunRepository{
  static const String _table = 'cmd_mgr_last_run';

  final Database _database;

  CmdMgrLastRunRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> createTable() =>
      _database.execute('CREATE TABLE IF NOT EXISTS $_table('
          'command_id STRING PRIMARY KEY, '
          'last_run DATETIME);');

  Future<void> upsertLastRun(String id, DateTime lastRun, {Transaction? txn}) async{
    await (txn ?? _database).insert(
      _table,
      {
        "command_id" : id,
        "last_run" : lastRun,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future <DateTime?> getLastRun(String id, {Transaction? txn}) async{
    String? lastRun = (await (txn ?? _database).query(
        _table,
        where: 'command_id = ?',
        whereArgs: [id]
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