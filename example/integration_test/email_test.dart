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
import 'package:tiki_data/src/email/sender/email_sender_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Tests', () {
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

      await emailService.upsertSenders(
          [EmailSenderModel(email: email, name: 'Updated Name')]);

      EmailSenderModel? sender = await emailService.getSenderByEmail(email);
      expect(sender?.senderId != null, true);
      expect(sender?.email, email);
      expect(sender?.name, 'Updated Name');
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

    test('UpsertMessages - Insert - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
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

      await emailService.upsertMessages([
        EmailMsgModel(
            sender: sender,
            extMessageId: Uuid().v4(),
            receivedDate: DateTime.now(),
            openedDate: DateTime.now(),
            toEmail: 'test@test.com',
            created: DateTime.now(),
            modified: DateTime.now())
      ]);

      //TODO ADD READ METHODS
    });

    test('UpsertMessages - Update - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
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

      await emailService.upsertMessages([
        EmailMsgModel(
            sender: sender,
            extMessageId: Uuid().v4(),
            receivedDate: DateTime.now(),
            toEmail: 'test@test.com',
            created: DateTime.now(),
            modified: DateTime.now())
      ]);

      await emailService.upsertMessages([
        EmailMsgModel(
            extMessageId: Uuid().v4(),
            toEmail: 'test@test.com',
            openedDate: DateTime.now())
      ]);

      //TODO ADD READ METHODS
    });

    test('UpsertMessages - Multiple - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
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

      await emailService.upsertMessages([
        EmailMsgModel(
            sender: sender,
            extMessageId: Uuid().v4(),
            receivedDate: DateTime.now(),
            openedDate: DateTime.now(),
            toEmail: 'test@test.com',
            created: DateTime.now(),
            modified: DateTime.now()),
        EmailMsgModel(
            sender: sender,
            extMessageId: Uuid().v4(),
            receivedDate: DateTime.now(),
            openedDate: DateTime.now(),
            toEmail: 'test2@test.com',
            created: DateTime.now(),
            modified: DateTime.now())
      ]);

      //TODO ADD READ METHODS
    });
  });
}
