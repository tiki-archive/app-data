import 'command_status.dart';

abstract class Command{
  CommandStatus status = CommandStatus.idle;

  void start(){
    status = CommandStatus.running;
    onStart();
  }
  void pause(){
    status = CommandStatus.paused;
    onPause();
  }
  void resumme(){
    status = CommandStatus.running;
    onResume();
  }
  void stop(){
    status = CommandStatus.idle;
    onStop();
  }

  Function onStart();
  Function onStop();
  Function onPause();
  Function onResume();
  Function notifyListeners(status, {Object data});
}