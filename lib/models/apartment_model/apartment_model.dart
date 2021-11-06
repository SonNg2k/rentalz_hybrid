/// The technique that I use below to convert Dart native data structures to
/// and from JSON is from here:
/// https://flutter.dev/docs/development/data-and-backend/json
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'apartment_model.g.dart';

enum ApartmentType {
  studio,
  duplex,
  triplex,
  garden,
  loft,
  penthouse,
  micro,
  walkUp,
  basement,
  coOp,
  highRise,
  midRise,
  lowRise,
}

extension ComfortLevelExtension on ComfortLevel {
  String get formattedString {
    switch (this) {
      case ComfortLevel.furnished:
        return "Furnished";
      case ComfortLevel.semiFurnished:
        return "Semi-furnished";

      case ComfortLevel.unfurnished:
        return "Unfurnished";
    }
  }
}

enum ComfortLevel {
  furnished,
  semiFurnished,
  unfurnished,
}

@JsonSerializable(anyMap: true, explicitToJson: true)
class ApartmentModel {
  ApartmentModel({
    required this.name,
    required this.reporterName,
    required this.formattedAddress,
    required this.addressComponents,
    required this.type,
    required this.comfortLevel,
    required this.monthlyRent,
    required this.nBedrooms,
    this.note,
    required this.createdAt,
  });

  final String name;

  @JsonKey(name: 'reporter_name')
  final String reporterName;

  @JsonKey(name: 'formatted_address')
  final String formattedAddress;

  @JsonKey(name: 'address_components')
  final AddressComponents addressComponents;

  final ApartmentType type;

  @JsonKey(name: 'comfort_level')
  final ComfortLevel comfortLevel;

  @JsonKey(name: 'monthly_rent')
  final int monthlyRent;

  @JsonKey(name: 'n_bedrooms')
  final int nBedrooms;

  final String? note;

  @JsonKey(
    name: 'created_at',
    fromJson: _fromJsonTimestamp,
    toJson: _toJsonTimestamp,
  )
  final Timestamp createdAt;

  factory ApartmentModel.fromJson(Map<String, dynamic> json) =>
      _$ApartmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApartmentModelToJson(this);

  static Timestamp _fromJsonTimestamp(Timestamp ts) => ts;
  static Timestamp _toJsonTimestamp(Timestamp ts) => ts;
}

/// The address components are based on this repo
/// https://github.com/daohoangson/dvhcvn
@JsonSerializable(anyMap: true, explicitToJson: true)
class AddressComponents {
  AddressComponents({
    required this.level1Id,
    required this.level2Id,
    required this.level3Id,
    required this.route,
  });

  /// The unique code for the province or city.
  @JsonKey(name: 'level1_id')
  final String level1Id;

  /// The unique code for the city, district, huyện, or thị xã.
  @JsonKey(name: 'level2_id')
  final String level2Id;

  /// The unique code for ward, xã, or thị trấn.
  @JsonKey(name: 'level3_id')
  final String level3Id;

  final String route;

  factory AddressComponents.fromJson(Map<String, dynamic> json) =>
      _$AddressComponentsFromJson(json);

  Map<String, dynamic> toJson() => _$AddressComponentsToJson(this);
}
