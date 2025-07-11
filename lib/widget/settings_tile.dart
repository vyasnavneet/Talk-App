import 'package:flutter/material.dart';

class MySettingsListTile extends StatelessWidget {
  final String title;
  final Widget action;
  final Color color;
  final Color textColor;
  final void Function()? onTap;

  const MySettingsListTile({
    super.key,
    required this.title,
    required this.action,
    required this.color,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              action,
            ],
          ),
        ),
      ),
    );
  }
}
