import 'package:flutter/material.dart';

const primary = Color(0xFF2789ce);
const Color primaryColor = primary;

const Color backType = Color(0xff1f72ac);
const Color layType = Color(0xffe33a5e);
const Color transparent = Colors.transparent;
const Color white = Colors.white;
const Color blue = Color(0xFF2789ce);
const Color black = Colors.black;
const Color green = Colors.green;
const Color amber = Colors.amber;
const Color cyan = Colors.cyan;
const Color red = Colors.red;
const Color grey = Colors.grey;
const Color layBtn = Colors.pinkAccent;
const Color pinkButtonClr = Color(0xFFFF6182);
const Color darkGreen = Color(0XFF0E3D49);
const Color highlightTileHover = Color(0xFFEFF2F2);
const Color appYellow = Color(0xFFffcc2e);
const Color backBtn = Color(0xFF2789ce);
const Color oddsBackBtn = Color(0xff4fa6f2);
const Color secondaryTextClr = Color(0xff3b5160);

///black
const Color lightBlack = Color(0xff1E1F25);
const Color plColor = Color(0xFFF3DFB0);
const Color bgColor = Color(0xFFEEEEEE);
const Color yellowTextColor = Color(0xFFFFB600);
const Color tileOrFontColor = Color(0xFF3B5160);
const Color primaryCardColor = Color(0xFFDDDCD7);

const Color account = Color(0xff243a48);
const Color about = Color(0xff7e97a7);
const Color accountStatementHeaderBg = Color(0xffe0e6e6);
const Color headerRowColor = Color(0xFFE4E4E4);
const Color borderColor = Color(0xFF7E97A7);
const Color headerTextColor = Color(0xFF243A48);
const Color arrowColor = Color(0xFFC5D0D7);
const Color fancy = Color(0xFF076875);
const Color lightGrey = Color(0XFF6d7078);
const Color mediumGrey = Color(0xff4E4E4E);
const Color darkGrey = Color(0xff3E404E);
const Color littleLightGrey = Color(0xffE0E0E0);

///color with opacity
Color applyOpacity(Color color, double opacity) {
  return color.withAlpha((opacity * 255).toInt());
}

///primary gradient
const LinearGradient selectedHeaderColor = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color.fromARGB(255, 158, 178, 192), borderColor],
);
const LinearGradient unselectedHeaderColor = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [headerRowColor, headerRowColor],
);

const LinearGradient bottomBarGradient = LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF070707), Color(0xFF474747)]);
const LinearGradient gradientClr = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF000000), Color(0xFF21222D)]);
const LinearGradient fancyGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ Color(0xFF0a92a5), fancy]);
