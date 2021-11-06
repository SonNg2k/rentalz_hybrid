import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:rentalz/models/gmp_service/gmp_place_autocomplete.model.dart';
import 'package:rentalz/services/gmp_service/find_geo_location_by_place_id.service.dart';
import 'package:rentalz/services/gmp_service/predict_similar_places.service.dart';

/// Return a geographic location picked by the user from a list of autocomplete
/// suggestions for location
class PickLocationScreen extends StatelessWidget {
  const PickLocationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      /// If [resizeToAvoidBottomInset] is true, the expandable body will first
      /// reduce its size to make room for the on-screen keyboard -> white
      /// background of the [Scaffold] at the bottom -> keyboard pops up.
      resizeToAvoidBottomInset: false,
      body: LocationSearchBar(),
    );
  }
}

class LocationSearchBar extends StatefulWidget {
  const LocationSearchBar({Key? key}) : super(key: key);

  @override
  _LocationSearchBarState createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  final controller = FloatingSearchBarController();
  bool isLoading = false;
  List<GoogleMapsPlaceAutocomplete> placePredictions = [];

  @override
  Widget build(BuildContext context) {
    /// [isPortrait = MediaQueryData.orientation == Orientation.portrait]
    /// [axisAlignment: isPortrait ? 0.0 : -1.0], avaiable width > width
    /// [width: isPortrait ? 600 : 500], max width of FSB

    /// Unless [isScrollControlled] is set to true, the expandable body of a
    /// FloatingSearchBar must not have an unbounded height, meaning that
    /// [shrinkWrap] should be set to true on all [Scrollable]s
    /// Read 'Usage with Scrollables' in the doc

    return FloatingSearchBar(
      controller: controller,
      progress: isLoading,
      hint: 'Find your location here...',

      /// [bottom] of [scrollPadding] is the distance from the top of
      /// the on-screen keyboard to the bottom of the expandable body
      scrollPadding: const EdgeInsets.only(top: 8, bottom: 16),
      openAxisAlignment: 0.0,
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOutCubic,
      physics: const BouncingScrollPhysics(),
      debounceDelay: const Duration(milliseconds: 800),
      clearQueryOnClose: true,
      onQueryChanged: (input) async {
        setState(() => isLoading = true);
        final predictions = await predictSimilarPlaces(input);
        setState(() {
          isLoading = false;
          placePredictions = predictions;
        });
      },
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () => controller.open(),
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],

      /// The expandable body returned by [FloatingSearchBar.builder]
      /// is nested inside a scrollable.
      builder: (context, transition) => Material(
        color: Colors.white,
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8),
        child: ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: placePredictions.length,
          itemBuilder: (context, index) => InkWell(
            onTap: () async {
              final location = await findGeoLocationByPlaceId(
                  placePredictions[index].placeId);
              Navigator.pop(context, location);
            },
            child: ListTile(
              title:
                  Text(placePredictions[index].structuredFormatting.mainText),
              subtitle: Text(
                  placePredictions[index].structuredFormatting.secondaryText),
              leading: const Icon(Icons.place),
            ),
          ),
          separatorBuilder: (_, __) => const Divider(thickness: 1),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// A local geographic location that is constructed based on Google Maps
/// Platform's response or the native Location API
class GeoLocation {
  const GeoLocation({
    required this.placeId,
    required this.latitule,
    required this.longitude,
    required this.address,
  });

  /// A textual identifier that uniquely identifies a place on Google Maps
  final String placeId;
  final double latitule;
  final double longitude;
  final String address;
}
