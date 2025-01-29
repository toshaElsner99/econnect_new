class ChannelListModel {
  int? statusCode;
  int? status;
  String? message;
  List<Data>? data;
  List<dynamic>? metadata;

  ChannelListModel({
    this.statusCode,
    this.status,
    this.message,
    this.data,
    this.metadata,
  });

  ChannelListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = json['data'].map<Data>((v) => Data.fromJson(v)).toList();
    }
    if (json['metadata'] != null) {
      metadata = List<dynamic>.from(json['metadata']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (metadata != null) {
      data['metadata'] = metadata;
    }
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  String? ownerId;
  String? description;
  bool? isPrivate;
  bool? isDeleted;
  bool? isDefault;
  String? updatedBy;
  String? deletedBy;
  List<dynamic>? headerHistory;
  String? createdAt;
  String? updatedAt;
  int? iV;
  int? unreadCount;
  Lastmessage? lastmessage;

  Data({
    this.sId,
    this.name,
    this.ownerId,
    this.description,
    this.isPrivate,
    this.isDeleted,
    this.isDefault,
    this.updatedBy,
    this.deletedBy,
    this.headerHistory,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.unreadCount,
    this.lastmessage,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    ownerId = json['ownerId'];
    description = json['description'];
    isPrivate = json['isPrivate'];
    isDeleted = json['isDeleted'];
    isDefault = json['isDefault'];
    updatedBy = json['updatedBy'];
    deletedBy = json['deletedBy'];
    if (json['header_history'] != null) {
      headerHistory = List<dynamic>.from(json['header_history']);
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    unreadCount = json['unreadCount'];
    lastmessage = json['lastmessage'] != null
        ? Lastmessage.fromJson(json['lastmessage'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['name'] = name;
    data['ownerId'] = ownerId;
    data['description'] = description;
    data['isPrivate'] = isPrivate;
    data['isDeleted'] = isDeleted;
    data['isDefault'] = isDefault;
    data['updatedBy'] = updatedBy;
    data['deletedBy'] = deletedBy;
    if (headerHistory != null) {
      data['header_history'] = headerHistory;
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['unreadCount'] = unreadCount;
    if (lastmessage != null) {
      data['lastmessage'] = lastmessage!.toJson();
    }
    return data;
  }
}

class Lastmessage {
  String? createdAt;

  Lastmessage({this.createdAt});

  Lastmessage.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    return {'createdAt': createdAt};
  }
}
