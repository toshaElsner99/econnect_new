class ChannelChatModel {
  final int statusCode;
  final int status;
  final String message;
  final Data data;
  final List<dynamic> metadata;

  ChannelChatModel({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
    required this.metadata,
  });

  factory ChannelChatModel.fromJson(Map<String, dynamic> json) {
    return ChannelChatModel(
      statusCode: json['statusCode'],
      status: json['status'],
      message: json['message'],
      data: Data.fromJson(json['data']),
      metadata: List<dynamic>.from(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'status': status,
      'message': message,
      'data': data.toJson(),
      'metadata': metadata,
    };
  }
}

class Data {
  final List<MessageGroup> messages;
  final int currentPage;
  final int totalPages;
  final int totalMessages;
  final int messagesOnPage;
  final int totalMessagesWithoutReplies;

  Data({
    required this.messages,
    required this.currentPage,
    required this.totalPages,
    required this.totalMessages,
    required this.messagesOnPage,
    required this.totalMessagesWithoutReplies,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      messages: json['messages'] != null
          ? List<MessageGroup>.from(
          json['messages'].map((msg) => MessageGroup.fromJson(msg)))
          : [],
      currentPage: json['currentPage'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      totalMessages: json['totalMessages'] ?? 0,
      messagesOnPage: json['messagesOnPage'] ?? 0,
      totalMessagesWithoutReplies: json['totalMessagesWithoutReplies'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalMessages': totalMessages,
      'messagesOnPage': messagesOnPage,
      'totalMessagesWithoutReplies': totalMessagesWithoutReplies,
    };
  }
}

class MessageGroup {
  final String id;
  final List<Message> messages;
  final int count;

  MessageGroup({
    required this.id,
    required this.messages,
    required this.count,
  });

  factory MessageGroup.fromJson(Map<String, dynamic> json) {
    return MessageGroup(
      id: json['_id'],
      messages: json['messages'] != null
          ? List<Message>.from(
          json['messages'].map((msg) => Message.fromJson(msg)))
          : [],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'count': count,
    };
  }
}

class Message {
  final String id;
  final String senderId;
  final String channelId;
  final String content;
  final List<String> files;
  final bool isMedia;
  final String? replyTo;
  final bool isReply;
  final bool isLog;
  final bool isForwarded;
  final bool isEdited;
  final String? forwardFrom;
  final List<String> readBy;
  final bool isSeen;
  final bool isDeleted;
  final List<dynamic> taggedUsers;
  final List<dynamic> reactions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final bool isPinned;
  final List<Reply>? replies;
  final int replyCount;
  final List<SenderInfo> repliesSenderInfo;
  final SenderInfo senderInfo;
  final List<dynamic> receiverInfo;
  final Forward? forwards;
  final SenderInfo? senderOfForward; // Make this nullable

  Message({
    required this.id,
    required this.senderId,
    required this.channelId,
    required this.content,
    required this.files,
    required this.isMedia,
    this.replyTo,
    required this.isReply,
    required this.isLog,
    required this.isForwarded,
    required this.isEdited,
    this.forwardFrom,
    required this.readBy,
    required this.isSeen,
    required this.isDeleted,
    required this.taggedUsers,
    required this.reactions,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.isPinned,
    this.replies,
    required this.replyCount,
    required this.repliesSenderInfo,
    required this.senderInfo,
    required this.receiverInfo,
    this.forwards,
    this.senderOfForward,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      senderId: json['senderId'],
      channelId: json['channelId'],
      content: json['content'],
      files: List<String>.from(json['files'] ?? []),
      isMedia: json['isMedia'] ?? false,
      replyTo: json['replyTo'],
      isReply: json['isReply'] ?? false,
      isLog: json['isLog'] ?? false,
      isForwarded: json['isForwarded'] ?? false,
      isEdited: json['isEdited'] ?? false,
      forwardFrom: json['forwardFrom'],
      readBy: List<String>.from(json['readBy'] ?? []),
      isSeen: json['is_seen'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      taggedUsers: List<dynamic>.from(json['tagged_users'] ?? []),
      reactions: List<dynamic>.from(json['reactions'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
      replies: json['replies'] != null
          ? List<Reply>.from(json['replies'].map((reply) => Reply.fromJson(reply)))
          : null,
      isPinned: json['isPinned'] ?? false,
      replyCount: json['replyCount'] ?? 0,
      repliesSenderInfo: List<SenderInfo>.from(
          json['repliesSenderInfo']?.map((info) => SenderInfo.fromJson(info)) ?? []),
      senderInfo: SenderInfo.fromJson(json['senderInfo']),
      receiverInfo: List<dynamic>.from(json['receiverInfo'] ?? []),
      forwards: json['forwards'] != null ? Forward.fromJson(json['forwards']) : null,
      senderOfForward: json['senderOfForward'] != null ? SenderInfo.fromJson(json['senderOfForward']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'channelId': channelId,
      'content': content,
      'files': files,
      'isMedia': isMedia,
      'replyTo': replyTo,
      'isReply': isReply,
      'isLog': isLog,
      'isForwarded': isForwarded,
      'isEdited': isEdited,
      'forwardFrom': forwardFrom,
      'readBy': readBy,
      'is_seen': isSeen,
      'isDeleted': isDeleted,
      'tagged_users': taggedUsers,
      'reactions': reactions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'replies': replies?.map((reply) => reply.toJson()).toList(),
      'replyCount': replyCount,
      'repliesSenderInfo': repliesSenderInfo.map((info) => info.toJson()).toList(),
      'senderInfo': senderInfo.toJson(),
      'receiverInfo': receiverInfo,
      'forwards': forwards?.toJson(),
      'senderOfForward': senderOfForward?.toJson(),
    };
  }
}

class Reply {
  final String id;
  final String senderId;
  final String channelId;
  final String content;
  final List<String> files;
  final bool isReply;
  final bool isLog;
  final bool isForwarded;
  final bool isEdited;
  final String? forwardFrom;
  final List<String> readBy;
  final bool isSeen;
  final bool isDeleted;
  final List<dynamic> taggedUsers;
  final List<dynamic> reactions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Reply({
    required this.id,
    required this.senderId,
    required this.channelId,
    required this.content,
    required this.files,
    required this.isReply,
    required this.isLog,
    required this.isForwarded,
    required this.isEdited,
    this.forwardFrom,
    required this.readBy ,
    required this.isSeen,
    required this.isDeleted,
    required this.taggedUsers,
    required this.reactions,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['_id'],
      senderId: json['senderId'],
      channelId: json['channelId'],
      content: json['content'],
      files: List<String>.from(json['files'] ?? []),
      isReply: json['isReply'] ?? false,
      isLog: json['isLog'] ?? false,
      isForwarded: json['isForwarded'] ?? false,
      isEdited: json['isEdited'] ?? false,
      forwardFrom: json['forwardFrom'],
      readBy: List<String>.from(json['readBy'] ?? []),
      isSeen: json['is_seen'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      taggedUsers: List<dynamic>.from(json['tagged_users'] ?? []),
      reactions: List<dynamic>.from(json['reactions'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'channelId': channelId,
      'content': content,
      'files': files,
      'isReply': isReply,
      'isLog': isLog,
      'isForwarded': isForwarded,
      'isEdited': isEdited,
      'forwardFrom': forwardFrom,
      'readBy': readBy,
      'is_seen': isSeen,
      'isDeleted': isDeleted,
      'tagged_users': taggedUsers,
      'reactions': reactions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class SenderInfo {
  final String id;
  final String username;
  final String email;
  final String status;
  final bool isActive;
  final String? customStatus;
  final String? customStatusEmoji;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String avatarUrl;
  final String thumbnailAvatarUrl;
  final DateTime lastActiveTime;
  final String elsnerEmail;

  SenderInfo({
    required this.id,
    required this.username,
    required this.email,
    required this.status,
    required this.isActive,
    this.customStatus,
    this.customStatusEmoji,
    required this.createdAt,
    required this.updatedAt,
    required this.avatarUrl,
    required this.thumbnailAvatarUrl,
    required this.lastActiveTime,
    required this.elsnerEmail,
  });

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      status: json['status'],
      isActive: json['isActive'] ?? false,
      customStatus: json['custom_status'],
      customStatusEmoji: json['custom_status_emoji'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      avatarUrl: json['avatarUrl'],
      thumbnailAvatarUrl: json['thumbnail_avatarUrl'],
      lastActiveTime: DateTime.parse(json['last_active_time']),
      elsnerEmail: json['elsner_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'status': status,
      'isActive': isActive,
      'custom_status': customStatus,
      'custom_status_emoji': customStatusEmoji,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'avatarUrl': avatarUrl,
      'thumbnail_avatarUrl': thumbnailAvatarUrl,
      'last_active_time': lastActiveTime.toIso8601String(),
      'elsner_email': elsnerEmail,
    };
  }
}

class Forward {
  final String id;
  final String senderId;
  final String channelId;
  final String content;
  final List<dynamic> files;
  final String? replyTo;
  final bool isReply;
  final bool isLog;
  final bool isForwarded;
  final bool isEdited;
  final String? forwardFrom;
  final List<String> readBy;
  final bool isSeen;
  final bool isDeleted;
  final List<dynamic> taggedUsers;
  final List<dynamic> reactions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Forward({
  required this.id,
  required this.senderId,
  required this.channelId,
  required this.content,
  required this.files,
  this.replyTo,
  required this.isReply,
  required this.isLog,
  required this.isForwarded,
  required this.isEdited,
  this.forwardFrom,
  required this.readBy,
  required this.isSeen,
  required this.isDeleted,
  required this.taggedUsers,
  required this.reactions,
  required this.createdAt,
  required this.updatedAt,
  required this.v,
  });

  factory Forward.fromJson(Map<String, dynamic> json) {
  return Forward(
  id: json['_id'],
  senderId: json['senderId'],
  channelId: json['channelId'],
  content: json['content'],
  files: List<dynamic>.from(json['files'] ?? []),
  replyTo: json['replyTo'],
  isReply: json['isReply'] ?? false,
  isLog: json['isLog'] ?? false,
  isForwarded: json['isForwarded'] ?? false,
  isEdited: json['isEdited'] ?? false,
  forwardFrom: json['forwardFrom'],
  readBy: List<String>.from(json['readBy'] ?? []),
  isSeen: json['is_seen'] ?? false,
  isDeleted: json['isDeleted'] ?? false,
  taggedUsers: List<dynamic>.from(json['tagged_users'] ?? []),
  reactions: List<dynamic>.from(json['reactions'] ?? []),
  createdAt: DateTime.parse(json['createdAt']),
  updatedAt: DateTime.parse(json['updatedAt']),
  v: json['__v'] ?? 0,
  );
  }

  Map<String, dynamic> toJson() {
  return {
  '_id': id,
  'senderId': senderId,
  'channelId': channelId,
  'content': content,
  'files': files,
  'replyTo': replyTo,
  'isReply': isReply,
  'isLog': isLog,
  'isForwarded': isForwarded,
  'isEdited': isEdited,
  'forwardFrom': forwardFrom,
  'readBy': readBy,
  'is_seen': isSeen,
  'isDeleted': isDeleted,
  'tagged_users': taggedUsers,
  'reactions': reactions,
  'createdAt': createdAt.toIso8601String(),
  'updatedAt': updatedAt.toIso8601String(),
  '__v': v,
  };
  }
}