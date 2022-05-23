import 'package:sqflite_sqlcipher/sqlite_api.dart';

import 'command.dart';
import 'command_manager_repository.dart';
import 'model/command_manager_model.dart';
import 'model/command_manager_queue_status.dart';
import 'model/command_status.dart';

class CommandManagerService{

  final CommandManagerRepository _repository;
  CommandManagerModel _model = CommandManagerModel();

  CommandManagerService(Database database) :
      _repository = CommandManagerRepository(database){
  }

  Future<void> init() async {
    _model.lastRun = await _repository.getAllLastRun();
  }

  void addCommand(Command command){
    command.addManager(this);
    command.status = CommandStatus.enqueued;
    _model.commandQueue.add(command);
    runQueue();
  }

  void pauseCommand(Command command){
    command.pause();
    _model.activeCommands--;
    _runCommands(ignore: [command]);
  }

  void stopCommand(Command command){
    command.stop();
    _model.activeCommands--;
    _runCommands(ignore: [command]);
  }

  void resumeCommand(Command command){
    command.enqueue();
    _runCommands();
  }

  Future<void> finishCommand(Command command) async {
    await command.stop();
    _model.commandQueue.remove(command);
    _model.activeCommands--;
    _runCommands();
  }

  void runQueue(){
    if(_queueIsRunning()) return;
    _runCommands();
  }

  void pauseQueue(){
    for(Command command in _model.commandQueue){
      if(_runningQueueIsFull()) break;
      if(command.status == CommandStatus.running){
        command.pause();
        _model.activeCommands--;
      }
    }
    _model.status = CommandManagerQueueStatus.idle;
  }

  void notify(Command command) {
    Type commandType = command.runtimeType;
    if(!_model.listeners.keys.contains(commandType) ||
        _model.listeners[commandType] == null) return;
    List<Function(Command)> listeners = _model.listeners[commandType]!;
    for(Function(Command) listener in listeners){
      listener(command);
    }
  }

  void subscribe(Type T, Function(Object) callback){
    _addNewListenerToCommandType(T, callback);
  }

  void _addNewListenerToCommandType(Type T, Function(Object) callback){}

  bool _queueIsRunning() => _model.status == CommandManagerQueueStatus.running;

  bool _runningQueueIsFull() => _model.activeCommands >= _model.activeLimit;

  List<Type> _getRunningTypes() => _model.commandQueue.where(
            (command) => command.status == CommandStatus.running).map(
              (command) => command.runtimeType).toList();

  void _runCommands({List<Command> ignore = const []}) {
    for(Command command in _model.commandQueue){
      if(_runningQueueIsFull()) break;
      if(_shouldRun(command, ignore: ignore)){
            command.start();
            _model.activeCommands++;
      }
    }
  }

  bool _shouldRun(Command command, {List<Command> ignore = const[]}) {
    if(command.status != CommandStatus.enqueued || ignore.contains(command))
      return false;
    List<Type> runnningTypes = _getRunningTypes();
    Type type = command.runtimeType;
    if(runnningTypes.contains(command.runtimeType)) return false;
    DateTime? lastRun = _model.lastRun[type.toString()];
    if(lastRun == null || lastRun.add(command.minRunInterval).isAfter(DateTime.now())) return false;
    return true;
  }
}