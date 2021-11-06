// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmp_geometry.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleMapsGeometry _$GoogleMapsGeometryFromJson(Map json) {
  return GoogleMapsGeometry(
    location: GoogleMapsLocation.fromJson(
        Map<String, dynamic>.from(json['location'] as Map)),
    viewport:
        Bounds.fromJson(Map<String, dynamic>.from(json['viewport'] as Map)),
    locationType: json['location_type'] as String?,
    bounds: json['bounds'] == null
        ? null
        : Bounds.fromJson(Map<String, dynamic>.from(json['bounds'] as Map)),
  );
}

Map<String, dynamic> _$GoogleMapsGeometryToJson(GoogleMapsGeometry instance) =>
    <String, dynamic>{
      'location': instance.location.toJson(),
      'viewport': instance.viewport.toJson(),
      'bounds': instance.bounds?.toJson(),
      'location_type': instance.locationType,
    };

Bounds _$BoundsFromJson(Map json) {
  return Bounds(
    northeast: GoogleMapsLocation.fromJson(
        Map<String, dynamic>.from(json['northeast'] as Map)),
    southwest: GoogleMapsLocation.fromJson(
        Map<String, dynamic>.from(json['southwest'] as Map)),
  );
}

Map<String, dynamic> _$BoundsToJson(Bounds instance) => <String, dynamic>{
      'northeast': instance.northeast.toJson(),
      'southwest': instance.southwest.toJson(),
    };

GoogleMapsLocation _$GoogleMapsLocationFromJson(Map json) {
  return GoogleMapsLocation(
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );
}

Map<String, dynamic> _$GoogleMapsLocationToJson(GoogleMapsLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };
