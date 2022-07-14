import 'package:amplitude_flutter/amplitude.dart';
import 'package:uuid/uuid.dart';

import 'widgets/widgety.dart';
import 'package:flutter/material.dart';
import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_data/tiki_data.dart';
import 'package:tiki_decision/tiki_decision.dart';
import 'package:tiki_kv/tiki_kv.dart';
import 'package:tiki_localgraph/tiki_localgraph.dart';
import 'package:tiki_spam_cards/tiki_spam_cards.dart';
import 'package:tiki_wallet/tiki_wallet.dart';

import 'widgets/fetch_command_tester.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String Function() accessToken = () => '';

  Httpp httpp = Httpp();
  Database database = await openDatabase('test.db'); //await openDatabase('${Uuid().v4()}.db');
  TikiKv tikiKv = await TikiKv(database: database).init();
  TikiDecision decision = await TikiDecision(tikiKv: tikiKv).init();

  TikiKeysModel keys = await TikiKeysService().generate();
  TikiChainService chainService = await TikiChainService(keys).open(
      database: database, kv: tikiKv, httpp: httpp, accessToken: accessToken);

  TikiLocalGraph localGraph = await TikiLocalGraph(chainService)
      .open(database, httpp: httpp, accessToken: accessToken);

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) =>
      print('${record.level.name} [${record.loggerName}] ${record.message}'));

  Amplitude amplitude = Amplitude.getInstance(instanceName: "Develop");
  await amplitude.init("afba707e002643a678747221206c9605");
  await amplitude.enableCoppaControl();
  await amplitude.setUserId(null);
  await amplitude.trackingSessionEvents(true);

  TikiData tikiData = await TikiData().init(
      database: database,
      spamCards: TikiSpamCards(decision),
      decision: decision,
      localGraph: localGraph,
      httpp: httpp,
      accessToken: accessToken,
      amplitude: amplitude);



  runApp(MaterialApp(
    title: 'Data Example',
    theme: ThemeData(),
    home: Builder(builder: (context) => Scaffold(
      body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
              child: Text('App Screen Test'),
              onPressed: () => navigateTo(Widgety(tikiData), context)),
              ElevatedButton(
                  child: Text('Fetch Command Test'),
                  onPressed: () => navigateTo(FetchCommandTester(tikiData), context))
            ]
          )
      ),
    ),
  )));
}

navigateTo(Widget destination, BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => destination));
}


