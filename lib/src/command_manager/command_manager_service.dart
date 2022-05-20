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
  
  Future<void> init() async{
    _model = CommandManagerModel.fromMap(await _repository.get());
  }

  void addCommand(Command command){
    command.addManager(this);
    _model.commandQueue.add(command);
    runQueue();
  }

  void finishCommand(Command command) {
    command.stop();
    _model.commandQueue.remove(command);
    _model.activeCommands--;
    runQueue();
  }

  void stopCommand(Command command){
    command.stop();
    _model.activeCommands--;
    runQueue();
  }

  void runQueue(){
    if(_queueIsRunning()) return;
    List<Type> runnningTypes = _getRunningTypes();
    for(Command command in _model.commandQueue){
      if(_queueIsFull()) break;
      if(command.status != CommandStatus.running && 
          !runnningTypes.contains(command.runtimeType)){
        command.start();
        _model.activeCommands++;
      }
    }
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

  void pauseQueue(){
    for(Command command in _model.commandQueue){
      if(_queueIsFull()) break;
      if(command.status == CommandStatus.running){
        command.pause();
        _model.activeCommands--;
      }
    }
  }

  void resumeQueue(){
    for(Command command in _model.commandQueue){
      if(_queueIsFull()) break;
      if(command.status == CommandStatus.paused){
        command.resumme();
        _model.activeCommands++;
      }
    }
  }

  void subscribe(Type T, Function(Object) callback){
    _addNewListenerToCommandType(T, callback);
  }

  void _addNewListenerToCommandType(Type T, Function(Object) callback){}

  bool _queueIsRunning() => _model.status == CommandManagerQueueStatus.running;

  bool _queueIsFull() => _model.activeCommands >= _model.activeLimit;

  List<Type> _getRunningTypes() {
    return _model.commandQueue.where(
            (command) => command.status == CommandStatus.running).map(
              (command) => command.runtimeType).toList();
  }
}