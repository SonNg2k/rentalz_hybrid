import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rentalz/models/apartment/apartment_model.dart';
import 'package:rentalz/navigation_service.dart';
import 'package:rentalz/repo/apartment_repo.dart';
import 'package:rentalz/widgets/input_formatters/numeric_text_input_formatter.dart';

class FilterSettingsDrawer extends StatefulWidget {
  const FilterSettingsDrawer({
    Key? key,
    required this.filters,
    required this.onClear,
    required this.onApply,
  }) : super(key: key);

  final List<FilterOption> filters;
  final void Function() onClear;
  final void Function(List<FilterOption>) onApply;

  @override
  State<FilterSettingsDrawer> createState() => _FilterSettingsDrawerState();
}

class _FilterSettingsDrawerState extends State<FilterSettingsDrawer> {
  final _comfortLevelFilterKey = GlobalKey<_ComfortLevelFilterState>();
  final _apartmentTypeFilterKey = GlobalKey<_ApartmentTypeFilterState>();
  final _monthlyRentalPriceRangeFilterKey =
      GlobalKey<_MonthlyRentalPriceRangeFilterState>();

  Column get _filterSettingsScrollView {
    final filterSubjectTextStyle = Theme.of(context).textTheme.bodyText1;
    final comfortLevelFilter = widget.filters.where(
        (filter) => filter.whereQuery == ApartmentWhereQuery.comfortLevel);
    final apartmentTypeFilter = widget.filters.where(
        (filter) => filter.whereQuery == ApartmentWhereQuery.apartmentTypes);
    final priceRangeFilter = widget.filters.where(
        (filter) => filter.whereQuery == ApartmentWhereQuery.monthlyPriceRange);

    return Column(
      children: [
        Text('Choose a comfort level', style: filterSubjectTextStyle),
        _ComfortLevelFilter(
          key: _comfortLevelFilterKey,
          initialValue: (comfortLevelFilter.isNotEmpty)
              ? comfortLevelFilter.first.value
              : null,
        ),
        const SizedBox(height: 16),
        Text('Choose up to 10 apartment types', style: filterSubjectTextStyle),
        _ApartmentTypeFilter(
          key: _apartmentTypeFilterKey,
          initialValues: (apartmentTypeFilter.isNotEmpty)
              ? apartmentTypeFilter.first.value
              : null,
        ),
        const SizedBox(height: 16),
        Text('Monthly rental price range', style: filterSubjectTextStyle),
        const SizedBox(height: 8),
        _MonthlyRentalPriceRangeFilter(
          key: _monthlyRentalPriceRangeFilterKey,
          initialValue: (priceRangeFilter.isNotEmpty)
              ? priceRangeFilter.first.value
              : null,
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
                    _comfortLevelFilterKey.currentState!.clear();
                    _apartmentTypeFilterKey.currentState!.clear();
                    _monthlyRentalPriceRangeFilterKey.currentState!.clear();
                    widget.onClear();
                  },
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final List<FilterOption> chosenFilters = [];
                    final chosenLevel =
                        _comfortLevelFilterKey.currentState!.value;
                    final chosenTypes =
                        _apartmentTypeFilterKey.currentState!.values;
                    final chosenRange =
                        _monthlyRentalPriceRangeFilterKey.currentState!.value;
                    if (chosenLevel != null) {
                      chosenFilters.add(FilterOption<ComfortLevel>(
                        whereQuery: ApartmentWhereQuery.comfortLevel,
                        value: chosenLevel,
                      ));
                    }
                    if (chosenTypes.isNotEmpty) {
                      chosenFilters.add(FilterOption<List<ApartmentType>>(
                        whereQuery: ApartmentWhereQuery.apartmentTypes,
                        value: chosenTypes,
                      ));
                    }
                    if (chosenRange != null) {
                      chosenFilters.add(FilterOption<PriceRange>(
                        whereQuery: ApartmentWhereQuery.monthlyPriceRange,
                        value: chosenRange,
                      ));
                    }
                    widget.onApply(chosenFilters);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ComfortLevelFilter extends StatefulWidget {
  const _ComfortLevelFilter({
    Key? key,
    required this.initialValue,
  }) : super(key: key);

  final ComfortLevel? initialValue;

  @override
  State<_ComfortLevelFilter> createState() => _ComfortLevelFilterState();
}

class _ComfortLevelFilterState extends State<_ComfortLevelFilter> {
  ComfortLevel? _selectedLevel;

  ComfortLevel? get value {
    return _selectedLevel;
  }

  void clear() {
    setState(() => _selectedLevel = null);
  }

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    if (initialValue == null) return;
    _selectedLevel = initialValue;
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
  const _ApartmentTypeFilter({
    Key? key,
    required this.initialValues,
  }) : super(key: key);

  final List<ApartmentType>? initialValues;

  @override
  State<_ApartmentTypeFilter> createState() => _ApartmentTypeFilterState();
}

class _ApartmentTypeFilterState extends State<_ApartmentTypeFilter> {
  final List<ApartmentType> _filters = <ApartmentType>[];

  List<ApartmentType> get values {
    return _filters;
  }

  void clear() {
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
  void initState() {
    super.initState();
    final initialValues = widget.initialValues;
    if (initialValues == null) return;
    _filters.addAll(initialValues);
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

class _MonthlyRentalPriceRangeFilter extends StatefulWidget {
  const _MonthlyRentalPriceRangeFilter({
    Key? key,
    required this.initialValue,
  }) : super(key: key);

  final PriceRange? initialValue;

  @override
  State<_MonthlyRentalPriceRangeFilter> createState() =>
      _MonthlyRentalPriceRangeFilterState();
}

class _MonthlyRentalPriceRangeFilterState
    extends State<_MonthlyRentalPriceRangeFilter> {
  final _minInputController = TextEditingController();
  final _maxInputController = TextEditingController();

  PriceRange? get value {
    String minText = _minInputController.text.trim();
    String maxText = _maxInputController.text.trim();
    if (minText.isEmpty && maxText.isEmpty) return null;

    /// If min is empty and max is x => Range: 0 -> x.
    /// If min is x and max is empty => Range: x -> 99,999 (max value allowed
    /// by the system).
    if (minText.isEmpty) minText = '0';
    if (maxText.isEmpty) maxText = '99,999';
    final minPrice = NumberFormat().parse(minText).toInt();
    final maxPrice = NumberFormat().parse(maxText).toInt();
    if (minPrice >= maxPrice) return null;
    return PriceRange(min: minPrice, max: maxPrice);
  }

  void clear() {
    _minInputController.clear();
    _maxInputController.clear();
  }

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    if (initialValue == null) return;
    if (initialValue.min != 0) {
      _minInputController.text = NumberFormat("#,###").format(initialValue.min);
    }
    if (initialValue.max != 99999) {
      _maxInputController.text = NumberFormat("#,###").format(initialValue.max);
    }
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
