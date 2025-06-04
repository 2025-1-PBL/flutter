import 'package:flutter/material.dart';

class CustomNextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool enabled;
  final String label;

  const CustomNextButton({
    super.key,
    required this.label,
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
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) {
              if (states.contains(MaterialState.disabled)) {
                return const Color(0xFFE0E0E0); // 비활성 상태 - 회색
              }
              return const Color(0xFFFFA724); // 활성 상태 - 오렌지
            },
          ),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          elevation: MaterialStateProperty.all<double>(0),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}