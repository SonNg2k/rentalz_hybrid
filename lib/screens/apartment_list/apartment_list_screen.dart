import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:rentalz/models/apartment/apartment_model.dart';
import 'package:rentalz/navigation_service.dart';
import 'package:rentalz/repo/apartment_repo.dart';
import 'package:rentalz/screens/apartment_detail/apartment_detail_screen.dart';
import 'package:rentalz/screens/apartment_list/flow_menu.dart';
import 'package:rentalz/utils/my_string_extension.dart';

import 'filter_settings_drawer.dart';

class ApartmentListScreen extends StatefulWidget {
  const ApartmentListScreen({Key? key}) : super(key: key);

  @override
  State<ApartmentListScreen> createState() => _ApartmentListScreenState();
}

class _ApartmentListScreenState extends State<ApartmentListScreen> {
  final List<FilterOption> _filters = [];

  void _updateFilter(List<FilterOption> options) {
    _clearFilter();
    setState(() => _filters.addAll(options));
  }

  void _clearFilter() {
    setState(() => _filters.clear());
  }

  Widget get _mainContent {
    return Center(
      child: StreamBuilder<QuerySnapshot<ApartmentModel>>(
        stream: ApartmentRepo.list(_filters),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator.adaptive();
          }

          final apartments = snapshot.data?.docs ?? [];
          return _SearchAndShowResultSection(
            apartments: apartments,
            filterIsNull: _filters.isEmpty,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        drawer: FilterSettingsDrawer(
          filters: _filters,
          onClear: _clearFilter,
          onApply: _updateFilter,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              _mainContent,
              const FlowMenu(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Find the apartments whose names contain the search by address/apartment name....
/// The search by address/apartment name... is also used to find the apartments
/// with reporters whose names contain the keyword.
class _SearchAndShowResultSection extends StatefulWidget {
  const _SearchAndShowResultSection({
    Key? key,
    required this.apartments,
    required this.filterIsNull,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<ApartmentModel>> apartments;

  /// Highlight the filter icon button if filter exists.
  final bool filterIsNull;

  @override
  _SearchAndShowResultSectionState createState() =>
      _SearchAndShowResultSectionState();
}

class _SearchAndShowResultSectionState
    extends State<_SearchAndShowResultSection> {
  final _fsabController = FloatingSearchBarController();
  List<QueryDocumentSnapshot<ApartmentModel>> _apartmentListToShow = [];

  void _findItemsRelevantToSearchTerm(String term) {
    if (term.trim().isEmpty) {
      return setState(() => _apartmentListToShow = widget.apartments);
    }
    setState(
      () => _apartmentListToShow = widget.apartments.where((snapshot) {
        final data = snapshot.data();
        return data.name.isRelevantTo(term) ||
            data.formattedAddress.isRelevantTo(term);
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _apartmentListToShow = widget.apartments;
  }

  @override
  Widget build(BuildContext context) {
    /// The widget below is from the package material_floating_search_bar here
    /// https://pub.dev/packages/material_floating_search_bar
    return FloatingSearchAppBar(
      controller: _fsabController,
      elevation: 8,
      automaticallyImplyBackButton: false,
      automaticallyImplyDrawerHamburger: false,
      transitionDuration: const Duration(seconds: 0),
      implicitDuration: const Duration(seconds: 0),

      /// The button below is a placeholder when the FSAP is closed and will
      /// be replaced by a search text field when the FSAP is opened.
      title: TextButton(
        style: TextButton.styleFrom(backgroundColor: Colors.white),
        onPressed: () => _fsabController.open(),
        child: const SizedBox(
          width: 260,
          child: Text(
            'Search by name or address...',
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
        Theme(
          data: ThemeData(
            iconTheme: (widget.filterIsNull)
                ? Theme.of(context).iconTheme
                : IconThemeData(color: Theme.of(context).colorScheme.secondary),
          ),
          child: Stack(
            children: [
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.filter_alt_outlined),
              ),
              if (!widget.filterIsNull)
                const Positioned(
                  top: 8,
                  right: 0,
                  child: Icon(Icons.check_circle, size: 16),
                )
            ],
          ),
        ),
      ],
      hint: 'Search by name or address...',
      onQueryChanged: _findItemsRelevantToSearchTerm,
      body: (_apartmentListToShow.isNotEmpty)
          ? Scrollbar(
              child: _ApartmentListView(apartmentList: _apartmentListToShow),
            )
          : const Center(
              child: Text('No apartments found 🤣.', textAlign: TextAlign.left),
            ),
    );
  }

  @override
  void didUpdateWidget(covariant _SearchAndShowResultSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// When the widget.apartmentList is updated in real-time due to
    /// StreamBuilder()...
    _apartmentListToShow = widget.apartments;

    /// New list detected, pick the apartment items relevant to the search
    /// keyword...
    _findItemsRelevantToSearchTerm(_fsabController.query);
  }

  @override
  void dispose() {
    super.dispose();
    _fsabController.dispose();
  }
}

class _ApartmentListView extends StatelessWidget {
  const _ApartmentListView({
    Key? key,
    required this.apartmentList,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<ApartmentModel>> apartmentList;

  RichText _formattedAddressText(String formattedAddress) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: _hintColor),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(Icons.map_outlined, size: 16, color: _hintColor),
          ),
          TextSpan(text: formattedAddress),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }

  RichText _apartmentTypeText(ApartmentType type) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: _hintColor),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(Icons.house_outlined, size: 16, color: _hintColor),
          ),
          TextSpan(text: type.formattedString),
        ],
      ),
    );
  }

  RichText _nBedroomsText(int nBedrooms) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: _hintColor),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(Icons.bed, size: 16, color: _hintColor),
          ),
          TextSpan(text: nBedrooms.toString()),
        ],
      ),
    );
  }

  RichText _monthlyRentText(int monthlyRent) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: _hintColor),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child:
                Icon(Icons.attach_money_outlined, size: 16, color: _hintColor),
          ),
          TextSpan(
            text: '${NumberFormat("#,###").format(monthlyRent)}/mo',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      itemCount: apartmentList.length,
      itemBuilder: (_, index) {
        final apartmentId = apartmentList[index].id;
        final data = apartmentList[index].data();
        return Card(
          key: ValueKey(apartmentId),
          elevation: 4,
          shape: ContinuousRectangleBorder(
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              NavigationService.pushNewPage(
                ApartmentDetailScreen(
                    apartmentRef: apartmentList[index].reference),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    horizontalTitleGap: 0,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    isThreeLine: true,
                    title: Text(
                      data.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: _formattedAddressText(data.formattedAddress),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _apartmentTypeText(data.type),
                    const SizedBox(height: 4),
                    _nBedroomsText(data.nBedrooms),
                    const SizedBox(height: 4),
                    _monthlyRentText(data.monthlyRent),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
    );
  }
}

final _hintColor =
    Theme.of(NavigationService.navigatorKey.currentContext!).hintColor;
