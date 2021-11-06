import 'package:json_annotation/json_annotation.dart';

part 'gmp_geometry.model.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class GoogleMapsGeometry {
  GoogleMapsGeometry({
    required this.location,
    required this.viewport,
    this.locationType,
    this.bounds,
  });

  final GoogleMapsLocation location;
  final Bounds viewport;
  final Bounds? bounds;

  @JsonKey(name: 'location_type')
  final String? locationType;

  factory GoogleMapsGeometry.fromJson(Map<String, dynamic> json) =>
      _$GoogleMapsGeometryFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleMapsGeometryToJson(this);
}

@JsonSerializable(anyMap: true, explicitToJson: true)
class Bounds {
  Bounds({
    required this.northeast,
    required this.southwest,
  });

  final GoogleMapsLocation northeast;
  final GoogleMapsLocation southwest;

  factory Bounds.fromJson(Map<String, dynamic> json) => _$BoundsFromJson(json);

  Map<String, dynamic> toJson() => _$BoundsToJson(this);
}

@JsonSerializable(anyMap: true, explicitToJson: true)
class GoogleMapsLocation {
  GoogleMapsLocation({
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  factory GoogleMapsLocation.fromJson(Map<String, dynamic> json) =>
      _$GoogleMapsLocationFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleMapsLocationToJson(this);
}
