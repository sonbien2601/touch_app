class TouchEvent {
  const TouchEvent({
    required this.id,
    required this.coupleId,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.device,
    required this.appVersion,
  });

  final String id;
  final String coupleId;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final String device;
  final String appVersion;
}

