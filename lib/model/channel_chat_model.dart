class ChannelChatModel {
  final int statusCode;
  final int status;
  final String message;
  final Data data;

  ChannelChatModel({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory ChannelChatModel.fromJson(Map<String, dynamic> json) {
    return ChannelChatModel(
      statusCode: json['statusCode'],
      status: json['status'],
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  final List<MessageGroup> messages;
  final int currentPage;
  final int totalPages;
  final int totalMessages;
  final int messagesOnPage;
  final int totalMessagesWithoutReplies;

  Data({
    required this.messages,
    required this.currentPage,
    required this.totalPages,
    required this.totalMessages,
    required this.messagesOnPage,
    required this.totalMessagesWithoutReplies,
  });

  // factory Data.fromJson(Map<String, dynamic> json) {
  //   var messagesList = json['messages'] as List;
  //   List<MessageGroup> messages = messagesList.map((i) => MessageGroup.fromJson(i)).toList();
  //
  //   return Data(
  //     messages: messages,
  //     currentPage: json['currentPage'],
  //     totalPages: json['totalPages'],
  //     totalMessages: json['totalMessages'],
  //     messagesOnPage: json['messagesOnPage'],
  //     totalMessagesWithoutReplies: json['totalMessagesWithoutReplies'],
  //   );
  // }
  factory Data.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List;
    List<MessageGroup> messages = messagesList.map((i) => MessageGroup.fromJson(i)).toList();

    return Data(
      messages: messages.reversed.toList(),  // Reverse the message groups
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalMessages: json['totalMessages'],
      messagesOnPage: json['messagesOnPage'],
      totalMessagesWithoutReplies: json['totalMessagesWithoutReplies'],
    );
  }

}

class MessageGroup {
  final String id;
  final List<Message> messages;
  final int count;

  MessageGroup({
    required this.id,
    required this.messages,
    required this.count,
  });

  factory MessageGroup.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List;
    List<Message> messages = messagesList.map((i) => Message.fromJson(i)).toList();

    return MessageGroup(
      id: json['_id'],
      messages: messages,
      count: json['count'],
    );
  }
}

class Message {
  final String id;
  final String senderId;
  final String channelId;
  final String content;
  final List<dynamic> files;
  final dynamic replyTo;
  final bool isReply;
  final bool isLog;
  final bool isForwarded;
  final bool isEdited;
  final dynamic forwardFrom;
  final List<String> readBy;
  final bool isSeen;
  final bool isDeleted;
  final List<dynamic> taggedUsers;
  final List<Reaction> reactions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final List<dynamic> replies;
  final int replyCount;
  final List<dynamic> repliesSenderInfo;
  final SenderInfo senderInfo;
  final List<dynamic> receiverInfo;

  Message({
    required this.id,
    required this.senderId,
    required this.channelId,
    required this.content,
    required this.files,
    required this.replyTo,
    required this.isReply,
    required this.isLog,
    required this.isForwarded,
    required this.isEdited,
    required this.forwardFrom,
    required this.readBy,
    required this.isSeen,
    required this.isDeleted,
    required this.taggedUsers,
    required this.reactions,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.replies,
    required this.replyCount,
    required this.repliesSenderInfo,
    required this.senderInfo,
    required this.receiverInfo,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    var reactionsList = json['reactions'] as List;
    List<Reaction> reactions = reactionsList.map((i) => Reaction.fromJson(i)).toList();

    return Message(
      id: json['_id'],
      senderId: json['senderId'],
      channelId: json['channelId'],
      content: json['content'],
      files: json['files'],
      replyTo: json['replyTo'],
      isReply: json['isReply'],
      isLog: json['isLog'],
      isForwarded: json['isForwarded'],
      isEdited: json['isEdited'],
      forwardFrom: json['forwardFrom'],
      readBy: List<String>.from(json['readBy']),
      isSeen: json['is_seen'],
      isDeleted: json['isDeleted'],
      taggedUsers: List<dynamic>.from(json['tagged_users']),
      reactions: reactions,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
      replies: json['replies'],
      replyCount: json['replyCount'],
      repliesSenderInfo: json['repliesSenderInfo'],
      senderInfo: SenderInfo.fromJson(json['senderInfo']),
      receiverInfo: json['receiverInfo'],
    );
  }
}

class Reaction {
  final String emoji;
  final String userId;
  final String id;
  final String username;

  Reaction({
    required this.emoji,
    required this.userId,
    required this.id,
    required this.username,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      emoji: json['emoji'],
      userId: json['userId'],
      id: json['_id'],
      username: json['username'],
    );
  }
}

class SenderInfo {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String status;
  final bool isActive;
  final String customStatus;
  final String customStatusEmoji;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String avatarUrl;
  final String thumbnailAvatarUrl;
  final DateTime lastActiveTime;
  final String elsnerEmail;

  SenderInfo({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.status,
    required this.isActive,
    required this.customStatus,
    required this.customStatusEmoji,
    required this.createdAt,
    required this.updatedAt,
    required this.avatarUrl,
    required this.thumbnailAvatarUrl,
    required this.lastActiveTime,
    required this.elsnerEmail,
  });

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['_id'],
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'],
      status: json['status'],
      isActive: json['isActive'],
      customStatus: json['custom_status'],
      customStatusEmoji: json['custom_status_emoji'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      avatarUrl: json['avatarUrl'],
      thumbnailAvatarUrl: json['thumbnail_avatarUrl'],
      lastActiveTime: DateTime.parse(json['last_active_time']),
      elsnerEmail: json['elsner_email'],
    );
  }
}