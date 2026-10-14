import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';

/// Single-select chips, used inside forms.
class AppChoiceChips<T> extends StatelessWidget {
  const AppChoiceChips({
    super.key,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> items;
  final T selected;
  final String Function(T item) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.sm,
      children: [
        for (final item in items)
          ChoiceChip(
            label: Text(labelOf(item)),
            selected: item == selected,
            onSelected: (_) => onSelected(item),
          ),
      ],
    );
  }
}