class FilesListingInChatModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata; // Changed from List<Null> to List<dynamic>

  FilesListingInChatModel(
      {this.statusCode, this.status, this.message, this.data, this.metadata});

  FilesListingInChatModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['metadata'] != null) {
      metadata = <dynamic>[]; // Changed from List<Null> to List<dynamic>
      json['metadata'].forEach((v) {
        metadata!.add(v); // No need to create a Null object
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = this.statusCode;
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (this.metadata != null) {
      data['metadata'] = this.metadata!;
    }
    return data;
  }
}

class Data {
  List<Messages>? messages;

  Data({this.messages});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  String? sId;
  String? senderId;
  String? receiverId;
  String? content;
  List<String>? files;
  bool? isMedia;
  dynamic replyTo; // Changed from Null to dynamic
  bool? isReply;
  bool? isLog;
  bool? isForwarded;
  bool? isEdited;
  dynamic forwardFrom; // Changed from Null to dynamic
  List<dynamic>? readBy; // Changed from List<Null> to List<dynamic>
  bool? isSeen;
  bool? isDeleted;
  List<dynamic>? taggedUsers; // Changed from List<Null> to List<dynamic>
  List<dynamic>? reactions; // Changed from List<Null> to List<dynamic>
  String? createdAt;
  String? updatedAt;
  int? iV;
  SenderInfo? senderInfo;

  Messages(
      {this.sId,
        this.senderId,
        this.receiverId,
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
        this.iV,
        this.senderInfo});

  Messages.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    content = json['content'];
    files = json['files']?.cast<String>();
    isMedia = json['isMedia'];
    replyTo = json['replyTo']; // Changed from Null to dynamic
    isReply = json['isReply'];
    isLog = json['isLog'];
    isForwarded = json['isForwarded'];
    isEdited = json['isEdited'];
    forwardFrom = json['forwardFrom']; // Changed from Null to dynamic
    if (json['readBy'] != null) {
      readBy = <dynamic>[]; // Changed from List<Null> to List<dynamic>
      json['readBy'].forEach((v) {
        readBy!.add(v); // No need to create a Null object
      });
    }
    isSeen = json['is_seen'];
    isDeleted = json['isDeleted'];
    if (json['tagged_users'] != null) {
      taggedUsers = <dynamic>[]; // Changed from List<Null> to List<dynamic>
      json['tagged_users'].forEach((v) {
        taggedUsers!.add(v); // No need to create a Null object
      });
    }
    if (json['reactions'] != null) {
      reactions = <dynamic>[]; // Changed from List<Null> to List<dynamic>
      json['reactions'].forEach((v) {
        reactions!.add(v); // No need to create a Null object
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    senderInfo = json['senderInfo'] != null
        ? SenderInfo.fromJson(json['senderInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['senderId'] = this.senderId;
    data['receiverId'] = this.receiverId;
    data['content'] = this.content;
    data['files'] = this.files;
    data['isMedia'] = this.isMedia;
    data['replyTo'] = this.replyTo; // Changed from Null to dynamic
    data['isReply'] = this.isReply;
    data['isLog'] = this.isLog;
    data['isForwarded'] = this.isForwarded;
    data['isEdited'] = this.isEdited;
    data['forwardFrom'] = this.forwardFrom; // Changed from Null to dynamic
    if (this.readBy != null) {
      data['readBy'] = this.readBy!;
    }
    data['is_seen'] = this.isSeen;
    data['isDeleted'] = this.isDeleted;
    if (this.taggedUsers != null) {
      data['tagged_users'] = this.taggedUsers!;
    }
    if (this.reactions != null) {
      data['reactions'] = this.reactions!;
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
  String? fullName;
  String? username;
  String? email;
  String? status;
  bool? isActive;
  List<dynamic>? loginActivity; // Changed from List<Null> to List<dynamic>
  String? customStatus;
  String? customStatusEmoji;
  List<String>? muteUsers;
  List<String>? muteChannels;
  bool? isLeft;
  List<CustomStatusHistory>? customStatusHistory;
  String? createdAt;
  String? updatedAt;
  int? iV;
  LastActiveChat? lastActiveChat;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  String? chatList;
  String? favouriteList;
  bool? isAutomatic;
  String? lastActiveTime;
  String? elsnerEmail;

  SenderInfo(
      {this.fullName,
        this.username,
        this.email,
        this.status,
        this.isActive,
        this.loginActivity,
        this.customStatus,
        this.customStatusEmoji,
        this.muteUsers,
        this.muteChannels,
        this.isLeft,
        this.customStatusHistory,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.lastActiveChat,
        this.avatarUrl,
        this.thumbnailAvatarUrl,
        this.chatList,
        this.favouriteList,
        this.isAutomatic,
        this.lastActiveTime,
        this.elsnerEmail});

  SenderInfo.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    status = json['status'];
    isActive = json['isActive'];
    if (json['loginActivity'] != null) {
      loginActivity = <dynamic>[]; // Changed from List<Null> to List<dynamic>
      json['loginActivity'].forEach((v) {
        loginActivity!.add(v); // No need to create a Null object
      });
    }
    customStatus = json['custom_status'];
    customStatusEmoji = json['custom_status_emoji'];
    muteUsers = json['mute_users']?.cast<String>();
    muteChannels = json['mute_channels']?.cast<String>();
    isLeft = json['isLeft'];
    if (json['custom_status_history'] != null) {
      customStatusHistory = <CustomStatusHistory>[];
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
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    chatList = json['chatList'];
    favouriteList = json['favouriteList'];
    isAutomatic = json['isAutomatic'];
    lastActiveTime = json['last_active_time'];
    elsnerEmail = json['elsner_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['fullName'] = this.fullName;
    data['username'] = this.username;
    data['email'] = this.email;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    if (this.loginActivity != null) {
      data['loginActivity'] = this.loginActivity!;
    }
    data['custom_status'] = this.customStatus;
    data['custom_status_emoji'] = this.customStatusEmoji;
    data['mute_users'] = this.muteUsers;
    data['mute_channels'] = this.muteChannels;
    data['isLeft'] = this.isLeft;
    if (this.customStatusHistory != null) {
      data['custom_status_history'] =
          this.customStatusHistory!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.lastActiveChat != null) {
      data['lastActiveChat'] = this.lastActiveChat!.toJson();
    }
    data['avatarUrl'] = this.avatarUrl;
    data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
    data['chatList'] = this.chatList;
    data['favouriteList'] = this.favouriteList;
    data['isAutomatic'] = this.isAutomatic;
    data['last_active_time'] = this.lastActiveTime;
    data['elsner_email'] = this.elsnerEmail;
    return data;
  }
}

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
    final Map<String, dynamic> data = {};
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
    final Map<String, dynamic> data = {};
    data['type'] = this.type;
    data['id'] = this.id;
    return data;
  }
}