class ChannelPinnedMessageModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata; // Changed from List<Null> to List<dynamic>

  ChannelPinnedMessageModel(
      {this.statusCode, this.status, this.message, this.data, this.metadata});

  ChannelPinnedMessageModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['metadata'] != null) {
      metadata = json['metadata'].map((v) => v).toList(); // Changed to dynamic
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
  List<Message>? messages;
  int? totalMessages;

  Data({this.messages, this.totalMessages});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messages = <Message>[];
      json['messages'].forEach((v) {
        messages!.add(Message.fromJson(v));
      });
    }
    totalMessages = json['totalMessages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.messages != null) {
      data['messages'] = this.messages!.map((v) => v.toJson()).toList();
    }
    data['totalMessages'] = this.totalMessages;
    return data;
  }
}

class Message {
  String? sId;
  List<MessageDetail>? messagesDetails;
  int? count;

  Message({this.sId, this.messagesDetails, this.count});

  Message.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['messages'] != null) {
      messagesDetails = <MessageDetail>[];
      json['messages'].forEach((v) {
        messagesDetails!.add(MessageDetail.fromJson(v));
      });
    }
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    if (this.messagesDetails != null) {
      data['messages'] = this.messagesDetails!.map((v) => v.toJson()).toList();
    }
    data['count'] = this.count;
    return data;
  }
}

class MessageDetail {
  String? sId;
  String? senderId;
  String? channelId;
  String? content;
  List<dynamic>? files; // Changed from List<Null> to List<dynamic>
  dynamic replyTo; // Changed from Null to dynamic
  bool? isReply;
  bool? isLog;
  bool? isForwarded;
  bool? isEdited;
  dynamic forwardFrom; // Changed from Null to dynamic
  List<String>? readBy;
  bool? isSeen;
  bool? isDeleted;
  List<dynamic>? taggedUsers; // Changed from List<Null> to List<dynamic>
  List<dynamic>? reactions; // Changed from List<Null> to List<dynamic>
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? isPinned;
  List<Replies>? replies;
  int? replyCount;
  List<RepliesSenderInfo>? repliesSenderInfo;
  SenderInfo? senderInfo;
  Forwards? forwards;
  SenderOfForward? senderOfForward;
  bool? isMedia;

  MessageDetail(
      {this.sId,
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
        this.iV,
        this.isPinned,
        this.replies,
        this.replyCount,
        this.repliesSenderInfo,
        this.senderInfo,
        this.forwards,
        this.senderOfForward,
        this.isMedia});

