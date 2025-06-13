import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'edit_nickname_screen.dart';
import 'email_edit_screen.dart';
import 'withdraw_screen.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../widgets/custom_pop_up.dart';
import '../widgets/custom_schedule_button.dart';
import 'package:mapmoa/global/user_profile.dart';
import 'password_edit_screen.dart';

class MyInfoEditScreen extends StatefulWidget {
  const MyInfoEditScreen({super.key});

  @override
  State<MyInfoEditScreen> createState() => _MyInfoEditScreenState();
}

class _MyInfoEditScreenState extends State<MyInfoEditScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isSaving = false;

  Future<void> getUserProfileFromLibrary() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 600,
      maxWidth: 600,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> postUserProfileToDB(String imagePath) async {
    final header = {
      "Content-Type": "multipart/form-data",
    };

    final formData = FormData.fromMap({
      'type': 'image',
      'image': await MultipartFile.fromFile(
        imagePath,
        contentType: MediaType('image', 'png'),
      ),
    });

    final dio = Dio();

    try {
      final response = await dio.post(
        'https://yourserver.com/api/upload',
        data: formData,
        options: Options(headers: header),
      );
      print('업로드 성공: ${response.data}');
    } catch (e) {
      print('업로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          CustomTopBar(
            title: '내 정보 수정',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ValueListenableBuilder<String?>(
                          valueListenable: globalUserProfileImage,
                          builder: (context, profilePath, _) {
                            return CircleAvatar(
                              radius: 48,
                              backgroundColor: const Color(0xFFE0E0E0),
                              backgroundImage: _image != null
                                  ? FileImage(File(_image!.path))
                                  : (profilePath != null
                                  ? FileImage(File(profilePath))
                                  : null),
                              child: (_image == null && profilePath == null)
                                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                                  : null,
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: getUserProfileFromLibrary,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFA724),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2B1D1D).withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildItem(
                          context,
                          '닉네임',
                          trailingWidget: ValueListenableBuilder<String>(
                            valueListenable: globalUserName,
                            builder: (context, name, _) {
                              return Text(name, style: const TextStyle(color: Colors.grey));
                            },
                          ),
                        ),
                        _buildItem(context, '이메일 변경'),
                        _buildItem(context, '비밀번호 변경', isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WithdrawScreen()),
                          );
                        },
                        child: const Text('계정탈퇴', style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 8),
                      const Text('|', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => LogoutPopup(
                              rootContext: context,
                              message: '로그아웃 하시겠습니까?',
                            ),
                          );
                        },
                        child: const Text('로그아웃', style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: (_image != null && !_isSaving)
          ? Padding(
        padding: const EdgeInsets.only(bottom: 24, right: 40),
        child: Align(
          alignment: Alignment.bottomRight,
          child: CustomScheduleButton(
            icon: Icons.check,
            label: '저장',
            enabled: true,
            onTap: () async {
              setState(() {
                _isSaving = true;
              });

              if (_image != null) {
                await postUserProfileToDB(_image!.path);
                globalUserProfileImage.value = _image!.path;
                globalUserProfileImage.notifyListeners();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('프로필 사진이 저장되었습니다.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF4CAF50),
                    duration: Duration(seconds: 2),
                  ),
                );

                await Future.delayed(const Duration(seconds: 2));

                setState(() {
                  _image = null;
                  _isSaving = false;
                });
              }
            },
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildItem(
      BuildContext context,
      String title, {
        String? trailing,
        Widget? trailingWidget,
        bool isLast = false,
      }) {
    return InkWell(
      onTap: () {
        if (title == '닉네임') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditNicknameScreen()),
          );
        } else if (title == '이메일 변경') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmailEditScreen()),
          );
        } else if (title == '비밀번호 변경') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PasswordEditScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: !isLast
            ? const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0)),
          ),
        )
            : null,
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (trailingWidget != null)
              trailingWidget
            else if (trailing != null)
              Text(trailing, style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
