import 'package:flutter/cupertino.dart';

import '../../domain/entities/touch_statistics.dart';

class StatGrid extends StatelessWidget {
  const StatGrid({
    required this.statistics,
    super.key,
  });

  final TouchStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _Stat(label: 'Total', value: statistics.totalTouch),
        _Stat(label: 'Today', value: statistics.today),
        _Stat(label: 'Week', value: statistics.thisWeek),
        _Stat(label: 'Month', value: statistics.thisMonth),
        _Stat(label: 'Streak', value: statistics.currentStreak),
        _Stat(label: 'Best', value: statistics.longestStreak),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel),
        ),
      ],
    );
  }
}

