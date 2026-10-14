import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/extensions/date_extension.dart';

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? Function(DateTime?)? validator;

  static final DateTime _firstDate = DateTime(2000);
  static final DateTime _lastDate = DateTime(2100);

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        final current = value;
        return InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          onTap: () async {
            final picked = await showDatePicker(
              context: field.context,
              initialDate: current ?? DateTime.now(),
              firstDate: _firstDate,
              lastDate: _lastDate,
            );
            if (picked == null || !field.mounted) return;
            onChanged(picked);
            field.didChange(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: field.errorText,
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            child: Text(
              current?.formatted ?? AppStrings.selectDate,
              style: current == null
                  ? context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              )
                  : context.text.bodyLarge,
            ),
          ),
        );
      },
    );
  }
}