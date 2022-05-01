/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../api/enrich_api_data.dart';
import 'enrich_company_model_about.dart';
import 'enrich_company_model_score.dart';
import 'enrich_company_model_social.dart';
import 'enrich_company_model_type.dart';

class EnrichCompanyModel extends EnrichApiData {
  EnrichCompanyModelAbout? about;
  EnrichCompanyModelScore? score;
  EnrichCompanyModelSocial? social;
  EnrichCompanyModelType? type;

  EnrichCompanyModel({this.about, this.score, this.social, this.type});

  EnrichCompanyModel.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      about = EnrichCompanyModelAbout.fromJson(json['about']);
      score = EnrichCompanyModelScore.fromJson(json['score']);
      social = EnrichCompanyModelSocial.fromJson(json['social']);
      type = EnrichCompanyModelType.fromJson(json['type']);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'about': about?.toJson(),
        'score': score?.toJson(),
        'social': social?.toJson(),
        'type': type?.toJson()
      };
}
