/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class EnrichCompanyModelSocial {
  String? facebook;
  String? twitter;
  String? linkedin;

  EnrichCompanyModelSocial({this.facebook, this.twitter, this.linkedin});

  EnrichCompanyModelSocial.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      facebook = json['facebook'];
      twitter = json['twitter'];
      linkedin = json['linkedin'];
    }
  }

  Map<String, dynamic> toJson() =>
      {'facebook': facebook, 'twitter': twitter, 'linkedin': linkedin};
}
