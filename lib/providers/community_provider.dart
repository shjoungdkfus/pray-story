import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community_models.dart';
import 'auth_provider.dart';

// ── UI State ──────────────────────────────────────────────────────────────────

final selectedCategoryProvider = StateProvider<String>((ref) => 'community');

// ── 그룹 ──────────────────────────────────────────────────────────────────────

final myGroupsProvider = FutureProvider.autoDispose<List<CommunityGroup>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final memberRows = await supabase
      .from('group_members')
      .select('group_id')
      .eq('user_id', user.id);

  if ((memberRows as List).isEmpty) return [];

  final groupIds = memberRows.map((r) => r['group_id'] as String).toList();

  final groupRows = await supabase
      .from('community_groups')
      .select()
      .inFilter('id', groupIds)
      .order('created_at', ascending: false);

  return (groupRows as List).map((e) => CommunityGroup.fromJson(e)).toList();
});

/// profiles 테이블에서 user id 목록에 대한 이름 맵을 가져온다.
/// (PostgREST 임베드 profiles(name) 가 이 프로젝트에선 FK 미감지로 실패하므로 별도 조회)
Future<Map<String, String>> _profileNames(dynamic supabase, Iterable<String> ids) async {
  final unique = ids.toSet().toList();
  if (unique.isEmpty) return {};
  final rows = await supabase.from('profiles').select('id, name').inFilter('id', unique);
  final map = <String, String>{};
  for (final r in (rows as List)) {
    final id = r['id'] as String?;
    final name = r['name'] as String?;
    if (id != null && name != null && name.isNotEmpty) map[id] = name;
  }
  return map;
}

final groupMembersProvider =
    FutureProvider.autoDispose.family<List<GroupMember>, String>((ref, groupId) async {
  final supabase = ref.watch(supabaseProvider);

  final res = await supabase
      .from('group_members')
      .select()
      .eq('group_id', groupId)
      .order('joined_at', ascending: true);

  final rows = res as List;
  final names = await _profileNames(supabase, rows.map((r) => r['user_id'] as String));
  return rows.map((r) {
    final j = Map<String, dynamic>.from(r as Map);
    final nm = names[j['user_id']];
    if (nm != null) j['profiles'] = {'name': nm};
    return GroupMember.fromJson(j);
  }).toList();
});

// ── 공지 ──────────────────────────────────────────────────────────────────────

final groupNoticesProvider =
    FutureProvider.autoDispose.family<List<GroupNotice>, String>((ref, groupId) async {
  final supabase = ref.watch(supabaseProvider);

  final res = await supabase
      .from('group_notices')
      .select()
      .eq('group_id', groupId)
      .order('created_at', ascending: false);

  final rows = res as List;
  final names = await _profileNames(supabase, rows.map((r) => r['author_id'] as String));
  return rows.map((r) {
    final j = Map<String, dynamic>.from(r as Map);
    final nm = names[j['author_id']];
    if (nm != null) j['profiles'] = {'name': nm};
    return GroupNotice.fromJson(j);
  }).toList();
});

// ── 서신 중보 반응 ────────────────────────────────────────────────────────────

final letterPrayerProvider =
    FutureProvider.autoDispose.family<LetterPrayerInfo, String>((ref, letterId) async {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);

  final res = await supabase
      .from('letter_prayers')
      .select('user_id')
      .eq('letter_id', letterId)
      .order('created_at', ascending: true);

  final rows = res as List;
  final ids = rows.map((r) => r['user_id'] as String).toList();
  final names = await _profileNames(supabase, ids);

  var prayedByMe = false;
  final participantNames = <String>[];
  for (final id in ids) {
    if (user != null && id == user.id) prayedByMe = true;
    final nm = names[id];
    if (nm != null && nm.isNotEmpty) participantNames.add(nm);
  }

  return LetterPrayerInfo(
    count: ids.length,
    prayedByMe: prayedByMe,
    participantNames: participantNames,
  );
});

// ── 편지 피드 ─────────────────────────────────────────────────────────────────

final communityLettersProvider =
    FutureProvider.autoDispose<List<CommunityLetter>>((ref) async {
  final supabase = ref.watch(supabaseProvider);

  final res = await supabase
      .from('community_letters')
      .select()
      .eq('visibility', 'community')
      .order('created_at', ascending: false)
      .limit(50);

  return (res as List).map((e) => CommunityLetter.fromJson(e)).toList();
});

final groupLettersProvider =
    FutureProvider.autoDispose.family<List<CommunityLetter>, String>((ref, groupId) async {
  final supabase = ref.watch(supabaseProvider);

  final res = await supabase
      .from('community_letters')
      .select()
      .eq('group_id', groupId)
      .order('created_at', ascending: false)
      .limit(50);

  return (res as List).map((e) => CommunityLetter.fromJson(e)).toList();
});

// ── 그룹 CRUD ─────────────────────────────────────────────────────────────────

String _generateInviteCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rng = Random();
  return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
}

Future<CommunityGroup> createGroup(
  WidgetRef ref, {
  required String name,
}) async {
  final supabase = ref.read(supabaseProvider);
  final user = ref.read(currentUserProvider)!;
  final code = _generateInviteCode();

  final res = await supabase
      .from('community_groups')
      .insert({
        'name': name,
        'invite_code': code,
        'owner_id': user.id,
        'max_members': 5,
      })
      .select()
      .single();

  final group = CommunityGroup.fromJson(res);

  await supabase.from('group_members').insert({
    'group_id': group.id,
    'user_id': user.id,
    'role': 'owner',
  });

  return group;
}

