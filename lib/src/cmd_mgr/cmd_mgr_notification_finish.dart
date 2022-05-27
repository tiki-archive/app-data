import 'cmd_mgr_command_notification.dart';

class CmdMgrNotificationFinish extends CmdMgrCommandNotification{
  final String commandId;

  CmdMgrNotificationFinish(this.commandId);
}