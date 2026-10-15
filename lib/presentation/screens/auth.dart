import 'package:deposit_guard/presentation/widgets/common/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/validators.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    context.read<AuthBloc>().add(
      _isSignUp
          ? AuthSignUpSubmitted(email: email, password: password)
          : AuthSignInSubmitted(email: email, password: password),
    );
  }

  void _onStateChanged(BuildContext context, AuthState state) {
    if (state.isSignedIn) {
      context.pop();
      return;
    }

    final error = state.errorMessage;
    if (error != null) context.showSnack(error, isError: true);

    final notice = state.noticeMessage;
    if (notice != null) {
      context.showSnack(notice);
      setState(() => _isSignUp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous != current,
      listener: _onStateChanged,
      builder: (context, state) {
        final busy = state.busy;

        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.md),
                children: [
                  Text(
                    _isSignUp ? AppStrings.signUp : AppStrings.signIn,
                    style: context.text.headlineMedium,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    _isSignUp
                        ? AppStrings.authSubtitleSignUp
                        : AppStrings.authSubtitleSignIn,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  AppTextField(
                    controller: _emailController,
                    label: AppStrings.emailLabel,
                    hint: AppStrings.emailHint,
                    keyboardType: TextInputType.emailAddress,
                    capitalization: TextCapitalization.none,
                    autofillHints: const [AutofillHints.email],
                    validator: Validators.email,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AppTextField(
                    controller: _passwordController,
                    label: AppStrings.passwordLabel,
                    obscureText: _hidePassword,
                    textInputAction: TextInputAction.done,
                    capitalization: TextCapitalization.none,
                    autofillHints: [
                      _isSignUp
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    validator: (value) => Validators.password(
                      value,
                      enforceLength: _isSignUp,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _hidePassword ? 'Show password' : 'Hide password',
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  ElevatedButton(
                    onPressed: busy ? null : _submit,
                    child: busy
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(
                      _isSignUp ? AppStrings.signUp : AppStrings.signIn,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  TextButton(
                    onPressed:
                    busy ? null : () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp
                          ? AppStrings.switchToSignIn
                          : AppStrings.switchToSignUp,
                    ),
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