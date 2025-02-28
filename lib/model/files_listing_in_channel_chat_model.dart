class FilesListingInChannelChatModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata; // Change this to the appropriate type if known

  FilesListingInChannelChatModel(
      {this.statusCode, this.status, this.message, this.data, this.metadata});

  FilesListingInChannelChatModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['metadata'] != null) {
      metadata = <dynamic>[]; // Change this to the appropriate type if known
      json['metadata'].forEach((v) {
        metadata!.add(v); // Assuming metadata is a list of dynamic objects
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
  String? channelId;
  String? content;
  List<String>? files;
  bool? isMedia;
  dynamic replyTo; // Change this to the appropriate type if known
  bool? isReply;
  bool? isLog;
  bool? isForwarded;
  bool? isEdited;
  dynamic forwardFrom; // Change this to the appropriate type if known
  List<String>? readBy;
  bool? isSeen;
  bool? isDeleted;
  List<dynamic>? taggedUsers; // Change this to the appropriate type if known
  List<dynamic>? reactions; // Change this to the appropriate type if known
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? isPinned;
  SenderInfo? senderInfo;

  Messages(
      {this.sId,
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
        this.iV,
        this.isPinned,
        this.senderInfo});

  Messages.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['senderId'];
    channelId = json['channelId'];
    content = json['content'];
    files = json['files']?.cast<String>();
    isMedia = json['isMedia'];
    replyTo = json['replyTo']; // Change this to the appropriate type if known
    isReply = json['isReply'];
    isLog = json['isLog'];
    isForwarded = json['isForwarded'];
    isEdited = json['isEdited'];
    forwardFrom = json['forwardFrom']; // Change this to the appropriate type if known
    readBy = json['readBy']?.cast<String>();
    isSeen = json['is_seen'];
    isDeleted = json['isDeleted'];
    if (json['tagged_users'] != null) {
      taggedUsers = <dynamic>[]; // Change this to the appropriate type if known
      json['tagged_users'].forEach((v) {
        taggedUsers!.add(v); // Assuming taggedUsers is a list of dynamic objects
      });
    }
    if (json['reactions'] != null) {
      reactions = <dynamic>[]; // Change this to the appropriate type if known
      json['reactions'].forEach((v) {
        reactions!.add(v); // Assuming reactions is a list of dynamic objects
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    isPinned = json['isPinned'];
    senderInfo = json['senderInfo'] != null
        ? SenderInfo.fromJson(json['senderInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['senderId'] = this.senderId;
    data['channelId'] = this.channelId;
    data['content'] = this.content;
    data['files'] = this.files;
    data['isMedia'] = this.isMedia;
    data['replyTo'] = this.replyTo; // Change this to the appropriate type if known
    data['isReply'] = this.isReply;
    data['isLog'] = this.isLog;
    data['isForwarded'] = this.isForwarded;
    data['isEdited'] = this.isEdited;
    data['forwardFrom'] = this.forwardFrom; // Change this to the appropriate type if known
    data['readBy'] = this.readBy;
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
    data['isPinned'] = this.isPinned;
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
  List<dynamic>? loginActivity; // Change this to the appropriate type if known
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
      loginActivity = <dynamic>[]; // Change this to the appropriate type if known
      json['loginActivity'].forEach((v) {
        loginActivity!.add(v); // Assuming loginActivity is a list of dynamic objects
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