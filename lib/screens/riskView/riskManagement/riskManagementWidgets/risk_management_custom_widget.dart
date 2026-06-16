import 'package:flutter/material.dart';

import '../../../../reusable/button.dart';
import '../../../../reusable/colors.dart';
import '../../../../reusable/highlighted_text_widget.dart';

class TabClipper extends CustomClipper<Path> {
  final bool isFirst;
  TabClipper({required this.isFirst});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (isFirst) {
      // First tab: left rounded, right slant
      path.moveTo(0, size.height);
      path.lineTo(0, 4);
      path.quadraticBezierTo(0, 0, 4, 0);
      path.lineTo(size.width - 8, 0);
      path.lineTo(size.width, size.height);
      path.close();
    } else {
      // Second tab: left slant, straight right
      path.moveTo(8, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RiskHeader extends StatelessWidget {
  const RiskHeader({
    super.key,
    required this.title,
    this.type = 0,
    this.action,
  });
  final String title;
  final int type;
  final void Function()? action;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: type == 0 ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
      children: [
        HighlightText(
          title,
          style: TextStyle(
            color: action != null ? account : black,
            fontSize: 16,
            height: 1.55,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: 10),
        if (action != null)
          CustomOutlineIconButton(
            width: 30,
            height: 30,
            borderColor: grey,
            onPressed: action,
            icon: Icons.refresh_outlined,
            size: 15,
          ),
      ],
    );
  }
}
