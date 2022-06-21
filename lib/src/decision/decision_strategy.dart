/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:tiki_decision/tiki_decision.dart';

class DecisionStrategy {
  final TikiDecision _decision;

  DecisionStrategy(this._decision);

  void setLinked(bool isLinked) => _decision.setLinked(isLinked);

  // TODO clear by account
  void clear() => _decision.clearWhere(({card, id}) => true);
}
