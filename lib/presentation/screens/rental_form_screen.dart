import 'package:deposit_guard/presentation/widgets/common/app_date_field.dart';
import 'package:deposit_guard/presentation/widgets/common/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/rental/rental_bloc.dart';
import '../../../bloc/rental/rental_event.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/rental_model.dart';

class RentalFormScreen extends StatefulWidget {
  const RentalFormScreen({super.key, this.rental});

  /// When provided, the form edits this rental instead of creating one.
  final RentalModel? rental;

  @override
  State<RentalFormScreen> createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  DateTime? _leaseStart;
  DateTime? _leaseEnd;

  bool get _isEditing => widget.rental != null;

  @override
  void initState() {
    super.initState();
    final rental = widget.rental;
    _nameController = TextEditingController(text: rental?.name);
    _addressController = TextEditingController(text: rental?.address);
    _leaseStart = rental?.leaseStart;
    _leaseEnd = rental?.leaseEnd;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final leaseStart = _leaseStart!;
    final leaseEnd = _leaseEnd!;
    final bloc = context.read<RentalBloc>();
    final existing = widget.rental;

    if (existing != null) {
      bloc.add(
        RentalUpdated(
          existing.copyWith(
            name: name,
            address: address,
            leaseStart: leaseStart,
            leaseEnd: leaseEnd,
          ),
        ),
      );
    } else {
      bloc.add(
        RentalAdded(
          RentalModel.create(
            name: name,
            address: address,
            leaseStart: leaseStart,
            leaseEnd: leaseEnd,
          ),
        ),
      );
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? AppStrings.editRentalTitle : AppStrings.newRentalTitle,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.md),
            children: [
              AppTextField(
                controller: _nameController,
                label: AppStrings.rentalNameLabel,
                hint: AppStrings.rentalNameHint,
                maxLength: Validators.maxName,
                validator: (value) => Validators.text(
                  value,
                  emptyMessage: AppStrings.enterName,
                  maxLength: Validators.maxName,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              AppTextField(
                controller: _addressController,
                label: AppStrings.rentalAddressLabel,
                hint: AppStrings.rentalAddressHint,
                maxLength: Validators.maxAddress,
                textInputAction: TextInputAction.done,
                validator: (value) => Validators.text(
                  value,
                  emptyMessage: AppStrings.enterAddress,
                  maxLength: Validators.maxAddress,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              AppDateField(
                label: AppStrings.leaseStartLabel,
                value: _leaseStart,
                validator: Validators.date,
                onChanged: (date) => setState(() => _leaseStart = date),
              ),
              const SizedBox(height: AppDimensions.md),
              AppDateField(
                label: AppStrings.leaseEndLabel,
                value: _leaseEnd,
                validator: (end) => Validators.leaseEnd(end, _leaseStart),
                onChanged: (date) => setState(() => _leaseEnd = date),
              ),
              const SizedBox(height: AppDimensions.xl),
              ElevatedButton(
                onPressed: _submit,
                child: const Text(AppStrings.saveRental),
              ),
            ],
          ),
        ),
      ),
    );
  }
}