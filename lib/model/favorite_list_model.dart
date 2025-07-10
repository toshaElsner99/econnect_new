// class FavoriteListModel {
//   int? statusCode;
//   int? status;
//   String? message;
//   Data? data;
//   List<dynamic>? metadata; // Changed to dynamic
//
//   FavoriteListModel({this.statusCode, this.status, this.message, this.data, this.metadata});
//
//   FavoriteListModel.fromJson(Map<String, dynamic> json) {
//     statusCode = json['statusCode'];
//     status = json['status'];
//     message = json['message'];
//     data = json['data'] != null ? Data.fromJson(json['data']) : null;
//     metadata = json['metadata'] ?? []; // Handle metadata as a list of dynamic
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['statusCode'] = statusCode;
//     data['status'] = status;
//     data['message'] = message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     if (metadata != null) {
//       data['metadata'] = metadata;
//     }
//     return data;
//   }
// }
//
// class Data {
//   String? userId;
//   List<ChatList>? chatList;
//   List<dynamic>? favouriteChannels; // Changed to dynamic
//
//   Data({this.userId, this.chatList, this.favouriteChannels});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     userId = json['userId'];
//     if (json['chatList'] != null) {
//       chatList = [];
//       json['chatList'].forEach((v) {
//         chatList!.add(ChatList.fromJson(v));
//       });
//     }
//     favouriteChannels = json['favouriteChannels'] ?? []; // Handle as a list of dynamic
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['userId'] = userId;
//     if (chatList != null) {
//       data['chatList'] = chatList!.map((v) => v.toJson()).toList();
//     }
//     if (favouriteChannels != null) {
//       data['favouriteChannels'] = favouriteChannels;
//     }
//     return data;
//   }
// }
//
// class ChatList {
//   String? sId;
//   String? username;
//   String? email;
//   String? password;
//   String? status;
//   bool? isActive;
//   List<dynamic>? loginActivity; // Changed to dynamic
//   String? customStatus;
//   String? customStatusEmoji;
//   List<String>? muteUsers;
//   List<String>? muteChannels;
//   List<CustomStatusHistory>? customStatusHistory;
//   String? createdAt;
//   String? updatedAt;
//   int? iV;
//   LastActiveChat? lastActiveChat;
//   String? chatList;
//   String? avatarUrl;
//   String? thumbnailAvatarUrl;
//   bool? isLeft;
//   bool? isAutomatic;
//   String? lastActiveTime;
//   String? favouriteList;
//   String? elsnerEmail;
//   int? unseenMessagesCount;
//   String? fullName;
//
//   ChatList({
//     this.sId,
//     this.username,
//     this.email,
//     this.password,
//     this.status,
//     this.isActive,
//     this.loginActivity,
//     this.customStatus,
//     this.customStatusEmoji,
//     this.muteUsers,
//     this.muteChannels,
//     this.customStatusHistory,
//     this.createdAt,
//     this.updatedAt,
//     this.iV,
//     this.lastActiveChat,
//     this.chatList,
//     this.avatarUrl,
//     this.thumbnailAvatarUrl,
//     this.isLeft,
//     this.isAutomatic,
//     this.lastActiveTime,
//     this.favouriteList,
//     this.elsnerEmail,
//     this.unseenMessagesCount,
//     this.fullName,
//   });
//
//   ChatList.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     username = json['username'];
//     email = json['email'];
//     password = json['password'];
//     status = json['status'];
//     isActive = json['isActive'];
//     loginActivity = json['loginActivity'] ?? []; // Handle as a list of dynamic
//     customStatus = json['customStatus'];
//     customStatusEmoji = json['customStatusEmoji'];
//     muteUsers = json['mute_users'].cast<String>();
//     muteChannels = json['mute_channels'].cast<String>();
//     if (json['custom_status_history'] != null) {
//       customStatusHistory = [];
//       json['custom_status_history'].forEach((v) {
//         customStatusHistory!.add(CustomStatusHistory.fromJson(v));
//       });
//     }
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     iV = json['__v'];
//     lastActiveChat = json['lastActiveChat'] != null
//         ? LastActiveChat.fromJson(json['lastActiveChat'])
//         : null;
//     chatList = json['chatList'];
//     avatarUrl = json['avatarUrl'];
//     thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
//     isLeft = json['isLeft'];
//     isAutomatic = json['isAutomatic'];
//     lastActiveTime = json['last_active_time'];
//     favouriteList = json['favouriteList'];
//     elsnerEmail = json['elsner_email'];
//     unseenMessagesCount = json['unseenMessagesCount'] ?? 0;
//     fullName = json['fullName'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['_id'] = sId;
//     data['username'] = username;
//     data['email'] = email;
//     data['password'] = password;
//     data['status'] = status;
//     data['isActive'] = isActive;
//     if (loginActivity != null) {
//       data['loginActivity'] = loginActivity;
//     }
//     data['customStatus'] = customStatus;
//     data['customStatusEmoji'] = customStatusEmoji;
//     data['mute_users'] = muteUsers;
//     data['mute_channels'] = muteChannels;
//     if (customStatusHistory != null) {
//       data['custom_status_history'] =
//           customStatusHistory!.map((v) => v.toJson()).toList();
//     }
//     data['createdAt'] = createdAt;
//     data['updatedAt'] = updatedAt;
//     data['__v'] = iV;
//     if (lastActiveChat != null) {
//       data['lastActiveChat'] = lastActiveChat!.toJson();
//     }
//     data['chatList'] = chatList;
//     data['avatarUrl'] = avatarUrl;
//     data['thumbnail_avatarUrl'] = thumbnailAvatarUrl;
//     data['isLeft'] = isLeft;
//     data['isAutomatic'] = isAutomatic;
//     data['last_active_time'] = lastActiveTime;
//     data['favouriteList'] = favouriteList;
//     data['elsner_email'] = elsnerEmail;
//     data['unseenMessagesCount'] = unseenMessagesCount ?? 0;
//     data['fullName'] = fullName;
//     return data;
//   }
// }
//
// // Other classes remain unchanged
//
// class CustomStatusHistory {
//   String? customStatus;
//   String? customStatusEmoji;
//   String? updatedBy;
//   String? updatedAt;
//   String? sId;
//
//   CustomStatusHistory(
//       {this.customStatus,
//         this.customStatusEmoji,
//         this.updatedBy,
//         this.updatedAt,
//         this.sId});
//
//   CustomStatusHistory.fromJson(Map<String, dynamic> json) {
//     customStatus = json['customStatus'];
//     customStatusEmoji = json['customStatusEmoji'];
//     updatedBy = json['updatedBy'];
//     updatedAt = json['updatedAt'];
//     sId = json['_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['customStatus'] = this.customStatus;
//     data['customStatusEmoji'] = this.customStatusEmoji;
//     data['updatedBy'] = this.updatedBy;
//     data['updatedAt'] = this.updatedAt;
//     data['_id'] = this.sId;
//     return data;
//   }
// }
//
// class LastActiveChat {
//   String? type;
//   String? id;
//
//   LastActiveChat({this.type, this.id});
//
//   LastActiveChat.fromJson(Map<String, dynamic> json) {
//     type = json['type'];
//     id = json['id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['type'] = this.type;
//     data['id'] = this.id;
//     return data;
//   }
// }
class FavoriteListModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata; // Changed from List<Null> to List<dynamic>

  FavoriteListModel(
      {this.statusCode, this.status, this.message, this.data, this.metadata});

  FavoriteListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['metadata'] != null) {
      metadata = json['metadata']; // Assuming metadata can be of any type
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
      data['metadata'] = this.metadata; // Assuming metadata can be of any type
    }
    return data;
  }
}

