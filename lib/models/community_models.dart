class CommunityGroup {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String inviteCode;
  final String ownerId;
  final int maxMembers;
  final DateTime createdAt;

  const CommunityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.inviteCode,
    required this.ownerId,
    required this.maxMembers,
    required this.createdAt,
  });

  factory CommunityGroup.fromJson(Map<String, dynamic> json) {
    return CommunityGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      icon: (json['icon'] as String?)?.isNotEmpty == true
          ? json['icon'] as String
          : '📖',
      inviteCode: json['invite_code'] as String,
      ownerId: json['owner_id'] as String,
      maxMembers: (json['max_members'] as int?) ?? 5,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}

class GroupNotice {
  final String id;
  final String groupId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final String? authorName;

  const GroupNotice({
    required this.id,
    required this.groupId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.authorName,
  });

  factory GroupNotice.fromJson(Map<String, dynamic> json) {
    String? name;
    if (json['profiles'] != null) {
      name = (json['profiles'] as Map<String, dynamic>)['name'] as String?;
    }
    return GroupNotice(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      authorName: name,
    );
  }
}

/// 한 서신의 중보 현황: 함께 기도한 사람 수 + 내가 눌렀는지 + 참여자 이름 일부
class LetterPrayerInfo {
  final int count;
  final bool prayedByMe;
  final List<String> participantNames;

  const LetterPrayerInfo({
    required this.count,
    required this.prayedByMe,
    required this.participantNames,
  });

  static const empty = LetterPrayerInfo(
    count: 0,
    prayedByMe: false,
    participantNames: [],
  );
}

class GroupMember {
  final String id;
  final String groupId;
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String? userName;

  const GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.userName,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    String? name;
    if (json['profiles'] != null) {
      name = (json['profiles'] as Map<String, dynamic>)['name'] as String?;
    }
    return GroupMember(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String).toLocal(),
      userName: name,
    );
  }

  bool get isOwner => role == 'owner';
}

class CommunityLetter {
  final String id;
  final String authorId;
  final String? groupId;
  final String? recipientName;
  final String content;
  final String visibility;
  final String anonymousName;
  final String anonymousEmoji;
  final DateTime createdAt;

  const CommunityLetter({
    required this.id,
    required this.authorId,
    this.groupId,
    this.recipientName,
    required this.content,
    required this.visibility,
    required this.anonymousName,
    required this.anonymousEmoji,
    required this.createdAt,
  });

  factory CommunityLetter.fromJson(Map<String, dynamic> json) {
    return CommunityLetter(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      groupId: json['group_id'] as String?,
      recipientName: json['recipient_name'] as String?,
      content: json['content'] as String,
      visibility: json['visibility'] as String,
      anonymousName: json['anonymous_name'] as String,
      anonymousEmoji: json['anonymous_emoji'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}
