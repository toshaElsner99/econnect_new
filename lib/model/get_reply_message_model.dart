class GetReplyMessageModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;

  GetReplyMessageModel({this.statusCode, this.status, this.message, this.data});

  GetReplyMessageModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Messages>? messages;

  Data({this.messages});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messages = (json['messages'] as List).map((v) => Messages.fromJson(v)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  String? date;
  List<GroupMessages>? groupMessages;

  Messages({this.date, this.groupMessages});

  Messages.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    if (json['messages'] != null) {
      groupMessages = (json['messages'] as List).map((v) => GroupMessages.fromJson(v)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    if (groupMessages != null) {
      data['messages'] = groupMessages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GroupMessages {
  String? sId;
  SenderId? senderId;
  String? receiverId;
  String? content;
  List<String>? files;
  bool? isMedia;
  String? replyTo;
  bool? isReply;
  bool? isLog;
  bool? isForwarded;
  bool? isEdited;
  String? forwardFrom;
  List<dynamic>? readBy;
  bool? isSeen;
  bool? isDeleted;
  List<dynamic>? taggedUsers;
  List<dynamic>? reactions;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? isPinned;

  GroupMessages({
    this.sId,
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
    this.isPinned,
  });

  GroupMessages.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['senderId'] != null ? SenderId.fromJson(json['senderId']) : null;
    receiverId = json['receiverId'];
    content = json['content'];
    files = json['files'] != null ? List<String>.from(json['files']) : null;
    isMedia = json['isMedia'];
    replyTo = json['replyTo'];
    isReply = json['isReply'];
    isLog = json['isLog'];
    isForwarded = json['isForwarded'];
    isEdited = json['isEdited'];
    forwardFrom = json['forwardFrom'];
    readBy = json['readBy'] != null ? List<dynamic>.from(json['readBy']) : null;
    isSeen = json['is_seen'];
    isDeleted = json['isDeleted'];
    taggedUsers = json['tagged_users'] != null ? List<dynamic>.from(json['tagged_users']) : null;
    reactions = json['reactions'] != null ? List<dynamic>.from(json['reactions']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    isPinned = json['isPinned'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (senderId != null) {
      data['senderId'] = senderId!.toJson();
    }
    data['receiverId'] = receiverId;
    data['content'] = content;
    data['files'] = files;
    data['isMedia'] = isMedia;
    data['replyTo'] = replyTo;
    data['isReply'] = isReply;
    data['isLog'] = isLog;
    data['isForwarded'] = isForwarded;
    data['isEdited'] = isEdited;
    data['forwardFrom'] = forwardFrom;
    data['readBy'] = readBy;
    data['is_seen'] = isSeen;
    data['isDeleted'] = isDeleted;
    data['tagged_users'] = taggedUsers;
    data['reactions'] = reactions;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['isPinned'] = isPinned;
    return data;
  }
}

class SenderId {
  String? sId;
  String? fullName;
  String? username;
  String? email;
  String? status;
  String? customStatus;
  String? customStatusEmoji;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  String? elsnerEmail;

  SenderId({
    this.sId,
    this.fullName,
    this.username,
    this.email,
    this.status,
    this.customStatus,
    this.customStatusEmoji,
    this.avatarUrl,
    this.thumbnailAvatarUrl,
    this.elsnerEmail,
  });

  SenderId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    status = json['status'];
    customStatus = json['custom_status'];
    customStatusEmoji = json['custom_status_emoji'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    elsnerEmail = json['elsner_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['username'] = username;
    data['email'] = email;
    data['status'] = status;
    data['custom_status'] = customStatus;
    data['custom_status_emoji'] = customStatusEmoji;
    data['avatarUrl'] = avatarUrl;
    data['thumbnail_avatarUrl'] = thumbnailAvatarUrl;
    data['elsner_email'] = elsnerEmail;
    return data;
  }
}
