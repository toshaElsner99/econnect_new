class ChannelChatModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata;

  ChannelChatModel({
    this.statusCode,
    this.status,
    this.message,
    this.data,
    this.metadata,
  });

  factory ChannelChatModel.fromJson(Map<String, dynamic> json) {
    return ChannelChatModel(
      statusCode: json['statusCode'],
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      metadata: json['metadata'] != null ? List<dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'status': status,
      'message': message,
      'data': data?.toJson(),
      'metadata': metadata,
    };
  }
}

class Data {
  List<MessageGroup>? messages;
  int? currentPage;
  int? totalPages;
  int? totalMessages;
  int? messagesOnPage;
  int? totalMessagesWithoutReplies;

  Data({
    this.messages,
    this.currentPage,
    this.totalPages,
    this.totalMessages,
    this.messagesOnPage,
    this.totalMessagesWithoutReplies,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      messages: json['messages'] != null
          ? List<MessageGroup>.from(
          json['messages'].map((msg) => MessageGroup.fromJson(msg)))
          : null,
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalMessages: json['totalMessages'],
      messagesOnPage: json['messagesOnPage'],
      totalMessagesWithoutReplies: json['totalMessagesWithoutReplies'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages?.map((msg) => msg.toJson()).toList(),
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalMessages': totalMessages,
      'messagesOnPage': messagesOnPage,
      'totalMessagesWithoutReplies': totalMessagesWithoutReplies,
    };
  }
}

class MessageGroup {
  String? id;
  List<Message>? messages;
  int? count;

  MessageGroup({
    this.id,
    this.messages,
    this.count,
  });

  factory MessageGroup.fromJson(Map<String, dynamic> json) {
    return MessageGroup(
      id: json['_id'],
      messages: json['messages'] != null
          ? List<Message>.from(
          json['messages'].map((msg) => Message.fromJson(msg)))
          : null,
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'messages': messages?.map((msg) => msg.toJson()).toList(),
      'count': count,
    };
  }
}

class Message {
  String? id;
  String? senderId;
  String? channelId;
  String? content;
  List<String>? files;
  bool? isMedia;
  String? replyTo;
  bool? isReply;
  bool? isLog;
  bool? isForwarded;
  bool? isEdited;
  String? forwardFrom;
  List<String>? readBy;
  bool? isSeen;
  bool? isDeleted;
  List<dynamic>? taggedUsers;
  List<dynamic>? reactions;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  bool? isPinned;
  List<Reply>? replies;
  int? replyCount;
  List<SenderInfo>? repliesSenderInfo;
  SenderInfo? senderInfo;
  List<dynamic>? receiverInfo;
  Forward? forwards;
  SenderInfo? senderOfForward;

