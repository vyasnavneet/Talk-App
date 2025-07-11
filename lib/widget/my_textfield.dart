import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool multiLine;
  final bool circular;

  final Color? fillColor;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final BorderRadius? customBorderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool showShadow;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.multiLine,
    this.focusNode,
    this.circular = false,
    this.fillColor,
    this.hintStyle,
    this.textStyle,
    this.customBorderRadius,
    this.contentPadding,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final BorderRadius radius =
        customBorderRadius ?? BorderRadius.circular(circular ? 28 : 14);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.07),
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: TextField(
        keyboardType: multiLine ? TextInputType.multiline : TextInputType.text,
        maxLines: multiLine ? null : 1,
        minLines: multiLine ? 1 : null,
        obscureText: obscureText,
        controller: controller,
        focusNode: focusNode,
        style:
            textStyle ??
            theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
        cursorColor: theme.colorScheme.primary,
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor ?? theme.colorScheme.surfaceContainerHighest,
          hintText: hintText,
          hintStyle:
              hintStyle ??
              theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
          contentPadding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}
