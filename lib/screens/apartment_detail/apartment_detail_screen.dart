import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:rentalz/alert_service.dart';
import 'package:rentalz/models/apartment/apartment_model.dart';
import 'package:rentalz/navigation_service.dart';
import 'package:rentalz/repo/apartment_repo.dart';
import 'package:rentalz/screens/save_apartment/save_apartment_screen.dart';
import 'package:rentalz/widgets/expansion_section.dart';

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
  late final Stream<DocumentSnapshot<ApartmentModel>> apartmentStream;

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
            stream: apartmentStream,
            builder: (_, snapshot) {
              if (snapshot.hasError) return const Text('Something went wrong');

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator.adaptive();
              }
              final id = snapshot.data!.id;
              final data = snapshot.data!.data();
              if (data == null) return Container();
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

  ListTile get _creationTsListTile {
    final createdAt = apartmentData.createdAt.toDate();
    final friendlyDate = DateFormat.yMMMMEEEEd().format(createdAt);
    final friendlyTime = DateFormat.jm().format(createdAt);
    return _listTile(
      const Icon(Icons.history_outlined),
      '$friendlyDate ($friendlyTime)',
    );
  }

  ExpansionSection get _cardActionArea2 {
    final globalContext = NavigationService.navigatorKey.currentContext!;
    return ExpansionSection(
      /// On rebuild due to real-time update of the note, a new UniqueKey is
      /// generated, which will cause the old state assigned with the old
      /// UniqueKey to be discarded and the new state assigned with a new
      /// UniqueKey is created with state.isOpen == false.
      key: UniqueKey(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: RichText(
          text: TextSpan(
            style: Theme.of(globalContext)
                .textTheme
                .bodyText2!
                .copyWith(fontSize: 16, height: 2),
            children: [
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.note_outlined, color: Colors.grey),
                ),
              ),
              TextSpan(text: apartmentData.note!),
            ],
          ),
        ),
      ),
      bottomBuilder: (state) => Column(
        children: [
          const Divider(),
          Row(
            children: [
              const SizedBox(width: 10),
              if (apartmentData.note != null && apartmentData.note!.isNotEmpty)
                TextButton(
                  onPressed: () => state.toggle(),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      state.isOpen ? 'HIDE NOTE' : 'SHOW NOTE',
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
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(globalContext).hintColor,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () async {
                  final isConfirmed = await AlertService.showConfirmationDialog(
                    title: const Text('Delete apartment'),
                    content: const Text(
                        'This item will be permanently deleted and its data cannot be recovered.'),
                  );
                  if (isConfirmed) {
                    await ApartmentRepo.delete(apartmentId);
                    Navigator.pop(globalContext);
                    AlertService.showEphemeralSnackBar(
                        'The item is successfully deleted ✅');
                  }
                },
                icon: Icon(
                  Icons.delete_forever,
                  color: Theme.of(globalContext).hintColor,
                ),
              ),
            ],
          ),
        ],
      ),
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
          _listTile(
            const Icon(Icons.map_outlined),
            apartmentData.formattedAddress,
            TextButton(
              onPressed: () =>
                  MapsLauncher.launchQuery(apartmentData.formattedAddress),
              child: const Text('View this place in Maps'),
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
          _listTile(
            const Icon(Icons.local_offer_outlined),
            '\$${NumberFormat("#,###").format(apartmentData.monthlyRent)}/month',
          ),
          _listTile(const Icon(Icons.bed_outlined),
              apartmentData.nBedrooms.toString()),
          _creationTsListTile,
          _cardActionArea2,
        ],
      ),
    );
  }
}
