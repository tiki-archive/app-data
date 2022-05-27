import '../account/account_model.dart';
import '../cmd_mgr/cmd_mgr_command_notification.dart';
import '../email/msg/email_msg_model.dart';

class FetchInboxCmdNotification extends CmdMgrCommandNotification{
  final AccountModel account;
  final List<EmailMsgModel> messages;

  FetchInboxCmdNotification(this.account, this.messages);
}