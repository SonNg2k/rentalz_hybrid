import 'package:json_annotation/json_annotation.dart';

part 'gmp_place_autocomplete.model.g.dart';

/// Models used to parse the JSON predictions from the Google Maps Platform
/// Autocomplete API. Documentation here: https://developers.google.com/maps/documentation/places/web-service/autocomplete#place_autocomplete_results
///
/// These models are only used to read JSON from the API, not used to send
/// JSON over the internet. However, toJson() methods are added to
/// turn off the linter warnings.
@JsonSerializable(anyMap: true, explicitToJson: true)
class GoogleMapsPlaceAutocomplete {
  @JsonKey(name: 'place_id')
  final String placeId;

  final String description;

  @JsonKey(name: 'structured_formatting')
  final StructuredFormatting structuredFormatting;

  GoogleMapsPlaceAutocomplete({
    required this.placeId,
    required this.description,
    required this.structuredFormatting,
  });

  factory GoogleMapsPlaceAutocomplete.fromJson(Map<String, dynamic> json) =>
      _$GoogleMapsPlaceAutocompleteFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleMapsPlaceAutocompleteToJson(this);
}

@JsonSerializable(anyMap: true, explicitToJson: true)
class StructuredFormatting {
  @JsonKey(name: 'main_text')
  final String mainText;

  @JsonKey(name: 'secondary_text')
  final String secondaryText;

  StructuredFormatting({
    required this.mainText,
    required this.secondaryText,
  });

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) =>
      _$StructuredFormattingFromJson(json);

  Map<String, dynamic> toJson() => _$StructuredFormattingToJson(this);
}
