/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:httpp/httpp.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_data/tiki_data.dart';
import 'package:tiki_decision/tiki_decision.dart';
import 'package:tiki_kv/tiki_kv.dart';
import 'package:tiki_localgraph/tiki_localgraph.dart';
import 'package:tiki_spam_cards/tiki_spam_cards.dart';
import 'package:tiki_wallet/tiki_wallet.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Log Error Tests', () {
    test("runzoneguarded catch uncaught errors", () async {
      bool errorCaught = false;
      await runZonedGuarded(() async {
        Logger.root.level = Level.INFO;
        Logger.root.onRecord.listen((record) => errorCaught = true);
        WidgetsFlutterBinding.ensureInitialized();
        String Function() accessToken = () => '';
        Httpp httpp = Httpp();
        Database database = await openDatabase('tiki_data_test.db');
        TikiKv tikiKv = await TikiKv(database: database).init();
        TikiDecision decision = await TikiDecision(tikiKv: tikiKv).init();

        TikiKeysModel keys = await TikiKeysService().generate();
        TikiChainService chainService = await TikiChainService(keys).open(
            database: database, kv: tikiKv, httpp: httpp, accessToken: accessToken);

        TikiLocalGraph localGraph = await TikiLocalGraph(chainService)
            .open(database, httpp: httpp, accessToken: accessToken);

        await TikiData().init(
            database: database,
            spamCards: TikiSpamCards(decision),
            decision: decision,
            localGraph: localGraph,
            httpp: httpp,
            accessToken: accessToken);

        FlutterError.onError = (FlutterErrorDetails details) {
          Logger("Flutter Error").severe(details.summary, details.exception, details.stack);
        };
        runApp(Container());
      }, (exception, stackTrace) async {
        Logger("Uncaught Exception").severe("Caught by runZoneGuarded", exception, stackTrace);
      });
      expect(errorCaught,true);
    });
  });
}