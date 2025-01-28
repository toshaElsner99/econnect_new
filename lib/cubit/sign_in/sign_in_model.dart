import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String? id;
  String? fullName;
  String? username;
  String? email;
  String? elsnerEmail;
  String? position;
  String? password;
  String? status;
  bool? isActive;
  List<dynamic>? loginActivity; // Changed from List<Null> to List<dynamic>
  String? customStatus;
  List<dynamic>? muteUsers; // Changed from List<Null> to List<dynamic>
  List<dynamic>? muteChannels; // Changed from List<Null> to List<dynamic>
  bool? isLeft;
  List<dynamic>? customStatusHistory; // Changed from List<Null> to List<dynamic>
  String? createdAt;
  String? updatedAt;
  LastActiveChat? lastActiveChat;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  bool? isAutomatic;
  String? lastActiveTime;

  User({
    this.id,
    this.fullName,
    this.username,
    this.email,
    this.elsnerEmail,
    this.position,
    this.password,
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
    this.isAutomatic,
    this.lastActiveTime,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    elsnerEmail = json['elsner_email'];
    position = json['position'];
    password = json['password'];
    status = json['status'];
    isActive = json['isActive'];
    loginActivity = json['loginActivity'] ?? []; // Default to empty list
    customStatus = json['custom_status'];
    muteUsers = json['mute_users'] ?? []; // Default to empty list
    muteChannels = json['mute_channels'] ?? []; // Default to empty list
    isLeft = json['isLeft'];
    customStatusHistory = json['custom_status_history'] ?? []; // Default to empty list
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    lastActiveChat = json['lastActiveChat'] != null
        ? LastActiveChat.fromJson(json['lastActiveChat'])
        : null;
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    isAutomatic = json['isAutomatic'];
    lastActiveTime = json['last_active_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = id;
    data['fullName'] = fullName;
    data['username'] = username;
    data['email'] = email;
    data['elsner_email'] = elsnerEmail;
    data['position'] = position;
    data['password'] = password;
    data['status'] = status;
    data['isActive'] = isActive;
    data['loginActivity'] = loginActivity; // No need to map, already a list
    data['custom_status'] = customStatus;
    data['mute_users'] = muteUsers; // No need to map, already a list
    data['mute_channels'] = muteChannels; // No need to map, already a list
    data['isLeft'] = isLeft;
    data['custom_status_history'] = customStatusHistory; // No need to map, already a list
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (lastActiveChat != null) {
      data['lastActiveChat'] = lastActiveChat!.toJson();
    }
    data['avatarUrl'] = avatarUrl;
    data['thumbnail_avatarUrl'] = thumbnailAvatarUrl;
    data['isAutomatic'] = isAutomatic;
    data['last_active_time'] = lastActiveTime;
    return data;
  }
}

class SignInModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata; // Changed from List<Null> to List<dynamic>

  SignInModel({
    this.statusCode,
    this.status,
    this.message,
    this.data,
    this.metadata,
  });

  SignInModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    metadata = json['metadata'] ?? []; // Default to empty list
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['metadata'] = metadata; // No need to map, already a list
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
    authToken = json['auth_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['auth_token'] = authToken;
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