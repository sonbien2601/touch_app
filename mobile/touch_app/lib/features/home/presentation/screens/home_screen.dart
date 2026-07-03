import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../couple/presentation/screens/pairing_screen.dart';
import '../../../touch/domain/entities/home_summary.dart';
import '../../../touch/presentation/controllers/touch_controller.dart';
import '../../../touch/presentation/screens/touch_history_screen.dart';
import '../../../touch/presentation/widgets/avatar_pair.dart';
import '../../../touch/presentation/widgets/heart_button.dart';
import '../../../touch/presentation/widgets/stat_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final uid = user?.uid;
    final summary = uid == null ? null : ref.watch(homeSummaryProvider(uid));
    final touchState = ref.watch(touchControllerProvider);
    final touchController = ref.read(touchControllerProvider.notifier);

    ref.listen(touchControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          showCupertinoDialog<void>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Touch queued'),
              content: Text(touchController.errorText(error)),
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Touch'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          child: const Icon(CupertinoIcons.square_arrow_right),
        ),
      ),
      child: SafeArea(
        child: summary?.when(
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (_, __) => const Center(child: Text('Cannot load Touch.')),
              data: (data) => _HomeContent(
                uid: uid!,
                name: user?.name ?? 'Touch',
                summary: data,
                isSending: touchState.isLoading,
                offline: touchState.valueOrNull?.isOffline ?? false,
                onSend: () => touchController.send(uid),
              ),
            ) ??
            const Center(child: CupertinoActivityIndicator()),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.uid,
    required this.name,
    required this.summary,
    required this.isSending,
    required this.offline,
    required this.onSend,
  });

  final String uid;
  final String name;
  final HomeSummary summary;
  final bool isSending;
  final bool offline;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    if (!summary.isPaired) {
      return const SingleChildScrollView(
        child: Center(child: PairingScreen()),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AvatarPair(
          myAvatar: summary.myAvatar,
          partnerAvatar: summary.partnerAvatar,
        ),
        const SizedBox(height: 14),
        Text(
          summary.partnerName == null ? 'Paired' : '$name + ${summary.partnerName}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          offline ? 'Offline queue active' : 'Connected',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: offline ? CupertinoColors.systemOrange : CupertinoColors.activeGreen,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: HeartButton(
            isSending: isSending,
            onPressed: onSend,
          ),
        ),
        const SizedBox(height: 18),
        _Meta(summary: summary),
        const SizedBox(height: 18),
        StatGrid(statistics: summary.statistics),
        if (summary.coupleId != null)
          CupertinoButton(
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute<void>(
                  builder: (_) => TouchHistoryScreen(coupleId: summary.coupleId!),
                ),
              );
            },
            child: const Text('History'),
          ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Last Touch: ${_format(summary.lastTouch?.createdAt)}'),
        const SizedBox(height: 4),
        Text('Last Online: ${_format(summary.partnerLastSeen)}'),
      ],
    );
  }

  String _format(DateTime? value) {
    if (value == null) return 'No data';
    return value.toLocal().toString();
  }
}
