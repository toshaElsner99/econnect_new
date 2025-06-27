// To parse this JSON data, do
//
//     final searchMessage = searchMessageFromJson(jsonString);

import 'dart:convert';

List<SearchMessage> searchMessageFromJson(String str) => List<SearchMessage>.from(json.decode(str).map((x) => SearchMessage.fromJson(x)));

String searchMessageToJson(List<SearchMessage> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SearchMessage {
  DateTime? id;
  List<Message> messages;
  int totalMessages;
  DateTime date;

  SearchMessage({
    required this.id,
    required this.messages,
    required this.totalMessages,
    required this.date,
  });

  factory SearchMessage.fromJson(Map<String, dynamic> json) => SearchMessage(
    id:json["_id"] == null ? null : DateTime.parse(json["_id"]) as DateTime? ,
    messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
    totalMessages: json["totalMessages"],
    date: DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "_id":id==null?"": "${id?.year.toString().padLeft(4, '0')}-${id?.month.toString().padLeft(2, '0')}-${id?.day.toString().padLeft(2, '0')}",
    "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
    "totalMessages": totalMessages,
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
  };
}

class Message {
  String id;
  String content;
  DateTime createdAt;
  dynamic replyTo;
  bool isForwarded;
  String senderId;
  ErInfo? senderInfo;
  ChannelInfo? channelInfo;
  String? channelId;
  ErInfo? oppositeUserInfo;
  String? receiverId;

  Message({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.replyTo,
    required this.isForwarded,
    required this.senderId,
    required this.senderInfo,
    this.channelInfo,
    this.channelId,
    required this.oppositeUserInfo,
    this.receiverId,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["_id"],
    content: json["content"],
    createdAt: DateTime.parse(json["createdAt"]),
    replyTo: json["replyTo"],
    isForwarded: json["isForwarded"],
    senderId: json["senderId"],
    senderInfo:json["senderInfo"] == null ? null : ErInfo.fromJson(json["senderInfo"]),
    channelInfo: json["channelInfo"] == null ? null : ChannelInfo.fromJson(json["channelInfo"]),
    channelId: json["channelId"],
    oppositeUserInfo:  json["oppositeUserInfo"] == null ? null :ErInfo.fromJson(json["oppositeUserInfo"]),
    receiverId: json["receiverId"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "content": content,
    "createdAt": createdAt.toIso8601String(),
    "replyTo": replyTo,
    "isForwarded": isForwarded,
    "senderId": senderId,
    "senderInfo": senderInfo?.toJson(),
    "channelInfo": channelInfo?.toJson(),
    "channelId": channelId,
    "oppositeUserInfo": oppositeUserInfo?.toJson(),
    "receiverId": receiverId,
  };
}

class ChannelInfo {
  String id;
  String name;
  String ownerId;
  bool isDefault;

  ChannelInfo({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.isDefault,
  });

  factory ChannelInfo.fromJson(Map<String, dynamic> json) => ChannelInfo(
    id: json["_id"],
    name: json["channelName"],
    ownerId: json["ownerId"],
    isDefault: json["isDefault"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "channelName": name,
    "ownerId": ownerId,
    "isDefault": isDefault,
  };
}

class ErInfo {
  String? id;
  String? username;
  String? email;
  String status;
  String? thumbnailAvatarUrl;
  String? elsnerEmail;

  ErInfo({
     this.id,
     this.username,
     this.email,
    required this.status,
    this.thumbnailAvatarUrl,
    this.elsnerEmail,
  });

  factory ErInfo.fromJson(Map<String, dynamic> json) => ErInfo(
    id: json["_id"] ?? "",
    username: json["userName"] ?? "",
    email: json["email"] ?? "",
    status: json["status"] ?? "offline",
    thumbnailAvatarUrl: json["thumbnailAvatarUrl"] ?? "",
    elsnerEmail: json["elsner_email"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userName": username,
    "email": email,
    // "status": statusValues.reverse[status],
    "thumbnailAvatarUrl": thumbnailAvatarUrl,
    "elsner_email": elsnerEmail,
  };
}

enum Status {
  OFFLINE,
  ONLINE
}

final statusValues = EnumValues({
  "offline": Status.OFFLINE,
  "online": Status.ONLINE
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
