class GetUserSuggestions {
  int? statusCode;
  int? status;
  String? message;
  Data? data;
  List<dynamic>? metadata; // Changed from List<Null> to List<dynamic>

  GetUserSuggestions({this.statusCode, this.status, this.message, this.data, this.metadata});

  GetUserSuggestions.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['metadata'] != null) {
      metadata =
          json['metadata']; // Assuming metadata is a list of dynamic objects
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
      data['metadata'] =
          this.metadata; // Assuming metadata is a list of dynamic objects
    }
    return data;
  }
}

class Data {
  List<Suggestions>? suggestions;
  int? totalUsers;

  Data({this.suggestions, this.totalUsers});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['suggestions'] != null) {
      suggestions = <Suggestions>[];
      json['suggestions'].forEach((v) {
        suggestions!.add(Suggestions.fromJson(v));
      });
    }
    totalUsers = json['total_users'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.suggestions != null) {
      data['suggestions'] = this.suggestions!.map((v) => v.toJson()).toList();
    }
    data['total_users'] = this.totalUsers;
    return data;
  }
}

class Suggestions {
  String? userId;
  String? username;
  String? fullName;
  String? thumbnailAvatarUrl;
  String? avatarUrl;
  String? createdAt;
  String? email;
  String? elsnerEmail;

  Suggestions(
      {this.userId,
      this.username,
      this.fullName,
      this.thumbnailAvatarUrl,
      this.avatarUrl,
      this.createdAt,
      this.email,
      this.elsnerEmail});

  Suggestions.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    username = json['username'];
    fullName = json['fullName'];
    thumbnailAvatarUrl = json['thumbnail_avatarUrl'];
    avatarUrl = json['avatarUrl'];
    createdAt = json['createdAt'];
    email = json['email'];
    elsnerEmail = json['elsner_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['userId'] = this.userId;
    data['username'] = this.username;
    data['fullName'] = this.fullName;
    data['thumbnail_avatarUrl'] = this.thumbnailAvatarUrl;
    data['avatarUrl'] = this.avatarUrl;
    data['createdAt'] = this.createdAt;
    data['email'] = this.email;
    data['elsner_email'] = this.elsnerEmail;
    return data;
  }
}