class Data {
  String? userId;
  List<ChatList>? chatList;
  List<FavouriteChannels>? favouriteChannels;
  List<dynamic>? mutedUsers = [];

  Data({this.userId, this.chatList, this.favouriteChannels,this.mutedUsers});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    if (json['chatList'] != null) {
      chatList = (json['chatList'] as List).map((v) => ChatList.fromJson(v)).toList();
    }
    if (json['favoriteChannels'] != null) {
      favouriteChannels = (json['favoriteChannels'] as List).map((v) => FavouriteChannels.fromJson(v)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['userId'] = this.userId;
    if (this.chatList != null) {
      data['chatList'] = this.chatList!.map((v) => v.toJson()).toList();
    }
    if (this.favouriteChannels != null) {
      data['favoriteChannels'] = this.favouriteChannels!.map((v) => v.toJson()).toList();
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
  List<dynamic>? loginActivity; // Changed from List<Null> to List<dynamic>
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
  String? favouriteList;
  String? fullName;
  bool? isAutomatic;
  String? lastActiveTime;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  bool? isLeft;
  String? elsnerEmail;
  int? unseenMessagesCount;
  String? latestMessageCreatedAt;
  String? position;

  ChatList(
      {this.sId,
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
        this.favouriteList,
        this.fullName,
        this.isAutomatic,
        this.lastActiveTime,
        this.avatarUrl,
        this.thumbnailAvatarUrl,
        this.isLeft,
        this.elsnerEmail,
        this.unseenMessagesCount,
        this.latestMessageCreatedAt,
        this.position});

  ChatList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    email = json['email'];
    password = json['password'];
    status = json['status'];
    isActive = json['isActive'];
    if (json['loginActivity'] != null) {
      loginActivity = json['loginActivity']; // Assuming loginActivity can be of any type
    }
    customStatus = json['customStatus'];
    customStatusEmoji = json['customStatusEmoji'];
    muteUsers = List<String>.from(json['mute_users'] ?? []);
    muteChannels = List<String>.from(json['mute_channels'] ?? []);
    if (json['custom_status_history'] != null) {
      customStatusHistory = (json['custom_status_history'] as List).map((v) => CustomStatusHistory.fromJson(v)).toList();
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    lastActiveChat = json['lastActiveChat'] != null ? LastActiveChat.fromJson(json['lastActiveChat']) : null;
    chatList = json['chatList'];
    favouriteList = json['favouriteList'];
    fullName = json['fullName'];
    isAutomatic = json['isAutomatic'];
    lastActiveTime = json['last_active_time'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    isLeft = json['isLeft'];
    elsnerEmail = json['elsner_email'];
    unseenMessagesCount = json['unseenMessagesCount'] ?? 0;
    latestMessageCreatedAt = json['latestMessageCreatedAt'] ?? "";
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['username'] = this.username;
    data['email'] = this.email;
    data['password'] = this.password;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    if (this.loginActivity != null) {
      data['loginActivity'] = this.loginActivity; // Assuming loginActivity can be of any type
    }
    data['customStatus'] = this.customStatus;
    data['customStatusEmoji'] = this.customStatusEmoji;
    data['mute_users'] = this.muteUsers;
    data['mute_channels'] = this.muteChannels;
    if (this.customStatusHistory != null) {
      data['custom_status_history'] = this.customStatusHistory!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.lastActiveChat != null) {
      data['lastActiveChat'] = this.lastActiveChat!.toJson();
    }
    data['chatList'] = this.chatList;
    data['favouriteList'] = this.favouriteList;
    data['fullName'] = this.fullName;
    data['isAutomatic'] = this.isAutomatic;
    data['last_active_time'] = this.lastActiveTime;
    data['avatarUrl'] = this.avatarUrl;
    data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
    data['isLeft'] = this.isLeft;
    data['elsner_email'] = this.elsnerEmail;
    data['unseenMessagesCount'] = this.unseenMessagesCount ?? 0;
    data['latestMessageCreatedAt'] = this.latestMessageCreatedAt ?? 0;
    data['position'] = this.position;
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

class FavouriteChannels {
  String? sId;
  String? name;
  String? description;
  bool? isPrivate;
  List<Members>? members;
  bool? isDeleted;
  bool? isDefault;
  String? updatedBy;
  dynamic deletedBy; // Changed from Null to dynamic
  List<dynamic>? headerHistory; // Changed from List<Null> to List<dynamic>
  String? createdAt;
  String? updatedAt;
  int? iV;
  int? unseenMessagesCount;
  String? lastMessage;
  String? ownerId;

  FavouriteChannels(
      {this.sId,
        this.name,
        this.description,
        this.isPrivate,
        this.members,
        this.isDeleted,
        this.isDefault,
        this.updatedBy,
        this.deletedBy,
        this.headerHistory,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.unseenMessagesCount,
        this.lastMessage,
        this.ownerId});

  FavouriteChannels.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['channelName'];
    description = json['description'];
    isPrivate = json['isPrivate'];
    if (json['members'] != null) {
      members = (json['members'] as List).map((v) => Members.fromJson(v)).toList();
    }
    isDeleted = json['isDeleted'];
    isDefault = json['isDefault'];
    updatedBy = json['updatedBy'];
    deletedBy = json['deletedBy']; // Assuming deletedBy can be of any type
    if (json['header_history'] != null) {
      headerHistory = json['header_history']; // Assuming headerHistory can be of any type
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    unseenMessagesCount = json['unseenMessagesCount'];
    lastMessage = json['lastMessage'];
    ownerId = json['ownerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['channelName'] = this.name;
    data['description'] = this.description;
    data['isPrivate'] = this.isPrivate;
    if (this.members != null) {
      data['members'] = this.members!.map((v) => v.toJson()).toList();
    }
    data['isDeleted'] = this.isDeleted;
    data['isDefault'] = this.isDefault;
    data['updatedBy'] = this.updatedBy;
    data['deletedBy'] = this.deletedBy; // Assuming deletedBy can be of any type
    if (this.headerHistory != null) {
      data['header_history'] = this.headerHistory; // Assuming headerHistory can be of any type
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['unseenMessagesCount'] = this.unseenMessagesCount;
    data['lastMessage'] = this.lastMessage;
    data['ownerId'] = this.ownerId;
    return data;
  }
}

class Members {
  String? id;
  bool? isAdmin;
  String? sId;

  Members({this.id, this.isAdmin, this.sId});

  Members.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isAdmin = json['isAdmin'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = this.id;
    data['isAdmin'] = this.isAdmin;
    data['_id'] = this.sId;
    return data;
  }
}
