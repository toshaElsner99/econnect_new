class GetReplyMessageChannelModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata; // Changed from List<Null> to List<dynamic>

  GetReplyMessageChannelModel(
      {this.statusCode, this.status, this.message, this.data, this.metadata});

  GetReplyMessageChannelModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    if (json['metadata'] != null) {
      metadata = <dynamic>[]; // Changed from List<Null> to List<dynamic>
      json['metadata'].forEach((v) {
        metadata!.add(v); // No need to create a Null object
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
  List<MessagesList>? messagesList;

  Data({this.messagesList});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messagesList = <MessagesList>[];
      json['messages'].forEach((v) {
        messagesList!.add(new MessagesList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.messagesList != null) {
      data['messages'] = this.messagesList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MessagesList {
  String? date;
  List<MessagesGroupList>? messagesGroupList;

  MessagesList({this.date, this.messagesGroupList});

  MessagesList.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    if (json['messages'] != null) {
      messagesGroupList = <MessagesGroupList>[];
      json['messages'].forEach((v) {
        messagesGroupList!.add(new MessagesGroupList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    if (this.messagesGroupList != null) {
      data['messages'] = this.messagesGroupList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MessagesGroupList {
  String? sId;
  SenderId? senderId;
  String? channelId;
  String? content;
  List<String>? files;
  bool? isMedia;
  dynamic replyTo; // Changed from Null? to dynamic
  bool? isReply;
  bool? isLog;
  bool? isForwarded;
  bool? isEdited;
  ForwardFrom? forwardFrom;
  List<String>? readBy;
  bool? isSeen;
  bool? isDeleted;
  List<dynamic>? taggedUsers; // Changed from List<Null> to List<dynamic>
  List<dynamic>? reactions; // Changed from List<Null> to List<dynamic>
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? isPinned;

  MessagesGroupList(
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

      });

  MessagesGroupList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['senderId'] != null
        ? new SenderId.fromJson(json['senderId'])
        : null;
    channelId = json['channelId'];
    content = json['content'];
    if (json['files'] != null) {
      files = <String>[]; // Changed from List<Null> to List<String>
      json['files'].forEach((v) {
        files!.add(v); // No need to create a Null object
      });
    }
    isMedia = json['isMedia'] ?? false;
    replyTo = json['replyTo'];
    isReply = json['isReply'];
    isLog = json['isLog'];
    isForwarded = json['isForwarded'];
    isEdited = json['isEdited'];
    forwardFrom = json['forwardFrom'] != null
        ? new ForwardFrom.fromJson(json['forwardFrom'])
        : null;
    readBy = json['readBy'].cast<String>();
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
    isPinned = json['isPinned'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.senderId != null) {
      data['senderId'] = this.senderId!.toJson();
    }
    data['channelId'] = this.channelId;
    data['content'] = this.content;
    if (this.files != null) {
      data['files'] = this.files!;
    }
    data['isMedia'] = this.isMedia;
    data['replyTo'] = this.replyTo;
    data['isReply'] = this.isReply;
    data['isLog'] = this.isLog;
    data['isForwarded'] = this.isForwarded;
    data['isEdited'] = this.isEdited;
    if (this.forwardFrom != null) {
      data['forwardFrom'] = this.forwardFrom!.toJson();
    }
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
    data['isPinned'] = this.isPinned ?? false;
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

  SenderId(
      {this.sId,
        this.fullName,
        this.username,
        this.email,
        this.status,
        this.customStatus,
        this.customStatusEmoji,
        this.avatarUrl,
        this.thumbnailAvatarUrl,
        this.elsnerEmail});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['username'] = this.username;
    data['email'] = this.email;
    data['status'] = this.status;
    data['custom_status'] = this.customStatus;
    data['custom_status_emoji'] = this.customStatusEmoji;
    data['avatarUrl'] = this.avatarUrl;
    data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
    data['elsner_email'] = this.elsnerEmail;
    return data;
  }
}


class ForwardFrom {
  String? sId;
  SenderId? senderId;
  String? content;
  List<dynamic>? files;
  String? createdAt;

  ForwardFrom(
      {this.sId, this.senderId, this.content, this.files, this.createdAt});

  ForwardFrom.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['senderId'] != null
        ? new SenderId.fromJson(json['senderId'])
        : null;
    content = json['content'];
    files = json['files']?.cast<String>(); // Ensure files is a List<String> or null
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.senderId != null) {
      data['senderId'] = this.senderId!.toJson();
    }
    data['content'] = this.content;
    data['files'] = this.files;
    data['createdAt'] = this.createdAt;
    return data;
  }
}