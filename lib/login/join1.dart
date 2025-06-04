import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../widgets/custom_next_nav_bar.dart';
import 'join2.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  bool allAgree = false;
  final List<bool> agreements = List.filled(6, false);

  final List<String> terms = [
    '[필수] 이용약관',
    '[필수] 위치기반서비스 이용약관',
    '[필수] 개인정보의 수집/이용동의',
    '[필수] 개인정보 위탁에 대한 동의',
    '[선택] 마케팅 및 광고 활용 동의',
    '[선택] 제 3자 정보 제공 동의',
  ];

  void _toggleAll(bool? value) {
    setState(() {
      allAgree = value ?? false;
      for (int i = 0; i < agreements.length; i++) {
        agreements[i] = allAgree;
      }
    });
  }

  void _toggleOne(int index, bool? value) {
    setState(() {
      agreements[index] = value ?? false;
      allAgree = agreements.every((e) => e);
    });
  }

  bool _isRequiredAgreed() {
    return agreements.sublist(0, 4).every((e) => e);
  }

  Color _getCheckboxColor(bool selected) {
    return selected ? const Color(0xFFFFA724) : Colors.transparent;
  }

  Widget _buildAgreementRow({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
    bool showTrailingIcon = false,
  }) {
    return InkWell(
      onTap: showTrailingIcon ? () {} : null,
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            shape: const CircleBorder(),
            side: const BorderSide(color: Color(0xFFFFA724), width: 2),
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            fillColor: MaterialStateProperty.resolveWith(
                  (states) => _getCheckboxColor(value),
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (showTrailingIcon)
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          Column(
            children: [
              CustomTopBar(
                title: '약관동의',
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100), // 버튼 영역 확보
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        const Text(
                          '다양한 서비스 이용을 위해서 아래 이용약관과 개인정보의 수집/이용 동의, 개인정보 위탁에 대한 동의 및 개인정보 목적 외 이용에 대한 안내를 읽고 동의하시기 바랍니다.',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 30),
                        _buildAgreementRow(
                          value: allAgree,
                          label: '모두 동의합니다',
                          onChanged: _toggleAll,
                        ),
                        const Divider(thickness: 1),
                        ...List.generate(terms.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildAgreementRow(
                              value: agreements[index],
                              label: terms[index],
                              onChanged: (val) => _toggleOne(index, val),
                              showTrailingIcon: true,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 40,
            right: 40,
            child: CustomNextButton(
              label: '동의하고 계속하기',
              enabled: _isRequiredAgreed(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Join2Screen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}