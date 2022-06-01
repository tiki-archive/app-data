import 'dart:async';

import 'package:logging/logging.dart';

import '../../account/account_model.dart';
import '../../email/msg/email_msg_model.dart';
import '../../fetch/fetch_model_part.dart';
import '../../fetch/fetch_service.dart';
import '../../intg/intg_context_email.dart';
import '../cmd_mgr/cmd_mgr_cmd.dart';
import '../cmd_mgr/cmd_mgr_cmd_notif_finish.dart';
import 'cmd_fetch_inbox_notification.dart';

class CmdFetchInbox extends CmdMgrCmd{
  final Logger _log = Logger('FetchInboxCommand');
  final AccountModel _account;
  final DateTime? _since;
  final String? _page;
  final IntgContextEmail _intgContextEmail;

  CmdFetchInbox(this._account, this._since, this._page, this._intgContextEmail);

  Future<void> index() async {
    _log.fine('email index ${_account.email} on ${DateTime.now().toIso8601String()}');
    _intgContextEmail.getInbox(
        account: _account,
        since: _since,
        onResult: _onResult,
        onFinish: _onFinish
    );
  }

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
  Future<void> onStart() async{
    index();
  }

  @override
  Future<void> onStop() async {
    notify(CmdMgrNotificationFinish(id));
  }

  static String generateId(AccountModel account) =>
      'FetchInboxCommand_${account.accountId!}_${account.provider!}';

  Future<void> _onResult(List<EmailMsgModel> messages) async {
      await messages.map((message) =>
          FetchModelPart(
              extId: message.extMessageId,
              account: _account,
              api: FetchService.apiFromProvider(_account.provider),
              obj: message))
          .toList();
      notify(CmdFetchInboxNotification(_account, messages));
      _log.fine('indexed ${messages.length} messages');
  }

  Future<void> _onFinish() async {
      _log.fine('finished email index for ${_account.email}.');
      notify(CmdMgrNotificationFinish(id));
  }
}