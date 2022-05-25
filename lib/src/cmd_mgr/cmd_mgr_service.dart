import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';

import 'cmd_mgr_command.dart';
import 'cmd_mgr_model_queue_status.dart';
import 'cmd_mgr_repository.dart';
import 'cmd_mgr_model.dart';
import 'cmd_mgr_command_status.dart';

class CmdMgrService{

  Logger _log = Logger('CmdMgrService');

  final CmdMgrRepository _repository;
  CmdMgrModel _model = CmdMgrModel();

  CmdMgrService(Database database) :
      _repository = CmdMgrRepository(database){
  }

  Future<void> init() async {
    _model.lastRun = await _repository.getAllLastRun();
  }

  bool addCommand(CmdMgrCommand command){
    if(_model.commandQueue.where((element) => element.id == command.id).isNotEmpty) {
      _log.warning('Command with id ${command.id} already enqueued.');
      return false;
    }
    _model.commandQueue.add(command);
    _log.finest('Command with id ${command.id} enqueued.');
    _log.finest('Queue has ${_model.commandQueue.length} commands.' );
    _runQueue();
    return true;
  }

  void pauseCommand(CmdMgrCommand command){
    command.status = CmdMgrCommandStatus.paused;
    _model.activeCommands--;
    _log.finest('Queue has ${_model.activeCommands} commands.' );
    _runCommands(ignore: [command]);
  }

  void stopCommand(CmdMgrCommand command) {
    command.status = CmdMgrCommandStatus.stopped;
    _model.activeCommands--;
    _log.finest('Queue has ${_model.activeCommands} commands.' );
    _runCommands();
  }

  void resumeCommand(CmdMgrCommand command){
    command.status = CmdMgrCommandStatus.waiting;
    _runCommands();
  }

  void notify(CmdMgrCommand command) {
    if(!_model.listeners.keys.contains(command.id) ||
        _model.listeners[command.id] == null) return;
    List<Function(CmdMgrCommand)> listeners = _model.listeners[command.id]!;
    for(Function(CmdMgrCommand) listener in listeners){
      listener(command);
    }
  }

  void subscribe(String id, Function(CmdMgrCommand) callback){
    _addNewListenerToCommand(id, callback);
  }

  void _runQueue(){
    if(_isQueueRunning()) return;
    _model.status = CmdMgrModelQueueStatus.running;
    _runCommands();
  }

  void _runCommands({List<CmdMgrCommand> ignore = const []}) {
    _model.commandQueue.removeWhere((command) => command.status == CmdMgrCommandStatus.stopped);
    if(_isQueueEmpty()) return;
    if(_isQueueRunningAll()) return;
    for(CmdMgrCommand command in _model.commandQueue){
      if(_isRunningQueueFull()) break;
      if(ignore.contains(command) || !_canRun(command)) continue;
      command.status = CmdMgrCommandStatus.running;
      _model.activeCommands++;
      _log.finest('Queue has ${_model.activeCommands} commands.' );
    }
  }

  void _addNewListenerToCommand(String id, Function(CmdMgrCommand) callback){
    if(_model.listeners[id] == null){
      _model.listeners[id] = [];
    }
    _model.listeners[id]!.add(callback);
  }

  bool _isQueueRunning() => _model.status == CmdMgrModelQueueStatus.running;

  bool _isRunningQueueFull() {
    if(_model.activeCommands >= _model.activeLimit){
      _log.finest('Queue has ${_model.activeCommands} commands and the limit is ${_model.activeLimit}');
      return true;
    }
    return false;
  }

  bool _canRun(CmdMgrCommand command) {
    if(command.status != CmdMgrCommandStatus.waiting) return false;
    if(_model.lastRun[command.id] != null && _model.lastRun[command.id]!
            .add(command.minRunFreq).isAfter(DateTime.now())) return false;
    return true;
  }

  bool _isQueueEmpty() {
    if(_model.commandQueue.length == 0){
      _log.finest('Queue is empty.' );
      _model.status = CmdMgrModelQueueStatus.idle;
      return true;
    }
    return false;
  }

  bool _isQueueRunningAll() {
    if(_model.commandQueue.length == _model.activeCommands){
      _log.finest('All items are running.' );
      return true;
    }
    return false;
  }

}