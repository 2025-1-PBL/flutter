import 'package:flutter/material.dart';

class CustomTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final String? actionText;

  final Color backgroundColor;
  final Color titleColor;
  final Color backIconColor;
  final Color? actionIconColor;

  const CustomTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.onAction,
    this.actionIcon,
    this.actionText,
    this.backgroundColor = const Color(0xFFF9FAFB),
    this.titleColor = Colors.black,
    this.backIconColor = const Color(0xFFFFA724),
    this.actionIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.fromLTRB(30, 70, 30, 0),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: backIconColor),
                onPressed: onBack ?? () => Navigator.pop(context),
              ),
            ),
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: actionText != null
                  ? TextButton(
                onPressed: onAction,
                child: Text(
                  actionText!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onAction != null
                        ? const Color(0xFFFFA724)
                        : Colors.grey,
                  ),
                ),
              )
                  : actionIcon != null
                  ? IconButton(
                icon: Icon(
                  actionIcon,
                  color: actionIconColor ?? Colors.black,
                ),
                onPressed: onAction,
              )
                  : const SizedBox(width: 40),
            ),
          ],
        ),
      ),
    );
  }
}