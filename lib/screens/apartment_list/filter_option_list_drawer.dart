import 'package:flutter/material.dart';

class FilterOptionListDrawer extends StatefulWidget {
  const FilterOptionListDrawer({Key? key}) : super(key: key);

  @override
  State<FilterOptionListDrawer> createState() =>
      FilterOptionListDrawerState();
}

class FilterOptionListDrawerState extends State<FilterOptionListDrawer> {
  Widget get _apartmentTypeOptions {
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
              'Filter options',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Colors.white, fontSize: 24),
            ),
          ),
          _apartmentTypeOptions,
        ],
      ),
    );
  }
}
