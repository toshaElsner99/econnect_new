class ChatModel {
  final int statusCode;
  final int status;
  final String message;
  final MessageData data;

  ChatModel({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      statusCode: json['statusCode'],
      status: json['status'],
      message: json['message'],
      data: MessageData.fromJson(json['data']),
    );
  }
}

class MessageData {
  final List<GroupMessages> messages;
  final int currentPage;
  final int messagesOnPage;
  final int totalPages;
  final int totalMessages;
  final int totalMessagesWithoutReplies;

  MessageData({
    required this.messages,
    required this.currentPage,
    required this.messagesOnPage,
    required this.totalPages,
    required this.totalMessages,
    required this.totalMessagesWithoutReplies,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List;
    List<GroupMessages> messages = messagesList.map((i) => GroupMessages.fromJson(i)).toList();

    return MessageData(
      messages: messages,
      currentPage: json['currentPage'],
      messagesOnPage: json['messagesOnPage'],
      totalPages: json['totalPages'],
      totalMessages: json['totalMessages'],
      totalMessagesWithoutReplies: json['totalMessagesWithoutReplies'],
    );
  }
}

class GroupMessages {
  final String id; // This represents the date
  final List<Message> messages;
  final int count;

  GroupMessages({
    required this.id,
    required this.messages,
    required this.count,
  });

  factory GroupMessages.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List;
    List<Message> messages = messagesList.map((i) => Message.fromJson(i)).toList();

    return GroupMessages(
      id: json['_id'],
      messages: messages,
      count: json['count'],
    );
  }
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final List<String> files;
  final String? replyTo; // Nullable
  final bool isReply;
  final bool isLog;
  final bool isForwarded;
  final bool isEdited;
  final String? forwardFrom; // Nullable
  final List<String> readBy;
  final bool isSeen;
  final bool isDeleted;
  final List<String> taggedUsers;
  final List<String> reactions;
  final String createdAt;
  final String updatedAt;
  final bool isPinned;
  final List<dynamic> replies; // Assuming replies can be of any type
  final int replyCount;
  final List<dynamic> repliesSenderInfo; // Assuming repliesSenderInfo can be of any type

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.files,
    this.replyTo,
    required this.isReply,
    required this.isLog,
    required this.isForwarded,
    required this.isEdited,
    this.forwardFrom,
    required this.readBy,
    required this.isSeen,
    required this.isDeleted,
    required this.taggedUsers,
    required this.reactions,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
    required this.replies,
    required this.replyCount,
    required this.repliesSenderInfo,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      files: List<String>.from(json['files']),
      replyTo: json['replyTo'],
      isReply: json['isReply'],
      isLog: json['isLog'],
      isForwarded: json['isForwarded'],
      isEdited: json['isEdited'],
      forwardFrom: json['forwardFrom'],
      readBy: List<String>.from(json['readBy']),
      isSeen: json['is_seen'],
      isDeleted: json['isDeleted'],
      taggedUsers: List<String>.from(json['tagged_users']),
      reactions: List<String>.from(json['reactions']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isPinned: json['isPinned'],
      replies: json['replies'], // Assuming replies can be of any type
      replyCount: json['replyCount'],
      repliesSenderInfo: json['repliesSenderInfo'], // Assuming repliesSenderInfo can be of any type
    );
  }
}