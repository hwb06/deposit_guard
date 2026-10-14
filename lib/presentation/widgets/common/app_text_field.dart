import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
    this.capitalization = TextCapitalization.words,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int maxLines;
  final TextInputAction textInputAction;
  final TextCapitalization capitalization;

  @override
  Widget build(BuildContext context) {
    final multiline = maxLines > 1;

    return TextFormField(
      controller: controller,
      validator: validator,
      minLines: multiline ? 3 : 1,
      maxLines: maxLines,
      keyboardType: multiline ? TextInputType.multiline : null,
      textInputAction: textInputAction,
      textCapitalization: capitalization,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: maxLength == null
          ? null
          : [LengthLimitingTextInputFormatter(maxLength)],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: multiline,
      ),
    );
  }
}