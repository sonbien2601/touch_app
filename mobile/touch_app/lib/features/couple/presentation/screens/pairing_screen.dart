import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/pairing_controller.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pairingControllerProvider);
    final controller = ref.read(pairingControllerProvider.notifier);

    ref.listen(pairingControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          showCupertinoDialog<void>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Cannot pair'),
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

    return state.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (_, __) => _PairingContent(
        codeController: _codeController,
        inviteCode: null,
        isLoading: false,
        onCreate: controller.createInviteCode,
        onJoin: () => controller.joinCouple(_codeController.text),
      ),
      data: (data) => _PairingContent(
        codeController: _codeController,
        inviteCode: data.inviteCode,
        isLoading: false,
        onCreate: controller.createInviteCode,
        onJoin: () => controller.joinCouple(_codeController.text),
      ),
    );
  }
}

class _PairingContent extends StatelessWidget {
  const _PairingContent({
    required this.codeController,
    required this.inviteCode,
    required this.isLoading,
    required this.onCreate,
    required this.onJoin,
  });

  final TextEditingController codeController;
  final String? inviteCode;
  final bool isLoading;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pair',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          if (inviteCode == null)
            const Text(
              'No pairing code yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: CupertinoColors.secondaryLabel),
            )
          else
            Text(
              inviteCode!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
          const SizedBox(height: 20),
          CupertinoButton.filled(
            onPressed: isLoading ? null : onCreate,
            child: const Text('Create code'),
          ),
          const SizedBox(height: 28),
          CupertinoTextField(
            controller: codeController,
            placeholder: 'Enter code',
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            onPressed: isLoading ? null : onJoin,
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}

