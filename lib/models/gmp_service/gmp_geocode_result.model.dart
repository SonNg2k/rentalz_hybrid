import 'package:json_annotation/json_annotation.dart';

import 'gmp_geometry.model.dart';

part 'gmp_geocode_result.model.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class GoogleMapsGeocodeResult {
  GoogleMapsGeocodeResult({
    required this.formattedAddress,
    required this.geometry,
    required this.placeId,
  });

  @JsonKey(name: 'formatted_address')
  final String formattedAddress;

  @JsonKey(name: 'place_id')
  final String placeId;

  final GoogleMapsGeometry geometry;

  factory GoogleMapsGeocodeResult.fromJson(Map<String, dynamic> json) =>
      _$GoogleMapsGeocodeResultFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleMapsGeocodeResultToJson(this);
}
