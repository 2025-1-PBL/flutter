import 'package:flutter/material.dart';

class CustomNextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool enabled;
  final String label; // ✅ 기본값 없이 무조건 받아야 함

  const CustomNextButton({
    super.key,
    required this.label,     // ✅ 필수로 지정
    required this.onPressed,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? const Color(0xFFFFA724) : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}