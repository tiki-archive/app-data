import 'package:decision/decision.dart';
import 'package:flutter/material.dart';
import 'package:spam_cards/spam_cards.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_data/tiki_data.dart';
import 'package:tiki_style/tiki_style.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Database database = await openDatabase('${Uuid().v4()}.db');
  Decision decision = await Decision().init();
  TikiData tikiData = await TikiData().init(
      database: database,
      spamCards: SpamCards(decision: decision),
      decision: decision);

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
