class MessageModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  // List<Null>? metadata;

  MessageModel(
      {this.statusCode, this.status, this.message, this.data,
        // this.metadata
      });

  MessageModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    if (json['metadata'] != null) {
      // metadata = <Null>[];
      // json['metadata'].forEach((v) {
      //   metadata!.add(new Null.fromJson(v));
      // });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    // if (this.metadata != null) {
    //   data['metadata'] = this.metadata!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class Data {
  List<MessageGroups>? messageGroups;
  int? currentPage;
  int? messagesOnPage;
  int? totalPages;
  int? totalMessages;
  int? totalMessagesWithoutReplies;

  Data(
      {this.messageGroups,
        this.currentPage,
        this.messagesOnPage,
        this.totalPages,
        this.totalMessages,
        this.totalMessagesWithoutReplies});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['messageGroups'] != null) {
      messageGroups = <MessageGroups>[];
      json['messageGroups'].forEach((v) {
        messageGroups!.add(new MessageGroups.fromJson(v));
      });
    }
    currentPage = json['currentPage'];
    messagesOnPage = json['messagesOnPage'];
    totalPages = json['totalPages'];
    totalMessages = json['totalMessages'];
    totalMessagesWithoutReplies = json['totalMessagesWithoutReplies'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.messageGroups != null) {
      data['messageGroups'] =
          this.messageGroups!.map((v) => v.toJson()).toList();
    }
    data['currentPage'] = this.currentPage;
    data['messagesOnPage'] = this.messagesOnPage;
    data['totalPages'] = this.totalPages;
    data['totalMessages'] = this.totalMessages;
    data['totalMessagesWithoutReplies'] = this.totalMessagesWithoutReplies;
    return data;
  }
}

class MessageGroups {
  String? sId;
  List<Messages>? messages;
  int? count;

  MessageGroups({this.sId, this.messages, this.count});

  MessageGroups.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(new Messages.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    data['count'] = this.count;
    return data;
  }
}

class Messages {
  String? sId;
  String? senderId;
  String? receiverId;
  String? content;
  List<String>? files;
  bool? isReply;
  bool? isLog;
  bool? isForwarded;
  bool? isEdited;
  List<Null>? readBy;
  bool? isSeen;
  bool? isDeleted;
  List<Null>? taggedUsers;
  List<Reaction>? reactions;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<Replies>? replies;
  int? replyCount;
  List<RepliesSenderInfo>? repliesSenderInfo;
  bool? isMedia;
  bool? isPinned;
  Forward? forwardInfo;
  SenderOfForward? senderOfForward;

  Messages({
    this.sId,
    this.senderId,
    this.receiverId,
    this.content,
    this.files,
    this.isReply,
    this.isLog,
    this.isForwarded,
    this.isEdited,
    this.readBy,
    this.isSeen,
    this.isDeleted,
    this.taggedUsers,
    this.reactions,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.replies,
    this.replyCount,
    this.repliesSenderInfo,
    this.isMedia,
    this.isPinned,
    this.forwardInfo,
    this.senderOfForward,
  });

