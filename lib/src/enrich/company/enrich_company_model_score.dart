/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class EnrichCompanyModelScore {
  double? sensitivityScore;
  double? breachScore;
  double? securityScore;

  EnrichCompanyModelScore(
      {this.sensitivityScore, this.breachScore, this.securityScore});

  EnrichCompanyModelScore.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      sensitivityScore = json['sensitivityScore'];
      breachScore = json['breachScore'];
      securityScore = json['securityScore'];
    }
  }

  Map<String, dynamic> toJson() => {
        'sensitivityScore': sensitivityScore,
        'breachScore': breachScore,
        'securityScore': securityScore
      };
}
