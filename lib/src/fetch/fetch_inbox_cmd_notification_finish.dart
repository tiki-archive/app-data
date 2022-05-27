import '../account/account_model.dart';
import '../cmd_mgr/cmd_mgr_command_notification.dart';

class FetchInboxCmdNotificationFinish extends CmdMgrCommandNotification{
  final AccountModel account;

  FetchInboxCmdNotificationFinish(this.account);
}