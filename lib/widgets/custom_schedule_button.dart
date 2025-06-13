import 'package:flutter/material.dart';

enum ScheduleButtonType { delete, select }

class CustomScheduleButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;
  final IconData icon;
  final String label;
  final Color activeColor;
  final Color inactiveColor;

  const CustomScheduleButton({
    super.key,
    required this.enabled,
    required this.onTap,
    required this.icon,
    required this.label,
    this.activeColor = const Color(0xFFFFA724),
    this.inactiveColor = Colors.grey,
  });

  /// ✨ 버튼 타입으로 생성 (delete or select)
  factory CustomScheduleButton.fromType({
    Key? key,
    required ScheduleButtonType type,
    required bool enabled,
    required VoidCallback? onTap,
  }) {
    switch (type) {
      case ScheduleButtonType.delete:
        return CustomScheduleButton(
          key: key,
          icon: Icons.delete,
          label: '삭제',
          enabled: enabled,
          onTap: onTap,
        );
      case ScheduleButtonType.select:
        return CustomScheduleButton(
          key: key,
          icon: Icons.check,
          label: '선택',
          enabled: enabled,
          onTap: onTap,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = enabled ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}