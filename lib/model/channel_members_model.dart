class ChannelMembersModel {
  int? statusCode;
  int? status;
  String? message;
  MembersData? data;

  ChannelMembersModel({this.statusCode, this.status, this.message, this.data});

  ChannelMembersModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new MembersData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class MembersData {
  String? sId;
  String? name;
  String? ownerId;
  String? description;
  bool? isPrivate;
  List<MemberDetails>? memberDetails;

  MembersData(
      {this.sId,
      this.name,
      this.ownerId,
      this.description,
      this.isPrivate,
      this.memberDetails});

  MembersData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    ownerId = json['ownerId'];
    description = json['description'];
    isPrivate = json['isPrivate'];
    if (json['memberDetails'] != null) {
      memberDetails = <MemberDetails>[];
      json['memberDetails'].forEach((v) {
        memberDetails!.add(new MemberDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['ownerId'] = this.ownerId;
    data['description'] = this.description;
    data['isPrivate'] = this.isPrivate;
    if (this.memberDetails != null) {
      data['memberDetails'] =
          this.memberDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MemberDetails {
  String? sId;
  String? fullName;
  String? username;
  String? email;
  String? status;
  String? customStatus;
  String? customStatusEmoji;
  String? avatarUrl;
  String? thumbnailAvatarUrl;
  String? elsnerEmail;
  bool? isAdmin;

  MemberDetails(
      {this.sId,
      this.fullName,
      this.username,
      this.email,
      this.status,
      this.customStatus,
      this.customStatusEmoji,
      this.avatarUrl,
      this.thumbnailAvatarUrl,
      this.elsnerEmail,
      this.isAdmin});

  MemberDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    status = json['status'];
    customStatus = json['custom_status'];
    customStatusEmoji = json['custom_status_emoji'];
    avatarUrl = json['avatarUrl'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    elsnerEmail = json['elsner_email'];
    isAdmin = json['isAdmin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['username'] = this.username;
    data['email'] = this.email;
    data['status'] = this.status;
    data['custom_status'] = this.customStatus;
    data['custom_status_emoji'] = this.customStatusEmoji;
    data['avatarUrl'] = this.avatarUrl;
    data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
    data['elsner_email'] = this.elsnerEmail;
    data['isAdmin'] = this.isAdmin;
    return data;
  }
}
