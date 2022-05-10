/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:tiki_localgraph/tiki_localgraph.dart';

class GraphStrategy {
  static const edgeTypeCompany = 'company';
  static const edgeTypeDataBreach = 'dataBreach';
  static const edgeTypeOccurrence = 'occurrence';
  static const edgeTypeAction = 'action';
  static const edgeTypeDate = 'date';
  static const edgeTypeSubject = 'subject';

  final TikiLocalGraph localGraph;

  GraphStrategy(this.localGraph);

  Uint8List sha256(Uint8List message, {bool sha3 = false}) {
    Digest digest = sha3 ? Digest("SHA3-256") : Digest("SHA-256");
    return digest.process(message);
  }
}
