import 'package:flutter/cupertino.dart';

class AvatarPair extends StatelessWidget {
  const AvatarPair({
    required this.myAvatar,
    required this.partnerAvatar,
    super.key,
  });

  final String? myAvatar;
  final String? partnerAvatar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-28, 0),
            child: _Avatar(url: myAvatar, icon: CupertinoIcons.person_fill),
          ),
          Transform.translate(
            offset: const Offset(28, 0),
            child: _Avatar(url: partnerAvatar, icon: CupertinoIcons.heart_fill),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.icon,
  });

  final String? url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        border: Border.all(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          width: 4,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null || imageUrl.isEmpty
          ? Icon(icon, size: 30, color: CupertinoColors.systemPink)
          : Image.network(imageUrl, fit: BoxFit.cover),
    );
  }
}

