import 'package:flutter/material.dart';

import '../../model/agency_model.dart';
import '../../reusable/colors.dart';
import '../../reusable/custom_alert_dialog.dart';
import '../../reusable/formatters.dart';
import '../../reusable/highlighted_text_widget.dart';
import '../../reusable/sized_box_hw.dart';

Future<dynamic> viewUserBalance(
  BuildContext context,
  AgencyModel user,
) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext ctxt) {
      return ViewUserBalanceBody(
        user: user,
      );
    },
  );
}

class ViewUserBalanceBody extends StatelessWidget {
  const ViewUserBalanceBody({super.key, required this.user});
  final AgencyModel user;
  @override
  Widget build(BuildContext context) {
    double tfw = 700;

    return CustomAlertDialog(
      title: user.userName,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        height: 220,
        width: tfw,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: white,
                  border: Border(
                    bottom: BorderSide(color: grey),
                  ),
                ),
                width: tfw,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HighlightText('Main Balance'),
                      HighlightText(
                        formattedAmounts(user.balancePoint),
                        style: TextStyle(fontSize: 25, color: blue, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          HighlightText('Exposure:', style: TextStyle(fontSize: 25, color: blue, fontWeight: FontWeight.bold)),
                          HighlightText(
                            formattedAmounts(user.exposure),
                            style: TextStyle(
                              fontSize: 25,
                              color: user.exposure > 0 ? green : red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            hb12,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: white,
                  border: Border(
                    bottom: BorderSide(color: grey),
                  ),
                ),
                width: tfw,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BalanceTile(title: 'Casino Balance', value: formattedAmounts(user.casinoBalance)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BalanceTile extends StatelessWidget {
  const BalanceTile({
    super.key,
    required this.title,
    required this.value,
  });
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HighlightText(
            title,
            style: TextStyle(fontSize: 15, color: black, fontWeight: FontWeight.normal),
          ),
          HighlightText(value, style: TextStyle(fontSize: 15, color: blue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CustomTCTAButton extends StatelessWidget {
  const CustomTCTAButton({
    super.key,
    required this.title,
    this.action,
  });
  final String title;
  final void Function()? action;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: InkWell(
        onTap: action,
        child: HighlightText(
          title,
          style: TextStyle(decoration: TextDecoration.underline, color: blue, decorationColor: blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class UserDetailsCell extends StatelessWidget {
  const UserDetailsCell({
    super.key,
    this.title,
    this.isHeader = false,
    this.color,
    this.child,
    this.flex = 1,
  });
  final double flex;
  final String? title;
  final bool isHeader;
  final Color? color;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      flex: (flex * 1000).toInt(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (title != null)
            HighlightText(
              "$title",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.25,
                color: isHeader ? headerTextColor : color ?? black,
                fontWeight: isHeader ? FontWeight.w700 : FontWeight.w300,
              ),
            ),
          SizedBox(child: child)
        ],
      ),
    );
  }
}

class ViewCTAButton extends StatelessWidget {
  const ViewCTAButton({super.key, this.onPressed});
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          minimumSize: const Size(60, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: HighlightText('View', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
      ),
    );
  }
}

class UserTableColumn {
  final String title;
  final Widget? headerChild;
  final double flex;
  final Widget Function(AgencyModel user, int index) cellBuilder;
  const UserTableColumn({
    required this.title,
    required this.cellBuilder,
    this.headerChild,
    this.flex = 1,
  });
}

class CheckboxWithValue extends StatelessWidget {
  const CheckboxWithValue({
    super.key,
    required this.title,
    this.value,
    this.onChanged,
  });

  final String title;
  final bool? value;
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return UserDetailsCell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
          ),
          HighlightText(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