  Messages.fromJson(Map<String, dynamic> json) {
    try {
      sId = json['_id'];
      senderId = json['senderId'];
      receiverId = json['receiverId'];
      content = json['content'];
      files = json['files']?.cast<String>();
      isReply = json['isReply'];
      isLog = json['isLog'];
      isForwarded = json['isForwarded'];
      isEdited = json['isEdited'];

      if (json['readBy'] != null) {
        readBy = <Null>[];
        json['readBy'].forEach((v) {
          // readBy!.add(new Null.fromJson(v));
        });
      }

      isSeen = json['is_seen'];
      isDeleted = json['isDeleted'];

      if (json['tagged_users'] != null) {
        taggedUsers = <Null>[];
        json['tagged_users'].forEach((v) {
          // taggedUsers!.add(new Null.fromJson(v));
        });
      }

      if (json['reactions'] != null) {
        reactions = <Reaction>[];
        json['reactions'].forEach((v) {
          reactions!.add(Reaction.fromJson(v));
        });
      }

      createdAt = json['createdAt'];
      updatedAt = json['updatedAt'];
      iV = json['__v'];

      if (json['replies'] != null) {
        replies = <Replies>[];
        json['replies'].forEach((v) {
          replies!.add(Replies.fromJson(v));
        });
      }

      replyCount = json['replyCount'] ?? 0;
      if (json['repliesSenderInfo'] != null) {
        repliesSenderInfo = <RepliesSenderInfo>[];
        json['repliesSenderInfo'].forEach((v) {
          repliesSenderInfo!.add(RepliesSenderInfo.fromJson(v));
        });
      }

      isMedia = json['isMedia'];
      isPinned = json['isPinned'];

      if (json['forwards'] != null) {
        forwardInfo = Forward.fromJson(json['forwards']);
      }
      
      if (json['senderOfForward'] != null) {
        senderOfForward = SenderOfForward.fromJson(json['senderOfForward']);
      }
    } catch (e) {
      print("Error parsing Messages: $e");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['senderId'] = this.senderId;
    data['receiverId'] = this.receiverId;
    data['content'] = this.content;
    data['files'] = this.files;
    data['isReply'] = this.isReply;
    data['isLog'] = this.isLog;
    data['isForwarded'] = this.isForwarded;
    data['isEdited'] = this.isEdited;

    if (this.readBy != null) {
      // data['readBy'] = this.readBy!.map((v) => v.toJson()).toList();
    }

    data['is_seen'] = this.isSeen;
    data['isDeleted'] = this.isDeleted;

    if (this.taggedUsers != null) {
      // data['tagged_users'] = this.taggedUsers!.map((v) => v.toJson()).toList();
    }

    if (this.reactions != null) {
      // data['reactions'] = this.reactions!.map((v) => v.toJson()).toList();
    }

    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;

    if (this.replies != null) {
      data['replies'] = this.replies!.map((v) => v.toJson()).toList();
    }

    data['replyCount'] = this.replyCount ?? 0;
    if (this.repliesSenderInfo != null) {
      data['repliesSenderInfo'] =
          this.repliesSenderInfo!.map((v) => v.toJson()).toList();
    }

    data['isMedia'] = this.isMedia;
    data['isPinned'] = this.isPinned;

    // Serialize forwardInfo if it exists
    if (this.forwardInfo != null) {
      data['forwards'] = this.forwardInfo!.toJson();
    }
    if (this.senderOfForward != null) {
      data['senderOfForward'] = this.senderOfForward!.toJson();
    }

    return data;
  }
}

class Reaction {
  String? emoji;
  String? userId;
  String? id;
  String? username;

  Reaction({
    this.emoji,
    this.userId,
    this.id,
    this.username,
  });

  Reaction.fromJson(Map<String, dynamic> json) {
    emoji = json['emoji'];
    userId = json['userId'];
    id = json['_id'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['emoji'] = emoji;
    data['userId'] = userId;
    data['_id'] = id;
    data['username'] = username;
    return data;
  }
}

class Replies {
  String? sId;
  String? senderId;
  String? receiverId;
  String? content;
  List<Null>? files;
  String? replyTo;
  bool? isReply;
  bool? isLog;
  bool? isForwarded;
  bool? isEdited;
  // Null? forwardFrom;
  List<Null>? readBy;
  bool? isSeen;
  bool? isDeleted;
  List<Null>? taggedUsers;
  List<Null>? reactions;
  String? createdAt;
  String? updatedAt;
  int? iV;
  SenderInfo? senderInfo;

  Replies(
      {this.sId,
        this.senderId,
        this.receiverId,
        this.content,
        this.files,
        this.replyTo,
        this.isReply,
        this.isLog,
        this.isForwarded,
        this.isEdited,
        // this.forwardFrom,
        this.readBy,
        this.isSeen,
        this.isDeleted,
        this.taggedUsers,
        this.reactions,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.senderInfo});

