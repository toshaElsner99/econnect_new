part of 'chat_cubit.dart';

sealed class ChatState {
  const ChatState();
}

final class ChatInitial extends ChatState {
  ChatInitial();
}

final class ChatLoading extends ChatState {
  ChatLoading();
}

final class ChatSuccess extends ChatState {
  final List<MessageGroups> messagesGroups;

  ChatSuccess(this.messagesGroups);
}

final class ChatFailure extends ChatState {
  final String errorText;

  ChatFailure(this.errorText);
}