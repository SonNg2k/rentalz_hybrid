import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentalz/models/apartment/apartment_model.dart';

class ApartmentRepo {
  ApartmentRepo._();

  static Stream<QuerySnapshot<ApartmentModel>> list() {
    return _apartmentListRef
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  static Future<DocumentReference<ApartmentModel>> add(ApartmentModel data) {
    return _apartmentListRef.add(data);
  }

  static Future update(String id, {required ApartmentModel data}) {
    return _apartmentListRef.doc(id).set(data, SetOptions(merge: true));
  }
}

final _apartmentListRef = FirebaseFirestore.instance
    .collection('apartments')
    .withConverter<ApartmentModel>(
      fromFirestore: (snapshot, _) => ApartmentModel.fromJson(snapshot.data()!),
      toFirestore: (doc, _) => doc.toJson(),
    );
