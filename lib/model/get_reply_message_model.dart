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
  ForwardFrom? forwardFrom;
  List<dynamic>? readBy;
  bool? isSeen;
  bool? isDeleted;
  List<dynamic>? taggedUsers;
  List<Reactions>? reactions;
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
    // forwardFrom = json['forwardFrom'];
    forwardFrom = json['forwardFrom'] != null ? ForwardFrom.fromJson(json['forwardFrom']) : null;
    readBy = json['readBy'] != null ? List<dynamic>.from(json['readBy']) : null;
    isSeen = json['is_seen'];
    isDeleted = json['isDeleted'];
    taggedUsers = json['tagged_users'] != null ? List<dynamic>.from(json['tagged_users']) : null;
    if (json['reactions'] != null) {
      reactions = <Reactions>[];
      json['reactions'].forEach((v) {
        reactions!.add(new Reactions.fromJson(v));
      });
    }
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
    if (this.forwardFrom != null) {
      data['forwardFrom'] = this.forwardFrom!.toJson();
    }
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
class Reactions {
  String? emoji;
  UserId? userId;
  String? sId;

  Reactions({this.emoji, this.userId, this.sId});

  Reactions.fromJson(Map<String, dynamic> json) {
    emoji = json['emoji'];
    userId =
    json['userId'] != null ? new UserId.fromJson(json['userId']) : null;
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['emoji'] = this.emoji;
    if (this.userId != null) {
      data['userId'] = this.userId!.toJson();
    }
    data['_id'] = this.sId;
    return data;
  }
}

class UserId {
  String? sId;
  String? username;

  UserId({this.sId, this.username});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['username'] = this.username;
    return data;
  }
}



// class SenderId {
//   String? sId;
//   String? fullName;
//   String? username;
//   String? email;
//   String? status;
//   String? customStatus;
//   String? customStatusEmoji;
//   String? avatarUrl;
//   String? thumbnailAvatarUrl;
//   String? elsnerEmail;
//
//   SenderId(
//       {this.sId,
//         this.fullName,
//         this.username,
//         this.email,
//         this.status,
//         this.customStatus,
//         this.customStatusEmoji,
//         this.avatarUrl,
//         this.thumbnailAvatarUrl,
//         this.elsnerEmail});
//
//   SenderId.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     fullName = json['fullName'];
//     username = json['username'];
//     email = json['email'];
//     status = json['status'];
//     customStatus = json['custom_status'];
//     customStatusEmoji = json['custom_status_emoji'];
//     avatarUrl = json['avatarUrl'];
//     thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
//     elsnerEmail = json['elsner_email'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['_id'] = this.sId;
//     data['fullName'] = this.fullName;
//     data['username'] = this.username;
//     data['email'] = this.email;
//     data['status'] = this.status;
//     data['custom_status'] = this.customStatus;
//     data['custom_status_emoji'] = this.customStatusEmoji;
//     data['avatarUrl'] = this.avatarUrl;
//     data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
//     data['elsner_email'] = this.elsnerEmail;
//     return data;
//   }
// }

class ForwardFrom {
  String? sId;
  SenderId? senderId;
  String? content;
  List<dynamic>? files;
  String? createdAt;

  ForwardFrom({
    this.sId,
    this.senderId,
    this.content,
    this.files,
    this.createdAt,
  });

  ForwardFrom.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['senderId'] != null
        ? SenderId.fromJson(json['senderId'])
        : null;
    content = json['content'];
    if (json['files'] != null) {
      files = List<dynamic>.from(json['files']);
    }
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (senderId != null) {
      data['senderId'] = senderId!.toJson();
    }
    data['content'] = content;
    if (files != null) {
      data['files'] = files;
    }
    data['createdAt'] = createdAt;
    return data;
  }
}

