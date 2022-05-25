import 'cmd_queue_command_notification.dart';

class CmdQueueCommandEvent extends CmdQueueCommandNotification {
  late final CmdQueueCommandEventType event;

  CmdQueueCommandEvent.start() : event = CmdQueueCommandEventType.start;
  CmdQueueCommandEvent.pause() : event = CmdQueueCommandEventType.pause;
  CmdQueueCommandEvent.resume() : event = CmdQueueCommandEventType.resume;
  CmdQueueCommandEvent.stop() : event = CmdQueueCommandEventType.stop;
}

enum CmdQueueCommandEventType{
  start,
  stop,
  pause,
  resume
}