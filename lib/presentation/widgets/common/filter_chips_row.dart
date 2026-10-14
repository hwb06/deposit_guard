import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

/// Horizontal filter chips with a leading "All" chip (selected == null).
class FilterChipsRow<T> extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> items;
  final T? selected;
  final String Function(T item) labelOf;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        itemCount: items.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sm),
        itemBuilder: (_, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text(AppStrings.allFilter),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            );
          }
          final item = items[index - 1];
          return ChoiceChip(
            label: Text(labelOf(item)),
            selected: item == selected,
            onSelected: (_) => onSelected(item),
          );
        },
      ),
    );
  }
}