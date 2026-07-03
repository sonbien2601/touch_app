import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/touch_controller.dart';

class TouchHistoryScreen extends ConsumerStatefulWidget {
  const TouchHistoryScreen({
    required this.coupleId,
    super.key,
  });

  final String coupleId;

  @override
  ConsumerState<TouchHistoryScreen> createState() => _TouchHistoryScreenState();
}

class _TouchHistoryScreenState extends ConsumerState<TouchHistoryScreen> {
  var _limit = 20;

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(touchRepositoryProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('History'),
      ),
      child: SafeArea(
        child: FutureBuilder(
          future: repository.getTouchHistory(widget.coupleId, limit: _limit),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Cannot load history.'));
            }

            final events = snapshot.data ?? [];
            if (events.isEmpty) {
              return const Center(child: Text('No touches yet.'));
            }

            return ListView.builder(
              itemCount: events.length + 1,
              itemBuilder: (context, index) {
                if (index == events.length) {
                  return CupertinoButton(
                    onPressed: () => setState(() => _limit += 20),
                    child: const Text('Load more'),
                  );
                }

                final event = events[index];
                return CupertinoListTile(
                  leading: const Text('❤️'),
                  title: Text(_relativeDay(event.createdAt)),
                  subtitle: Text(event.createdAt.toLocal().toString()),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _relativeDay(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(value.year, value.month, value.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }
}

