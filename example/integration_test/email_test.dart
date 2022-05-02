/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_data/src/company/company_model.dart';
import 'package:tiki_data/src/company/company_repository.dart';
import 'package:tiki_data/src/email/email_service.dart';
import 'package:tiki_data/src/email/msg/email_msg_model.dart';
import 'package:tiki_data/src/email/msg/email_msg_repository.dart';
import 'package:tiki_data/src/email/sender/email_sender_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Email Tests', () {
    test('Open - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await EmailService().open(database);
    });

    test('UpsertSenders - Insert - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await CompanyRepository(database).createTable();
      EmailService emailService = await EmailService().open(database);
      int count = await emailService.upsertSenders([
        EmailSenderModel(
            email: 'test@test.com',
            name: 'Test Name',
            category: 'Test Category',
            unsubscribed: false,
            emailSince: DateTime.now(),
            unsubscribeMailTo: 'unsubscribe@test.com',
            ignoreUntil: DateTime.now().add(Duration(days: 10)),
            company: CompanyModel(domain: 'test.com'),
            created: DateTime.now(),
            modified: DateTime.now())
      ]);
      expect(count, 1);
    });

    test('GetSenderByEmail - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await CompanyRepository(database).createTable();
      EmailService emailService = await EmailService().open(database);
      String email = Uuid().v4() + '@test.com';
      await emailService.upsertSenders([
        EmailSenderModel(
            email: email,
            name: 'Test Name',
            category: 'Test Category',
            unsubscribed: false,
            emailSince: DateTime.now(),
            unsubscribeMailTo: 'unsubscribe@test.com',
            ignoreUntil: DateTime.now().add(Duration(days: 10)),
            company: CompanyModel(domain: 'test.com'),
            created: DateTime.now(),
            modified: DateTime.now())
      ]);
      EmailSenderModel? sender = await emailService.getSenderByEmail(email);
      expect(sender?.senderId != null, true);
      expect(sender?.email, email);
      expect(sender?.name, 'Test Name');
      expect(sender?.category, 'Test Category');
      expect(sender?.emailSince != null, true);
      expect(sender?.unsubscribeMailTo, 'unsubscribe@test.com');
      expect(sender?.unsubscribed, false);
      expect(sender?.emailSince != null, true);
      expect(sender?.ignoreUntil != null, true);
      expect(sender?.company?.domain, 'test.com');
      expect(sender?.created != null, true);
      expect(sender?.modified != null, true);
    });

    test('GetSenderByEmail - None - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await CompanyRepository(database).createTable();
      EmailService emailService = await EmailService().open(database);
      EmailSenderModel? sender =
          await emailService.getSenderByEmail(Uuid().v4());
      expect(sender, null);
    });

    test('UpsertSenders - Update - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await CompanyRepository(database).createTable();
      EmailService emailService = await EmailService().open(database);

      String email = Uuid().v4() + '@test.com';
      int count = await emailService.upsertSenders([
        EmailSenderModel(
            email: email,
            name: 'Test Name',
            category: 'Test Category',
            unsubscribed: false,
            emailSince: DateTime.now(),
            unsubscribeMailTo: 'unsubscribe@test.com',
            ignoreUntil: DateTime.now().add(Duration(days: 10)),
            company: CompanyModel(domain: 'test.com'),
            created: DateTime.now(),
            modified: DateTime.now())
      ]);

      await emailService.upsertSenders([
        EmailSenderModel(
            email: email,
            name: 'Updated Name',
            emailSince: DateTime.now().add(Duration(days: 10)))
      ]);

      EmailSenderModel? sender = await emailService.getSenderByEmail(email);
      expect(sender?.senderId != null, true);
      expect(sender?.email, email);
      expect(sender?.name, 'Updated Name');
      expect(sender?.category, 'Test Category');
      expect(
          sender?.emailSince?.isBefore(DateTime.now().add(Duration(days: 1))),
          true);
      expect(sender?.unsubscribeMailTo, 'unsubscribe@test.com');
      expect(sender?.unsubscribed, false);
      expect(sender?.emailSince != null, true);
      expect(sender?.ignoreUntil != null, true);
      expect(sender?.company?.domain, 'test.com');
      expect(sender?.created != null, true);
      expect(sender?.modified != null, true);
    });

    test('UpsertSenders - Multiple - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await CompanyRepository(database).createTable();
      EmailService emailService = await EmailService().open(database);

      String email1 = Uuid().v4() + '@test.com';
      String email2 = Uuid().v4() + '@test.com';
      int count = await emailService.upsertSenders([
        EmailSenderModel(
            email: email1,
            name: 'Test Name',
            category: 'Test Category',
            unsubscribed: false,
            emailSince: DateTime.now(),
            unsubscribeMailTo: 'unsubscribe@test.com',
            ignoreUntil: DateTime.now().add(Duration(days: 10)),
            company: CompanyModel(domain: 'test.com'),
            created: DateTime.now(),
            modified: DateTime.now()),
        EmailSenderModel(
            email: email2,
            name: 'Test Name',
            category: 'Test Category',
            unsubscribed: false,
            emailSince: DateTime.now(),
            unsubscribeMailTo: 'unsubscribe@test.com',
            ignoreUntil: DateTime.now().add(Duration(days: 10)),
            company: CompanyModel(domain: 'test.com'),
            created: DateTime.now(),
            modified: DateTime.now())
      ]);

      expect(count, 2);
    });

    test('MarkAsUnsubscribed - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await CompanyRepository(database).createTable();
      EmailService emailService = await EmailService().open(database);

      String email = Uuid().v4() + '@test.com';
      EmailSenderModel sender = EmailSenderModel(
          email: email,
          name: 'Test Name',
          category: 'Test Category',
          unsubscribed: false,
          emailSince: DateTime.now(),
          unsubscribeMailTo: 'unsubscribe@test.com',
          ignoreUntil: DateTime.now().add(Duration(days: 10)),
          company: CompanyModel(domain: 'test.com'),
          created: DateTime.now(),
          modified: DateTime.now());
      int count = await emailService.upsertSenders([sender]);
      await emailService.markAsUnsubscribed(sender);
      EmailSenderModel? updated = await emailService.getSenderByEmail(email);
      expect(updated?.unsubscribed, true);
    });

    test('MarkAsKept - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await CompanyRepository(database).createTable();
      EmailService emailService = await EmailService().open(database);

      String email = Uuid().v4() + '@test.com';
      EmailSenderModel sender = EmailSenderModel(
          email: email,
          name: 'Test Name',
          category: 'Test Category',
          unsubscribed: false,
          emailSince: DateTime.now(),
          unsubscribeMailTo: 'unsubscribe@test.com',
          ignoreUntil: DateTime.now().add(Duration(days: 10)),
          company: CompanyModel(domain: 'test.com'),
          created: DateTime.now(),
          modified: DateTime.now());
      int count = await emailService.upsertSenders([sender]);
      await emailService.markAsKept(sender);
      EmailSenderModel? updated = await emailService.getSenderByEmail(email);
      expect(
          updated?.ignoreUntil?.isAfter(DateTime.now().add(Duration(days: 59))),
          true);
    });

    test('GetByIgnoreUntilBeforeNow - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await CompanyRepository(database).createTable();
      EmailService emailService = await EmailService().open(database);

      String email1 = Uuid().v4() + '@test.com';
      String email2 = Uuid().v4() + '@test.com';
      String email3 = Uuid().v4() + '@test.com';
      int count = await emailService.upsertSenders([
        EmailSenderModel(
            email: email1,
            name: 'Test Name',
            category: 'Test Category',
            unsubscribed: false,
            emailSince: DateTime.now(),
            unsubscribeMailTo: 'unsubscribe@test.com',
            ignoreUntil: DateTime.now().subtract(Duration(days: 10)),
            company: CompanyModel(domain: 'test.com'),
            created: DateTime.now(),
            modified: DateTime.now()),
        EmailSenderModel(
            email: email2,
            name: 'Test Name',
            category: 'Test Category',
            unsubscribed: false,
            emailSince: DateTime.now(),
            unsubscribeMailTo: 'unsubscribe@test.com',
            ignoreUntil: DateTime.now().add(Duration(days: 10)),
            company: CompanyModel(domain: 'test.com'),
            created: DateTime.now(),
            modified: DateTime.now()),
        EmailSenderModel(
            email: email2,
            name: 'Test Name',
            category: 'Test Category',
            unsubscribed: false,
            emailSince: DateTime.now(),
            unsubscribeMailTo: 'unsubscribe@test.com',
            company: CompanyModel(domain: 'test.com'),
            created: DateTime.now(),
            modified: DateTime.now())
      ]);

      List<EmailSenderModel> senders =
          await emailService.getSendersNotIgnored();
      expect(senders.length, 2);
    });

    test('UpsertMessages - Insert - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await CompanyRepository(database).createTable();
      EmailService emailService = await EmailService().open(database);

      String email = Uuid().v4() + '@test.com';
      EmailSenderModel sender = EmailSenderModel(
          email: email,
          name: 'Test Name',
          category: 'Test Category',
          unsubscribed: false,
          emailSince: DateTime.now(),
          unsubscribeMailTo: 'unsubscribe@test.com',
          ignoreUntil: DateTime.now().add(Duration(days: 10)),
          company: CompanyModel(domain: 'test.com'),
          created: DateTime.now(),
          modified: DateTime.now());
      await emailService.upsertSenders([sender]);

      String extMsgId = Uuid().v4();
      String toEmail = 'test@test.com';
      await emailService.upsertMessages([
        EmailMsgModel(
            sender: sender,
            extMessageId: extMsgId,
            receivedDate: DateTime.now(),
            openedDate: DateTime.now(),
            toEmail: toEmail,
            created: DateTime.now(),
            modified: DateTime.now())
      ]);

      EmailMsgRepository msgRepository = EmailMsgRepository(database);
      EmailMsgModel? inserted =
          await msgRepository.getByExtMessageIdAndToDate(extMsgId, toEmail);

      expect(inserted != null, true);
      expect(inserted?.sender?.email != null, true);
      expect(inserted?.extMessageId, extMsgId);
      expect(inserted?.toEmail, toEmail);
      expect(inserted?.receivedDate != null, true);
      expect(inserted?.openedDate != null, true);
      expect(inserted?.created != null, true);
      expect(inserted?.modified != null, true);
    });

    test('UpsertMessages - Update - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await CompanyRepository(database).createTable();
      EmailService emailService = await EmailService().open(database);

      String email = Uuid().v4() + '@test.com';
      EmailSenderModel sender = EmailSenderModel(
          email: email,
          name: 'Test Name',
          category: 'Test Category',
          unsubscribed: false,
          emailSince: DateTime.now(),
          unsubscribeMailTo: 'unsubscribe@test.com',
          ignoreUntil: DateTime.now().add(Duration(days: 10)),
          company: CompanyModel(domain: 'test.com'),
          created: DateTime.now(),
          modified: DateTime.now());
      await emailService.upsertSenders([sender]);

      String extMsgId = Uuid().v4();
      String toEmail = 'test@test.com';
      await emailService.upsertMessages([
        EmailMsgModel(
            sender: sender,
            extMessageId: extMsgId,
            receivedDate: DateTime.now(),
            toEmail: toEmail,
            created: DateTime.now(),
            modified: DateTime.now())
      ]);

      await emailService.upsertMessages([
        EmailMsgModel(
            extMessageId: extMsgId,
            toEmail: toEmail,
            openedDate: DateTime.now())
      ]);

      EmailMsgRepository msgRepository = EmailMsgRepository(database);
      EmailMsgModel? updated =
          await msgRepository.getByExtMessageIdAndToDate(extMsgId, toEmail);

      expect(updated != null, true);
      expect(updated?.sender?.email != null, true);
      expect(updated?.extMessageId, extMsgId);
      expect(updated?.toEmail, toEmail);
      expect(updated?.receivedDate != null, true);
      expect(updated?.openedDate != null, true);
      expect(updated?.created != null, true);
      expect(updated?.modified != null, true);
    });

    test('UpsertMessages - Multiple - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      await CompanyRepository(database).createTable();
      EmailService emailService = await EmailService().open(database);

      String email = Uuid().v4() + '@test.com';
      EmailSenderModel sender = EmailSenderModel(
          email: email,
          name: 'Test Name',
          category: 'Test Category',
          unsubscribed: false,
          emailSince: DateTime.now(),
          unsubscribeMailTo: 'unsubscribe@test.com',
          ignoreUntil: DateTime.now().add(Duration(days: 10)),
          company: CompanyModel(domain: 'test.com'),
          created: DateTime.now(),
          modified: DateTime.now());
      await emailService.upsertSenders([sender]);

      String extMsgId1 = Uuid().v4();
      String extMsgId2 = Uuid().v4();
      String toEmail = 'test@test.com';
      await emailService.upsertMessages([
        EmailMsgModel(
            sender: sender,
            extMessageId: extMsgId1,
            receivedDate: DateTime.now(),
            openedDate: DateTime.now(),
            toEmail: toEmail,
            created: DateTime.now(),
            modified: DateTime.now()),
        EmailMsgModel(
            sender: sender,
            extMessageId: extMsgId2,
            receivedDate: DateTime.now(),
            openedDate: DateTime.now(),
            toEmail: toEmail,
            created: DateTime.now(),
            modified: DateTime.now())
      ]);

      EmailMsgRepository msgRepository = EmailMsgRepository(database);
      EmailMsgModel? updated1 =
          await msgRepository.getByExtMessageIdAndToDate(extMsgId1, toEmail);
      EmailMsgModel? updated2 =
          await msgRepository.getByExtMessageIdAndToDate(extMsgId2, toEmail);

      expect(updated1 != null, true);
      expect(updated1?.sender?.email != null, true);
      expect(updated1?.extMessageId, extMsgId1);
      expect(updated1?.toEmail, toEmail);
      expect(updated1?.receivedDate != null, true);
      expect(updated1?.openedDate != null, true);
      expect(updated1?.created != null, true);
      expect(updated1?.modified != null, true);
      expect(updated2 != null, true);
      expect(updated2?.sender?.email != null, true);
      expect(updated2?.extMessageId, extMsgId2);
      expect(updated2?.toEmail, toEmail);
      expect(updated2?.receivedDate != null, true);
      expect(updated2?.openedDate != null, true);
      expect(updated2?.created != null, true);
      expect(updated2?.modified != null, true);
    });
  });
}
