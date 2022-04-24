/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class EnrichCompanyModelType {
  String? sector;
  String? industry;
  String? subIndustry;
  List<String>? tags;

  EnrichCompanyModelType(
      {this.sector, this.industry, this.subIndustry, this.tags});

  EnrichCompanyModelType.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      sector = json['sector'];
      industry = json['industry'];
      subIndustry = json['subIndustry'];
      tags = json['tags'] != null ? List.from(json['tags']) : null;
    }
  }

  Map<String, dynamic> toJson() => {
        'sector': sector,
        'industry': industry,
        'subIndustry': subIndustry,
        'tags': tags,
      };
}
