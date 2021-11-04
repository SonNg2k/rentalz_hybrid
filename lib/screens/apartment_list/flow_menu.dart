import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlowMenu extends StatefulWidget {
  const FlowMenu({Key? key}) : super(key: key);

  @override
  _FlowMenuState createState() => _FlowMenuState();
}

class _FlowMenuState extends State<FlowMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController menuAnimation;
  bool isOpened = false;

  Widget get flowMenuLogoutBtn {
    return flowMenuButton(
      Icon(
        Icons.logout,
        color: Theme.of(context).errorColor,
      ),
      onPressed: () => showCupertinoModalPopup(
        context: context,
        builder: (_) => CupertinoActionSheet(
          message: const Text(
              "Your data will be saved. Can't wait to have you back!"),
          actions: [
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text('Logout'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget flowMenuButton(Icon icon, {void Function()? onPressed}) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 16),
        child: RawMaterialButton(
          fillColor: Colors.white,
          shape: const CircleBorder(),

          /// The diameter of this button
          constraints: BoxConstraints.tight(const Size.square(56)),
          onPressed: () {
            if (onPressed != null) onPressed();
            if (menuAnimation.status == AnimationStatus.completed) {
              menuAnimation.reverse();
              setState(() => isOpened = false);
            } else {
              menuAnimation.forward();
              setState(() => isOpened = true);
            }
          },
          child: icon,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    menuAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Flow layouts are optimized for repositioning children using
    /// transformation matrices.
    ///
    /// The most efficient way to trigger a repaint of the flow is to supply an
    /// animation to the constructor of the FlowDelegate. The flow will listen
    /// to this animation and repaint whenever the animation ticks, avoiding
    /// both the build and layout phases of the pipeline.
    ///
    /// A widget that sizes and positions children efficiently, according to
    /// the logic in a FlowDelegate.
    return Flow(
      delegate: _FlowMenuDelegate(menuAnimation: menuAnimation),
      children: [
        flowMenuButton(const Icon(
          Icons.close,
          color: Colors.deepPurpleAccent,
        )),
        flowMenuButton(const Icon(
          Icons.add_business_outlined,
          color: Colors.deepPurpleAccent,
        )),
        if (isOpened) flowMenuLogoutBtn,
        if (!isOpened)
          flowMenuButton(const Icon(
            Icons.menu,
            color: Colors.deepPurpleAccent,
          ))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    menuAnimation.dispose();
  }
}

/// Controls the visual presentation of the children in a flow layout.
/// For optimal performance, construct the FlowDelegate with an Animation that
/// ticks whenever the delegate wishes to change the transformation matrices
/// for the children and avoid rebuilding the Flow widget itself every
/// animation frame.
class _FlowMenuDelegate extends FlowDelegate {
  _FlowMenuDelegate({required this.menuAnimation})
      : super(repaint: menuAnimation);

  final Animation<double> menuAnimation;

  /// Tell Flutter where to draw each of Flow's children using the paintChild
  /// method of the Flow's painting context. This method is called when the
  /// animation has not yet started (menuAnimation.value = 0) and when the
  /// animation completes (menuAnimation.value = 1)
  @override
  void paintChildren(FlowPaintingContext context) {
    /// This feels like a stack that uses matrices instead of Positioned
    /// widgets. But that's not where Flow shines, it can interact with the
    /// animation's value. The position of items in the Stack never changes,
    /// however, the items in a Flow can be repositioned efficiently by simply
    /// repainting the flow.
    ///
    /// The index within the list of Flow's children.
    /// U can place the child in its default position with Matrix4.identity()
    /// to indicate no transformation at all.
    for (int i = 0; i < context.childCount; i++) {
      final offset = i * menuAnimation.value * 50;
      context.paintChild(
        i,
        transform: Matrix4.translationValues(-offset, -offset, 0),
      );
    }
  }

  @override
  bool shouldRepaint(_FlowMenuDelegate oldDelegate) {
    return menuAnimation != oldDelegate.menuAnimation;
  }
}
