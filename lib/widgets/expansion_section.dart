/// My code for this widget is inspired by this thread:
/// https://stackoverflow.com/questions/49029841/how-to-animate-collapse-elements-in-flutter/54173729#54173729
import 'package:flutter/material.dart';

class ExpansionSection extends StatefulWidget {
  const ExpansionSection({
    Key? key,
    required this.body,
    required this.bottomBuilder,
  }) : super(key: key);

  /// A widget that can be expanded and collapsed.
  final Widget body;

  /// Build a widget that is always visible below the collapsible [body].
  final Widget Function(ExpansionSectionState) bottomBuilder;

  @override
  ExpansionSectionState createState() => ExpansionSectionState();
}

class ExpansionSectionState extends State<ExpansionSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  bool isOpen = false;

  void toggle() {
    setState(() => isOpen = !isOpen);
    if (isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  ///Setting up the animation
  void _prepareAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final Animation<double> curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );

    /// Do something when the animation starts or ends...
    _animation = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void initState() {
    super.initState();
    _prepareAnimations();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizeTransition(
          axisAlignment: 1,
          sizeFactor: _animation,
          child: widget.body,
        ),
        widget.bottomBuilder(this),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}
