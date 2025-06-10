import 'package:flutter/foundation.dart';

/// 전역 사용자 프로필 이미지 경로 (초기값은 null)
ValueNotifier<String?> globalUserProfileImage = ValueNotifier<String?>(null);

/// 전역 사용자 이름 (초기값은 비어 있고, 로그인 후 설정 필요)
ValueNotifier<String> globalUserName = ValueNotifier<String>('');
