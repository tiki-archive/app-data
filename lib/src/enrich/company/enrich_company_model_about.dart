/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class EnrichCompanyModelAbout {
  String? domain;
  String? name;
  String? description;
  String? logo;
  String? url;
  String? address;
  String? phone;

  EnrichCompanyModelAbout(
      {this.domain,
      this.name,
      this.description,
      this.logo,
      this.url,
      this.address,
      this.phone});

  EnrichCompanyModelAbout.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      domain = json['domain'];
      name = json['name'];
      description = json['description'];
      logo = json['logo'];
      url = json['url'];
      address = json['address'];
      phone = json['phone'];
    }
  }

  Map<String, dynamic> toJson() => {
        'domain': domain,
        'name': name,
        'description': description,
        'logo': logo,
        'url': url,
        'address': address,
        'phone': phone
      };
}