Future<CommunityGroup> joinGroupByCode(WidgetRef ref, String code) async {
  final supabase = ref.read(supabaseProvider);
  final user = ref.read(currentUserProvider)!;

  final groupRes = await supabase
      .from('community_groups')
      .select()
      .eq('invite_code', code.toUpperCase().trim())
      .single();

  final group = CommunityGroup.fromJson(groupRes);

  final existing = await supabase
      .from('group_members')
      .select()
      .eq('group_id', group.id)
      .eq('user_id', user.id);

  if ((existing as List).isNotEmpty) return group;

  final memberCount = await supabase
      .from('group_members')
      .select()
      .eq('group_id', group.id);

  if ((memberCount as List).length >= group.maxMembers) {
    throw Exception('그룹 인원이 꽉 찼습니다 (${group.maxMembers}명)');
  }

  await supabase.from('group_members').insert({
    'group_id': group.id,
    'user_id': user.id,
    'role': 'member',
  });

  return group;
}

// ── 편지 작성 ─────────────────────────────────────────────────────────────────

const _anonymousEmojis = ['🌻', '🌷', '🌸', '🍀', '🌿', '🌺', '🌼', '🪻', '🌾', '💐', '🕊️', '✨', '🌙', '⭐', '🦋'];

const _anonymousAdjectives = [
  'gentle', 'quiet', 'warm', 'bright', 'little',
  'kind', 'humble', 'faithful', 'joyful', 'peaceful',
  'thankful', 'hopeful', 'blessed', 'graceful', 'pure',
];

const _anonymousNouns = [
  'lamb', 'dove', 'sparrow', 'lily', 'seed',
  'light', 'star', 'rain', 'breeze', 'river',
  'cloud', 'rose', 'meadow', 'sunrise', 'moonlight',
];

String _generateAnonymousName() {
  final rng = Random();
  final adj = _anonymousAdjectives[rng.nextInt(_anonymousAdjectives.length)];
  final noun = _anonymousNouns[rng.nextInt(_anonymousNouns.length)];
  return '$adj-$noun';
}

String _generateAnonymousEmoji() {
  final rng = Random();
  return _anonymousEmojis[rng.nextInt(_anonymousEmojis.length)];
}

Future<void> postCommunityLetter(
  WidgetRef ref, {
  required String content,
  required String visibility,
  String? groupId,
  String? recipientName,
}) async {
  final supabase = ref.read(supabaseProvider);
  final user = ref.read(currentUserProvider)!;

  await supabase.from('community_letters').insert({
    'author_id': user.id,
    'group_id': groupId,
    'recipient_name': recipientName,
    'content': content,
    'visibility': visibility,
    'anonymous_name': _generateAnonymousName(),
    'anonymous_emoji': _generateAnonymousEmoji(),
  });
}

Future<void> leaveGroup(WidgetRef ref, String groupId) async {
  final supabase = ref.read(supabaseProvider);
  final user = ref.read(currentUserProvider)!;

  await supabase
      .from('group_members')
      .delete()
      .eq('group_id', groupId)
      .eq('user_id', user.id);
}

Future<void> deleteGroup(WidgetRef ref, String groupId) async {
  final supabase = ref.read(supabaseProvider);

  await supabase.from('group_members').delete().eq('group_id', groupId);
  await supabase.from('community_letters').delete().eq('group_id', groupId);
  await supabase.from('community_groups').delete().eq('id', groupId);
}

Future<void> updateGroupName(WidgetRef ref, String groupId, String newName) async {
  final supabase = ref.read(supabaseProvider);
  await supabase
      .from('community_groups')
      .update({'name': newName})
      .eq('id', groupId);
}

Future<void> updateGroupDescription(WidgetRef ref, String groupId, String desc) async {
  final supabase = ref.read(supabaseProvider);
  await supabase
      .from('community_groups')
      .update({'description': desc})
      .eq('id', groupId);
}

Future<void> updateGroupIcon(WidgetRef ref, String groupId, String icon) async {
  final supabase = ref.read(supabaseProvider);
  await supabase
      .from('community_groups')
      .update({'icon': icon})
      .eq('id', groupId);
}

/// 방장이 멤버를 내보냄
Future<void> removeMember(WidgetRef ref, String groupId, String userId) async {
  final supabase = ref.read(supabaseProvider);
  await supabase
      .from('group_members')
      .delete()
      .eq('group_id', groupId)
      .eq('user_id', userId);
}

// ── 공지 작성/삭제 ────────────────────────────────────────────────────────────

Future<void> postNotice(WidgetRef ref, String groupId, String content) async {
  final supabase = ref.read(supabaseProvider);
  final user = ref.read(currentUserProvider)!;
  await supabase.from('group_notices').insert({
    'group_id': groupId,
    'author_id': user.id,
    'content': content,
  });
}

Future<void> deleteNotice(WidgetRef ref, String noticeId) async {
  final supabase = ref.read(supabaseProvider);
  await supabase.from('group_notices').delete().eq('id', noticeId);
}

// ── 중보 반응 토글 ────────────────────────────────────────────────────────────

/// 서신에 "함께 기도" 토글. 추가했으면 true, 취소했으면 false 반환.
Future<bool> toggleLetterPrayer(WidgetRef ref, String letterId) async {
  final supabase = ref.read(supabaseProvider);
  final user = ref.read(currentUserProvider)!;

  final existing = await supabase
      .from('letter_prayers')
      .select('id')
      .eq('letter_id', letterId)
      .eq('user_id', user.id);

  if ((existing as List).isNotEmpty) {
    await supabase
        .from('letter_prayers')
        .delete()
        .eq('letter_id', letterId)
        .eq('user_id', user.id);
    return false;
  }

  await supabase.from('letter_prayers').insert({
    'letter_id': letterId,
    'user_id': user.id,
  });
  return true;
}
