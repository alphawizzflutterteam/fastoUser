import 'package:flutter/material.dart';
import 'package:pristine_andaman/Theme/style.dart';
import 'package:pristine_andaman/utils/Session.dart';

class CustomButton extends StatelessWidget {
  final Function? onTap;
  final String? text;
  final Color? color;
  final textColor;
  final BorderRadius? borderRadius;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  CustomButton({
    this.onTap,
    this.text,
    this.color,
    this.textColor,
    this.borderRadius,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return icon != null
        ? TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                side: BorderSide.none,
              ),
              backgroundColor: color ?? theme.primaryColor,
            ),
            onPressed: onTap as void Function()? ?? () {},
            icon: Icon(
              icon,
              color: textColor ?? theme.scaffoldBackgroundColor,
            ),
            label: Text(
              text != null
                  ? text!.toUpperCase()
                  : getTranslated(context, "CONTINUE")!.toUpperCase(),
              style: theme.textTheme.labelLarge!
                  .copyWith(color: textColor ?? theme.scaffoldBackgroundColor),
            ),
          )
        : TextButton(
            style: TextButton.styleFrom(
              padding: padding ?? EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                side: BorderSide.none,
              ),
              backgroundColor: color ?? AppTheme.secondaryColor,
            ),
            onPressed: onTap as void Function()? ?? () {},
            child: Text(
              text != null
                  ? text!.toUpperCase()
                  : getTranslated(context, "CONTINUE")!.toUpperCase(),
              style: theme.textTheme.bodyMedium!.copyWith(
                  color: textColor), //?? theme.scaffoldBackgroundColor
            ),
          );
  }
}
