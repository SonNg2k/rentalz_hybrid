import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentalz/models/apartment/apartment_model.dart';

class ApartmentRepo {
  ApartmentRepo._();

  static Stream<QuerySnapshot<ApartmentModel>> list() {
    return _apartmentListRef
        .orderBy('created_at', descending: true)
        .snapshots();
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
