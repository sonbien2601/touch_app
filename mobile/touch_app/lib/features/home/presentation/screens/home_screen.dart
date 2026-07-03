import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../couple/presentation/screens/pairing_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Touch'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          child: const Icon(CupertinoIcons.square_arrow_right),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user?.name ?? 'Touch',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 28),
              const Icon(
                CupertinoIcons.heart_fill,
                size: 148,
                color: CupertinoColors.systemPink,
              ),
              const SizedBox(height: 18),
              const CupertinoActivityIndicator(),
              const SizedBox(height: 24),
              const PairingScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
