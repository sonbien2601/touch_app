import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  var _registerMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          showCupertinoDialog<void>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Cannot continue'),
              content: Text(controller.errorText(error)),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      );
    });

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Touch',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 32),
              if (_registerMode) ...[
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'Name',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
              ],
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: 'Password',
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: state.isLoading
                    ? null
                    : () {
                        if (_registerMode) {
                          controller.registerWithEmail(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            name: _nameController.text.trim(),
                          );
                        } else {
                          controller.signInWithEmail(
                            _emailController.text.trim(),
                            _passwordController.text,
                          );
                        }
                      },
                child: state.isLoading
                    ? const CupertinoActivityIndicator()
                    : Text(_registerMode ? 'Create account' : 'Sign in'),
              ),
              CupertinoButton(
                onPressed: state.isLoading
                    ? null
                    : () => setState(() => _registerMode = !_registerMode),
                child: Text(_registerMode
                    ? 'I already have an account'
                    : 'Create new account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
