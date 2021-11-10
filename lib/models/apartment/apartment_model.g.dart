// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apartment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApartmentModel _$ApartmentModelFromJson(Map json) => ApartmentModel(
      name: json['name'] as String,
      reporterName: json['reporter_name'] as String,
      formattedAddress: json['formatted_address'] as String,
      addressComponents: AddressComponents.fromJson(
          Map<String, dynamic>.from(json['address_components'] as Map)),
      type: $enumDecode(_$ApartmentTypeEnumMap, json['type']),
      comfortLevel: $enumDecode(_$ComfortLevelEnumMap, json['comfort_level']),
      monthlyRent: json['monthly_rent'] as int,
      nBedrooms: json['n_bedrooms'] as int,
      note: json['note'] as String?,
      creatorId: json['creator_id'] as String,
      createdAt:
          ApartmentModel._fromJsonTimestamp(json['created_at'] as Timestamp),
    );

Map<String, dynamic> _$ApartmentModelToJson(ApartmentModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'reporter_name': instance.reporterName,
      'formatted_address': instance.formattedAddress,
      'address_components': instance.addressComponents.toJson(),
      'type': _$ApartmentTypeEnumMap[instance.type],
      'comfort_level': _$ComfortLevelEnumMap[instance.comfortLevel],
      'monthly_rent': instance.monthlyRent,
      'n_bedrooms': instance.nBedrooms,
      'note': instance.note,
      'creator_id': instance.creatorId,
      'created_at': ApartmentModel._toJsonTimestamp(instance.createdAt),
    };

const _$ApartmentTypeEnumMap = {
  ApartmentType.studio: 'studio',
  ApartmentType.duplex: 'duplex',
  ApartmentType.triplex: 'triplex',
  ApartmentType.garden: 'garden',
  ApartmentType.loft: 'loft',
  ApartmentType.penthouse: 'penthouse',
  ApartmentType.micro: 'micro',
  ApartmentType.walkUp: 'walkUp',
  ApartmentType.basement: 'basement',
  ApartmentType.coOp: 'coOp',
  ApartmentType.highRise: 'highRise',
  ApartmentType.midRise: 'midRise',
  ApartmentType.lowRise: 'lowRise',
};

const _$ComfortLevelEnumMap = {
  ComfortLevel.furnished: 'furnished',
  ComfortLevel.semiFurnished: 'semiFurnished',
  ComfortLevel.unfurnished: 'unfurnished',
};

AddressComponents _$AddressComponentsFromJson(Map json) => AddressComponents(
      level1Id: json['level1_id'] as String,
      level2Id: json['level2_id'] as String,
      level3Id: json['level3_id'] as String?,
      route: json['route'] as String,
    );

Map<String, dynamic> _$AddressComponentsToJson(AddressComponents instance) =>
    <String, dynamic>{
      'level1_id': instance.level1Id,
      'level2_id': instance.level2Id,
      'level3_id': instance.level3Id,
      'route': instance.route,
    };
