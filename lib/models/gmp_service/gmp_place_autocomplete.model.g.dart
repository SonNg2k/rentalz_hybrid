// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmp_place_autocomplete.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleMapsPlaceAutocomplete _$GoogleMapsPlaceAutocompleteFromJson(Map json) {
  return GoogleMapsPlaceAutocomplete(
    placeId: json['place_id'] as String,
    description: json['description'] as String,
    structuredFormatting: StructuredFormatting.fromJson(
        Map<String, dynamic>.from(json['structured_formatting'] as Map)),
  );
}

Map<String, dynamic> _$GoogleMapsPlaceAutocompleteToJson(
        GoogleMapsPlaceAutocomplete instance) =>
    <String, dynamic>{
      'place_id': instance.placeId,
      'description': instance.description,
      'structured_formatting': instance.structuredFormatting.toJson(),
    };

StructuredFormatting _$StructuredFormattingFromJson(Map json) {
  return StructuredFormatting(
    mainText: json['main_text'] as String,
    secondaryText: json['secondary_text'] as String,
  );
}

Map<String, dynamic> _$StructuredFormattingToJson(
        StructuredFormatting instance) =>
    <String, dynamic>{
      'main_text': instance.mainText,
      'secondary_text': instance.secondaryText,
    };
