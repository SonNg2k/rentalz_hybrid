import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:rentalz/screens/apartment_list/flow_menu.dart';

class ApartmentListScreen extends StatelessWidget {
  const ApartmentListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _SearchFilterDrawer(),
      body: SafeArea(
        child: Stack(
          children: const [
            _SearchSection(),
            FlowMenu(),
          ],
        ),
      ),
    );
  }
}

class _SearchFilterDrawer extends StatefulWidget {
  const _SearchFilterDrawer({Key? key}) : super(key: key);

  @override
  State<_SearchFilterDrawer> createState() => _SearchFilterDrawerState();
}

class _SearchFilterDrawerState extends State<_SearchFilterDrawer> {
  Widget get apartmentTypeOptions {
    return Column(
      children: [
        Text(
          'Apartment types',
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    /// "A Drawer can contain any widget u like, but it's common to use a
    /// ListView with a DrawerHeader and ListTiles, which allows the user to
    /// scroll through the items" (from Flutter API Ref about the Drawer class).
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.secondary),
            child: Text(
              'Search Filter',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Colors.white, fontSize: 24),
            ),
          ),
          apartmentTypeOptions,
        ],
      ),
    );
  }
}

/// Find the apartments whose names contain the search keyword.
/// The search keyword is also used to find the apartments with reporters
/// whose names contain the keyword.
class _SearchSection extends StatefulWidget {
  const _SearchSection({Key? key}) : super(key: key);

  @override
  _SearchSectionState createState() => _SearchSectionState();
}

class _SearchSectionState extends State<_SearchSection> {
  final fsabController = FloatingSearchBarController();

  @override
  Widget build(BuildContext context) {
    /// The widget below is from the package material_floating_search_bar here
    /// https://pub.dev/packages/material_floating_search_bar
    return FloatingSearchAppBar(
      controller: fsabController,
      elevation: 8,
      automaticallyImplyBackButton: false,
      automaticallyImplyDrawerHamburger: false,
      transitionDuration: const Duration(seconds: 0),
      implicitDuration: const Duration(seconds: 0),

      /// The button below is a placeholder when the FSAP is closed and will
      /// be replaced by a search text field when the FSAP is opened.
      title: TextButton(
        style: TextButton.styleFrom(backgroundColor: Colors.white),
        onPressed: () => fsabController.open(),
        child: const SizedBox(
          width: 260,
          child: Text(
            'Name of property or reporter...',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color(0x99000000),
              fontSize: 16,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
      actions: [
        FloatingSearchBarAction.searchToClear(),
        IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.filter_alt_outlined),
        ),
      ],
      hint: 'Name of property or reporter...',
      onQueryChanged: (query) {},
      body: Container(),
    );
  }
}