  MessageDetail.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['senderId'];
    channelId = json['channelId'];
    content = json['content'];
    files = json['files']?.map((v) => v).toList(); // Changed to List<dynamic>
    replyTo = json['replyTo']; // Changed from Null to dynamic
    isReply = json['isReply'];
    isLog = json['isLog'];
    isForwarded = json['isForwarded'];
    isEdited = json['isEdited'];
    forwardFrom = json['forwardFrom']; // Changed from Null to dynamic
    readBy = json['readBy']?.cast<String>();
    isSeen = json['is_seen'];
    isDeleted = json['isDeleted'];
    taggedUsers = json['tagged_users']?.map((v) => v).toList(); // Changed to List<dynamic>
    reactions = json['reactions']?.map((v) => v).toList(); // Changed to List<dynamic>
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    isPinned = json['isPinned'];
    if (json['replies'] != null) {
      replies = <Replies>[];
      json['replies'].forEach((v) {
        replies!.add(Replies.fromJson(v));
      });
    }
    replyCount = json['replyCount'];
    if (json['repliesSenderInfo'] != null) {
      repliesSenderInfo = <RepliesSenderInfo>[];
      json['repliesSenderInfo'].forEach((v) {
        repliesSenderInfo!.add(RepliesSenderInfo.fromJson(v));
      });
    }
    senderInfo = json['senderInfo'] != null
        ? SenderInfo.fromJson(json['senderInfo'])
        : null;
    forwards = json['forwards'] != null
        ? Forwards.fromJson(json['forwards'])
        : null;
    senderOfForward = json['senderOfForward'] != null
        ? SenderOfForward.fromJson(json['senderOfForward'])
        : null;
    isMedia = json['isMedia'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['senderId'] = this.senderId;
    data['channelId'] = this.channelId;
    data['content'] = this.content;
    data['files'] = this.files;
    data['replyTo'] = this.replyTo; // Changed from Null to dynamic
    data['isReply'] = this.isReply;
    data['isLog'] = this.isLog;
    data['isForwarded'] = this.isForwarded;
    data['isEdited'] = this.isEdited;
    data['forwardFrom'] = this.forwardFrom; // Changed from Null to dynamic
    data['readBy'] = this.readBy;
    data['is_seen'] = this.isSeen;
    data['isDeleted'] = this.isDeleted;
    data['tagged_users'] = this.taggedUsers;
    data['reactions'] = this.reactions;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['isPinned'] = this.isPinned;
    if (this.replies != null) {
      data['replies'] = this.replies!.map((v) => v.toJson()).toList();
    }
    data['replyCount'] = this.replyCount;
    if (this.repliesSenderInfo != null) {
      data['repliesSenderInfo'] =
          this.repliesSenderInfo!.map((v) => v.toJson()).toList();
    }
    if (this.senderInfo != null) {
      data['senderInfo'] = this.senderInfo!.toJson();
    }
    if (this.forwards != null) {
      data['forwards'] = this.forwards!.toJson();
    }
    if (this.senderOfForward != null) {
      data['senderOfForward'] = this.senderOfForward!.toJson();
    }
    data['isMedia'] = this.isMedia;
    return data;
  }
}

class Replies {
  String? sId;
  String? senderId;
  String? channelId;
  String? content;
  List<dynamic>? files; // Changed from List<Null> to List<dynamic>
  dynamic replyTo; // Changed from Null to dynamic
  bool? isReply;
  bool? isLog;
  bool? isForwarded;
  bool? isEdited;
  dynamic forwardFrom; // Changed from Null to dynamic
  List<String>? readBy;
  bool? isSeen;
  bool? isDeleted;
  List<dynamic>? taggedUsers; // Changed from List<Null> to List<dynamic>
  List<dynamic>? reactions; // Changed from List<Null> to List<dynamic>
  String? createdAt;
  String? updatedAt;
  int? iV;
  SenderInfo? senderInfo;

  Replies(
      {this.sId,
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
        this.iV,
        this.senderInfo});

  Replies.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['senderId'];
    channelId = json['channelId'];
    content = json['content'];
    files = json['files']?.map((v) => v).toList(); // Changed to List<dynamic>
    replyTo = json['replyTo']; // Changed from Null to dynamic
    isReply = json['isReply'];
    isLog = json['isLog'];
    isForwarded = json['isForwarded'];
    isEdited = json['isEdited'];
    forwardFrom = json['forwardFrom']; // Changed from Null to dynamic
    readBy = json['readBy']?.cast<String>();
    isSeen = json['is_seen'];
    isDeleted = json['isDeleted'];
    taggedUsers = json['tagged_users']?.map((v) => v).toList(); // Changed to List<dynamic>
    reactions = json['reactions']?.map((v) => v).toList(); // Changed to List<dynamic>
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
    data['channelId'] = this.channelId;
    data['content'] = this.content;
    data['files'] = this.files;
    data['replyTo'] = this.replyTo; // Changed from Null to dynamic
    data['isReply'] = this.isReply;
    data['isLog'] = this.isLog;
    data['isForwarded'] = this.isForwarded;
    data['isEdited'] = this.isEdited;
    data['forwardFrom'] = this.forwardFrom; // Changed from Null to dynamic
    data['readBy'] = this.readBy;
    data['is_seen'] = this.isSeen;
    data['isDeleted'] = this.isDeleted;
    data['tagged_users'] = this.taggedUsers;
    data['reactions'] = this.reactions;
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
  List<dynamic>? loginActivity; // Changed from List<Null> to List<dynamic>
  String? customStatus;
  String? customStatusEmoji;
  List<String>? muteUsers;
  List<dynamic>? muteChannels; // Changed from List<Null> to List<dynamic>
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
  String? password;

