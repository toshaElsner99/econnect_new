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
