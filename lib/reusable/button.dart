import 'package:flutter/material.dart';

import 'colors.dart';
import 'sized_box_hw.dart';

class ColouredElevatedButton extends StatelessWidget {
  const ColouredElevatedButton({super.key, required this.onCLick, required this.child, this.gradientColor, this.height, required this.width, this.color});

  final LinearGradient? gradientColor;
  final Color? color;
  final Function() onCLick;
  final Widget child;
  final double? height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCLick,
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          gradient: gradientColor,
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: black),
          boxShadow: [BoxShadow(color: black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class CustomCTAButton extends StatelessWidget {
  const CustomCTAButton({
    super.key,
    this.icon,
    this.color,
    this.width,
    this.action,
    this.height,
    required this.title,
    this.leading,
    this.msg,
    this.isDisabled = false,
    this.isProcessing = false,
  });

  final Widget? leading;
  final Color? color;
  final String title;
  final double? height;
  final double? width;
  final IconData? icon;
  final Function()? action;
  final bool isDisabled;
  final bool isProcessing;
  final String? msg;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled || isProcessing ? null : action,
      child: Container(
        height: height ?? 45,
        width: width ?? 120,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(4)),
        child: Center(
          child: isProcessing
              ? Text(
                  msg ?? "Please wait..",
                  style: TextStyle(color: white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(child: leading),
                    leading == null ? wb0 : wb5,
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, height: 1.25, color: isDisabled ? black : color ?? white),
                    ),
                    icon == null ? wb0 : wb5,
                    Visibility(
                      visible: icon != null,
                      child: Icon(icon, size: 20, color: color ?? white),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class CustomOCTAButton extends StatelessWidget {
  const CustomOCTAButton({
    super.key,
    required this.title,
    this.width,
    this.height,
    this.action,
    this.fontSize,
    this.textColor,
    this.borderColor,
    this.fontWeight,
    this.icon,
  });
  final IconData? icon;
  final String title;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? textColor;
  final Color? borderColor;
  final FontWeight? fontWeight;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 120,
      height: height ?? 30,
      child: OutlinedButton(
        onPressed: action,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(white),
          foregroundColor: MaterialStateProperty.all(textColor ?? blue),
          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
            return BorderSide(
              color: borderColor ?? grey,
              width: states.contains(MaterialState.hovered) ? 1.2 : 1,
            );
          }),
          overlayColor: MaterialStateProperty.all(blue.withOpacity(0.1)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: textColor ?? black,
              ),
            if (icon != null) wb4,
            Text(
              title,
              style: TextStyle(
                fontSize: fontSize ?? 12,
                height: 1.25,
                fontWeight: fontWeight ?? FontWeight.w500,
                color: textColor ?? black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomECTAButton extends StatelessWidget {
  const CustomECTAButton({
    super.key,
    required this.title,
    this.width,
    this.height,
    this.action,
    this.fontSize,
    this.textColor,
    this.borderColor,
    this.fontWeight,
  });

  final String title;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? textColor;
  final Color? borderColor;
  final FontWeight? fontWeight;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 130,
      height: height ?? 30,
      child: ElevatedButton(
        onPressed: action,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(blue.withOpacity(0.7)),
          foregroundColor: MaterialStateProperty.all(textColor ?? white),
          side: MaterialStateProperty.all(BorderSide(color: borderColor ?? blue, width: 1)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          overlayColor: MaterialStateProperty.all(white.withOpacity(0.1)),
          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 6)),
          elevation: MaterialStateProperty.all(1),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize ?? 12,
            height: 1.25,
            fontWeight: fontWeight ?? FontWeight.w600,
            color: textColor ?? white,
          ),
        ),
      ),
    );
  }
}

class CustomOutlineIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData icon;
  final double? width;
  final double? height;
  final double? size;
  final Color borderColor;
  final Color iconColor;
  final double borderRadius;
  final EdgeInsets padding;

  const CustomOutlineIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.width,
    this.height,
    this.borderColor = Colors.black,
    this.iconColor = Colors.black,
    this.borderRadius = 5,
    this.padding = const EdgeInsets.all(0),
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 0.5),
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(icon, color: iconColor, size: size ?? 20),
        ),
      ),
    );
  }
}