class SenderId {
  String? sId;
  String? fullName;
  String? userName;
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
    this.userName,
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
    userName = json['username'];
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
    data['username'] = userName;
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


// class GetReplyMessageModel {
//   int? statusCode;
//   int? status;
//   String? message;
//   Data? data;
//   List<dynamic>? metadata; // Changed from List<Null> to List<dynamic>
//
//   GetReplyMessageModel(
//       {this.statusCode, this.status, this.message, this.data, this.metadata});
//
//   GetReplyMessageModel.fromJson(Map<String, dynamic> json) {
//     statusCode = json['statusCode'];
//     status = json['status'];
//     message = json['messages'];
//     data = json['data'] != null ? Data.fromJson(json['data']) : null;
//     if (json['metadata'] != null) {
//       metadata = <dynamic>[]; // Changed from List<Null> to List<dynamic>
//       json['metadata'].forEach((v) {
//         metadata!.add(v); // No need to create a Null instance
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['statusCode'] = this.statusCode;
//     data['status'] = this.status;
//     data['messages'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     if (this.metadata != null) {
//       data['metadata'] = this.metadata; // No need to map toJson
//     }
//     return data;
//   }
// }
//
// class Data {
//   List<GroupMessages>? groupMessages;
//
//   Data({this.groupMessages});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     if (json['messages'] != null) {
//       groupMessages = <GroupMessages>[];
//       json['messages'].forEach((v) {
//         groupMessages!.add(GroupMessages.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (this.groupMessages != null) {
//       data['messages'] =
//           this.groupMessages!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class GroupMessages {
//   String? date;
//   List<Messages>? messages;
//
//   GroupMessages({this.date, this.messages});
//
//   GroupMessages.fromJson(Map<String, dynamic> json) {
//     date = json['date'];
//     if (json['messages'] != null) {
//       messages = <Messages>[];
//       json['messages'].forEach((v) {
//         messages!.add(Messages.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['date'] = this.date;
//     if (this.messages != null) {
//       data['messages'] = this.messages!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Messages {
//   String? sId;
//   SenderId? senderId;
//   String? receiverId;
//   String? content;
//   List<dynamic>? files; // Changed from List<Null> to List<dynamic>
//   dynamic replyTo; // Changed from Null to dynamic
//   bool? isReply;
//   bool? isLog;
//   bool? isForwarded;
//   bool? isEdited;
//   ForwardFrom? forwardFrom;
//   List<dynamic>? readBy; // Changed from List<Null> to List<dynamic>
//   bool? isSeen;
//   bool? isDeleted;
//   List<dynamic>? taggedUsers; // Changed from List<Null> to List<dynamic>
//   List<dynamic>? reactions; // Changed from List<Null> to List<dynamic>
//   String? createdAt;
//   String? updatedAt;
//   int? iV;
//
//   Messages(
//       {this.sId,
//         this.senderId,
//         this.receiverId,
//         this.content,
//         this.files,
//         this.replyTo,
//         this.isReply,
//         this.isLog,
//         this.isForwarded,
//         this.isEdited,
//         this.forwardFrom,
//         this.readBy,
//         this.isSeen,
//         this.isDeleted,
//         this.taggedUsers,
//         this.reactions,
//         this.createdAt,
//         this.updatedAt,
//         this.iV});
//
//   Messages.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     senderId = json['senderId'] != null
//         ? SenderId.fromJson(json['senderId'])
//         : null;
//     receiverId = json['receiverId'];
//     content = json['content'];
//     if (json['files'] != null) {
//       files = <dynamic>[]; // Changed from List<Null> to List<dynamic>
//       json['files'].forEach((v) {
//         files!.add(v); // No need to create a Null instance
//       });
//     }
//     replyTo = json['replyTo'];
//     isReply = json['isReply'];
//     isLog = json['isLog'];
//     isForwarded = json['isForwarded'];
//     isEdited = json['isEdited'];
//     forwardFrom = json['forwardFrom'] != null
//         ? ForwardFrom.fromJson(json['forwardFrom'])
//         : null;
//     if (json['readBy'] != null) {
//       readBy = <dynamic>[]; // Changed from List<Null> to List<dynamic>
//       json['readBy'].forEach((v) {
//         readBy!.add(v); // No need to create a Null instance
//       });
//     }
//     isSeen = json['is_seen'];
//     isDeleted = json['isDeleted'];
//     if (json['tagged_users'] != null) {
//       taggedUsers = <dynamic>[]; // Changed from List<Null> to List<dynamic>
//       json['tagged_users'].forEach((v) {
//         taggedUsers!.add(v); // No need to create a Null instance
//       });
//     }
//     if (json['reactions'] != null) {
//       reactions = <dynamic>[]; // Changed from List<Null> to List<dynamic>
//       json['reactions'].forEach((v) {
//         reactions!.add(v); // No need to create a Null instance
//       });
//     }
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     iV = json['__v'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['_id'] = this.sId;
//     if (this.senderId != null) {
//       data['senderId'] = this.senderId!.toJson();
//     }
//     data['receiverId'] = this.receiverId;
//     data['content'] = this.content;
//     if (this.files != null) {
//       data['files'] = this.files; // No need to map toJson
//     }
//     data['replyTo'] = this.replyTo;
//     data['isReply'] = this.isReply;
//     data['isLog'] = this.isLog;
//     data['isForwarded'] = this.isForwarded;
//     data['isEdited'] = this.isEdited;
//     if (this.forwardFrom != null) {
//       data['forwardFrom'] = this.forwardFrom!.toJson();
//     }
//     if (this.readBy != null) {
//       data['readBy'] = this.readBy; // No need to map toJson
//     }
//     data['is_seen'] = this.isSeen;
//     data['isDeleted'] = this.isDeleted;
//     if (this.taggedUsers != null) {
//       data['tagged_users'] = this.taggedUsers; // No need to map toJson
//     }
//     if (this.reactions != null) {
//       data['reactions'] = this.reactions; // No need to map toJson
//     }
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['__v'] = this.iV;
//     return data;
//   }
// }
//
// class SenderId {
//   String? sId;
//   String? fullName;
//   String? username;
//   String? email;
//   String? status;
//   String? customStatus;
//   String? customStatusEmoji;
//   String? avatarUrl;
//   String? thumbnailAvatarUrl;
//   String? elsnerEmail;
//
//   SenderId(
//       {this.sId,
//         this.fullName,
//         this.username,
//         this.email,
//         this.status,
//         this.customStatus,
//         this.customStatusEmoji,
//         this.avatarUrl,
//         this.thumbnailAvatarUrl,
//         this.elsnerEmail});
//
//   SenderId.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     fullName = json['fullName'];
//     username = json['username'];
//     email = json['email'];
//     status = json['status'];
//     customStatus = json['custom_status'];
//     customStatusEmoji = json['custom_status_emoji'];
//     avatarUrl = json['avatarUrl'];
//     thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
//     elsnerEmail = json['elsner_email'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['_id'] = this.sId;
//     data['fullName'] = this.fullName;
//     data['username'] = this.username;
//     data['email'] = this.email;
//     data['status'] = this.status;
//     data['custom_status'] = this.customStatus;
//     data['custom_status_emoji'] = this.customStatusEmoji;
//     data['avatarUrl'] = this.avatarUrl;
//     data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
//     data['elsner_email'] = this.elsnerEmail;
//     return data;
//   }
// }
//
// class ForwardFrom {
//   String? sId;
//   SenderId? senderId;
//   String? content;
//   List<dynamic>? files; // Changed from List<Null> to List<dynamic>
//   String? createdAt;
//
//   ForwardFrom(
//       {this.sId, this.senderId, this.content, this.files, this.createdAt});
//
//   ForwardFrom.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     senderId = json['senderId'] != null
//         ? SenderId.fromJson(json['senderId'])
//         : null;
//     content = json['content'];
//     if (json['files'] != null) {
//       files = <dynamic>[]; // Changed from List<Null> to List<dynamic>
//       json['files'].forEach((v) {
//         files!.add(v); // No need to create a Null instance
//       });
//     }
//     createdAt = json['createdAt'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['_id'] = this.sId;
//     if (this.senderId != null) {
//       data['senderId'] = this.senderId!.toJson();
//     }
//     data['content'] = this.content;
//     if (this.files != null) {
//       data['files'] = this.files; // No need to map toJson
//     }
//     data['createdAt'] = this.createdAt;
//     return data;
//   }
// }