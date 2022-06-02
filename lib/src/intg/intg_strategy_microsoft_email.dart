/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:httpp/httpp.dart';

import '../account/account_model.dart';
import '../account/account_service.dart';
import '../email/msg/email_msg_model.dart';
import 'intg_strategy_interface_email.dart';
import 'intg_strategy_microsoft.dart';

class IntgStrategyMicrosoftEmail extends IntgStrategyMicrosoft
    with IntgStrategyInterfaceEmail {
  IntgStrategyMicrosoftEmail(AccountService accountService, {Httpp? httpp})
      : super(accountService, httpp: httpp);

  @override
  Future<void> getInbox(
          {required AccountModel account,
          DateTime? since,
          required Function(List<EmailMsgModel> messages, {String? page}) onResult,
          required Function() onFinish}) =>
      construct(account: account).fetchInbox(
          onResult: (msgIdList, {page}) => onResult(msgIdList
              .map((msgId) => EmailMsgModel(extMessageId: msgId))
              .toList(), page: page),
          onFinish: onFinish);

  @override
  Future<void> getMessages(
          {required AccountModel account,
          required List<String> messageIds,
          required Function(EmailMsgModel message) onResult,
          required Function() onFinish}) =>
      construct(account: account).fetchMessages(
          messageIds: messageIds,
          onResult: (msg) => onResult(EmailMsgModel.fromMap(msg.toJson())),
          onFinish: onFinish);

  @override
  Future<void> send(
          {required AccountModel account,
          String? body,
          required String to,
          String? subject,
          Function(bool success)? onResult}) =>
      construct(account: account)
          .sendEmail(body: body, to: to, subject: subject, onResult: onResult);
}
