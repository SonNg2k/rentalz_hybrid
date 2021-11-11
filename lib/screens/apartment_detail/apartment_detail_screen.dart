import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentalz/models/apartment/apartment_model.dart';
import 'package:rentalz/navigation_service.dart';
import 'package:rentalz/screens/save_apartment/save_apartment_screen.dart';

class ApartmentDetailScreen extends StatefulWidget {
  const ApartmentDetailScreen({
    Key? key,
    required this.apartmentRef,
  }) : super(key: key);

  final DocumentReference<ApartmentModel> apartmentRef;

  @override
  State<ApartmentDetailScreen> createState() => _ApartmentDetailScreenState();
}

class _ApartmentDetailScreenState extends State<ApartmentDetailScreen> {
  Stream<DocumentSnapshot<ApartmentModel>>? apartmentStream;

  @override
  void initState() {
    super.initState();
    apartmentStream = widget.apartmentRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More details'),
      ),
      body: SafeArea(
        child: Center(
          child: StreamBuilder<DocumentSnapshot<ApartmentModel>>(
            stream: apartmentStream!,
            builder: (_, snapshot) {
              if (snapshot.hasError) return const Text('Something went wrong');

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator.adaptive();
              }
              final id = snapshot.data!.id;
              final data = snapshot.data!.data()!;
              return Scrollbar(
                child: SingleChildScrollView(
                  child: _DetailCard(apartmentId: id, apartmentData: data),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    Key? key,
    required this.apartmentId,
    required this.apartmentData,
  }) : super(key: key);

  final String apartmentId;
  final ApartmentModel apartmentData;

  ListTile _listTile(Widget icon, String title, [Widget? subtitle]) {
    return ListTile(
      horizontalTitleGap: 0,
      leading: icon,
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: subtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: ContinuousRectangleBorder(
        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Text(
            apartmentData.name,
            style: Theme.of(context).textTheme.headline6,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          _listTile(
              const Icon(Icons.person_outline), apartmentData.reporterName),

          /// TODO open the address in default map app and add note
          _listTile(
            const Icon(Icons.map_outlined),
            apartmentData.formattedAddress,
            TextButton(
              onPressed: () {},
              child: const Text('View this place on Maps'),
            ),
          ),
          _listTile(
            const Icon(Icons.house_outlined),
            apartmentData.type.formattedString,
          ),
          _listTile(
            const Icon(Icons.category_outlined),
            apartmentData.comfortLevel.formattedString,
          ),
          //TODO change the icon to price tag and add $ here
          _listTile(
            const Icon(Icons.attach_money_outlined),
            '${NumberFormat("#,###").format(apartmentData.monthlyRent)}/month',
          ),
          _listTile(const Icon(Icons.bed_outlined),
              apartmentData.nBedrooms.toString()),
          //TODO add creation date
          if (apartmentData.note != null && apartmentData.note!.isNotEmpty)
            const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 10),
              if (apartmentData.note != null && apartmentData.note!.isNotEmpty)
                TextButton(
                  onPressed: () {},
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SHOW NOTE',
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              const Spacer(),
              IconButton(
                onPressed: () => NavigationService.pushNewPage(
                  SaveApartmentScreen(
                    apartmentId: apartmentId,
                    initialData: apartmentData,
                  ),
                ),
                icon: Icon(Icons.edit, color: Theme.of(context).hintColor),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