  SenderInfo(
      {this.sId,
        this.fullName,
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
        this.elsnerEmail,
        this.password});

  SenderInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    status = json['status'];
    isActive = json['isActive'];
    if (json['loginActivity'] != null) {
      loginActivity = <dynamic>[]; // Changed from List<Null> to List<dynamic>
      json['loginActivity'].forEach((v) {
        loginActivity!.add(v); // Changed to dynamic
      });
    }
    customStatus = json['customStatus'];
    customStatusEmoji = json['customStatusEmoji'];
    muteUsers = json['mute_users']?.cast<String>();
    muteChannels = json['mute_channels']?.map((v) => v).toList(); // Changed to List<dynamic>
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
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['username'] = this.username;
    data['email'] = this.email;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    if (this.loginActivity != null) {
      data['loginActivity'] = this.loginActivity!;
    }
    data['customStatus'] = this.customStatus;
    data['customStatusEmoji'] = this.customStatusEmoji;
    data['mute_users'] = this.muteUsers;
    if (this.muteChannels != null) {
      data['mute_channels'] = this.muteChannels!;
    }
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
    data['password'] = this.password;
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
    customStatus = json['customStatus'];
    customStatusEmoji = json['customStatusEmoji'];
    updatedBy = json['updatedBy'];
    updatedAt = json['updatedAt'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['customStatus'] = this.customStatus;
    data['customStatusEmoji'] = this.customStatusEmoji;
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

class Forwards {
  String? sId;
  String? senderId;
  String? channelId;
  String? content;
  List<dynamic>? files; // Changed from List<Null> to List<dynamic>
  dynamic replyTo; // Changed from Null to dynamic
  bool? isReply;
  bool? isLog;
  bool? isForwarded;
  bool? isEdited;
  dynamic forwardFrom; // Changed from Null to dynamic
  List<String>? readBy;
  bool? isSeen;
  bool? isDeleted;
  List<dynamic>? taggedUsers; // Changed from List<Null> to List<dynamic>
  List<dynamic>? reactions; // Changed from List<Null> to List<dynamic>
  String? createdAt;
  String? updatedAt;
  int? iV;

  Forwards(
      {this.sId,
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
        this.iV});

  Forwards.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['senderId'];
    channelId = json['channelId'];
    content = json['content'];
    files = json['files']?.map((v) => v).toList(); // Changed to List<dynamic>
    replyTo = json['replyTo']; // Changed from Null to dynamic
    isReply = json['isReply'];
    isLog = json['isLog'];
    isForwarded = json['isForwarded'];
    isEdited = json['isEdited'];
    forwardFrom = json['forwardFrom']; // Changed from Null to dynamic
    readBy = json['readBy']?.cast<String>();
    isSeen = json['is_seen'];
    isDeleted = json['isDeleted'];
    taggedUsers = json['tagged_users']?.map((v) => v).toList(); // Changed to List<dynamic>
    reactions = json['reactions']?.map((v) => v).toList(); // Changed to List<dynamic>
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['senderId'] = this.senderId;
    data['channelId'] = this.channelId;
    data['content'] = this.content;
    data['files'] = this.files;
    data['replyTo'] = this.replyTo; // Changed from Null to dynamic
    data['isReply'] = this.isReply;
    data['isLog'] = this.isLog;
    data['isForwarded'] = this.isForwarded;
    data['isEdited'] = this.isEdited;
    data['forwardFrom'] = this.forwardFrom; // Changed from Null to dynamic
    data['readBy'] = this.readBy;
    data['is_seen'] = this.isSeen;
    data['isDeleted'] = this.isDeleted;
    data['tagged_users'] = this.taggedUsers;
    data['reactions'] = this.reactions;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class SenderOfForward {
  String? sId;
  String? username;
  String? email;
  String? status;
  bool? isActive;
  List<dynamic>? loginActivity; // Changed from List<Null> to List<dynamic>
  String? customStatus;
  String? customStatusEmoji;
  List<String>? muteUsers;
  List<dynamic>? muteChannels; // Changed from List<Null> to List<dynamic>
  List<CustomStatusHistory>? customStatusHistory;
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
  String? password;

  SenderOfForward(
      {this.sId,
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
        this.lastActiveChat,
        this.avatarUrl,
        this.thumbnailAvatarUrl,
        this.isLeft,
        this.chatList,
        this.favouriteList,
        this.isAutomatic,
        this.lastActiveTime,
        this.elsnerEmail,
        this.password});

  SenderOfForward.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    email = json['email'];
    status = json['status'];
    isActive = json['isActive'];
    if (json['loginActivity'] != null) {
      loginActivity = <dynamic>[]; // Changed from List<Null> to List<dynamic>
      json['loginActivity'].forEach((v) {
        loginActivity!.add(v); // Changed to dynamic
      });
    }
    customStatus = json['customStatus'];
    customStatusEmoji = json['customStatusEmoji'];
    muteUsers = json['mute_users']?.cast<String>();
    muteChannels = json['mute_channels']?.map((v) => v).toList(); // Changed to List<dynamic>
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
    isLeft = json['isLeft'];
    chatList = json['chatList'];
    favouriteList = json['favouriteList'];
    isAutomatic = json['isAutomatic'];
    lastActiveTime = json['last_active_time'];
    elsnerEmail = json['elsner_email'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['username'] = this.username;
    data['email'] = this.email;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    if (this.loginActivity != null) {
      data['loginActivity'] = this.loginActivity!;
    }
    data['customStatus'] = this.customStatus;
    data['customStatusEmoji'] = this.customStatusEmoji;
    data['mute_users'] = this.muteUsers;
    if (this.muteChannels != null) {
      data['mute_channels'] = this.muteChannels!;
    }
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
    data['isLeft'] = this.isLeft;
    data['chatList'] = this.chatList;
    data['favouriteList'] = this.favouriteList;
    data['isAutomatic'] = this.isAutomatic;
    data['last_active_time'] = this.lastActiveTime;
    data['elsner_email'] = this.elsnerEmail;
    data['password'] = this.password;
    return data;
  }
}
class RepliesSenderInfo {
  String? sId;
  String? fullName;
  String? username;
  String? email;
  String? password;
  String? status;
  bool? isActive;
  List<dynamic>? loginActivity;
  String? customStatus;
  String? customStatusEmoji;
  List<String>? muteUsers;
  List<String>? muteChannels;
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

  RepliesSenderInfo({
    this.sId,
    this.fullName,
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
    this.avatarUrl,
    this.thumbnailAvatarUrl,
    this.chatList,
    this.favouriteList,
    this.isAutomatic,
    this.lastActiveTime,
    this.elsnerEmail,
  });

  RepliesSenderInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    password = json['password'];
    status = json['status'];
    isActive = json['isActive'];
    if (json['loginActivity'] != null) {
      loginActivity = <dynamic>[]; // Changed from List<Null> to List<dynamic>
      json['loginActivity'].forEach((v) {
        loginActivity!.add(v); // Changed to dynamic
      });
    }
    customStatus = json['customStatus'];
    customStatusEmoji = json['customStatusEmoji'];
    muteUsers = json['mute_users']?.cast<String>();
    muteChannels = json['mute_channels']?.cast<String>(); // Changed from List<Null> to List<String>
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
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['username'] = this.username;
    data['email'] = this.email;
    data['password'] = this.password;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    if (this.loginActivity != null) {
      data['loginActivity'] = this.loginActivity!;
    }
    data['customStatus'] = this.customStatus;
    data['customStatusEmoji'] = this.customStatusEmoji;
    data['mute_users'] = this.muteUsers;
    data['mute_channels'] = this.muteChannels;
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


