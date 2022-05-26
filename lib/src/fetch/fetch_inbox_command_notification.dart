import '../account/account_model.dart';
import '../cmd_mgr/cmd_mgr_command_notification.dart';
import '../email/msg/email_msg_model.dart';

class FetchInboxCommandNotification extends CmdMgrCommandNotification{
  final AccountModel account;
  final List<EmailMsgModel> messages;

  FetchInboxCommandNotification(this.account, this.messages);
}