/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

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
        super(decision);

  Future<void> loadFromDb(AccountModel account) async {
    List<EmailSenderModel> senders = await _emailService.getSendersNotIgnored();
    for (EmailSenderModel sender in senders) {
      if (sender.unsubscribed == null || sender.unsubscribed == false) {
        List<EmailMsgModel> msgs =
            await _emailService.getSenderMessages(sender);
        addSpamCards(account, msgs);
      }
    }
  }

  void addSpamCards(AccountModel account, List<EmailMsgModel> messages) {
    Map<String, EmailSenderModel> senderMap = {};
    Map<String, List<EmailMsgModel>> senderMsgMap = {};
    for (EmailMsgModel msg in messages) {
      EmailSenderModel? sender = msg.sender;
      if (sender != null && sender.email != null) {
        senderMap.putIfAbsent(sender.email!, () => sender);
        if (senderMsgMap.containsKey(sender.email!)) {
          List<EmailMsgModel> msgs = List.from(senderMsgMap[sender.email!]!)
            ..add(msg);
          senderMsgMap[sender.email!] = msgs;
        } else {
          senderMsgMap[sender.email!] = [msg];
        }
      }
    }

    Set<CardModel> cards = {};
    for (MapEntry<String, EmailSenderModel> entry in senderMap.entries) {
      List<EmailMsgModel>? msgs = senderMsgMap[entry.key];
      double? openRate;
      String? frequency;

      if (msgs != null) {
        frequency = _spamCards.calculateFrequency(
            msgs.map((e) => e.receivedDate ?? DateTime.now()).toList());
        openRate = _spamCards
            .calculateOpenRate(msgs.map((e) => e.openedDate).toList());
      }

      cards.add(CardModel(
          strategy: account.provider!.value,
          logoUrl: entry.value.company?.logo,
          category: entry.value.category,
          companyName: entry.value.name,
          frequency: frequency,
          sinceYear: entry.value.emailSince?.year.toString(),
          totalEmails: msgs?.length,
          openRate: openRate,
          securityScore: entry.value.company?.securityScore,
          sensitivityScore: entry.value.company?.sensitivityScore,
          hackingScore: entry.value.company?.breachScore,
          senderEmail: entry.value.email,
          onUnsubscribe: () async {
            _unsubscribeFromSpam(account, entry.value.email!);
          },
          onKeep: () async {
            _keepReceiving(entry.value.email!);
          }));
    }

    _spamCards.upsert(cards);
  }

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
    Completer<bool> completer = Completer();
    IntgContextEmail(_accountService, httpp: _httpp).send(
        account: account,
        to: to,
        body: body,
        subject: subject,
        onResult: (success) {
          sender.unsubscribed = success;
          _emailService.upsertSenders([sender]);
          completer.complete(success);
        });
    return completer.future;
  }

  Future<void> _keepReceiving(String senderEmail) async {
    EmailSenderModel? sender =
        await _emailService.getSenderByEmail(senderEmail);
    if (sender != null) {
      await _emailService.markAsKept(sender);
    }
  }
}
