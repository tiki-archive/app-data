/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../account/account_model.dart';
import '../email/msg/email_msg_model.dart';

abstract class IntgStrategyInterfaceEmail {

  Future<void> countInbox(
      {required AccountModel account,
        DateTime? since,
        required Function(int amount) onResult,
        required Function() onFinish});

  Future<void> getInbox(
      {required AccountModel account,
      DateTime? since,
      required Function(List<EmailMsgModel> messages, {String? page}) onResult,
      required Function() onFinish});


  Future<void> getMessages(
      {required AccountModel account,
      required List<String> messageIds,
      required Function(EmailMsgModel message) onResult,
      required Function() onFinish});


  Future<void> send(
      {required AccountModel account,
      String? body,
      required String to,
      String? subject,
      Function(bool success)? onResult});

}
