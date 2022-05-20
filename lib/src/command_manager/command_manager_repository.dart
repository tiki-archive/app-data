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
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'last_run DATETIME);');

  Future<void> save(CommandManagerModel model, {Transaction? txn}) async{
    Map<String, Object?> oldModel = await get();
    Map<String, Object?> newModel = model.toMap();
    if(oldModel["last_run"] != null){
      newModel["id"] = oldModel["id"];
    }
    await (txn ?? _database).insert(
      _table,
        model.toMap()
    );
  }

  Future <Map<String, Object?>> get({Transaction? txn}) async{
    return (await (txn ?? _database).query(_table))[0];
  }
}