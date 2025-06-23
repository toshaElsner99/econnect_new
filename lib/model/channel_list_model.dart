class ChannelListModel {
  int? statusCode;
  int? status;
  String? message;
  List<ChannelList>? data;
  List<dynamic>? metadata; // Changed from List<Null>? to List<dynamic>?

  ChannelListModel({this.statusCode, this.status, this.message, this.data, this.metadata});

  ChannelListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ChannelList>[];
      json['data'].forEach((v) {
        data!.add(ChannelList.fromJson(v));
      });
    }
    metadata = json['metadata'] ?? []; // Assign empty list if null
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['metadata'] = metadata;
    return data;
  }
}

class ChannelList {
  String? sId;
  String? name;
  String? description;
  bool? isPrivate;
  bool? isDeleted;
  bool? isDefault;
  String? updatedBy;
  String? deletedBy; // Changed from Null? to String?
  List<dynamic>? headerHistory; // Changed from List<Null>? to List<dynamic>?
  String? createdAt;
  String? updatedAt;
  int? iV;
  int? unreadCount;
  Lastmessage? lastmessage;
  String? ownerId;

  ChannelList({
    this.sId,
    this.name,
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
    this.ownerId,
  });

  ChannelList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['channelName'];
    description = json['description'];
    isPrivate = json['isPrivate'];
    isDeleted = json['isDeleted'];
    isDefault = json['isDefault'];
    updatedBy = json['updatedBy'];
    deletedBy = json['deletedBy']; // No need to parse as Null
    headerHistory = json['header_history'] ?? []; // Assign empty list if null
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    unreadCount = json['unreadCount'];
    lastmessage = json['lastMessage'] != null ? Lastmessage.fromJson(json['lastMessage']) : null;
    ownerId = json['ownerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['isPrivate'] = isPrivate;
    data['isDeleted'] = isDeleted;
    data['isDefault'] = isDefault;
    data['updatedBy'] = updatedBy;
    data['deletedBy'] = deletedBy; // No need to convert null
    data['header_history'] = headerHistory;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['unreadCount'] = unreadCount;
    if (lastmessage != null) {
      data['lastmessage'] = lastmessage!.toJson();
    }
    data['ownerId'] = ownerId;
    return data;
  }
}

class Lastmessage {
  String? createdAt;

  Lastmessage({this.createdAt});

  Lastmessage.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    return data;
  }
}
