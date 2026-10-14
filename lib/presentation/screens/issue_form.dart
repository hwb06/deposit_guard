import 'package:deposit_guard/presentation/widgets/common/app_choice_chips.dart';
import 'package:deposit_guard/presentation/widgets/common/app_text_field.dart';
import 'package:deposit_guard/presentation/widgets/issue/photo_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/issue_form/issue_form_cubit.dart';
import '../../../bloc/issue_form/issue_form_state.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_rooms.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/issue_model.dart';
import '../../../data/models/issue_severity.dart';
import '../../../data/models/issue_stage.dart';
import '../../../injection_container.dart';


class IssueFormScreen extends StatelessWidget {
  const IssueFormScreen({super.key, required this.rentalId, this.issue});

  final String rentalId;

  /// When provided, the form edits this issue instead of creating one.
  final IssueModel? issue;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<IssueFormCubit>()..init(issue),
      child: _IssueFormView(rentalId: rentalId, issue: issue),
    );
  }
}

class _IssueFormView extends StatefulWidget {
  const _IssueFormView({required this.rentalId, this.issue});

  final String rentalId;
  final IssueModel? issue;

  @override
  State<_IssueFormView> createState() => _IssueFormViewState();
}

class _IssueFormViewState extends State<_IssueFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late String _room;
  late IssueSeverity _severity;
  late IssueStage _stage;

  bool get _isEditing => widget.issue != null;

  @override
  void initState() {
    super.initState();
    final issue = widget.issue;
    _titleController = TextEditingController(text: issue?.title);
    _noteController = TextEditingController(text: issue?.note);
    _room = issue?.room ?? AppRooms.defaultRoom;
    _severity = issue?.severity ?? IssueSeverity.minor;
    _stage = issue?.stage ?? IssueStage.moveIn;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<IssueFormCubit>().save(
      rentalId: widget.rentalId,
      existing: widget.issue,
      title: _titleController.text,
      room: _room,
      severity: _severity,
      stage: _stage,
      note: _noteController.text,
    );
  }

  Future<void> _confirmDelete() async {
    final issue = widget.issue;
    if (issue == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteIssueTitle),
        content: const Text(AppStrings.deleteIssueMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              AppStrings.delete,
              style: TextStyle(color: dialogContext.colors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await context.read<IssueFormCubit>().delete(issue);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IssueFormCubit, IssueFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == IssueFormStatus.done) {
          context.pop();
        } else if (state.status == IssueFormStatus.failure) {
          context.showSnack(
            state.errorMessage ?? AppStrings.somethingWentWrong,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        final saving = state.status == IssueFormStatus.saving;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isEditing
                  ? AppStrings.editIssueTitle
                  : AppStrings.newIssueTitle,
            ),
            actions: [
              if (_isEditing)
                IconButton(
                  tooltip: AppStrings.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: saving ? null : _confirmDelete,
                ),
            ],
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.md),
                children: [
                  PhotoPickerField(
                    fileName: state.photoName,
                    onPick: context.read<IssueFormCubit>().pickPhoto,
                    onRemove: context.read<IssueFormCubit>().removePhoto,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AppTextField(
                    controller: _titleController,
                    label: AppStrings.issueTitleLabel,
                    hint: AppStrings.issueTitleHint,
                    maxLength: Validators.maxIssueTitle,
                    capitalization: TextCapitalization.sentences,
                    validator: (value) => Validators.text(
                      value,
                      emptyMessage: AppStrings.enterIssueTitle,
                      maxLength: Validators.maxIssueTitle,
                    ),
                  ),
                  const _FieldLabel(AppStrings.roomLabel),
                  AppChoiceChips<String>(
                    items: AppRooms.all,
                    selected: _room,
                    labelOf: (room) => room,
                    onSelected: (room) => setState(() => _room = room),
                  ),
                  const _FieldLabel(AppStrings.severityLabel),
                  AppChoiceChips<IssueSeverity>(
                    items: IssueSeverity.values,
                    selected: _severity,
                    labelOf: (severity) => severity.label,
                    onSelected: (severity) =>
                        setState(() => _severity = severity),
                  ),
                  const _FieldLabel(AppStrings.stageLabel),
                  AppChoiceChips<IssueStage>(
                    items: IssueStage.values,
                    selected: _stage,
                    labelOf: (stage) => stage.label,
                    onSelected: (stage) => setState(() => _stage = stage),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  AppTextField(
                    controller: _noteController,
                    label: AppStrings.noteLabel,
                    hint: AppStrings.noteHint,
                    maxLength: Validators.maxNote,
                    maxLines: 4,
                    capitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  ElevatedButton(
                    onPressed: saving ? null : _submit,
                    child: saving
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text(AppStrings.saveIssue),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.lg,
        bottom: AppDimensions.sm,
      ),
      child: Text(text, style: context.text.titleMedium),
    );
  }
}