class GetUserModel {
  int? statusCode;
  int? status;
  Data? data;
  List<dynamic>? metadata;

  GetUserModel({this.statusCode, this.status, this.data, this.metadata});

  GetUserModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['metadata'] != null) {
      metadata = <dynamic>[];
      json['metadata'].forEach((v) {
        metadata!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (metadata != null) {
      data['metadata'] = metadata!.map((v) => v).toList();
    }
    return data;
  }
}

class Data {
  User? user;

  Data({this.user});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? sId;
  String? fullName;
  String? username;
  String? email;
  String? elsnerEmail;
  String? position;
  String? status;
  bool? isActive;
  List<dynamic>? loginActivity;
  dynamic customStatus;
  dynamic customStatusEmoji;
  List<dynamic>? muteUsers;
  List<dynamic>? favoriteList;
  bool? isLeft;
  List<dynamic>? customStatusHistory;
  String? createdAt;
  String? updatedAt;
  LastActiveChat? lastActiveChat;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  bool? isAutomatic;
  String? lastActiveTime;
  List<dynamic>? pinmessage;
  bool? isMuted;
  bool? isFavourite;
  int? pinnedMessageCount;

  User({
    this.sId,
    this.fullName,
    this.username,
    this.email,
    this.elsnerEmail,
    this.position,
    String? status, // Accept status as a parameter
    this.isActive,
    this.loginActivity,
    this.customStatus,
    this.customStatusEmoji,
    this.muteUsers,
    this.favoriteList,
    this.isLeft,
    this.customStatusHistory,
    this.createdAt,
    this.updatedAt,
    this.lastActiveChat,
    this.avatarUrl,
    this.thumbnailAvatarUrl,
    this.isAutomatic,
    this.lastActiveTime,
    this.pinmessage,
    this.isMuted,
    this.isFavourite,
    this.pinnedMessageCount,
  }) : status = status ?? "Offline"; // Default to "Offline" if null

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    elsnerEmail = json['elsner_email'];
    position = json['position'];
    status = json['status'] ?? "Offline"; // Default to "Offline" if null
    isActive = json['isActive'];
    if (json['loginActivity'] != null) {
      loginActivity = <dynamic>[];
      json['loginActivity'].forEach((v) {
        loginActivity!.add(v);
      });
    }
    customStatus = json['custom_status'];
    customStatusEmoji = json['custom_status_emoji'];
    if (json['mute_users'] != null) {
      muteUsers = <dynamic>[];
      json['mute_users'].forEach((v) {
        muteUsers!.add(v);
      });
    }
    if (json['mute_users'] != null) {
      muteUsers = <dynamic>[];
      json['mute_users'].forEach((v) {
        muteUsers!.add(v);
      });
    }
    isLeft = json['isLeft'] ?? false;
    if (json['custom_status_history'] != null) {
      customStatusHistory = <dynamic>[];
      json['custom_status_history'].forEach((v) {
        customStatusHistory!.add(v);
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    lastActiveChat = json['lastActiveChat'] != null
        ? LastActiveChat.fromJson(json['lastActiveChat'])
        : null;
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    isAutomatic = json['isAutomatic'];
    lastActiveTime = json['last_active_time'];
    if (json['pinmessage'] != null) {
      pinmessage = <dynamic>[];
      json['pinmessage'].forEach((v) {
        pinmessage!.add(v);
      });
    }
    isMuted = json['isMuted'];
    isFavourite = json['isFavourite'];
    pinnedMessageCount = json['pinnedMessageCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['username'] = username;
    data['email'] = email;
    data['elsner_email'] = elsnerEmail;
    data['position'] = position;
    data['status'] = status ?? "Offline"; // Default to "Offline" if null
    data['isActive'] = isActive;
    if (loginActivity != null) {
      data['loginActivity'] = loginActivity!.map((v) => v).toList();
    }
    data['custom_status'] = customStatus;
    data['custom_status_emoji'] = customStatusEmoji;
    if (muteUsers != null) {
      data['mute_users'] = muteUsers!.map((v) => v).toList();
    }
    data['isLeft'] = isLeft ?? false;
    if (customStatusHistory != null) {
      data['custom_status_history'] =
          customStatusHistory!.map((v) => v).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (lastActiveChat != null) {
      data['lastActiveChat'] = lastActiveChat!.toJson();
    }
    data['avatarUrl'] = avatarUrl;
    data['thumbnail_avatarUrl'] = thumbnailAvatarUrl;
    data['isAutomatic'] = isAutomatic;
    data['last_active_time'] = lastActiveTime;
    if (pinmessage != null) {
      data['pinmessage'] = pinmessage!.map((v) => v).toList();
    }
    data['isMuted'] = isMuted;
    data['isFavourite'] = isFavourite;
    data['pinnedMessageCount'] = pinnedMessageCount;
    return data;
  }
}

class LastActiveChat {
  String? type;
  String? id;

  LastActiveChat({this.type, this.id});

  LastActiveChat.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['type'] = type;
    data['id'] = id;
    return data;
  }
}

/// User For Second User Details Store /// Don't Remove It.....
class GetUserModelSecondUser {
  int? statusCode;
  int? status;
  DataSecondUser? data;
  List<dynamic>? metadata;

  GetUserModelSecondUser(
      {this.statusCode, this.status, this.data, this.metadata});

  GetUserModelSecondUser.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    data = json['data'] != null ? DataSecondUser.fromJson(json['data']) : null;
    if (json['metadata'] != null) {
      metadata = <dynamic>[];
      json['metadata'].forEach((v) {
        metadata!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (metadata != null) {
      data['metadata'] = metadata!.map((v) => v).toList();
    }
    return data;
  }
}

class DataSecondUser {
  SecondUser? user;

  DataSecondUser({this.user});

  DataSecondUser.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? SecondUser.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class SecondUser {
  String? sId;
  String? fullName;
  String? username;
  String? email;
  String? elsnerEmail;
  String? position;
  String? status;
  bool? isActive;
  List<dynamic>? loginActivity;
  dynamic customStatus;

  dynamic customStatusEmoji;
  List<dynamic>? muteUsers;
  List<dynamic>? favoriteList;
  bool? isLeft;
  List<dynamic>? customStatusHistory;
  String? createdAt;
  String? updatedAt;
  LastActiveChatSecondUser? lastActiveChat;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  bool? isAutomatic;
  String? lastActiveTime;
  List<PinmessageSecondUser>? pinmessage;
  bool? isMuted;
  bool? isFavourite;
  int? pinnedMessageCount;

  SecondUser({
    this.sId,
    this.fullName,
    this.username,
    this.email,
    this.elsnerEmail,
    this.position,
    String? status,
    this.isActive,
    this.loginActivity,
    this.customStatus,
    this.customStatusEmoji,
    this.muteUsers,
    this.favoriteList,
    this.isLeft,
    this.customStatusHistory,
    this.createdAt,
    this.updatedAt,
    this.lastActiveChat,
    this.avatarUrl,
    this.thumbnailAvatarUrl,
    this.isAutomatic,
    this.lastActiveTime,
    this.pinmessage,
    this.isMuted,
    this.isFavourite,
    this.pinnedMessageCount,
  }) : status = status ?? "Offline"; // Default to "Offline" if null

  SecondUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    elsnerEmail = json['elsner_email'];
    position = json['position'];
    status = json['status'] ?? "Offline"; // Default to "Offline" if null
    isActive = json['isActive'];
    if (json['loginActivity'] != null) {
      loginActivity = <dynamic>[];
      json['loginActivity'].forEach((v) {
        loginActivity!.add(v);
      });
    }
    customStatus = json['custom_status'];
    customStatusEmoji = json['custom_status_emoji'];
    if (json['mute_users'] != null) {
      muteUsers = <dynamic>[];
      json['mute_users'].forEach((v) {
        muteUsers!.add(v);
      });
    }
    isLeft = json['isLeft'];
    if (json['custom_status_history'] != null) {
      customStatusHistory = <dynamic>[];
      json['custom_status_history'].forEach((v) {
        customStatusHistory!.add(v);
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    lastActiveChat = json['lastActiveChat'] != null
        ? LastActiveChatSecondUser.fromJson(json['lastActiveChat'])
        : null;
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    isAutomatic = json['isAutomatic'];
    lastActiveTime = json['last_active_time'];
    pinmessage = (json['pinmessage'] as List?)
        ?.map((dynamic e) =>
            PinmessageSecondUser.fromJson(e as Map<String, dynamic>))
        .toList();
    isMuted = json['isMuted'];
    isFavourite = json['isFavourite'];
    pinnedMessageCount = json['pinnedMessageCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['username'] = username;
    data['email'] = email;
    data['elsner_email'] = elsnerEmail;
    data['position'] = position;
    data['status'] = status ?? "Offline"; // Default to "Offline" if null
    data['isActive'] = isActive;
    if (loginActivity != null) {
      data['loginActivity'] = loginActivity!.map((v) => v).toList();
    }
    data['custom_status'] = customStatus;
    data['custom_status_emoji'] = customStatusEmoji;
    if (muteUsers != null) {
      data['mute_users'] = muteUsers!.map((v) => v).toList();
    }
    data['isLeft'] = isLeft;
    if (customStatusHistory != null) {
      data['custom_status_history'] =
          customStatusHistory!.map((v) => v).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (lastActiveChat != null) {
      data['lastActiveChat'] = lastActiveChat!.toJson();
    }
    data['avatarUrl'] = avatarUrl;
    data['thumbnail_avatarUrl'] = thumbnailAvatarUrl;
    data['isAutomatic'] = isAutomatic;
    data['last_active_time'] = lastActiveTime;
    data['pinmessage'] = pinmessage?.map((e) => e.toJson()).toList();
    data['isMuted'] = isMuted;
    data['isFavourite'] = isFavourite;
    data['pinnedMessageCount'] = pinnedMessageCount;
    return data;
  }
}

class LastActiveChatSecondUser {
  String? type;
  String? id;

  LastActiveChatSecondUser({this.type, this.id});

  LastActiveChatSecondUser.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['type'] = type;
    data['id'] = id;
    return data;
  }
}

class PinmessageSecondUser {
  final String? id;
  final String? senderId;
  final String? receiverId;
  final String? content;
  final List<dynamic>? files;
  final bool? isForwarded;
  final List<dynamic>? readBy;
  final bool? isSeen;
  final List<ReactionSecondUser>? reactions;
  final String? createdAt;
  final String? updatedAt;
  final bool? isPinned;
  final SenderInfoSecondUser? senderInfo;
  final ReceiverInfoSecondUser? receiverInfo;
  final int? replyCount;
  final ForwardMSGInfoSecondUser? forwardMSGInfoSecondUser;
  final SenderOfForwardSecondUser? senderOfForwardSecondUser;

  PinmessageSecondUser({
    this.id,
    this.senderId,
    this.receiverId,
    this.content,
    this.files,
    this.isForwarded,
    this.readBy,
    this.isSeen,
    this.reactions,
    this.createdAt,
    this.updatedAt,
    this.isPinned,
    this.senderInfo,
    this.receiverInfo,
    this.replyCount,
    this.forwardMSGInfoSecondUser,
    this.senderOfForwardSecondUser,
  });

  PinmessageSecondUser.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        senderId = json['senderId'] as String?,
        receiverId = json['receiverId'] as String?,
        content = json['content'] as String?,
        files = json['files'] as List<dynamic>?,
        isForwarded = json['isForwarded'] as bool?,
        readBy = json['readBy'] as List<dynamic>?,
        isSeen = json['is_seen'] as bool?,
        reactions = (json['reactions'] as List?)
            ?.map((dynamic e) =>
                ReactionSecondUser.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        isPinned = json['isPinned'] as bool?,
        senderInfo = (json['senderInfo'] as Map<String, dynamic>?) != null
            ? SenderInfoSecondUser.fromJson(
                json['senderInfo'] as Map<String, dynamic>)
            : null,
        receiverInfo = (json['receiverInfo'] as Map<String, dynamic>?) != null
            ? ReceiverInfoSecondUser.fromJson(
                json['receiverInfo'] as Map<String, dynamic>)
            : null,
        replyCount = json['replyCount'] as int?,
        forwardMSGInfoSecondUser = (json['forwards'] as Map<String, dynamic>?) != null
            ? ForwardMSGInfoSecondUser.fromJson(
            json['forwards'] as Map<String, dynamic>)
            : null,
        senderOfForwardSecondUser = (json['senderOfForward'] as Map<String, dynamic>?) != null
            ? SenderOfForwardSecondUser.fromJson(
            json['senderOfForward'] as Map<String, dynamic>)
            : null

  ;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'files': files,
        'isForwarded': isForwarded,
        'readBy': readBy,
        'is_seen': isSeen,
        'reactions': reactions?.map((e) => e.toJson()).toList(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'isPinned': isPinned,
        'senderInfo': senderInfo?.toJson(),
        'receiverInfo': receiverInfo?.toJson(),
        'replyCount': replyCount,
        'forwards': forwardMSGInfoSecondUser?.toJson(),
        'senderOfForward': senderOfForwardSecondUser?.toJson(),
      };
}

class SenderInfoSecondUser {
  String? id;
  String? fullName;
  String? username;
  String? email;
  String? elsnerEmail;
  bool? isActive;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? avatarUrl;
  String? thumbnailAvatarUrl;

  SenderInfoSecondUser({
    this.id,
    this.fullName,
    this.username,
    this.email,
    this.elsnerEmail,
    this.isActive,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.avatarUrl,
    this.thumbnailAvatarUrl,
  });

  SenderInfoSecondUser.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    elsnerEmail = json['elsner_email'];
    isActive = json['isActive'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'elsner_email': elsnerEmail,
      'isActive': isActive,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'avatarUrl': avatarUrl,
      'thumbnail_avatarUrl': thumbnailAvatarUrl,
    };
  }
}

class ReactionSecondUser {
  String? emoji;
  String? userId;
  String? id;

  ReactionSecondUser({
    this.emoji,
    this.userId,
    this.id,
  });

  ReactionSecondUser.fromJson(Map<String, dynamic> json) {
    emoji = json['emoji'];
    userId = json['userId'];
    id = json['_id'];
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'userId': userId,
      '_id': id,
    };
  }
}

class ReceiverInfoSecondUser {
  String? id;
  String? fullName;
  String? username;
  String? email;
  String? elsnerEmail;
  bool? isActive;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? avatarUrl;
  String? thumbnailAvatarUrl;

  ReceiverInfoSecondUser({
    this.id,
    this.fullName,
    this.username,
    this.email,
    this.elsnerEmail,
    this.isActive,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.avatarUrl,
    this.thumbnailAvatarUrl,
  });

  ReceiverInfoSecondUser.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    elsnerEmail = json['elsner_email'];
    isActive = json['isActive'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'elsner_email': elsnerEmail,
      'isActive': isActive,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'avatarUrl': avatarUrl,
      'thumbnail_avatarUrl': thumbnailAvatarUrl,
    };
  }
}


class ForwardMSGInfoSecondUser {
  String id;
  String senderId;
  String receiverId;
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
  List<String> reactions;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  ForwardMSGInfoSecondUser({
    required this.id,
    required this.senderId,
    required this.receiverId,
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

  // Factory method to create a Forward instance from JSON
  factory ForwardMSGInfoSecondUser.fromJson(Map<String, dynamic> json) {
    return ForwardMSGInfoSecondUser(
      id: json['_id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      files: List<String>.from(json['files'] ?? []),
      replyTo: json['replyTo'],
      isReply: json['isReply'],
      isLog: json['isLog'],
      isForwarded: json['isForwarded'],
      isEdited: json['isEdited'],
      forwardFrom: json['forwardFrom'],
      readBy: List<String>.from(json['readBy'] ?? []),
      isSeen: json['is_seen'],
      isDeleted: json['isDeleted'],
      taggedUsers: List<String>.from(json['tagged_users'] ?? []),
      reactions: List<String>.from(json['reactions'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }

  // Method to convert a Forward instance to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'receiverId': receiverId,
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


class SenderOfForwardSecondUser {
  String? id;
  String? fullName;
  String? username;
  String? email;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? thumbnailAvatarUrl;
  String? elsnerEmail;

  SenderOfForwardSecondUser({
    this.id,
    this.fullName,
    this.username,
    this.email,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.thumbnailAvatarUrl,
    this.elsnerEmail,
  });

  // Factory method to create a User instance from JSON
  factory SenderOfForwardSecondUser.fromJson(Map<String, dynamic> json) {
    return SenderOfForwardSecondUser(
      id: json['_id'],
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      thumbnailAvatarUrl: json['thumbnail_avatarUrl'],
      elsnerEmail: json['elsner_email'],
    );
  }

  // Method to convert a User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'thumbnail_avatarUrl': thumbnailAvatarUrl,
      'elsner_email': elsnerEmail,
    };
  }
}