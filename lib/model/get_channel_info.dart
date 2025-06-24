class GetChannelInfo {
  int? statusCode;
  int? status;
  String? message;
  Data? data;

  GetChannelInfo({this.statusCode, this.status, this.message, this.data});

  GetChannelInfo.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  OwnerId? ownerId;
  String? description;
  bool? isPrivate;
  List<Members>? members;
  bool? isDeleted;
  bool? isDefault;
  dynamic updatedBy;
  dynamic deletedBy;
  List<dynamic>? headerHistory;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? isFavourite;
  int? pinnedMessagesCount;

  Data({
    this.sId,
    this.name,
    this.ownerId,
    this.description,
    this.isPrivate,
    this.members,
    this.isDeleted,
    this.isDefault,
    this.updatedBy,
    this.deletedBy,
    this.headerHistory,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.isFavourite,
    this.pinnedMessagesCount,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['channelName'];
    ownerId = json['ownerId'] != null ? OwnerId.fromJson(json['ownerId']) : null;
    description = json['description'];
    isPrivate = json['isPrivate'];
    if (json['members'] != null) {
      members = (json['members'] as List).map((v) => Members.fromJson(v)).toList();
    }
    isDeleted = json['isDeleted'];
    isDefault = json['isDefault'];
    updatedBy = json['updatedBy'];
    deletedBy = json['deletedBy'];
    headerHistory = json['header_history'] ?? [];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    isFavourite = json['isFavourite'];
    pinnedMessagesCount = json['pinnedMessagesCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['name'] = name;
    if (ownerId != null) {
      data['ownerId'] = ownerId!.toJson();
    }
    data['description'] = description;
    data['isPrivate'] = isPrivate;
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    data['isDeleted'] = isDeleted;
    data['isDefault'] = isDefault;
    data['updatedBy'] = updatedBy;
    data['deletedBy'] = deletedBy;
    data['header_history'] = headerHistory;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['isFavourite'] = isFavourite;
    data['pinnedMessagesCount'] = pinnedMessagesCount;
    return data;
  }
}

class OwnerId {
  String? sId;
  String? username;
  String? email;
  String? fullName;
  String? elsnerEmail;

  OwnerId({this.sId, this.username, this.email, this.fullName, this.elsnerEmail});

  OwnerId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    email = json['email'];
    fullName = json['fullName'];
    elsnerEmail = json['elsner_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['username'] = username;
    data['email'] = email;
    data['fullName'] = fullName;
    data['elsner_email'] = elsnerEmail;
    return data;
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
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['isAdmin'] = isAdmin;
    data['_id'] = sId;
    return data;
  }
}
