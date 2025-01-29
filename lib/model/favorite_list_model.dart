class FavoriteListModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata; // Changed to dynamic

  FavoriteListModel({this.statusCode, this.status, this.message, this.data, this.metadata});

  FavoriteListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    metadata = json['metadata'] ?? []; // Handle metadata as a list of dynamic
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (metadata != null) {
      data['metadata'] = metadata;
    }
    return data;
  }
}

class Data {
  String? userId;
  List<ChatList>? chatList;
  List<dynamic>? favouriteChannels; // Changed to dynamic

  Data({this.userId, this.chatList, this.favouriteChannels});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    if (json['chatList'] != null) {
      chatList = [];
      json['chatList'].forEach((v) {
        chatList!.add(ChatList.fromJson(v));
      });
    }
    favouriteChannels = json['favouriteChannels'] ?? []; // Handle as a list of dynamic
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['userId'] = userId;
    if (chatList != null) {
      data['chatList'] = chatList!.map((v) => v.toJson()).toList();
    }
    if (favouriteChannels != null) {
      data['favouriteChannels'] = favouriteChannels;
    }
    return data;
  }
}

class ChatList {
  String? sId;
  String? username;
  String? email;
  String? password;
  String? status;
  bool? isActive;
  List<dynamic>? loginActivity; // Changed to dynamic
  String? customStatus;
  String? customStatusEmoji;
  List<String>? muteUsers;
  List<String>? muteChannels;
  List<CustomStatusHistory>? customStatusHistory;
  String? createdAt;
  String? updatedAt;
  int? iV;
  LastActiveChat? lastActiveChat;
  String? chatList;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  bool? isLeft;
  bool? isAutomatic;
  String? lastActiveTime;
  String? favouriteList;
  String? elsnerEmail;
  int? unseenMessagesCount;
  String? fullName;

  ChatList({
    this.sId,
    this.username,
    this.email,
    this.password,
    this.status,
    this.isActive,
    this.loginActivity,
    this.customStatus,
    this.customStatusEmoji,
    this.muteUsers,
    this.muteChannels,
    this.customStatusHistory,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.lastActiveChat,
    this.chatList,
    this.avatarUrl,
    this.thumbnailAvatarUrl,
    this.isLeft,
    this.isAutomatic,
    this.lastActiveTime,
    this.favouriteList,
    this.elsnerEmail,
    this.unseenMessagesCount,
    this.fullName,
  });

  ChatList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    email = json['email'];
    password = json['password'];
    status = json['status'];
    isActive = json['isActive'];
    loginActivity = json['loginActivity'] ?? []; // Handle as a list of dynamic
    customStatus = json['custom_status'];
    customStatusEmoji = json['custom_status_emoji'];
    muteUsers = json['mute_users'].cast<String>();
    muteChannels = json['mute_channels'].cast<String>();
    if (json['custom_status_history'] != null) {
      customStatusHistory = [];
      json['custom_status_history'].forEach((v) {
        customStatusHistory!.add(CustomStatusHistory.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    lastActiveChat = json['lastActiveChat'] != null
        ? LastActiveChat.fromJson(json['lastActiveChat'])
        : null;
    chatList = json['chatList'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    isLeft = json['isLeft'];
    isAutomatic = json['isAutomatic'];
    lastActiveTime = json['last_active_time'];
    favouriteList = json['favouriteList'];
    elsnerEmail = json['elsner_email'];
    unseenMessagesCount = json['unseenMessagesCount'];
    fullName = json['fullName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['username'] = username;
    data['email'] = email;
    data['password'] = password;
    data['status'] = status;
    data['isActive'] = isActive;
    if (loginActivity != null) {
      data['loginActivity'] = loginActivity;
    }
    data['custom_status'] = customStatus;
    data['custom_status_emoji'] = customStatusEmoji;
    data['mute_users'] = muteUsers;
    data['mute_channels'] = muteChannels;
    if (customStatusHistory != null) {
      data['custom_status_history'] =
          customStatusHistory!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (lastActiveChat != null) {
      data['lastActiveChat'] = lastActiveChat!.toJson();
    }
    data['chatList'] = chatList;
    data['avatarUrl'] = avatarUrl;
    data['thumbnail_avatarUrl'] = thumbnailAvatarUrl;
    data['isLeft'] = isLeft;
    data['isAutomatic'] = isAutomatic;
    data['last_active_time'] = lastActiveTime;
    data['favouriteList'] = favouriteList;
    data['elsner_email'] = elsnerEmail;
    data['unseenMessagesCount'] = unseenMessagesCount;
    data['fullName'] = fullName;
    return data;
  }
}

// Other classes remain unchanged

class CustomStatusHistory {
  String? customStatus;
  String? customStatusEmoji;
  String? updatedBy;
  String? updatedAt;
  String? sId;

  CustomStatusHistory(
      {this.customStatus,
        this.customStatusEmoji,
        this.updatedBy,
        this.updatedAt,
        this.sId});

  CustomStatusHistory.fromJson(Map<String, dynamic> json) {
    customStatus = json['custom_status'];
    customStatusEmoji = json['custom_status_emoji'];
    updatedBy = json['updatedBy'];
    updatedAt = json['updatedAt'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['custom_status'] = this.customStatus;
    data['custom_status_emoji'] = this.customStatusEmoji;
    data['updatedBy'] = this.updatedBy;
    data['updatedAt'] = this.updatedAt;
    data['_id'] = this.sId;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['id'] = this.id;
    return data;
  }
}
