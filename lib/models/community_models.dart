class CommunityGroup {
  final String id;
  final String name;
  final String inviteCode;
  final String ownerId;
  final int maxMembers;
  final DateTime createdAt;

  const CommunityGroup({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.ownerId,
    required this.maxMembers,
    required this.createdAt,
  });

  factory CommunityGroup.fromJson(Map<String, dynamic> json) {
    return CommunityGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['invite_code'] as String,
      ownerId: json['owner_id'] as String,
      maxMembers: (json['max_members'] as int?) ?? 5,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
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
