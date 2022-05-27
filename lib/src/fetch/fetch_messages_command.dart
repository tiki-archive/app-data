import 'dart:async';

import 'package:logging/logging.dart';

import '../account/account_model.dart';
import '../account/account_service.dart';
import '../cmd_mgr/cmd_mgr_command.dart';
import '../cmd_mgr/cmd_mgr_notification_finish.dart';
import '../email/msg/email_msg_model.dart';
import '../email/sender/email_sender_model.dart';
import '../intg/intg_context.dart';
import '../intg/intg_context_email.dart';
import 'fetch_inbox_command_notification.dart';
import 'fetch_messages_command_notification.dart';
import 'fetch_part_model.dart';

class FetchInboxCommand extends CmdMgrCommand {

  var _httpp;
  Logger _log = Logger('FetchInboxCommand');

  AccountModel _account;
  List<EmailMsgModel> _save;
  List<EmailMsgModel> _fetch;
  List<EmailMsgModel> message;
  IntgContextEmail _intgContextEmail;
  List<FetchPartModel>_parts;

  @override
  String get id => generateId(_account);

  @override
  Duration get minRunFreq => Duration(days: 1);

  @override
  Future<void> onPause() async {
    // record where paused
    // stop fetching
  }

  @override
  Future<void> onResume() async {
    // get where paused
    // restart from there
  }

  @override
  Future<void> onStart() async {
    _processParts();
  }

  @override
  Future<void> onStop() async {
    notify(CmdMgrNotificationFinish(id));
  }

  static String generateId(AccountModel account) =>
      'FetchInboxCommand_${account.accountId!}_${account.provider!}';

  _processParts() async {
    List<String> ids = _parts
        .where((part) => part.obj?.extMessageId != null)
        .map((part) => part.obj!.extMessageId! as String)
        .toList();
    List<EmailMsgModel> fetched = List.empty(growable: true);
    List<EmailMsgModel> save = List.empty(growable: true);
    _intgContextEmail.getMessages(
        account: _account,
        messageIds: ids,
        onResult: (message) => (message) {
          if (message.toEmail == _account.email! &&
              message.sender?.unsubscribeMailTo != null) save.add(message);
          fetched.add(message);
        },
        onFinish: () => notify(FetchMessagesCommandNotification(_account, _save, _fetch))
    );
  }
}
