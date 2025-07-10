class SearchUserModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata;

  SearchUserModel({
    this.statusCode,
    this.status,
    this.message,
    this.data,
    this.metadata,
  });

  SearchUserModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    metadata = json['metadata'] != null ? List<dynamic>.from(json['metadata']) : null;
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
  int? totalSearchResults;
  int? totalUsers;
  List<Users>? users;

  Data({this.totalSearchResults, this.totalUsers, this.users});

  Data.fromJson(Map<String, dynamic> json) {
    totalSearchResults = json['totalSearchResults'];
    totalUsers = json['total_users'];
    if (json['users'] != null) {
      users = List<Users>.from(json['users'].map((v) => Users.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['totalSearchResults'] = totalSearchResults;
    data['total_users'] = totalUsers;
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  LastActiveChat? lastActiveChat;
  String? sId;
  String? username;
  String? email;
  String? status;
  bool? isActive;
  List<dynamic>? loginActivity;  // Fixed here
  String? customStatus;
  String? customStatusEmoji;
  List<String>? muteUsers;
  List<String>? muteChannels;
  List<CustomStatusHistory>? customStatusHistory;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? chatList;
  String? favouriteList;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  bool? isAutomatic;
  String? lastActiveTime;
  String? fullName;
  String? password;
  bool? isLeft;
  String? elsnerEmail;
  String? position;

  Users({
    this.lastActiveChat,
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
    this.customStatusHistory,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.chatList,
    this.favouriteList,
    this.avatarUrl,
    this.thumbnailAvatarUrl,
    this.isAutomatic,
    this.lastActiveTime,
    this.fullName,
    this.password,
    this.isLeft,
    this.elsnerEmail,
    this.position,
  });

  Users.fromJson(Map<String, dynamic> json) {
    lastActiveChat = json['lastActiveChat'] != null
        ? LastActiveChat.fromJson(json['lastActiveChat'])
        : null;
    sId = json['userId'];
    username = json['fullName'];
    email = json['email'];
    status = json['status'];
    isActive = json['isActive'];
    loginActivity = json['loginActivity'] != null ? List<dynamic>.from(json['loginActivity']) : null;
    customStatus = json['customStatus'];
    customStatusEmoji = json['customStatusEmoji'];
    muteUsers = json['mute_users']?.cast<String>();
    muteChannels = json['mute_channels']?.cast<String>();
    if (json['custom_status_history'] != null) {
      customStatusHistory = List<CustomStatusHistory>.from(
          json['custom_status_history'].map((v) => CustomStatusHistory.fromJson(v)));
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    chatList = json['chatList'];
    favouriteList = json['favouriteList'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnailAvatarUrl'];
    isAutomatic = json['isAutomatic'];
    lastActiveTime = json['last_active_time'];
    fullName = json['fullName'];
    password = json['password'];
    isLeft = json['isLeft'];
    elsnerEmail = json['elsner_email'];
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (lastActiveChat != null) {
      data['lastActiveChat'] = lastActiveChat!.toJson();
    }
    data['userId'] = sId;
    data['fullName'] = username;
    data['email'] = email;
    data['status'] = status;
    data['isActive'] = isActive;
    if (loginActivity != null) {
      data['loginActivity'] = loginActivity;
    }
    data['customStatus'] = customStatus;
    data['customStatusEmoji'] = customStatusEmoji;
    data['mute_users'] = muteUsers;
    data['mute_channels'] = muteChannels;
    if (customStatusHistory != null) {
      data['custom_status_history'] =
          customStatusHistory!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['chatList'] = chatList;
    data['favouriteList'] = favouriteList;
    data['avatarUrl'] = avatarUrl;
    data['thumbnailAvatarUrl'] = thumbnailAvatarUrl;
    data['isAutomatic'] = isAutomatic;
    data['last_active_time'] = lastActiveTime;
    data['fullName'] = fullName;
    data['password'] = password;
    data['isLeft'] = isLeft;
    data['elsner_email'] = elsnerEmail;
    data['position'] = position;
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
    return {'type': type, 'id': id};
  }
}

class CustomStatusHistory {
  String? customStatus;
  String? customStatusEmoji;
  String? updatedBy;
  String? updatedAt;
  String? sId;

  CustomStatusHistory({
    this.customStatus,
    this.customStatusEmoji,
    this.updatedBy,
    this.updatedAt,
    this.sId,
  });

  CustomStatusHistory.fromJson(Map<String, dynamic> json) {
    customStatus = json['customStatus'];
    customStatusEmoji = json['customStatusEmoji'];
    updatedBy = json['updatedBy'];
    updatedAt = json['updatedAt'];
    sId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    return {
      'customStatus': customStatus,
      'customStatusEmoji': customStatusEmoji,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt,
      'userId': sId,
    };
  }
}
