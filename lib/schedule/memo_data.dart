List<Map<String, dynamic>> globalPersonalMemos = [
  {
    'location': '5호선 광화문역 (서울특별시 종로구 세종대로 172)',
    'memo': '123',
    'color': 'red',
    'latitude': 37.5665,
    'longitude': 126.9780,
  },
  {
    'location': '카페 베네 (신촌점)',
    'memo': '스터디 회의',
    'color': 'blue',
  },
];

List<Map<String, dynamic>> globalSharedMemos = [
  {
    'location': '롯데백화점 (잠실점)',
    'memo': '같이 쇼핑하자',
    'color': 'green',
    'profileUrl': 'https://cdn-icons-png.flaticon.com/512/847/847969.png',
    'latitude': 37.5700,
    'longitude': 126.9820,
  },
  {
    'location': '한강공원 (여의도)',
    'memo': '치맥 모임',
    'color': 'orange',
    'profileUrl': 'https://cdn-icons-png.flaticon.com/512/847/847969.png'
  },
];

List<Map<String, dynamic>> getPersonalMemos() => globalPersonalMemos;
List<Map<String, dynamic>> getSharedMemos() => globalSharedMemos;
