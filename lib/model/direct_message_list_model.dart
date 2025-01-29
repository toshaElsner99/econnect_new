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
    metadata = json['metadata'] != null ? List<dynamic>.from(json['metadata']) : null;
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
  List<ChatList>? chatList;

  Data({this.userId, this.chatList});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    chatList = json['chatList'] != null
        ? (json['chatList'] as List).map((v) => ChatList.fromJson(v)).toList()
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'chatList': chatList?.map((v) => v.toJson()).toList(),
    };
  }
}

class ChatList {
  String? sId;
  String? username;
  String? email;
  String? status;
  bool? isActive;
  List<dynamic>? loginActivity;
  String? customStatus;
  String? customStatusEmoji;
  List<dynamic>? muteUsers;
  List<String>? muteChannels;
  String? createdAt;
  String? updatedAt;
  int? iV;
  LastActiveChat? lastActiveChat;
  String? chatList;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  String? fullName;
  bool? isAutomatic;
  String? lastActiveTime;
  String? favouriteList;
  bool? isLeft;
  String? elsnerEmail;
  int? unseenMessagesCount;
  String? latestMessage;
  String? latestMessageCreatedAt;

  ChatList({
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
    this.chatList,
    this.avatarUrl,
    this.thumbnailAvatarUrl,
    this.fullName,
    this.isAutomatic,
    this.lastActiveTime,
    this.favouriteList,
    this.isLeft,
    this.elsnerEmail,
    this.unseenMessagesCount,
    this.latestMessage,
    this.latestMessageCreatedAt,
  });

  ChatList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    email = json['email'];
    status = json['status'];
    isActive = json['isActive'];
    loginActivity = json['loginActivity'] != null ? List<dynamic>.from(json['loginActivity']) : null;
    customStatus = json['custom_status'];
    customStatusEmoji = json['custom_status_emoji'];
    muteUsers = json['mute_users'] != null ? List<dynamic>.from(json['mute_users']) : null;
    muteChannels = json['mute_channels'] != null ? List<String>.from(json['mute_channels']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    lastActiveChat = json['lastActiveChat'] != null ? LastActiveChat.fromJson(json['lastActiveChat']) : null;
    chatList = json['chatList'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    fullName = json['fullName'];
    isAutomatic = json['isAutomatic'];
    lastActiveTime = json['last_active_time'];
    favouriteList = json['favouriteList'];
    isLeft = json['isLeft'];
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
      'chatList': chatList,
      'avatarUrl': avatarUrl,
      'thumbnail_avatarUrl': thumbnailAvatarUrl,
      'fullName': fullName,
      'isAutomatic': isAutomatic,
      'last_active_time': lastActiveTime,
      'favouriteList': favouriteList,
      'isLeft': isLeft,
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
