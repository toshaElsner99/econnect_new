class BrowseAndSearchChannelModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata; // Changed List<Null> to List<dynamic>

  BrowseAndSearchChannelModel({
    this.statusCode,
    this.status,
    this.message,
    this.data,
    this.metadata,
  });

  BrowseAndSearchChannelModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    metadata = json['metadata'] ?? []; // Ensuring metadata is an empty list if null
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['metadata'] = metadata ?? []; // Ensuring metadata is an empty list if null
    return data;
  }
}

class Data {
  int? totalSearchResults;
  int? totalUsers;
  List<Users>? users;
  List<Channels>? channels;
  int? totalChannels;

  Data({
    this.totalSearchResults,
    this.totalUsers,
    this.users,
    this.channels,
    this.totalChannels,
  });

  Data.fromJson(Map<String, dynamic> json) {
    totalSearchResults = json['totalSearchResults'];
    totalUsers = json['total_users'];
    users = (json['users'] as List?)?.map((v) => Users.fromJson(v)).toList() ?? [];
    channels = (json['channels'] as List?)?.map((v) => Channels.fromJson(v)).toList() ?? [];
    totalChannels = json['totalChannels'];
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSearchResults': totalSearchResults,
      'total_users': totalUsers,
      'users': users?.map((v) => v.toJson()).toList() ?? [],
      'channels': channels?.map((v) => v.toJson()).toList() ?? [],
      'totalChannels': totalChannels,
    };
  }
}

class Users {
  String? fullName;
  String? username;
  String? email;
  String? elsnerEmail;
  String? position;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  bool? hasRecentMessages;
  String? latestMessageDate;
  String? userId;

  Users({
    this.fullName,
    this.username,
    this.email,
    this.elsnerEmail,
    this.position,
    this.avatarUrl,
    this.thumbnailAvatarUrl,
    this.hasRecentMessages,
    this.latestMessageDate,
    this.userId,
  });

  Users.fromJson(Map<String, dynamic> json) {
    print("json['userId']${json['userId']}");
    print("json[ ${json}");
    fullName = json['fullName'];
    username = json['userName'];
    email = json['email'];
    elsnerEmail = json['elsner_email'];
    position = json['position'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnailAvatarUrl'];
    hasRecentMessages = json['hasRecentMessages'];
    latestMessageDate = json['latestMessageDate'];
    userId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'userName': username,
      'email': email,
      'elsner_email': elsnerEmail,
      'position': position,
      'avatarUrl': avatarUrl,
      'thumbnailAvatarUrl': thumbnailAvatarUrl,
      'hasRecentMessages': hasRecentMessages,
      'latestMessageDate': latestMessageDate,
      '_id': userId,
    };
  }
}

class Channels {
  String? sId;
  String? channelName;
  bool? isPrivate;
  List<Members>? members;

  Channels({this.sId, this.channelName, this.isPrivate, this.members});

  Channels.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    channelName = json['name'];
    isPrivate = json['isPrivate'];
    members = (json['members'] as List?)?.map((v) => Members.fromJson(v)).toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': channelName,
      'isPrivate': isPrivate,
      'members': members?.map((v) => v.toJson()).toList() ?? [],
    };
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
    return {
      'id': id,
      'isAdmin': isAdmin,
      '_id': sId,
    };
  }
}
