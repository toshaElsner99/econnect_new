import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GetUserMentionModel {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  // List<Null>? metadata;

  GetUserMentionModel(
      {this.statusCode, this.status, this.message, this.data, });

  GetUserMentionModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    // if (json['metadata'] != null) {
    //   metadata = <Null>[];
    //   json['metadata'].forEach((v) {
    //     metadata!.add(new Null.fromJson(v));
    //   });
    // }
  }
  // Future<void> saveToPrefs() async {
  //   if (statusCode == 200) {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String jsonString = jsonEncode(toJson());
  //     await prefs.setString('getUserMentionModel', jsonString);
  //   }
  // }
  Future<void> saveToPrefs(String id) async {
    if (statusCode == 200) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonString = jsonEncode(toJson());
        await prefs.setString('getUserMentionModel_$id', jsonString);
      } catch (e) {
        print("Error saving GetUserMentionModel to preferences for id '$id': $e");
      }
    }
  }

  // static Future<GetUserMentionModel?> loadFromPrefs() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? jsonString = prefs.getString('getUserMentionModel');
  //   if (jsonString != null) {
  //     return GetUserMentionModel.fromJson(jsonDecode(jsonString));
  //   }
  //   return null;
  // }
  static Future<GetUserMentionModel?> loadFromPrefs(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('getUserMentionModel_$id');
      if (jsonString != null) {
        final jsonMap = jsonDecode(jsonString);
        return GetUserMentionModel.fromJson(jsonMap);
      }
    } catch (e) {
      print("Error loading GetUserMentionModel from preferences for id '$id': $e");
    }
    return null;
  }

  static Future<void> clearFromPrefs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('getUserMentionModel');
    } catch (e) {
      print("Error clearing GetUserMentionModel from preferences: $e");
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
    // if (this.metadata != null) {
    //   data['metadata'] = this.metadata!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class Data {
  int? totalUsers;
  List<Users>? users;

  Data({this.totalUsers, this.users});

  Data.fromJson(Map<String, dynamic> json) {
    totalUsers = json['total_users'];
    if (json['suggestions'] != null) {
      users = <Users>[];
      json['suggestions'].forEach((v) {
        users!.add(new Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_users'] = this.totalUsers;
    if (this.users != null) {
      data['suggestions'] = this.users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  String? sId;
  String? username;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  String? fullName;
  String? createdAt;
  String? email;
  String? position;

  Users(
      {this.sId,
        this.username,
        this.avatarUrl,
        this.thumbnailAvatarUrl,
        this.fullName,
        this.createdAt,
        this.email,
        this.position,

      });

  Users.fromJson(Map<String, dynamic> json) {
    sId = json['userId'];
    username = json['userName'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    fullName = json['fullName'];
    createdAt= json['createdAt'];
    email = json['email'];
    position = json['position'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['username'] = this.username;
    data['avatarUrl'] = this.avatarUrl;
    data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
    data['fullName'] = this.fullName;
    data['createdAt'] =this.createdAt;
    data['email'] = this.email;
    data['position'] = this.position;
    return data;
  }
}
