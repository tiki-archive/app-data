import 'dart:core';

import 'package:logging/logging.dart';

import '../../account/account_model.dart';
import '../../company/company_service.dart';
import '../../decision/decision_strategy_spam.dart';
import '../../email/email_service.dart';
import '../../email/msg/email_msg_model.dart';
import '../../email/sender/email_sender_model.dart';
import '../../fetch/fetch_model_part.dart';
import '../../fetch/fetch_service.dart';
import '../../graph/graph_strategy_email.dart';
import '../../intg/intg_context_email.dart';
import '../cmd_mgr/cmd_mgr_cmd.dart';
import '../cmd_mgr/cmd_mgr_cmd_notif_finish.dart';
import '../cmd_mgr/cmd_mgr_cmd_status.dart';
import 'cmd_fetch_msg_notification.dart';

class CmdFetchMsg extends CmdMgrCmd {

  final Logger _log = Logger('CmdFetchMsg');
  final List<EmailMsgModel> _save = [];
  final List<EmailMsgModel> _fetched = [];

  final FetchService _fetchService;
  final AccountModel _account;
  final DecisionStrategySpam _decisionStrategySpam;
  final GraphStrategyEmail _graphStrategyEmail;
  final EmailService _emailService;
  final CompanyService _companyService;
  final IntgContextEmail _intgContextEmail;

  CmdFetchMsg(
      AccountModel this._account,
      FetchService this._fetchService,
      DecisionStrategySpam this._decisionStrategySpam,
      GraphStrategyEmail this._graphStrategyEmail,
      EmailService this._emailService,
      CompanyService this._companyService,
      IntgContextEmail this._intgContextEmail,
  );

  @override
  String get id => generateId(_account);

  @override
  Duration get minRunFreq => Duration(days: 1);

  @override
  Future<void> onPause() async {
    _processFetchedMessages();
  }

  @override
  Future<void> onResume() async {
    _getPartsAndFetchMsg();
  }

  @override
  Future<void> onStart() async {
    _getPartsAndFetchMsg();
  }

  @override
  Future<void> onStop() async {
    _processFetchedMessages();
  }

  static String generateId(AccountModel account) {
    int id = account.accountId!;
    String prov = FetchService.apiFromProvider(account.provider)!.value;
    return "FetchInboxCommand.$prov.$id";
  }

  Future<void> _getPartsAndFetchMsg() async {
    if (!await _intgContextEmail.isConnected(_account)) {
      _log.warning('${_account.email} - ${_account.provider} not connected.');
      notify(CmdMgrNotificationFinish(id));
    }
    List<FetchModelPart> parts = await _fetchService.getParts(_account);
    if(parts.isEmpty){
      _log.warning('${_account.email} - ${_account.provider} no parts to fetch.');
      notify(CmdMgrNotificationFinish(id));
      return;
    }
    _fetchMessages(parts);
  }

  Future<void> _fetchMessages(List<FetchModelPart> parts) async {
    List<String> ids = parts
        .where((part) => part.obj?.extMessageId != null)
        .map((part) => part.obj!.extMessageId! as String)
        .toList();
    _intgContextEmail.getMessages(
        account: _account,
        messageIds: ids,
        onResult: _onMessageFetched,
        onFinish: _processFetchedMessages
    );
  }

  void _onMessageFetched(message){
    if (message.toEmail == _account.email! &&
        message.sender?.unsubscribeMailTo != null) _save.add(message);
    _fetched.add(message);
    notify(CmdFetchMsgNotification(_account, _save, _fetched));
  }

  Future<void> _processFetchedMessages() async {
    _log.fine('Fetched ${_fetched.length} messages');
    Map<String, EmailSenderModel> senders = {};
    _save.where((msg) => msg.sender != null && msg.sender?.email != null)
        .forEach((msg) => senders[msg.sender!.email!] = msg.sender!);
    await _saveSenders(senders, _save);
    await _saveMessages(_save);
    await _saveCompanies(senders);
    await _fetchService.deleteParts(_fetched, _account);
    _decisionStrategySpam.addSpamCards(_account, _save);
    _graphStrategyEmail.write(_save);
    if(status == CmdMgrCmdStatus.running) _getPartsAndFetchMsg();
  }

  Future<void> _saveMessages(save) async {
    _log.fine('Saving ${save.length} messages');
    await _emailService.upsertMessages(save);
  }

  Future<void> _saveSenders(senders, save) async {
    senders.forEach((email, sender) {
      List<DateTime?> dates = save.map((msg) {
        if (msg.sender?.email == email) return msg.receivedDate;
      }).toList();
      DateTime? since = dates.reduce((min, date) =>
      min != null && date != null && date.isBefore(min)
          ? date
          : min);
      sender.emailSince = since;
      senders[sender.email!] = sender;
    });
    _log.fine('Saving ${senders.length} senders');
    await _emailService.upsertSenders(List.of(senders.values));
  }

  Future<void> _saveCompanies(senders) async {
    Set<String> domains = {};
    for (var sender in senders.values) {
      if (sender.company?.domain != null) {
        domains.add(sender.company!.domain!);
      }
    }
    _log.fine('Saving ${domains.length} companies');
    for (String domain in domains) {
      _companyService.upsert(domain);
    }
  }

}
