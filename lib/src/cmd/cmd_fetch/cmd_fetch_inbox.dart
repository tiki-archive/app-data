import 'dart:async';

import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

import '../../account/account_model.dart';
import '../../account/account_service.dart';
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
  String? _page;
  final IntgContextEmail _intgContextEmail;
  final FetchService _fetchService;

  CmdFetchInbox(
      FetchService this._fetchService,
      AccountModel this._account,
      DateTime? this._since,
      String? this._page,
      AccountService accountService,
      Httpp httpp
    ) :
        this._intgContextEmail = IntgContextEmail(accountService, httpp: httpp);

  Future<void> index() async {
    _log.fine('email index ${_account.email} on ${DateTime.now().toIso8601String()}');
    _intgContextEmail.getInbox(
        account: _account,
        since: _since,
        onResult: _saveParts,
        onFinish: _onFinish
    );
  }

  @override
  String get id => generateId(_account);

  @override
  Duration get minRunFreq => Duration(days: 1);

  @override
  Future<void> onPause() async {
    if(_page != null) {
      await _fetchService.savePage(_page!, _account);
    }
  }

  @override
  Future<void> onResume() async {
    _page = await _fetchService.getPage(_account);
    index();
  }

  @override
  Future<void> onStart() async{
    index();
  }

  @override
  Future<void> onStop() async {
    notify(CmdMgrNotificationFinish(id));
  }

  static String generateId(AccountModel account) {
    int id = account.accountId!;
    String prov = FetchService.apiFromProvider(account.provider)!.value;
    return "CmdFetchInbox.$prov.$id";
  }

  Future<void> _saveParts(List<EmailMsgModel> messages, {String? page}) async {
      List<FetchModelPart<EmailMsgModel>> parts = messages.map((message) =>
          FetchModelPart(
              extId: message.extMessageId,
              account: _account,
              api: FetchService.apiFromProvider(_account.provider),
              obj: message))
          .toList();
      await _fetchService.saveParts(parts, _account);
      _page = page;
      if(_page !=null) await _fetchService.savePage(_page!, _account);
      notify(CmdFetchInboxNotification(_account, messages));
      _log.fine('indexed ${messages.length} messages');
  }

  Future<void> _onFinish() async {
      _log.fine('finished email index for ${_account.email}.');
      await _fetchService.savePage(_page!, _account);
      notify(CmdMgrNotificationFinish(id));
  }
}