import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentalz/models/apartment/apartment_model.dart';

class ApartmentRepo {
  ApartmentRepo._();

  static Future<DocumentReference<ApartmentModel>> add(ApartmentModel data) {
    return _apartmentListRef.add(data);
  }
}

final _apartmentListRef = FirebaseFirestore.instance
    .collection('apartments')
    .withConverter<ApartmentModel>(
      fromFirestore: (snapshot, _) => ApartmentModel.fromJson(snapshot.data()!),
      toFirestore: (doc, _) => doc.toJson(),
    );
