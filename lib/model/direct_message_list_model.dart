class DirectMessageListModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata;

  DirectMessageListModel({
    this.statusCode,
    this.status,
    this.message,
    this.data,
    this.metadata,
  });

  DirectMessageListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    metadata = json['metadata'] ?? [];
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
  String? userId;
  List<ChatListDirectMessage>? chatList;

  Data({this.userId, this.chatList});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    chatList = (json['chatList'] as List?)?.map((v) => ChatListDirectMessage.fromJson(v)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'chatList': chatList?.map((v) => v.toJson()).toList(),
    };
  }
}

class ChatListDirectMessage {
  String? sId;
  String? username;
  String? email;
  String? status;
  bool? isActive;
  List<dynamic>? loginActivity;
  String? customStatus;
  String? customStatusEmoji;
  List<String>? muteUsers;
  List<String>? muteChannels;
  String? createdAt;
  String? updatedAt;
  int? iV;
  LastActiveChat? lastActiveChat;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  bool? isLeft;
  String? chatList;
  String? favouriteList;
  bool? isAutomatic;
  String? lastActiveTime;
  String? elsnerEmail;
  int? unseenMessagesCount;
  String? latestMessage;
  String? latestMessageCreatedAt;

  ChatListDirectMessage({
    this.sId,
    this.username,
    this.email,
    this.status,
    this.isActive,
    this.loginActivity,
    this.customStatus,
    this.customStatusEmoji,
    this.muteUsers,
    this.muteChannels,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.lastActiveChat,
    this.avatarUrl,
    this.thumbnailAvatarUrl,
    this.isLeft,
    this.chatList,
    this.favouriteList,
    this.isAutomatic,
    this.lastActiveTime,
    this.elsnerEmail,
    this.unseenMessagesCount,
    this.latestMessage,
    this.latestMessageCreatedAt,
  });

  ChatListDirectMessage.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    email = json['email'];
    status = json['status'];
    isActive = json['isActive'];
    loginActivity = json['loginActivity'] ?? [];
    customStatus = json['custom_status'];
    customStatusEmoji = json['custom_status_emoji'];
    muteUsers = (json['mute_users'] as List?)?.cast<String>();
    muteChannels = (json['mute_channels'] as List?)?.cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    lastActiveChat = json['lastActiveChat'] != null ? LastActiveChat.fromJson(json['lastActiveChat']) : null;
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    isLeft = json['isLeft'];
    chatList = json['chatList'];
    favouriteList = json['favouriteList'];
    isAutomatic = json['isAutomatic'];
    lastActiveTime = json['last_active_time'];
    elsnerEmail = json['elsner_email'];
    unseenMessagesCount = json['unseenMessagesCount'];
    latestMessage = json['latestMessage'];
    latestMessageCreatedAt = json['latestMessageCreatedAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'username': username,
      'email': email,
      'status': status,
      'isActive': isActive,
      'loginActivity': loginActivity,
      'custom_status': customStatus,
      'custom_status_emoji': customStatusEmoji,
      'mute_users': muteUsers,
      'mute_channels': muteChannels,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': iV,
      'lastActiveChat': lastActiveChat?.toJson(),
      'avatarUrl': avatarUrl,
      'thumbnail_avatarUrl': thumbnailAvatarUrl,
      'isLeft': isLeft,
      'chatList': chatList,
      'favouriteList': favouriteList,
      'isAutomatic': isAutomatic,
      'last_active_time': lastActiveTime,
      'elsner_email': elsnerEmail,
      'unseenMessagesCount': unseenMessagesCount,
      'latestMessage': latestMessage,
      'latestMessageCreatedAt': latestMessageCreatedAt,
    };
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
    return {
      'type': type,
      'id': id,
    };
  }
}