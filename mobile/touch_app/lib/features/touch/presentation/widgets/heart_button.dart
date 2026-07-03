import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class HeartButton extends StatefulWidget {
  const HeartButton({
    required this.isSending,
    required this.onPressed,
    super.key,
  });

  final bool isSending;
  final VoidCallback onPressed;

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1, end: 1.14).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isSending ? null : (_) => _controller.forward(),
      onTapCancel: widget.isSending ? null : () => _controller.reverse(),
      onTapUp: widget.isSending
          ? null
          : (_) {
              _controller.reverse();
              HapticFeedback.mediumImpact();
              widget.onPressed();
            },
      child: Hero(
        tag: 'touch-heart',
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedOpacity(
            opacity: widget.isSending ? 0.45 : 1,
            duration: const Duration(milliseconds: 180),
            child: const Icon(
              CupertinoIcons.heart_fill,
              size: 168,
              color: CupertinoColors.systemPink,
            ),
          ),
        ),
      ),
    );
  }
}

