import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_data/tiki_data.dart';
import 'package:tiki_decision/tiki_decision.dart';
import 'package:tiki_kv/tiki_kv.dart';
import 'package:tiki_spam_cards/tiki_spam_cards.dart';
import 'package:tiki_style/tiki_style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Database database = await openDatabase('tiki_data_test.db');
  TikiKv tikiKv = await TikiKv(database: database).init();
  TikiDecision decision = await TikiDecision(tikiKv: tikiKv).init();
  TikiData tikiData = await TikiData().init(
      database: database,
      _spamCards: TikiSpamCards(decision),
      decision: decision);

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) =>
      print('${record.level.name} [${record.loggerName}] ${record.message}'));

  runApp(MaterialApp(
    title: 'Data Example',
    theme: ThemeData(),
    home: Scaffold(
      body: Center(child: Widgety(tikiData)),
    ),
  ));
}

class Widgety extends StatelessWidget {
  final TikiData tikiData;

  Widgety(this.tikiData);

  @override
  Widget build(BuildContext context) {
    TikiStyle style = TikiStyle.init(context);
    return tikiData.widget(
        headerBar: Container(
      height: SizeProvider.instance.height(34),
      color: Colors.blue,
    ));
  }
}
