class ThreadModel {
  int? statusCode;
  int? status;
  List<Thread>? data;

  ThreadModel({this.statusCode, this.status, this.data});

  ThreadModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    if (json['data'] != null) {
      data = <Thread>[];
      json['data'].forEach((v) {
        data!.add(new Thread.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Thread {
  String? sId;
  String? mainMessageContent;
  String? mainMessageCreatedAt;
  String? mainMessageSenderId;
  String? mainMessageRecieverId;
  String? mainMessageChannelId;
  MainMessageSenderInfo? mainMessageSenderInfo;
  MainMessageSenderInfo? mainMessageReceiverInfo;
  MainMessageChannelInfo? mainMessageChannelInfo;
  int? totalUnseenReplies;
  String? lastUnseenReplyDate;

  Thread(
      {this.sId,
        this.mainMessageContent,
        this.mainMessageCreatedAt,
        this.mainMessageSenderId,
        this.mainMessageRecieverId,
        this.mainMessageChannelId,
        this.mainMessageSenderInfo,
        this.mainMessageReceiverInfo,
        this.mainMessageChannelInfo,
        this.totalUnseenReplies,
        this.lastUnseenReplyDate});

  Thread.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mainMessageContent = json['mainMessageContent'];
    mainMessageCreatedAt = json['mainMessageCreatedAt'];
    mainMessageSenderId = json['mainMessageSenderId'];
    mainMessageRecieverId = json['mainMessageRecieverId'];
    mainMessageChannelId = json['mainMessageChannelId'];
    mainMessageSenderInfo = json['mainMessageSenderInfo'] != null
        ? new MainMessageSenderInfo.fromJson(json['mainMessageSenderInfo'])
        : null;
    mainMessageReceiverInfo = json['mainMessageReceiverInfo'] != null
        ? new MainMessageSenderInfo.fromJson(json['mainMessageReceiverInfo'])
        : null;
    mainMessageChannelInfo = json['mainMessageChannelInfo'] != null
        ? new MainMessageChannelInfo.fromJson(json['mainMessageChannelInfo'])
        : null;
    totalUnseenReplies = json['totalUnseenReplies'];
    lastUnseenReplyDate = json['lastUnseenReplyDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['mainMessageContent'] = this.mainMessageContent;
    data['mainMessageCreatedAt'] = this.mainMessageCreatedAt;
    data['mainMessageSenderId'] = this.mainMessageSenderId;
    data['mainMessageRecieverId'] = this.mainMessageRecieverId;
    data['mainMessageChannelId'] = this.mainMessageChannelId;
    if (this.mainMessageSenderInfo != null) {
      data['mainMessageSenderInfo'] = this.mainMessageSenderInfo!.toJson();
    }
    if (this.mainMessageReceiverInfo != null) {
      data['mainMessageReceiverInfo'] = this.mainMessageReceiverInfo!.toJson();
    }
    if (this.mainMessageChannelInfo != null) {
      data['mainMessageChannelInfo'] = this.mainMessageChannelInfo!.toJson();
    }
    data['totalUnseenReplies'] = this.totalUnseenReplies;
    data['lastUnseenReplyDate'] = this.lastUnseenReplyDate;
    return data;
  }
}

class MainMessageSenderInfo {
  String? sId;
  String? fullName;
  String? username;
  String? email;
  String? status;
  String? thumbnailAvatarUrl;
  String? elsnerEmail;

  MainMessageSenderInfo(
      {this.sId,
        this.fullName,
        this.username,
        this.email,
        this.status,
        this.thumbnailAvatarUrl,
        this.elsnerEmail});

  MainMessageSenderInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    status = json['status'];
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
    data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
    data['elsner_email'] = this.elsnerEmail;
    return data;
  }
}

class MainMessageChannelInfo {
  String? sId;
  String? name;
  String? ownerId;
  String? description;
  bool? isPrivate;
  bool? isDeleted;
  bool? isDefault;

  MainMessageChannelInfo(
      {this.sId,
        this.name,
        this.ownerId,
        this.description,
        this.isPrivate,
        this.isDeleted,
        this.isDefault});

  MainMessageChannelInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    ownerId = json['ownerId'];
    description = json['description'];
    isPrivate = json['isPrivate'];
    isDeleted = json['isDeleted'];
    isDefault = json['isDefault'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['ownerId'] = this.ownerId;
    data['description'] = this.description;
    data['isPrivate'] = this.isPrivate;
    data['isDeleted'] = this.isDeleted;
    data['isDefault'] = this.isDefault;
    return data;
  }
}
