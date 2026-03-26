import '../../auth/data/auth_repository.dart';

class SoulieRepositoryException implements Exception {
  const SoulieRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SoulieFriend {
  const SoulieFriend({
    required this.id,
    required this.name,
    required this.username,
    required this.status,
    required this.isOnline,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String username;
  final String status;
  final bool isOnline;
  final String avatarUrl;
}

class SoulieUserSuggestion {
  const SoulieUserSuggestion({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.relation,
  });

  final String id;
  final String name;
  final String username;
  final String email;
  final String avatarUrl;
  final String relation;
}

class SoulieFriendRequestData {
  const SoulieFriendRequestData({
    required this.id,
    required this.direction,
    required this.status,
    required this.createdAt,
    required this.user,
  });

  final String id;
  final String direction;
  final String status;
  final String createdAt;
  final SoulieFriend user;
}

class SoulieFriendRequestsData {
  const SoulieFriendRequestsData({
    required this.incoming,
    required this.outgoing,
  });

  final List<SoulieFriendRequestData> incoming;
  final List<SoulieFriendRequestData> outgoing;
}

class SoulieChatPreview {
  const SoulieChatPreview({
    required this.friendId,
    required this.friendName,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    required this.unread,
    required this.isPhoto,
  });

  final String friendId;
  final String friendName;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final int unread;
  final bool isPhoto;
}

class SoulieChatMessageData {
  const SoulieChatMessageData({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    required this.type,
    this.mediaUrl,
  });

  final String id;
  final String text;
  final bool isMe;
  final String time;
  final String type;
  final String? mediaUrl;
}

class SoulieChatThread {
  const SoulieChatThread({
    required this.conversationId,
    required this.friend,
    required this.messages,
  });

  final String conversationId;
  final SoulieFriend friend;
  final List<SoulieChatMessageData> messages;
}

class SoulieJournalEntryData {
  const SoulieJournalEntryData({
    required this.id,
    required this.timeLabel,
    required this.friendName,
    this.caption,
    this.imageUrl,
  });

  final String id;
  final String timeLabel;
  final String friendName;
  final String? caption;
  final String? imageUrl;
}

class SoulieJournalData {
  const SoulieJournalData({
    required this.totalSent,
    required this.totalReceived,
    required this.totalFriends,
    required this.streakDays,
    required this.sentEntries,
    required this.receivedEntries,
  });

  final int totalSent;
  final int totalReceived;
  final int totalFriends;
  final int streakDays;
  final List<SoulieJournalEntryData> sentEntries;
  final List<SoulieJournalEntryData> receivedEntries;
}

class SoulieProfileData {
  const SoulieProfileData({
    required this.id,
    required this.email,
    required this.displayName,
    required this.username,
    required this.avatarUrl,
    required this.totalSent,
    required this.totalReceived,
    required this.friendCount,
    required this.streakDays,
  });

  final String id;
  final String email;
  final String displayName;
  final String username;
  final String avatarUrl;
  final int totalSent;
  final int totalReceived;
  final int friendCount;
  final int streakDays;
}

class SoulieCameraRecipient {
  const SoulieCameraRecipient({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isGroup,
    required this.isOnline,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final bool isGroup;
  final bool isOnline;
}

class SoulieFriendActivityData {
  const SoulieFriendActivityData({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.timeAgo,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final String timeAgo;
  final String? imageUrl;
}

class SoulieHomeFriendData {
  const SoulieHomeFriendData({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isOnline,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;
}

class SoulieHomeData {
  const SoulieHomeData({
    required this.recentlyShared,
    required this.friendsGrid,
    required this.liveFeedMessage,
    required this.notificationCount,
  });

  final List<SoulieFriendActivityData> recentlyShared;
  final List<SoulieHomeFriendData> friendsGrid;
  final String liveFeedMessage;
  final int notificationCount;
}

class SoulieRepository {
  SoulieRepository({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<List<SoulieFriend>> fetchFriends({String query = ''}) async {
    final data = await _getJson(
      '/soulie/friends${query.trim().isEmpty ? '' : '?q=${Uri.encodeQueryComponent(query.trim())}'}',
    );
    final friends = _readList(data, 'friends');
    return friends.map(_friendFromJson).toList(growable: false);
  }

  Future<List<SoulieUserSuggestion>> discoverUsers({String query = ''}) async {
    final suggestions = await _getJsonList(
      '/soulie/friends/discover${query.trim().isEmpty ? '' : '?q=${Uri.encodeQueryComponent(query.trim())}'}',
    );
    return suggestions
        .map(
          (item) => SoulieUserSuggestion(
            id: _readString(item, 'id'),
            name: _readString(item, 'name'),
            username: _readString(item, 'username'),
            email: _readString(item, 'email'),
            avatarUrl: _readStringOrEmpty(item, 'avatarUrl'),
            relation: _readString(item, 'relation'),
          ),
        )
        .toList(growable: false);
  }

  Future<SoulieFriendRequestsData> fetchFriendRequests() async {
    final data = await _getJson('/soulie/friends/requests');
    return SoulieFriendRequestsData(
      incoming: _readList(data, 'incoming')
          .map(_friendRequestFromJson)
          .toList(growable: false),
      outgoing: _readList(data, 'outgoing')
          .map(_friendRequestFromJson)
          .toList(growable: false),
    );
  }

  Future<void> createFriendRequest({required String targetUserId}) async {
    await _authRepository.sendAuthenticatedRequest(
      method: 'POST',
      path: '/soulie/friends/requests',
      body: {'targetUserId': targetUserId},
    );
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await _authRepository.sendAuthenticatedRequest(
      method: 'POST',
      path: '/soulie/friends/requests/$requestId/accept',
    );
  }

  Future<void> rejectFriendRequest(String requestId) async {
    await _authRepository.sendAuthenticatedRequest(
      method: 'POST',
      path: '/soulie/friends/requests/$requestId/reject',
    );
  }

  Future<void> removeFriend(String friendKey) async {
    await _authRepository.sendAuthenticatedRequest(
      method: 'DELETE',
      path: '/soulie/friends/$friendKey',
    );
  }

  Future<List<SoulieChatPreview>> fetchChats({String query = ''}) async {
    final data = await _getJson(
      '/soulie/chats${query.trim().isEmpty ? '' : '?q=${Uri.encodeQueryComponent(query.trim())}'}',
    );
    final chats = _readList(data, 'chats');
    return chats.map(_chatPreviewFromJson).toList(growable: false);
  }

  Future<SoulieChatThread> fetchChatThread(String friendKey) async {
    final data = await _getJson('/soulie/chats/$friendKey/messages');
    return SoulieChatThread(
      conversationId: '',
      friend: _friendFromJson(_readMap(data, 'friend')),
      messages: _readList(data, 'messages')
          .map(_chatMessageFromJson)
          .toList(growable: false),
    );
  }

  Future<String> openDirectConversation(String friendId) async {
    final data = await _authRepository.sendAuthenticatedRequest(
      method: 'POST',
      path: '/soulie/conversations/direct',
      body: {'friendId': friendId},
    );

    if (data is! Map<String, dynamic>) {
      throw const SoulieRepositoryException(
        'Phản hồi mở cuộc trò chuyện không hợp lệ',
      );
    }

    return _readString(data, 'conversationId');
  }

  Future<SoulieChatThread> fetchConversationThread(String conversationId) async {
    final data = await _getJson('/soulie/conversations/$conversationId/messages');
    return SoulieChatThread(
      conversationId: _readString(data, 'conversationId'),
      friend: _friendFromJson(_readMap(data, 'friend')),
      messages: _readList(data, 'messages')
          .map(_chatMessageFromJson)
          .toList(growable: false),
    );
  }

  Future<SoulieChatMessageData> sendChatMessage({
    required String friendKey,
    required String message,
  }) async {
    final data = await _authRepository.sendAuthenticatedRequest(
      method: 'POST',
      path: '/soulie/chats/$friendKey/messages',
      body: {'text': message},
    );

    if (data is! Map<String, dynamic>) {
      throw const SoulieRepositoryException('Phản hồi gửi tin nhắn không hợp lệ');
    }

    return _chatMessageFromJson(data);
  }

  Future<SoulieChatMessageData> sendConversationMessage({
    required String conversationId,
    required String message,
  }) async {
    final data = await _authRepository.sendAuthenticatedRequest(
      method: 'POST',
      path: '/soulie/conversations/$conversationId/messages',
      body: {'text': message},
    );

    if (data is! Map<String, dynamic>) {
      throw const SoulieRepositoryException('Phản hồi gửi tin nhắn không hợp lệ');
    }

    return _chatMessageFromJson(data);
  }

  Future<void> markConversationRead(String conversationId) async {
    await _authRepository.sendAuthenticatedRequest(
      method: 'POST',
      path: '/soulie/conversations/$conversationId/read',
    );
  }

  Future<SoulieJournalData> fetchJournal() async {
    final data = await _getJson('/soulie/journal');
    return SoulieJournalData(
      totalSent: _readInt(data, 'totalSent'),
      totalReceived: _readInt(data, 'totalReceived'),
      totalFriends: _readInt(data, 'totalFriends'),
      streakDays: _readInt(data, 'streakDays'),
      sentEntries: _readList(data, 'sentEntries')
          .map(_journalEntryFromJson)
          .toList(growable: false),
      receivedEntries: _readList(data, 'receivedEntries')
          .map(_journalEntryFromJson)
          .toList(growable: false),
    );
  }

  Future<SoulieProfileData> fetchProfile() async {
    final data = await _getJson('/soulie/profile');
    return SoulieProfileData(
      id: _readString(data, 'id'),
      email: _readString(data, 'email'),
      displayName: _readString(data, 'displayName'),
      username: _readString(data, 'username'),
      avatarUrl: _readStringOrEmpty(data, 'avatarUrl'),
      totalSent: _readInt(data, 'totalSent'),
      totalReceived: _readInt(data, 'totalReceived'),
      friendCount: _readInt(data, 'friendCount'),
      streakDays: _readInt(data, 'streakDays'),
    );
  }

  Future<List<SoulieCameraRecipient>> fetchCameraRecipients() async {
    final data = await _getJson('/soulie/camera/recipients');
    final recipients = _readList(data, 'recipients');
    return recipients.map((item) {
      return SoulieCameraRecipient(
        id: _readString(item, 'id'),
        name: _readString(item, 'name'),
        avatarUrl: _readStringOrEmpty(item, 'avatarUrl'),
        isGroup: _readBool(item, 'isGroup'),
        isOnline: _readBool(item, 'isOnline'),
      );
    }).toList(growable: false);
  }

  Future<void> createMoment({
    required List<String> recipientIds,
    String? caption,
  }) async {
    await _authRepository.sendAuthenticatedRequest(
      method: 'POST',
      path: '/soulie/moments',
      body: {
        'recipientIds': recipientIds,
        if (caption != null && caption.trim().isNotEmpty) 'caption': caption.trim(),
      },
    );
  }

  Future<void> markMomentOpened(String momentId) async {
    await _authRepository.sendAuthenticatedRequest(
      method: 'POST',
      path: '/soulie/moments/$momentId/opened',
    );
  }

  Future<SoulieHomeData> fetchHome() async {
    final data = await _getJson('/soulie/home');
    return SoulieHomeData(
      recentlyShared: _readList(data, 'recentlyShared')
          .map((item) => SoulieFriendActivityData(
                id: _readString(item, 'id'),
                name: _readString(item, 'name'),
                avatarUrl: _readStringOrEmpty(item, 'avatarUrl'),
                timeAgo: _readStringOrEmpty(item, 'timeAgo'),
                imageUrl: _readNullableString(item, 'imageUrl'),
              ))
          .toList(growable: false),
      friendsGrid: _readList(data, 'friendsGrid')
          .map((item) => SoulieHomeFriendData(
                id: _readString(item, 'id'),
                name: _readString(item, 'name'),
                avatarUrl: _readStringOrEmpty(item, 'avatarUrl'),
                isOnline: _readBool(item, 'isOnline'),
              ))
          .toList(growable: false),
      liveFeedMessage: _readStringOrEmpty(data, 'liveFeedMessage'),
      notificationCount: _readInt(data, 'notificationCount'),
    );
  }

  Future<SoulieProfileData> updateProfile({
    String? displayName,
    String? username,
    String? avatarUrl,
  }) async {
    final payload = <String, dynamic>{};
    if (displayName != null) {
      payload['displayName'] = displayName.trim();
    }
    if (username != null) {
      payload['username'] = username.trim();
    }
    if (avatarUrl != null) {
      payload['avatarUrl'] = avatarUrl.trim();
    }

    final data = await _authRepository.sendAuthenticatedRequest(
      method: 'PATCH',
      path: '/soulie/profile',
      body: payload,
    );

    if (data is! Map<String, dynamic>) {
      throw const SoulieRepositoryException('Phản hồi cập nhật hồ sơ không hợp lệ');
    }

    return SoulieProfileData(
      id: _readString(data, 'id'),
      email: _readString(data, 'email'),
      displayName: _readString(data, 'displayName'),
      username: _readString(data, 'username'),
      avatarUrl: _readStringOrEmpty(data, 'avatarUrl'),
      totalSent: _readInt(data, 'totalSent'),
      totalReceived: _readInt(data, 'totalReceived'),
      friendCount: _readInt(data, 'friendCount'),
      streakDays: _readInt(data, 'streakDays'),
    );
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    final data = await _authRepository.sendAuthenticatedRequest(
      method: 'GET',
      path: path,
    );

    if (data is! Map<String, dynamic>) {
      throw const SoulieRepositoryException('Phản hồi API không đúng định dạng');
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> _getJsonList(String path) async {
    final data = await _authRepository.sendAuthenticatedRequest(
      method: 'GET',
      path: path,
    );

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList(growable: false);
    }

    throw const SoulieRepositoryException('Phản hồi API không đúng định dạng');
  }

  SoulieFriend _friendFromJson(Map<String, dynamic> json) {
    return SoulieFriend(
      id: _readString(json, 'id'),
      name: _readString(json, 'name'),
      username: _readString(json, 'username'),
      status: _readStringOrEmpty(json, 'status'),
      isOnline: _readBool(json, 'isOnline'),
      avatarUrl: _readStringOrEmpty(json, 'avatarUrl'),
    );
  }

  SoulieFriendRequestData _friendRequestFromJson(Map<String, dynamic> json) {
    return SoulieFriendRequestData(
      id: _readString(json, 'id'),
      direction: _readString(json, 'direction'),
      status: _readString(json, 'status'),
      createdAt: _readString(json, 'createdAt'),
      user: _friendFromJson(_readMap(json, 'user')),
    );
  }

  SoulieChatPreview _chatPreviewFromJson(Map<String, dynamic> json) {
    final friendName = _readStringOrEmpty(json, 'friendName');
    return SoulieChatPreview(
      friendId: _readString(json, 'friendId'),
      friendName: friendName.isNotEmpty ? friendName : _readString(json, 'name'),
      avatarUrl: _readStringOrEmpty(json, 'avatarUrl'),
      lastMessage: _readStringOrEmpty(json, 'lastMessage'),
      time: _readStringOrEmpty(json, 'time'),
      isOnline: _readBool(json, 'isOnline'),
      unread: _readInt(json, 'unread'),
      isPhoto: _readBool(json, 'isPhoto'),
    );
  }

  SoulieChatMessageData _chatMessageFromJson(Map<String, dynamic> json) {
    return SoulieChatMessageData(
      id: _readString(json, 'id'),
      text: _readStringOrEmpty(json, 'text'),
      isMe: _readBool(json, 'isMe'),
      time: _readStringOrEmpty(json, 'time'),
      type: _readString(json, 'type'),
      mediaUrl: _readNullableString(json, 'mediaUrl'),
    );
  }

  SoulieJournalEntryData _journalEntryFromJson(Map<String, dynamic> json) {
    return SoulieJournalEntryData(
      id: _readString(json, 'id'),
      timeLabel: _readString(json, 'timeLabel'),
      friendName: _readString(json, 'friendName'),
      caption: _readNullableString(json, 'caption'),
      imageUrl: _readNullableString(json, 'imageUrl'),
    );
  }

  Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw SoulieRepositoryException('Thiếu object `$key` trong phản hồi');
  }

  List<Map<String, dynamic>> _readList(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList(growable: false);
    }

    return const [];
  }

  String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    if (value is int) {
      return value.toString();
    }

    throw SoulieRepositoryException('Thiếu trường `$key` trong phản hồi');
  }

  String _readStringOrEmpty(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      return value;
    }
    if (value is int) {
      return value.toString();
    }

    return '';
  }

  String? _readNullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }

    return null;
  }

  int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  bool _readBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is bool ? value : false;
  }
}
