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
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String jsonString = jsonEncode(toJson());
        await prefs.setString('signInModel', jsonString);
      } catch (e) {
        print("Error saving SignInModel to preferences: $e");
        // Optionally show user feedback or handle gracefully
      }
    }
  }

  static Future<SignInModel?> loadFromPrefs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('signInModel');
      if (jsonString != null) {
        return SignInModel.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      print("Error loading SignInModel from preferences: $e");
    }
    return null;
  }

  static Future<void> clearFromPrefs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('signInModel');
    } catch (e) {
      print("Error clearing SignInModel from preferences: $e");
    }
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
  String? sId;
  String? fullName;
  String? userName;
  String? email;
  String? status;
  bool? isActive;
  String? customStatus;
  String? customStatusEmoji;
  List<String>? muteUsers;
  List<String>? muteChannels;
  String? lastActiveTime;
  bool? isLeft;
  String? createdAt;
  String? updatedAt;
  LastActiveChat? lastActiveChat;
  String? chatList;
  String? position;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  String? roleId;
  String? roleName;
  String? companyId;
  String? companyName;
  String? companyEmail;
  String? domain;
  String? companyLogoUrl;
  String? companyFavIcoUrl;
  String? deffaultchannels;
  int? fileUploadSize;

  User(
      {this.sId,
        this.fullName,
        this.userName,
        this.email,
        this.status,
        this.isActive,
        this.customStatus,
        this.customStatusEmoji,
        this.muteUsers,
        this.muteChannels,
        this.lastActiveTime,
        this.isLeft,
        this.createdAt,
        this.updatedAt,
        this.lastActiveChat,
        this.chatList,
        this.position,
        this.avatarUrl,
        this.thumbnailAvatarUrl,
        this.roleId,
        this.roleName,
        this.companyId,
        this.companyName,
        this.companyEmail,
        this.domain,
        this.companyLogoUrl,
        this.companyFavIcoUrl,
        this.deffaultchannels,
        this.fileUploadSize
      });

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    userName = json['userName'];
    email = json['email'];
    status = json['status'];
    isActive = json['isActive'];
    customStatus = json['customStatus'];
    customStatusEmoji = json['customStatusEmoji'];
    muteUsers = json['muteUsers']?.cast<String>() ?? [];
    muteChannels = json['muteChannels']?.cast<String>() ?? [];
    lastActiveTime = json['lastActiveTime'];
    isLeft = json['isLeft'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    lastActiveChat = json['lastActiveChat'] != null
        ? new LastActiveChat.fromJson(json['lastActiveChat'])
        : null;
    chatList = json["chatList"];
    position = json['position'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnailAvatarUrl'];
    roleId = json['roleId'];
    roleName = json['roleName'];
    companyId = json['companyId'];
    companyName = json['companyName'];
    companyEmail = json['companyEmail'];
    domain = json['domain'];
    companyLogoUrl = json['companyLogoUrl'];
    companyFavIcoUrl = json['companyFavIcoUrl'];
    deffaultchannels = json['deffaultchannels'];
     fileUploadSize = json['fileUploadSize'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['userName'] = this.userName;
    data['email'] = this.email;
    data['status'] = this.status;
    data['isActive'] = this.isActive;
    data['customStatus'] = this.customStatus;
    data['customStatusEmoji'] = this.customStatusEmoji;
    data['muteUsers'] = muteUsers;
    data['muteChannels'] = muteChannels;
    data['lastActiveTime'] = this.lastActiveTime;
    data['isLeft'] = this.isLeft;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.lastActiveChat != null) {
      data['lastActiveChat'] = this.lastActiveChat!.toJson();
    }
    data['chatList'] =this.chatList;
    data['position'] = this.position;
    data['avatarUrl'] = this.avatarUrl;
    data['thumbnailAvatarUrl'] = this.thumbnailAvatarUrl;
    data['roleId'] = this.roleId;
    data['roleName'] = this.roleName;
    data['companyId'] = this.companyId;
    data['companyName'] = this.companyName;
    data['companyEmail'] = this.companyEmail;
    data['domain'] = this.domain;
    data['companyLogoUrl'] = this.companyLogoUrl;
    data['companyFavIcoUrl'] = this.companyFavIcoUrl;
    data['deffaultchannels'] = this.deffaultchannels;
    data['fileUploadSize'] = this.fileUploadSize;
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
