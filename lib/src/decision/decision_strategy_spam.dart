/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:httpp/httpp.dart';
import 'package:tiki_decision/tiki_decision.dart';
import 'package:tiki_spam_cards/tiki_spam_cards.dart';

import '../account/account_model.dart';
import '../account/account_service.dart';
import '../email/email_service.dart';
import '../email/msg/email_msg_model.dart';
import '../email/sender/email_sender_model.dart';
import '../intg/intg_context_email.dart';
import 'decision_strategy.dart';

class DecisionStrategySpam extends DecisionStrategy {
  final TikiSpamCards _spamCards;
  final EmailService _emailService;
  final AccountService _accountService;
  final Httpp? _httpp;

  DecisionStrategySpam(TikiDecision decision, this._spamCards,
      this._emailService, this._accountService,
      {Httpp? httpp})
      : _httpp = httpp,
        super(decision) {
    init();
  }

  Future<void> init() async {
    List<EmailSenderModel> senders = await _emailService.getSendersNotIgnored();
    //addSpamCards
  }

  void addSpamCards(AccountModel account, List<EmailMsgModel> messages) =>
      _spamCards.addCards(
          provider: account.provider!.value,
          messages: messages,
          onUnsubscribe: (email) => _unsubscribeFromSpam(account, email),
          onKeep: _keepReceiving);

  Future<bool> _unsubscribeFromSpam(
      AccountModel account, String senderEmail) async {
    EmailSenderModel? sender =
        await _emailService.getSenderByEmail(senderEmail);
    if (sender == null) throw 'Invalid sender';
    String unsubscribeMailTo = sender.unsubscribeMailTo!;
    Uri uri = Uri.parse(unsubscribeMailTo);
    String to = uri.path;
    String list = sender.name ?? sender.email!;
    String subject = uri.queryParameters['subject'] ?? "Unsubscribe from $list";
    String body = '''
Hello,<br /><br />
I'd like to stop receiving emails from this email list.<br /><br />
Thanks,<br /><br />
${account.displayName ?? ''}<br />
<br />
''';
    bool success = false;
    await IntgContextEmail(_accountService, httpp: _httpp).send(
        account: account,
        to: to,
        body: body,
        subject: subject,
        onResult: (res) => success = res);
    return success;
  }

  Future<void> _keepReceiving(String senderEmail) async {
    EmailSenderModel? sender =
        await _emailService.getSenderByEmail(senderEmail);
    if (sender != null) {
      await _emailService.markAsKept(sender);
    }
  }
}