  Message({
    this.id,
    this.senderId,
    this.channelId,
    this.content,
    this.files,
    this.isMedia,
    this.replyTo,
    this.isReply,
    this.isLog,
    this.isForwarded,
    this.isEdited,
    this.forwardFrom,
    this.readBy,
    this.isSeen,
    this.isDeleted,
    this.taggedUsers,
    this.reactions,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isPinned,
    this.replies,
    this.replyCount,
    this.repliesSenderInfo,
    this.senderInfo,
    this.receiverInfo,
    this.forwards,
    this.senderOfForward,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      senderId: json['senderId'],
      channelId: json['channelId'],
      content: json['content'],
      files: json['files'] != null ? List<String>.from(json['files']) : null,
      isMedia: json['isMedia'],
      replyTo: json['replyTo'],
      isReply: json['isReply'],
      isLog: json['isLog'],
      isForwarded: json['isForwarded'],
      isEdited: json['isEdited'],
      forwardFrom: json['forwardFrom'],
      readBy: json['readBy'] != null ? List<String>.from(json['readBy']) : null,
      isSeen: json['is_seen'],
      isDeleted: json['isDeleted'],
      taggedUsers: json['tagged_users'] != null ? List<dynamic>.from(json['tagged_users']) : null,
      reactions: json['reactions'] != null ? List<dynamic>.from(json['reactions']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'],
      replies: json['replies'] != null
          ? List<Reply>.from(json['replies'].map((reply) => Reply.fromJson(reply)))
          : null,
      isPinned: json['isPinned'],
      replyCount: json['replyCount'],
      repliesSenderInfo: json['repliesSenderInfo'] != null
          ? List<SenderInfo>.from(
          json['repliesSenderInfo'].map((info) => SenderInfo.fromJson(info)))
          : null,
      senderInfo: json['senderInfo'] != null ? SenderInfo.fromJson(json['senderInfo']) : null,
      receiverInfo: json['receiverInfo'] != null ? List<dynamic>.from(json['receiverInfo']) : null,
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
      'replies': replies?.map((reply) => reply.toJson()).toList(),
      'replyCount': replyCount,
      'repliesSenderInfo': repliesSenderInfo?.map((info) => info.toJson()).toList(),
      'senderInfo': senderInfo?.toJson(),
      'receiverInfo': receiverInfo,
      'forwards': forwards?.toJson(),
      'senderOfForward': senderOfForward?.toJson(),
    };
  }
}

class Reply {
  String? id;
  String? senderId;
  String? channelId;
  String? content;
  List<String>? files;
  bool? isReply;
  bool? isLog;
  bool? isForwarded;
  bool? isEdited;
  String? forwardFrom;
  List<String>? readBy;
  bool? isSeen;
  bool? isDeleted;
  List<dynamic>? taggedUsers;
  List<dynamic>? reactions;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Reply({
    this.id,
    this.senderId,
    this.channelId,
    this.content,
    this.files,
    this.isReply,
    this.isLog,
    this.isForwarded,
    this.isEdited,
    this.forwardFrom,
    this.readBy,
    this.isSeen,
    this.isDeleted,
    this.taggedUsers,
    this.reactions,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['_id'],
      senderId: json['senderId'],
      channelId: json['channelId'],
      content: json['content'],
      files: json['files'] != null ? List<String>.from(json['files']) : null,
      isReply: json['isReply'],
      isLog: json['isLog'],
      isForwarded: json['isForwarded'],
      isEdited: json['isEdited'],
      forwardFrom: json['forwardFrom'],
      readBy: json['readBy'] != null ? List<String>.from(json['readBy']) : null,
      isSeen: json['is_seen'],
      isDeleted: json['isDeleted'],
      taggedUsers: json['tagged_users'] != null ? List<dynamic>.from(json['tagged_users']) : null,
      reactions: json['reactions'] != null ? List<dynamic>.from(json['reactions']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'],
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}

class SenderInfo {
  String? id;
  String? username;
  String? email;
  String? status;
  bool? isActive;
  String? customStatus;
  String? customStatusEmoji;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  DateTime? lastActiveTime;
  String? elsnerEmail;

  SenderInfo({
    this.id,
    this.username,
    this.email,
    this.status,
    this.isActive,
    this.customStatus,
    this.customStatusEmoji,
    this.createdAt,
    this.updatedAt,
    this.avatarUrl,
    this.thumbnailAvatarUrl,
    this.lastActiveTime,
    this.elsnerEmail,
  });

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      status: json['status'],
      isActive: json['isActive'],
      customStatus: json['custom_status'],
      customStatusEmoji: json['custom_status_emoji'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      avatarUrl: json['avatarUrl'],
      thumbnailAvatarUrl: json['thumbnail_avatarUrl'],
      lastActiveTime: json['last_active_time'] != null ? DateTime.parse(json['last_active_time']) : null,
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'avatarUrl': avatarUrl,
      'thumbnail_avatarUrl': thumbnailAvatarUrl,
      'last_active_time': lastActiveTime?.toIso8601String(),
      'elsner_email': elsnerEmail,
    };
  }
}

class Forward {
  String? id;
  String? senderId;
  String? channelId;
  String? content;
  List<dynamic>? files;
  String? replyTo;
  bool? isReply;
  bool? isLog;
  bool? isForwarded;
  bool? isEdited;
  String? forwardFrom;
  List<String>? readBy;
  bool? isSeen;
  bool? isDeleted;
  List<dynamic>? taggedUsers;
  List<dynamic>? reactions;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Forward({
    this.id,
    this.senderId,
    this.channelId,
    this.content,
    this.files,
    this.replyTo,
    this.isReply,
    this.isLog,
    this.isForwarded,
    this.isEdited,
    this.forwardFrom,
    this.readBy,
    this.isSeen,
    this.isDeleted,
    this.taggedUsers,
    this.reactions,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Forward.fromJson(Map<String, dynamic> json) {
    return Forward(
      id: json['_id'],
      senderId: json['senderId'],
      channelId: json['channelId'],
      content: json['content'],
      files: json['files'] != null ? List<dynamic>.from(json['files']) : null,
      replyTo: json['replyTo'],
      isReply: json['isReply'],
      isLog: json['isLog'],
      isForwarded: json['isForwarded'],
      isEdited: json['isEdited'],
      forwardFrom: json['forwardFrom'],
      readBy: json['readBy'] != null ? List<String>.from(json['readBy']) : null,
      isSeen: json['is_seen'],
      isDeleted: json['isDeleted'],
      taggedUsers: json['tagged_users'] != null ? List<dynamic>.from(json['tagged_users']) : null,
      reactions: json['reactions'] != null ? List<dynamic>.from(json['reactions']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'],
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}