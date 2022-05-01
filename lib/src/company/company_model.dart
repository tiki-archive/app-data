/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class CompanyModel {
  int? companyId;
  String? logo;
  double? securityScore;
  double? breachScore;
  double? sensitivityScore;
  String? domain;
  DateTime? created;
  DateTime? modified;

  CompanyModel(
      {this.companyId,
      this.logo,
      this.securityScore,
      this.breachScore,
      this.sensitivityScore,
      this.domain,
      this.created,
      this.modified});

  CompanyModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      companyId = map['company_id'];
      logo = map['logo'];
      securityScore = map['security_score'];
      breachScore = map['breach_score'];
      sensitivityScore = map['sensitivity_score'];
      domain = map['domain'];
      if (map['modified_epoch'] != null) {
        modified = DateTime.fromMillisecondsSinceEpoch(map['modified_epoch']);
      }
      if (map['created_epoch'] != null) {
        created = DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
      }
    }
  }

  Map<String, dynamic> toMap() => {
        'company_id': companyId,
        'logo': logo,
        'security_score': securityScore,
        'breach_score': breachScore,
        'sensitivity_score': sensitivityScore,
        'domain': domain,
        'modified_epoch': modified?.millisecondsSinceEpoch,
        'created_epoch': created?.millisecondsSinceEpoch
      };
}
