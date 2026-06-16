import 'package:flutter/material.dart';

import 'colors.dart';
import 'sized_box_hw.dart';
import 'snack_bar.dart';

class CustomTitleWithCloseButton extends StatelessWidget {
  const CustomTitleWithCloseButton({
    super.key,
    this.isProcessing,
    required this.title,
  });
  final String title;
  final bool? isProcessing;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE4E4E4),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          hb8,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: borderColor, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () {
                    if (isProcessing == true) {
                      showSnackBar(context, "Please wait for previous action to complete", error: true);
                    } else {
                      removeScreen(context);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(4)),
                    child: Icon(Icons.close, color: white),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: borderColor),
        ],
      ),
    );
  }
}

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    super.key,
    this.actions,
    this.isProcessing,
    required this.title,
    required this.content,
    this.contentPadding,
  });
  final String title;
  final Widget content;
  final bool? isProcessing;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      backgroundColor: Color(0xFFE4E4E4),
      titlePadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      title: CustomTitleWithCloseButton(title: title, isProcessing: isProcessing),
      contentPadding: contentPadding,
      content: content,
      actions: isProcessing == true ? [] : actions,
    );
  }
}
