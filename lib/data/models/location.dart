import 'package:screenshare/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  LocationModel.fromJSON(Map<String, dynamic> json)
  :super (
    town: json['town'],
    county: json['county'],
    state: json['state'],
    region: json['region'],
    postcode: json['postcode'],
    country: json['country'],
    country_code: json['country_code'],
  );
}