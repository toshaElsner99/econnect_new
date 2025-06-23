import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignInModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata; // Changed from List<Null>? to List<dynamic>?

  SignInModel({this.statusCode, this.status, this.message, this.data, this.metadata});

  SignInModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    metadata = json['metadata'] ?? []; // Default to an empty list if null
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['metadata'] = metadata;
    return data;
  }

  Future<void> saveToPrefs() async {
    if (statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String jsonString = jsonEncode(toJson());
      await prefs.setString('signInModel', jsonString);
    }
  }

  static Future<SignInModel?> loadFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('signInModel');
    if (jsonString != null) {
      return SignInModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  static Future<void> clearFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('signInModel');
  }
}

class Data {
  User? user;
  String? authToken;

  Data({this.user, this.authToken});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    authToken = json['authToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['authToken'] = authToken;
    return data;
  }
}

class User {
  String? id;
  String? fullName;
  String? username;
  String? email;
  String? status;
  bool? isActive;
  List<dynamic>? loginActivity; // Fixed issue here
  String? customStatus;
  List<String>? muteUsers;
  List<String>? muteChannels;
  bool? isLeft;
  List<CustomStatusHistory>? customStatusHistory;
  String? createdAt;
  String? updatedAt;
  LastActiveChat? lastActiveChat;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  String? chatList;
  bool? isAutomatic;
  String? lastActiveTime;
  String? elsnerEmail;
  String? password;
  String? roleId;
  String? roleName;

  User({
    this.id,
    this.fullName,
    this.username,
    this.email,
    this.status,
    this.isActive,
    this.loginActivity,
    this.customStatus,
    this.muteUsers,
    this.muteChannels,
    this.isLeft,
    this.customStatusHistory,
    this.createdAt,
    this.updatedAt,
    this.lastActiveChat,
    this.avatarUrl,
    this.thumbnailAvatarUrl,
    this.chatList,
    this.isAutomatic,
    this.lastActiveTime,
    this.elsnerEmail,
    this.password,
    this.roleId,
    this.roleName
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    status = json['status'];
    isActive = json['isActive'];
    loginActivity = json['loginActivity'] ?? []; // Fixed issue here
    customStatus = json['custom_status'];
    muteUsers = json['mute_users']?.cast<String>();
    muteChannels = json['mute_channels']?.cast<String>();
    isLeft = json['isLeft'];
    if (json['custom_status_history'] != null) {
      customStatusHistory = (json['custom_status_history'] as List)
          .map((v) => CustomStatusHistory.fromJson(v))
          .toList();
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    lastActiveChat = json['lastActiveChat'] != null
        ? LastActiveChat.fromJson(json['lastActiveChat'])
        : null;
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    chatList = json['chatList'];
    isAutomatic = json['isAutomatic'];
    lastActiveTime = json['last_active_time'];
    elsnerEmail = json['elsner_email'];
    password = json['password'];
    roleId = json['role_id'];
    roleName = json['role_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = id;
    data['fullName'] = fullName;
    data['username'] = username;
    data['email'] = email;
    data['status'] = status;
    data['isActive'] = isActive;
    data['loginActivity'] = loginActivity; // Fixed issue here
    data['custom_status'] = customStatus;
    data['mute_users'] = muteUsers;
    data['mute_channels'] = muteChannels;
    data['isLeft'] = isLeft;
    if (customStatusHistory != null) {
      data['custom_status_history'] =
          customStatusHistory!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (lastActiveChat != null) {
      data['lastActiveChat'] = lastActiveChat!.toJson();
    }
    data['avatarUrl'] = avatarUrl;
    data['thumbnail_avatarUrl'] = thumbnailAvatarUrl;
    data['chatList'] = chatList;
    data['isAutomatic'] = isAutomatic;
    data['last_active_time'] = lastActiveTime;
    data['elsner_email'] = elsnerEmail;
    data['password'] = password;
    data['role_id'] = roleId;
    data['role_name'] = roleName;
    return data;
  }
}

class CustomStatusHistory {
  String? customStatus;
  String? customStatusEmoji;
  String? updatedBy;
  String? updatedAt;
  String? sId;

  CustomStatusHistory({
    this.customStatus,
    this.customStatusEmoji,
    this.updatedBy,
    this.updatedAt,
    this.sId,
  });

  CustomStatusHistory.fromJson(Map<String, dynamic> json) {
    customStatus = json['custom_status'];
    customStatusEmoji = json['custom_status_emoji'];
    updatedBy = json['updatedBy'];
    updatedAt = json['updatedAt'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['custom_status'] = customStatus;
    data['custom_status_emoji'] = customStatusEmoji;
    data['updatedBy'] = updatedBy;
    data['updatedAt'] = updatedAt;
    data['_id'] = sId;
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
    data['type'] = type;
    data['id'] = id;
    return data;
  }
}
