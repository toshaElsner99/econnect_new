// class FavoriteListModel {
//   int? statusCode;
//   int? status;
//   String? message;
//   Data? data;
//   List<Null>? metadata;
//
//   FavoriteListModel(
//       {this.statusCode, this.status, this.message, this.data, this.metadata});
//
//   FavoriteListModel.fromJson(Map<String, dynamic> json) {
//     statusCode = json['statusCode'];
//     status = json['status'];
//     message = json['message'];
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//     if (json['metadata'] != null) {
//       metadata = <Null>[];
//       json['metadata'].forEach((v) {
//         metadata!.add(new Null.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['statusCode'] = this.statusCode;
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     if (this.metadata != null) {
//       data['metadata'] = this.metadata!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Data {
//   String? userId;
//   List<ChatList>? chatList;
//   List<Null>? favouriteChannels;
//
//   Data({this.userId, this.chatList, this.favouriteChannels});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     userId = json['userId'];
//     if (json['chatList'] != null) {
//       chatList = <ChatList>[];
//       json['chatList'].forEach((v) {
//         chatList!.add(new ChatList.fromJson(v));
//       });
//     }
//     if (json['favouriteChannels'] != null) {
//       favouriteChannels = <Null>[];
//       json['favouriteChannels'].forEach((v) {
//         favouriteChannels!.add(new Null.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['userId'] = this.userId;
//     if (this.chatList != null) {
//       data['chatList'] = this.chatList!.map((v) => v.toJson()).toList();
//     }
//     if (this.favouriteChannels != null) {
//       data['favouriteChannels'] =
//           this.favouriteChannels!.map((v) => v.toJson()).toList();
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
//   List<Null>? loginActivity;
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
//   ChatList(
//       {this.sId,
//         this.username,
//         this.email,
//         this.password,
//         this.status,
//         this.isActive,
//         this.loginActivity,
//         this.customStatus,
//         this.customStatusEmoji,
//         this.muteUsers,
//         this.muteChannels,
//         this.customStatusHistory,
//         this.createdAt,
//         this.updatedAt,
//         this.iV,
//         this.lastActiveChat,
//         this.chatList,
//         this.avatarUrl,
//         this.thumbnailAvatarUrl,
//         this.isLeft,
//         this.isAutomatic,
//         this.lastActiveTime,
//         this.favouriteList,
//         this.elsnerEmail,
//         this.unseenMessagesCount,
//         this.fullName});
//
//   ChatList.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     username = json['username'];
//     email = json['email'];
//     password = json['password'];
//     status = json['status'];
//     isActive = json['isActive'];
//     if (json['loginActivity'] != null) {
//       loginActivity = <Null>[];
//       json['loginActivity'].forEach((v) {
//         loginActivity!.add(new Null.fromJson(v));
//       });
//     }
//     customStatus = json['custom_status'];
//     customStatusEmoji = json['custom_status_emoji'];
//     muteUsers = json['mute_users'].cast<String>();
//     muteChannels = json['mute_channels'].cast<String>();
//     if (json['custom_status_history'] != null) {
//       customStatusHistory = <CustomStatusHistory>[];
//       json['custom_status_history'].forEach((v) {
//         customStatusHistory!.add(new CustomStatusHistory.fromJson(v));
//       });
//     }
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     iV = json['__v'];
//     lastActiveChat = json['lastActiveChat'] != null
//         ? new LastActiveChat.fromJson(json['lastActiveChat'])
//         : null;
//     chatList = json['chatList'];
//     avatarUrl = json['avatarUrl'];
//     thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
//     isLeft = json['isLeft'];
//     isAutomatic = json['isAutomatic'];
//     lastActiveTime = json['last_active_time'];
//     favouriteList = json['favouriteList'];
//     elsnerEmail = json['elsner_email'];
//     unseenMessagesCount = json['unseenMessagesCount'];
//     fullName = json['fullName'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     data['username'] = this.username;
//     data['email'] = this.email;
//     data['password'] = this.password;
//     data['status'] = this.status;
//     data['isActive'] = this.isActive;
//     if (this.loginActivity != null) {
//       data['loginActivity'] =
//           this.loginActivity!.map((v) => v.toJson()).toList();
//     }
//     data['custom_status'] = this.customStatus;
//     data['custom_status_emoji'] = this.customStatusEmoji;
//     data['mute_users'] = this.muteUsers;
//     data['mute_channels'] = this.muteChannels;
//     if (this.customStatusHistory != null) {
//       data['custom_status_history'] =
//           this.customStatusHistory!.map((v) => v.toJson()).toList();
//     }
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['__v'] = this.iV;
//     if (this.lastActiveChat != null) {
//       data['lastActiveChat'] = this.lastActiveChat!.toJson();
//     }
//     data['chatList'] = this.chatList;
//     data['avatarUrl'] = this.avatarUrl;
//     data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
//     data['isLeft'] = this.isLeft;
//     data['isAutomatic'] = this.isAutomatic;
//     data['last_active_time'] = this.lastActiveTime;
//     data['favouriteList'] = this.favouriteList;
//     data['elsner_email'] = this.elsnerEmail;
//     data['unseenMessagesCount'] = this.unseenMessagesCount;
//     data['fullName'] = this.fullName;
//     return data;
//   }
// }
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
//     customStatus = json['custom_status'];
//     customStatusEmoji = json['custom_status_emoji'];
//     updatedBy = json['updatedBy'];
//     updatedAt = json['updatedAt'];
//     sId = json['_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['custom_status'] = this.customStatus;
//     data['custom_status_emoji'] = this.customStatusEmoji;
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
