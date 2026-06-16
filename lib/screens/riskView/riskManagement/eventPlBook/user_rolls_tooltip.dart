import 'package:flutter/material.dart';

import '../../../../model/bm_book_model.dart';

class UserRollsTT extends StatefulWidget {
  const UserRollsTT({
    super.key,
    required this.upLines,
    required this.child,
  });
  final Widget child;
  final List<UplineData> upLines;

  @override
  State<UserRollsTT> createState() => _UserRollsTTState();
}

class _UserRollsTTState extends State<UserRollsTT> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  void _show() {
    if (widget.upLines.isEmpty) return;
    _entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 0,
          top: 0,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topLeft,
            followerAnchor: Alignment.bottomLeft,
            offset: const Offset(0, -4),
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.upLines.map((u) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: getBadgeColor(u.title),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                u.title,
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              u.name,
                              style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_entry!);
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.upLines.isEmpty) return widget.child;

    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) => _show(),
        onExit: (_) => _hide(),
        child: widget.child,
      ),
    );
  }
}
