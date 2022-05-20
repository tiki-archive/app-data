import 'command.dart';

class CommanManagerService{

  void addCommand(Command command){
    _addListenersToNewCommand(command);
  }

  void removeCommand(Command command){}

  void stopCommand(Command command){}

  void startQueue(){}

  void pauseQueue(){}

  void resumeQueue(){}

  void _addListenersToNewCommand(Command command){}

  void subscribe(Type T, Function(Object) callback){
    _addNewListenerToCommands(T, callback);
  }

  void _addNewListenerToCommands(Type T, Function(Object) callback){}
}