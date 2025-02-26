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
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(new Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_users'] = this.totalUsers;
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
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

  Users(
      {this.sId,
        this.username,
        this.avatarUrl,
        this.thumbnailAvatarUrl,
        this.fullName});

  Users.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    fullName = json['fullName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['username'] = this.username;
    data['avatarUrl'] = this.avatarUrl;
    data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
    data['fullName'] = this.fullName;
    return data;
  }
}
