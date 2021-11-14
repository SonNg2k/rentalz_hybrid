import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentalz/models/apartment/apartment_model.dart';
import 'package:rentalz/navigation_service.dart';
import 'package:rentalz/widgets/input_formatters/numeric_text_input_formatter.dart';

class FilterSettingsDrawer extends StatefulWidget {
  const FilterSettingsDrawer({Key? key}) : super(key: key);

  @override
  State<FilterSettingsDrawer> createState() => _FilterSettingsDrawerState();
}

class _FilterSettingsDrawerState extends State<FilterSettingsDrawer> {
  final _comfortLevelFilterKey = GlobalKey<_ComfortLevelFilterState>();
  final _apartmentTypeFilterKey = GlobalKey<_ApartmentTypeFilterState>();
  final _monthlyRentPriceRangeFilterKey =
      GlobalKey<_MonthlyRentPriceRangeFilterState>();

  Column get _filterSettingsScrollView {
    final filterSubjectTextStyle = Theme.of(context).textTheme.bodyText1;
    return Column(
      children: [
        Text('Choose a comfort level', style: filterSubjectTextStyle),
        _ComfortLevelFilter(key: _comfortLevelFilterKey),
        const SizedBox(height: 16),
        Text('Choose up to 10 apartment types', style: filterSubjectTextStyle),
        _ApartmentTypeFilter(key: _apartmentTypeFilterKey),
        const SizedBox(height: 16),
        Text('Monthly price range', style: filterSubjectTextStyle),
        const SizedBox(height: 8),
        _MonthlyRentPriceRangeFilter(key: _monthlyRentPriceRangeFilterKey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    /// "A Drawer can contain any widget u like, but it's common to use a
    /// ListView with a DrawerHeader and ListTiles, which allows the user to
    /// scroll through the items" (from Flutter API Ref about the Drawer class).
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary),
                  child: Text(
                    'Filter results',
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: Colors.white, fontSize: 24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: _filterSettingsScrollView,
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black38, width: 0.4),
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _comfortLevelFilterKey.currentState!.reset();
                    _apartmentTypeFilterKey.currentState!.reset();
                    _monthlyRentPriceRangeFilterKey.currentState!.reset();
                  },
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: () {}, child: const Text('Apply')),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ComfortLevelFilter extends StatefulWidget {
  const _ComfortLevelFilter({Key? key}) : super(key: key);

  @override
  State<_ComfortLevelFilter> createState() => _ComfortLevelFilterState();
}

class _ComfortLevelFilterState extends State<_ComfortLevelFilter> {
  ComfortLevel? _selectedLevel;

  void reset() {
    setState(() => _selectedLevel = null);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ...[
          for (final level in ComfortLevel.values)
            ChoiceChip(
              label: Text(level.formattedString),
              labelStyle:
                  (level == _selectedLevel) ? _selectedChipTextStyle : null,
              selectedColor: _selectedChipColor,
              selected: level == _selectedLevel,
              onSelected: (selected) => setState(() {
                if (selected) _selectedLevel = level;
              }),
            )
        ].expand((widget) => [widget, const SizedBox(width: 8)])
      ],
    );
  }
}

class _ApartmentTypeFilter extends StatefulWidget {
  const _ApartmentTypeFilter({Key? key}) : super(key: key);

  @override
  State<_ApartmentTypeFilter> createState() => _ApartmentTypeFilterState();
}

class _ApartmentTypeFilterState extends State<_ApartmentTypeFilter> {
  final List<ApartmentType> _filters = <ApartmentType>[];

  void reset() {
    setState(() => _filters.clear());
  }

  /// Generate values on-demand when someone tries to iterate over the iterator.
  Iterable<FilterChip> get _filterOptions sync* {
    for (final type in ApartmentType.values) {
      yield FilterChip(
        label: Text(type.formattedString),
        labelStyle: _filters.contains(type) ? _selectedChipTextStyle : null,
        checkmarkColor: Theme.of(context).colorScheme.primary,
        selectedColor: _selectedChipColor,
        selected: _filters.contains(type),
        onSelected: (bool selected) {
          if (selected && _filters.length == 10) return;
          return setState(() {
            if (selected) {
              _filters.add(type);
            } else {
              _filters.removeWhere((value) => value == type);
            }
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ..._filterOptions.expand((widget) => [widget, const SizedBox(width: 8)])
      ],
    );
  }
}

class _MonthlyRentPriceRangeFilter extends StatefulWidget {
  const _MonthlyRentPriceRangeFilter({Key? key}) : super(key: key);

  @override
  State<_MonthlyRentPriceRangeFilter> createState() =>
      _MonthlyRentPriceRangeFilterState();
}

class _MonthlyRentPriceRangeFilterState
    extends State<_MonthlyRentPriceRangeFilter> {
  final _minInputController = TextEditingController();
  final _maxInputController = TextEditingController();

  void reset() {
    _minInputController.clear();
    _maxInputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => Scrollable.ensureVisible(context));
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: _minInputController,
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType:
                    const TextInputType.numberWithOptions(signed: true),
                placeholder: 'MIN',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  NumericTextInputFormatter(),
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
            ),
            const Text(' — '),
            Expanded(
              child: CupertinoTextField(
                controller: _maxInputController,
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType:
                    const TextInputType.numberWithOptions(signed: true),
                placeholder: 'MAX',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  NumericTextInputFormatter(),
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _minInputController.dispose();
    _maxInputController.dispose();
  }
}

final _selectedChipColor =
    Theme.of(NavigationService.navigatorKey.currentContext!)
        .colorScheme
        .secondary
        .withOpacity(0.2);

final _selectedChipTextStyle = TextStyle(
    color: Theme.of(NavigationService.navigatorKey.currentContext!)
        .colorScheme
        .primary,
    fontWeight: FontWeight.w500);
