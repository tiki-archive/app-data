/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:decision/decision.dart';

class DecisionStrategy {
  final Decision _decision;

  DecisionStrategy(this._decision);

  void setLinked(bool isLinked) => _decision.setLinked(isLinked);
}
