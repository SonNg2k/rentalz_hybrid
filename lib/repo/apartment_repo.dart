import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rentalz/models/apartment/apartment_model.dart';

class ApartmentRepo {
  ApartmentRepo._();

  /// You can use at most one 'in' clause per query.
  /// You can't order your query by a field included in an equality (==) or 'in'
  /// clause.
  /// Cloud Firestore provides limited support for logical OR queries. The 'in'
  /// operator supports a logical OR of up to 10 equality (==) on a single field.
  /// For other cases, create a separate query for each OR condition and merge
  /// the query results in your app.
  ///
  /// You can chain multiple equality operators (==) methods to create more
  /// specific queries (logical AND). However, you must create a composite index
  /// to combine equality operators with the inequality operators (<, <=, >, >=, and !=).
  ///
  /// In a compound query, range (<, <=, >, >=) and not equals (!=, not-in)
  /// comparisons must all filter on the same field.
  static Stream<QuerySnapshot<ApartmentModel>> list(
      [List<FilterOption> filters = const []]) {
    Query<ApartmentModel> query = _apartmentListRef.where('creator_id',
        isEqualTo: FirebaseAuth.instance.currentUser!.uid);

    for (final filter in filters) {
      switch (filter.whereQuery) {
        case ApartmentWhereQuery.comfortLevel:
          query = query.comfortLevelFilter(filter.value);
          break;
        case ApartmentWhereQuery.apartmentTypes:
          query = query.apartmentTypeFilter(filter.value);
          break;
        case ApartmentWhereQuery.monthlyPriceRange:
          query = query.monthlyRentalPriceRangeFilter(filter.value);
      }
    }

    /// .orderBy() should be the last part of the query...
    if (_priceRangeFilterIsPresent(filters)) {
      /// When an inequality operator is applied on a particular field,
      /// orderBy() must also be applied on this same field or an error
      /// will be thrown. Therefore, u must order by 'monthly_rent' when
      /// the user want to filter results by 'monthly_rent'
      query = query.orderBy('monthly_rent', descending: true);
    } else {
      query = query.orderBy('created_at', descending: true);
    }
    return query.snapshots();
  }

  static Future<DocumentReference<ApartmentModel>> add(
      ApartmentModel data) async {
    final errMsg = await _checkForDuplicateApartment(
      sanitizedName: data.sanitizedName,
      sanitizedAddress: data.sanitizedAddress,
    );
    if (errMsg != null) return Future.error(errMsg);
    return _apartmentListRef.add(data);
  }

  static Future<void> update(String id, {required ApartmentModel data}) async {
    final errMsg = await _checkForDuplicateApartment(
      sanitizedName: data.sanitizedName,
      sanitizedAddress: data.sanitizedAddress,
      idOfUpdatedItem: id,
    );
    if (errMsg != null) return Future.error(errMsg);
    return _apartmentListRef.doc(id).set(data, SetOptions(merge: true));
  }

  static Future<void> delete(String id) {
    return _apartmentListRef.doc(id).delete();
  }
}

/// The different ways that we can filter/sort apartments
enum ApartmentWhereQuery {
  comfortLevel,
  apartmentTypes,
  monthlyPriceRange,
}

/// Create a Firestore query from a [ApartmentWhereQuery]
extension on Query<ApartmentModel> {
  Query<ApartmentModel> comfortLevelFilter(ComfortLevel value) {
    return where('comfort_level', isEqualTo: describeEnum(value));
  }

  Query<ApartmentModel> apartmentTypeFilter(List<ApartmentType> values) {
    return where(
      'type',
      whereIn: values.map((value) => describeEnum(value)).toList(),
    );
  }

  Query<ApartmentModel> monthlyRentalPriceRangeFilter(PriceRange value) {
    return where('monthly_rent', isGreaterThanOrEqualTo: value.min)
        .where('monthly_rent', isLessThanOrEqualTo: value.max);
  }
}

class FilterOption<T> {
  const FilterOption({required this.whereQuery, required this.value});
  final ApartmentWhereQuery whereQuery;

  /// The data structure of value varies depending on the type of filter query.
  final T value;
}

bool _priceRangeFilterIsPresent(List<FilterOption> filters) {
  final priceRangeFilter = filters.where(
      (filter) => filter.whereQuery == ApartmentWhereQuery.monthlyPriceRange);
  return priceRangeFilter.isNotEmpty;
}

class PriceRange {
  const PriceRange({required this.min, required this.max});
  final int min;
  final int max;
}

Future<String?> _checkForDuplicateApartment({
  required String sanitizedName,
  required String sanitizedAddress,
  String? idOfUpdatedItem,
}) async {
  final names = await _apartmentListRef
      .where('sanitized_name', isEqualTo: sanitizedName)
      .get();
  if (names.docs.isNotEmpty && names.docs[0].id != idOfUpdatedItem) {
    return 'There is already an apartment item with this name.';
  }
  final addressList = await _apartmentListRef
      .where('sanitized_address', isEqualTo: sanitizedAddress)
      .get();
  if (addressList.docs.isNotEmpty &&
      addressList.docs[0].id != idOfUpdatedItem) {
    return 'There is already an apartment item at this location.';
  }
}

final _apartmentListRef = FirebaseFirestore.instance
    .collection('apartments')
    .withConverter<ApartmentModel>(
      fromFirestore: (snapshot, _) => ApartmentModel.fromJson(snapshot.data()!),
      toFirestore: (doc, _) => doc.toJson(),
    );
