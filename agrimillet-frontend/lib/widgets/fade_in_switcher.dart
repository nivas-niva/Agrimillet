import 'package:flutter/material.dart';

class FadeInSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeInSwitcher({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration interval;

  const StaggeredList({
    Key? key,
    required this.children,
    this.interval = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final widget = entry.value;
        return FadeInSwitcher(
          delay: Duration(milliseconds: index * interval.inMilliseconds),
          child: widget,
        );
      }).toList(),
    );
  }
}
