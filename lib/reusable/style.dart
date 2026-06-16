import 'package:flutter/material.dart';

import 'colors.dart';

InputDecoration tfInputDecoration = InputDecoration(
  filled: true,
  fillColor: white,
  hintStyle: TextStyle(color: grey, fontSize: 12, height: 1.25),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: blue, width: 2),
    borderRadius: BorderRadius.circular(5),
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: BorderSide(color: grey),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: BorderSide(color: grey),
  ),
);

InputDecoration passwordInputDecoration = const InputDecoration(
  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: green)),
  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: grey)),
  border: OutlineInputBorder(borderSide: BorderSide(color: green)),
);
TextStyle b14ts = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: black);
TextStyle n12ts = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: black);
TextStyle b13ts({Color? color}) {
  return TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color ?? black);
}
