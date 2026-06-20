import 'package:flutter_riverpod/flutter_riverpod.dart';

final shellTabProvider = StateProvider<int>((ref) => 0);

// 달력 탭 → 서신서 탭 이동 시 돌아올 탭 인덱스를 기록
final previousTabProvider = StateProvider<int?>((ref) => null);