  Replies.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    content = json['content'];
    if (json['files'] != null) {
      files = <Null>[];
      json['files'].forEach((v) {
        // files!.add(new Null.fromJson(v));
      });
    }
    replyTo = json['replyTo'];
    isReply = json['isReply'];
    isLog = json['isLog'];
    isForwarded = json['isForwarded'];
    isEdited = json['isEdited'];
    // forwardFrom = json['forwardFrom'];
    if (json['readBy'] != null) {
      readBy = <Null>[];
      json['readBy'].forEach((v) {
        // readBy!.add(new Null.fromJson(v));
      });
    }
    isSeen = json['is_seen'];
    isDeleted = json['isDeleted'];
    if (json['tagged_users'] != null) {
      taggedUsers = <Null>[];
      json['tagged_users'].forEach((v) {
        // taggedUsers!.add(new Null.fromJson(v));
      });
    }
    if (json['reactions'] != null) {
      reactions = <Null>[];
      json['reactions'].forEach((v) {
        // reactions!.add(new Null.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    senderInfo = json['senderInfo'] != null
        ? new SenderInfo.fromJson(json['senderInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['senderId'] = this.senderId;
    data['receiverId'] = this.receiverId;
    data['content'] = this.content;
    if (this.files != null) {
      // data['files'] = this.files!.map((v) => v.toJson()).toList();
    }
    data['replyTo'] = this.replyTo;
    data['isReply'] = this.isReply;
    data['isLog'] = this.isLog;
    data['isForwarded'] = this.isForwarded;
    data['isEdited'] = this.isEdited;
    // data['forwardFrom'] = this.forwardFrom;
    if (this.readBy != null) {
      // data['readBy'] = this.readBy!.map((v) => v.toJson()).toList();
    }
    data['is_seen'] = this.isSeen;
    data['isDeleted'] = this.isDeleted;
    if (this.taggedUsers != null) {
      // data['tagged_users'] = this.taggedUsers!.map((v) => v.toJson()).toList();
    }
    if (this.reactions != null) {
      // data['reactions'] = this.reactions!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.senderInfo != null) {
      data['senderInfo'] = this.senderInfo!.toJson();
    }
    return data;
  }
}

class SenderInfo {
  String? sId;
  String? fullName;
  String? username;
  String? email;
  String? status;
  bool? isActive;
  String? customStatus;
  String? customStatusEmoji;
  String? createdAt;
  String? updatedAt;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  String? lastActiveTime;
  String? elsnerEmail;

  SenderInfo(
      {this.sId,
        this.fullName,
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
        this.elsnerEmail});

  SenderInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    status = json['status'];
    isActive = json['isActive'];
    customStatus = json['custom_status'];
    customStatusEmoji = json['custom_status_emoji'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    lastActiveTime = json['last_active_time'];
    elsnerEmail = json['elsner_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['username'] = this.username;
    data['email'] = this.email;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    data['custom_status'] = this.customStatus;
    data['custom_status_emoji'] = this.customStatusEmoji;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['avatarUrl'] = this.avatarUrl;
    data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
    data['last_active_time'] = this.lastActiveTime;
    data['elsner_email'] = this.elsnerEmail;
    return data;
  }
}

class Forward {
  String id;
  String senderId;
  String receiverId;
  String channelId;
  String content;
  List<String> files;
  String? replyTo;
  bool isReply;
  bool isLog;
  bool isForwarded;
  bool isEdited;
  String? forwardFrom;
  List<String> readBy;
  bool isSeen;
  bool isDeleted;
  List<String> taggedUsers;
  // List<Reactions> reactions;
  DateTime createdAt;
  DateTime updatedAt;
  String? hrms_bdy;
  int v;

  Forward({
    required this.id,
    required this.senderId,
    required this.receiverId,
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
    // required this.reactions,
    required this.createdAt,
    required this.updatedAt,
    required this.hrms_bdy,
    required this.v,
  });

  // Factory method to create a Forward object from JSON
  factory Forward.fromJson(Map<String, dynamic> json) {
    print("GET_messages_forward ${json['content']}");
    return Forward(
      id: json['_id'],
      senderId: json['senderId'],
      receiverId: json.containsKey('receiverId') ? json['receiverId'] : json['channelId'],
      channelId: json.containsKey('channelId') ? json['channelId'] : json['receiverId'],
      content: json['content'],
      files: List<String>.from(json['files']),
      replyTo: json['replyTo'],
      isReply: json['isReply'],
      isLog: json['isLog'],
      isForwarded: json['isForwarded'],
      isEdited: json['isEdited'],
      forwardFrom: json['forwardFrom'],
      readBy: List<String>.from(json['readBy']),
      isSeen: json['is_seen'],
      isDeleted: json['isDeleted'],
      taggedUsers: List<String>.from(json['tagged_users']),
      // reactions: json['reactions'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
      hrms_bdy: json['hrms_birthday_email'] ?? '',
    );
  }

  // Method to convert a Forward object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      if (receiverId != null) 'receiverId': receiverId else 'receiverId': channelId,  // Only include if not null
      if (channelId != null) 'channelId': channelId else 'channelId': receiverId, // Only include if not null
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
      // 'reactions': reactions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class Reactions {
  String? emoji;
  String? userId;
  String? sId;

  Reactions({this.emoji, this.userId, this.sId});

  Reactions.fromJson(Map<String, dynamic> json) {
    emoji = json['emoji'];
    userId = json['userId'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['emoji'] = this.emoji;
    data['userId'] = this.userId;
    data['_id'] = this.sId;
    return data;
  }
}

class SenderOfForward {
  String? id;
  String? username;
  String? email;
  String? status;
  bool? isActive;
  String? customStatus;
  String? customStatusEmoji;
  String? createdAt;
  String? updatedAt;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  String? lastActiveTime;
  String? elsnerEmail;

  SenderOfForward({
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

  SenderOfForward.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    username = json['username'];
    email = json['email'];
    status = json['status'];
    isActive = json['isActive'];
    customStatus = json['custom_status'];
    customStatusEmoji = json['custom_status_emoji'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    lastActiveTime = json['last_active_time'];
    elsnerEmail = json['elsner_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['username'] = this.username;
    data['email'] = this.email;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    data['custom_status'] = this.customStatus;
    data['custom_status_emoji'] = this.customStatusEmoji;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['avatarUrl'] = this.avatarUrl;
    data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
    data['last_active_time'] = this.lastActiveTime;
    data['elsner_email'] = this.elsnerEmail;
    return data;
  }
}

class RepliesSenderInfo {
  final String id;
  final String username;
  final String email;
  final String status;
  final bool isActive;
  final String customStatus;
  final String customStatusEmoji;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String avatarUrl;
  final String thumbnailAvatarUrl;
  final DateTime lastActiveTime;
  final String elsnerEmail;

  RepliesSenderInfo({
    required this.id,
    required this.username,
    required this.email,
    required this.status,
    required this.isActive,
    required this.customStatus,
    required this.customStatusEmoji,
    required this.createdAt,
    required this.updatedAt,
    required this.avatarUrl,
    required this.thumbnailAvatarUrl,
    required this.lastActiveTime,
    required this.elsnerEmail,
  });

  factory RepliesSenderInfo.fromJson(Map<String, dynamic> json) {
    return RepliesSenderInfo(
      id: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      isActive: json['isActive'] as bool,
      customStatus: json['custom_status'] as String? ?? '',
      customStatusEmoji: json['custom_status_emoji'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      avatarUrl: json['avatarUrl'] as String,
      thumbnailAvatarUrl: json['thumbnail_avatarUrl'] as String,
      lastActiveTime: DateTime.parse(json['last_active_time'] as String),
      elsnerEmail: json['elsner_email'] as String,
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
