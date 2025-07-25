import 'package:flutter/material.dart';

/// A wrapper widget that prevents rapid successive taps
class SafeTapWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration debounceTime;

  const SafeTapWidget({
    super.key,
    required this.child,
    this.onTap,
    this.debounceTime = const Duration(milliseconds: 300),
  });

  @override
  State<SafeTapWidget> createState() => _SafeTapWidgetState();
}

class _SafeTapWidgetState extends State<SafeTapWidget> {
  DateTime? _lastTapTime;

  bool get _canTap {
    if (_lastTapTime == null) return true;
    return DateTime.now().difference(_lastTapTime!) > widget.debounceTime;
  }

  void _handleTap() {
    if (_canTap) {
      _lastTapTime = DateTime.now();
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
      child: widget.child,
    );
  }
}

/// Extension to easily wrap widgets with safe tap functionality
extension SafeTapExtension on Widget {
  Widget withSafeTap(VoidCallback? onTap, {Duration? debounceTime}) {
    return SafeTapWidget(
      onTap: onTap,
      debounceTime: debounceTime ?? const Duration(milliseconds: 300),
      child: this,
    );
  }
}
