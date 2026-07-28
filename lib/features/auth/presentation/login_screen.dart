import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../design_system/app_spacing.dart';
import '../../../di/app_module.dart';
import 'login_cubit.dart';
import 'login_state.dart';

/// Login screen wired to [LoginCubit] via BLoC.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.onLoginSuccess});

  /// Invoked with no arguments once login succeeds, e.g. to trigger
  /// navigation from a router redirect listener.
  final VoidCallback? onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(AppModule.instance.authUseCase),
      child: _LoginView(onLoginSuccess: onLoginSuccess),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({this.onLoginSuccess});

  final VoidCallback? onLoginSuccess;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.hideKeyboard();
    if (_formKey.currentState?.validate() != true) return;
    context.read<LoginCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginFailure) {
              context.showSnackBar(
                state.message,
                backgroundColor: context.colorScheme.error,
              );
            } else if (state is LoginSuccess) {
              widget.onLoginSuccess?.call();
            }
          },
          builder: (context, state) {
            final isLoading = state is LoginLoading;

            return SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSpacing.gapXl,
                    Text(
                      'Welcome back',
                      style: context.textTheme.headlineMedium,
                    ),
                    AppSpacing.gapSm,
                    Text(
                      'Sign in to continue',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.outline,
                      ),
                    ),
                    AppSpacing.gapXl,
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator:
                          (value) =>
                              (value == null || !value.contains('@'))
                                  ? 'Enter a valid email'
                                  : null,
                    ),
                    AppSpacing.gapMd,
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed:
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        ),
                      ),
                      validator:
                          (value) =>
                              (value == null || value.length < 8)
                                  ? 'Minimum 8 characters'
                                  : null,
                    ),
                    AppSpacing.gapLg,
                    FilledButton(
                      onPressed: isLoading ? null : () => _submit(context),
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Sign in'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
