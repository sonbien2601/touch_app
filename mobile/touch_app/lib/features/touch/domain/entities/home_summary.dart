import 'touch_event.dart';
import 'touch_statistics.dart';

class HomeSummary {
  const HomeSummary({
    required this.coupleId,
    required this.myAvatar,
    required this.partnerAvatar,
    required this.partnerName,
    required this.isPaired,
    required this.partnerLastSeen,
    required this.lastTouch,
    required this.statistics,
  });

  final String? coupleId;
  final String? myAvatar;
  final String? partnerAvatar;
  final String? partnerName;
  final bool isPaired;
  final DateTime? partnerLastSeen;
  final TouchEvent? lastTouch;
  final TouchStatistics statistics;
}
