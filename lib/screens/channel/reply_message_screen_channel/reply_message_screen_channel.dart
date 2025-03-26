import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/model/get_user_model.dart';
import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:e_connect/utils/app_string_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:e_connect/model/channel_members_model.dart';

import '../../../main.dart';
import '../../../model/get_reply_message_channel_model.dart';
import '../../../model/get_user_mention_model.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/common_provider.dart';
import '../../../providers/download_provider.dart';
import '../../../providers/file_service_provider.dart';
import '../../../socket_io/socket_io.dart';
import '../../../utils/api_service/api_string_constants.dart';
import '../../../utils/app_color_constants.dart';
import '../../../utils/app_image_assets.dart';
import '../../../utils/app_preference_constants.dart';
import '../../../utils/common/common_function.dart';
import '../../../utils/common/common_widgets.dart';
import '../../chat/forward_message/forward_message_screen.dart';

class ReplyMessageScreenChannel extends StatefulWidget {
  final String channelName;
  String msgID;
  String channelId;
  ReplyMessageScreenChannel({super.key,required this.channelName,required this.msgID,required this.channelId});

  @override
  State<ReplyMessageScreenChannel> createState() => _ReplyMessageScreenChannelState();
}

class _ReplyMessageScreenChannelState extends State<ReplyMessageScreenChannel> {
  final scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final chatProvider = Provider.of<ChatProvider>(navigatorKey.currentState!.context,listen: false);
  final fileServiceProvider = Provider.of<FileServiceProvider>(navigatorKey.currentState!.context,listen: false);
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context,listen: false);
  final channelChatProvider = Provider.of<ChannelChatProvider>(navigatorKey.currentState!.context,listen: false);
  String currentUserMessageId = "";
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _showMentionList = false;
  final _textFieldKey = GlobalKey();
  int _mentionCursorPosition = 0;
  final Map<String, dynamic> userCache = {};
  bool _isTextFieldEmpty = true;


  final TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    print("REPLY_CHANNEL_ID>>>> ${widget.msgID}");
    super.initState();
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketProvider.userTypingEventChannel(
        channelId: widget.channelId,
        isReplyMsg: true,
        isTyping: 0,
        msgId: widget.msgID,
      );
      Provider.of<ChatProvider>(context, listen: false).seenReplayMessage(msgId: widget.msgID);
      /// socket listen messages list ///
      channelChatProvider.getReplyListUpdateSocketForChannel(widget.msgID);
      /// socket listen messages list for deleted message ///
      socketProvider.listenDeleteMessageSocketForChannelReply(msgId: widget.msgID);
      socketProvider.socketListenPinMessageInChannelReplyScreen(msgId: widget.channelId);
      print("I'm In initState");
      /// For the first time init ///
      channelChatProvider.getReplyMessageListChannel(msgId: widget.msgID,fromWhere: "SCREEN INIT");
      // Provider.of<CommonProvider>(context, listen: false).getUserApi(id :widget.receiverId);
    });
  }

  late FileServiceProvider _fileServiceProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeMentionOverlay();
    _fileServiceProvider = Provider.of<FileServiceProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    super.dispose();
    socketProvider.userTypingEventChannel(
      channelId: widget.channelId,
      isReplyMsg: true,
      isTyping: 0,
      msgId: widget.msgID,
    );
    scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    _fileServiceProvider.clearFilesForScreen(AppString.channelChatReply);

  }

  @override
  Widget build(BuildContext context) {
    // setTransparentStatusBar();
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // pop(popValue: true);
        channelChatProvider.getChannelChatApiCall(channelId: widget.channelId, pageNo: channelChatProvider.currentPage,onlyReadInChat: true);
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(onPressed: () {
              pop(popValue: true);
              channelChatProvider.getChannelChatApiCall(channelId: widget.channelId, pageNo: channelChatProvider.currentPage,onlyReadInChat: false);
            } , icon: Icon(CupertinoIcons.back,color: Colors.white,)),
            bottom: PreferredSize(preferredSize: Size.zero , child: Divider(color: Colors.grey.shade800, height: 1,),),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                commonText(text: "Thread", fontSize: 16,),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: commonText(text: widget.channelName, fontSize: 12,fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding:  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              inputTextFieldWithEditor()
            ],),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: scrollController,
                  reverse: true,
                  children: [
                    dateHeaders(),
                  ],
                ),
              ),
              Consumer<ChannelChatProvider>(builder: (context, channelChatProvider, child) {
                var filteredTypingUsers = channelChatProvider.typingUsers
                    .where((user) => user['user_id'].toString() != signInModel.data?.user?.id.toString()
                    && user['routeId'] == widget.channelId
                    && user['isReply'] == true
                    && user['parentId'] == widget.msgID).toList();

                String typingMessage;

                if (filteredTypingUsers.isEmpty) {
                  typingMessage = "";
                } else if (filteredTypingUsers.length == 1) {
                  typingMessage = "${filteredTypingUsers[0]['username']} is Typing...";
                } else {
                  var usernames = filteredTypingUsers.map((user) => user['username']).toList();
                  var lastUser  = usernames.removeLast();
                  typingMessage = "${usernames.join(', ')}, and $lastUser are Typing...";
                }

                return Container(
                  margin: EdgeInsets.only(right: 20, left: 20, top: 15, bottom: 6),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      if (typingMessage.isNotEmpty)
                        commonText(
                          text: typingMessage,
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                    ],
                  ),
                );
              },),
            ],
          ),
        ),
      ),
    );
  }

  Widget dateHeaders() {
    return Consumer<ChannelChatProvider>(builder: (context, value, child) {
      return value.getReplyMessageChannelModel?.data?.messagesList?.length == 0 ? SizedBox.shrink() : ListView.builder(
        shrinkWrap: true,
        reverse: false,
        physics: NeverScrollableScrollPhysics(),
        itemCount: value.getReplyMessageChannelModel?.data?.messagesList?.length ?? 0,
        itemBuilder: (itemContext, index) {
          final messageList =  value.getReplyMessageChannelModel?.data?.messagesList?[index];
          final grpId = messageList?.date;
          String? previousSenderId;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColor.blueColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: commonText(
                        text: formatDateTime(DateTime.parse(grpId!)),
                        fontSize: 12,
                        color: AppColor.whiteColor,
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: messageList?.messagesGroupList?.length ?? 0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  MessagesGroupList? message = messageList?.messagesGroupList?[index];
                  previousSenderId = message?.senderId!.sId;
                  return chatBubble(
                    chatIndex: index, // Pass index here
                    messageList: message!,
                    messageId: messageList?.messagesGroupList?[index].sId ?? "",
                    userId: message.senderId?.sId ?? "",
                    message: message.content ?? "",
                    time: DateTime.parse(message.createdAt!).toString(),
                  );
                },
              )

            ],
          );
        },
      );
    },);
  }

  Widget chatBubble({
    required int chatIndex,
    required MessagesGroupList messageList,
    required String userId,
    required String messageId,
    required String message,
    required String time,
  })  {
    return Consumer<CommonProvider>(builder: (context, commonProvider, child) {
      bool pinnedMsg = messageList.isPinned ?? false;
      bool isEdited = messageList.isEdited ?? false;
      return Container(
        color:  pinnedMsg == true ? AppPreferenceConstants.themeModeBoolValueGet ? Colors.greenAccent.withOpacity(0.15) : AppColor.pinnedColorLight : null,
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: Column(
          children: [
            Visibility(
                visible: pinnedMsg,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0,vertical: 5),
                  child: Row(
                    children: [
                      Image.asset(AppImage.pinMessageIcon,height: 12,width: 12,),
                      SizedBox(width: 5,),
                      commonText(text: "Pinned",color: AppColor.blueColor)
                    ],
                  ),
                )),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /// Profile  Section ///
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: profileIconWithStatus(userID: "${messageList.senderId?.sId}", status: "${messageList.senderId?.status}",otherUserProfile: messageList.senderId?.thumbnailAvatarUrl ?? "",radius: 17,userName: messageList.senderId?.username ?? ""),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          commonText(
                              height: 1.2,
                              text:
                              messageList.senderId?.username ?? messageList.senderId!.fullName ?? 'Unknown', fontWeight: FontWeight.bold),
                          SizedBox(width: 5),
                          commonText(
                              height: 1.2,
                              text: formatTime(time), color: Colors.grey, fontSize: 12
                          ),
                        ],
                      ),
                      Visibility(
                        visible: message.isNotEmpty,
                        child: Wrap(
                          direction: Axis.horizontal,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: commonHTMLText(message: message),
                                  ),

                                  if (isEdited)
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.only(left: 4.0),
                                        // Space between content & label
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          // Ensures compact fit
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit_outlined,
                                              size: 13,
                                              color: AppColor.borderColor,
                                            ),
                                            const SizedBox(width: 2),
                                            commonText(
                                              text: "Edited",
                                              fontSize: 10,
                                              color: AppColor.borderColor,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (messageList.reactions?.isNotEmpty ?? false)
                        Container(
                          margin: const EdgeInsets.only(top: 6, bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Reaction avatars section
                              Builder(builder: (context) {
                                // Get unique users who reacted
                                final uniqueUsers = messageList.reactions!
                                  .map((r) => r.userId!.sId)
                                  .where((id) => id != null)
                                  .toSet()
                                  .toList();

                                // Count total unique users for the counter
                                final totalUniqueUsers = uniqueUsers.length;

                                // Get usernames for the visible avatars (show at most 3)
                                final visibleUsers = uniqueUsers.take(3).toList();
                                final remainingUsers = totalUniqueUsers > 2 ? totalUniqueUsers - 2 : 0;

                                // Get usernames for the visible avatars
                                List<String> usernames = [];
                                for (int i = 0; i < visibleUsers.length && i < messageList.reactions!.length; i++) {
                                  String? username = messageList.reactions!
                                    .firstWhere((r) => r.userId!.sId == visibleUsers[i],
                                      orElse: () => messageList.reactions!.first)
                                    .userId!.username;

                                  usernames.add(username ?? "");
                                }

                                // Calculate the width needed based on number of avatars
                                final double stackWidth = visibleUsers.isEmpty ? 0 :
                                                        (visibleUsers.length == 1 ? 30 :
                                                        (visibleUsers.length == 2 ? 50 : 70));

                                // Create container with avatars
                                return Container(
                                  height: 32,
                                  width: stackWidth,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      for (int i = 0; i < visibleUsers.length; i++)
                                        Positioned(
                                          left: i * 20.0, // Offset each avatar by 20 pixels
                                          child: GestureDetector(
                                            onTap: () => _showReactionsList(context, messageList.reactions!),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppPreferenceConstants.themeModeBoolValueGet ?
                                                    Colors.grey.shade900 : Colors.white,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: i < 2 || remainingUsers == 0 ?
                                                profileIconWithStatus(
                                                  userID: visibleUsers[i] ?? "",
                                                  userName: i < usernames.length ? usernames[i] : "",
                                                  status: "",
                                                  needToShowIcon: false,
                                                  radius: 14,
                                                  otherUserProfile: channelChatProvider.getUserById(visibleUsers[i]!)?.thumbnailAvatarUrl ?? '',
                                                  onTap: () => _showReactionsList(context, messageList.reactions!)
                                                ) :
                                                // Last avatar with +X indicator
                                                Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "+$remainingUsers",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),

                              SizedBox(width: 8),

                              // Reaction emojis section - keep this part to maintain functionality
                              Flexible(
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  alignment: WrapAlignment.start,
                                  children: groupReactions(messageList.reactions!).entries.map((entry) {
                                    bool hasUserReacted = messageList.reactions!.any((reaction) =>
                                    reaction.userId!.sId == signInModel.data?.user?.id &&
                                        reaction.emoji == entry.key);

                                    return GestureDetector(
                                      onTap: () {
                                        if (hasUserReacted) {
                                          context.read<ChannelChatProvider>().reactionRemove(
                                              messageId: messageList.sId!,
                                              reactUrl: entry.key,
                                              channelId: widget.channelId,
                                              isFrom: "ChannelReply"
                                          );
                                        } else {
                                          context.read<ChannelChatProvider>().reactMessage(
                                              messageId: messageList.sId!,
                                              reactUrl: entry.key,
                                              channelId: widget.channelId,
                                              isFrom: "ChannelReply"
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: hasUserReacted ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: entry.key,
                                              height: 20,
                                              width: 20,
                                              errorWidget: (context, url, error) => Icon(Icons.error, size: 20),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              entry.value.toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: hasUserReacted ? Colors.blue : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Visibility(
                          visible: messageList.isForwarded ?? false,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16,horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColor.borderColor,width: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.forwardColor : Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                commonText(text: "Forwarded",color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : AppColor.borderColor,fontWeight: FontWeight.w500),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Row(children: [
                                    profileIconWithStatus(userID: messageList.forwardFrom?.sId ?? "", status: messageList.forwardFrom?.senderId?.status ?? "offline",needToShowIcon: false,otherUserProfile: messageList.forwardFrom?.senderId?.avatarUrl,userName: messageList.forwardFrom?.senderId?.username ?? messageList.forwardFrom?.senderId?.fullName ?? ""),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          commonText(text: messageList.forwardFrom?.senderId?.username ?? messageList.forwardFrom?.senderId?.fullName ?? ""),
                                          SizedBox(height: 3),
                                          commonText(text: formatDateString("${messageList.forwardFrom?.createdAt}"),color: AppColor.borderColor,fontWeight: FontWeight.w500),
                                        ],
                                      ),
                                    ),
                                  ],),
                                ),
                                commonHTMLText(message: "${messageList.forwardFrom?.content}"),
                                Visibility(
                                  visible: messageList.forwardFrom?.files?.length != 0 ? true : false,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: messageList.forwardFrom?.files?.length ?? 0,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final filesUrl = messageList.forwardFrom?.files?[index];
                                      String originalFileName = getFileName(messageList.forwardFrom?.files?[index]);
                                      String formattedFileName = formatFileName(originalFileName);
                                      String fileType = getFileExtension(originalFileName);
                                      return Container(
                                        margin: EdgeInsets.only(top: 5,right: 10),
                                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColor.lightGreyColor),
                                        ),
                                        child: Row(
                                          children: [
                                            getFileIconInChat(fileType: fileType, pngUrl: "${ApiString.profileBaseUrl}$filesUrl"),
                                            SizedBox(width: 20,),
                                            Flexible(
                                                flex: 10,
                                                fit: FlexFit.loose,
                                                child: commonText(text: formattedFileName,maxLines: 1)),
                                            Spacer(),
                                            GestureDetector(
                                                onTap: () => Provider.of<DownloadFileProvider>(context,listen: false).downloadFile(fileUrl: "${ApiString.profileBaseUrl}$filesUrl", context: context),
                                                child: Image.asset(AppImage.downloadIcon,fit: BoxFit.contain,height: 20,width: 20,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black))
                                          ],
                                        ),
                                      );
                                    },),
                                ),

                              ],),

                          )
                      ),
                      Visibility(
                        visible: messageList.isMedia == true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: messageList.files?.length ?? 0,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final filesUrl = messageList.files![index];
                            String originalFileName = getFileName(messageList.files![index]);
                            String formattedFileName = formatFileName(originalFileName);
                            String fileType = getFileExtension(originalFileName);
                            // IconData fileIcon = getFileIcon(fileType);
                            return Container(
                              margin: EdgeInsets.only(top: 4,right: 10),
                              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColor.lightGreyColor),
                              ),
                              child: Row(
                                children: [
                                  getFileIconInChat(fileType: fileType, pngUrl: "${ApiString.profileBaseUrl}$filesUrl"),
                                  SizedBox(width: 20,),
                                  Flexible(
                                      flex: 10,
                                      fit: FlexFit.loose,
                                      child: commonText(text: formattedFileName,maxLines: 1)),
                                  Spacer(),
                                  GestureDetector(
                                      onTap: () => Provider.of<DownloadFileProvider>(context,listen: false).downloadFile(fileUrl: "${ApiString.profileBaseUrl}$filesUrl", context: context),
                                      child: Image.asset(AppImage.downloadIcon,fit: BoxFit.contain,height: 20,width: 20,color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black))
                                ],
                              ),
                            );
                          },),
                      ),
                      // Spacer(),
                    ],
                  ),
                ),
                popMenuForReply2(context,
                  isPinned: pinnedMsg,
                  onOpened: () {}  ,
                  onClosed: () {} ,
                  onReact: () {
                    showReactionBar(context, messageId.toString(), userId, "ChannelReply");
                  },
                  opened:  false,
                  currentUserId: messageList.senderId?.sId ?? "",
                  onForward: () => pushScreen(screen: ForwardMessageScreen(userName: messageList.senderId?.username ?? messageList.senderId!.fullName ?? 'Unknown',time: formatDateString1(time),msgToForward: message,userID: userId,otherUserProfile: "${messageList.senderId!.avatarUrl}",forwardMsgId: messageId,)),
                  onPin: () => channelChatProvider.pinUnPinMessage(messageId: messageId,pinned: pinnedMsg = !pinnedMsg,channelID: widget.channelId,isCalledForReply: true),
                  onCopy: () => copyToClipboard(context, parse(message).body?.text ?? ""),
                  onEdit: () => setState(() {
                    _messageController.clear();
                    FocusScope.of(context).requestFocus(_focusNode);
                    int position = _messageController.text.length;
                    currentUserMessageId = messageId;
                    print("currentMessageId>>>>> $currentUserMessageId && 67c6af1c8ac51e0633f352b7");
                    _messageController.text = _messageController.text.substring(0, position) + message + _messageController.text.substring(position);
                  }),
                  onDelete: () => deleteMessageDialog(context, ()=> channelChatProvider.deleteMessageForReplyChannel(messageId: messageId.toString(),firsMessageId: widget.msgID)),
                  createdAt:"${messageList.createdAt}",)
              ],
            ),
          ],
        ),
      );
    },
    );
  }


  Widget inputTextFieldWithEditor() {
    return Container(
      decoration: BoxDecoration(
        color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.darkAppBarColor : AppColor.appBarColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        // color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CompositedTransformTarget(
                              link: _layerLink,
                              child: TextField(
                                key: _textFieldKey,
                                maxLines: 5,
                                minLines: 1,
                                controller: _messageController,
                                focusNode: _focusNode,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                style: TextStyle(color: AppColor.whiteColor),
                                decoration: InputDecoration(
                                  hintText: 'Write to ${channelChatProvider.getChannelInfo?.data?.name ?? ""}',
                                  hintMaxLines: 1,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // const SizedBox(width: 8),
                                      // Container(
                                      //   width: 1,
                                      //   height: 25,
                                      //   color: Colors.white
                                      // ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          _focusNode.unfocus();
                                          FileServiceProvider.instance.pickFiles(AppString.channelChatReply);
                                        },
                                        child: const Icon(Icons.attach_file, color: Colors.white),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          _focusNode.unfocus();
                                          FileServiceProvider.instance.pickImages(AppString.channelChatReply);
                                        },
                                        child: const Icon(Icons.image, color: Colors.white),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          _focusNode.unfocus();
                                          showCameraOptionsBottomSheet(context,AppString.channelChatReply);
                                        },
                                        child: const Icon(Icons.camera_alt, color: Colors.white),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColor.blueColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: AppColor.whiteColor, size: 20),
                      onPressed: () async {
                        final plainText = _messageController.text.trim();
                        if(plainText.isNotEmpty || fileServiceProvider.getFilesForScreen(AppString.channelChatReply).isNotEmpty) {
                          if(fileServiceProvider.getFilesForScreen(AppString.channelChatReply).isNotEmpty){
                            final filesOfList = await chatProvider.uploadFiles(AppString.channelChatReply);
                            await channelChatProvider.sendMessage(
                              content: plainText,
                              channelId: widget.channelId,
                              files: filesOfList,
                              replyId: widget.msgID,
                              editMsgID: currentUserMessageId,
                              isEditFromReply: true,
                            );
                          } else {
                            await channelChatProvider.sendMessage(
                                content: plainText,
                                channelId: widget.channelId,
                                replyId: widget.msgID,
                                editMsgID: currentUserMessageId.isEmpty ? "" : currentUserMessageId,
                                isEditFromReply: true,
                            ).then((value) {
                              currentUserMessageId = "";
                              socketProvider.userTypingEventChannel(
                                channelId: widget.channelId,
                                isReplyMsg: true,
                                isTyping: 0,
                                msgId: widget.msgID,
                              );
                            },);
                          }

                          // Update reply count in single chat screen
                          ///////////////////////////////////////////////////////////
                          // chatProvider.updateReplyCount(widget.messageId);

                          setState(() {
                            currentUserMessageId = "";
                          });

                          _clearInputAndDismissKeyboard();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            if(Platform.isIOS)...{
              SizedBox(height: 20)
            },
            selectedFilesWidget(screenName: AppString.channelChatReply),
          ],
        ),
      ),
    );
  }
  void _clearInputAndDismissKeyboard() {
    _focusNode.unfocus();
    _messageController.clear();
    FocusScope.of(context).unfocus();
  }

  void _onTextChanged() {
    final text = _messageController.text;
    final cursorPosition = _messageController.selection.baseOffset;

    // Update text field empty state
    setState(() {
      _isTextFieldEmpty = text.isEmpty;
    });

    if (cursorPosition > 0) {
      // Check if @ was just typed
      if (text[cursorPosition - 1] == '@') {
        _mentionCursorPosition = cursorPosition;
        _showMentionOverlay();
      }
      // Check if we should keep showing the mention list and filter based on input
      else if (_showMentionList) {
        // Find the last @ before cursor
        int lastAtIndex = text.substring(0, cursorPosition).lastIndexOf('@');
        if (lastAtIndex == -1) {
          // No @ found before cursor, remove overlay
          _removeMentionOverlay();
        } else {
          // Get the search query (text between @ and cursor)
          String searchQuery = text.substring(lastAtIndex + 1, cursorPosition).toLowerCase();
          _showMentionOverlay(searchQuery: searchQuery);
        }
      }
    } else {
      // Text is empty or cursor at start, remove overlay
      _removeMentionOverlay();
    }

    socketProvider.userTypingEventChannel(
        channelId: widget.channelId,
        isReplyMsg: true,
        isTyping: text.trim().length > 1 ? 1 : 0,
        msgId: widget.msgID,
    );
  }
  void _showMentionOverlay({String? searchQuery}) {
    _removeMentionOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final maxHeight = (screenSize.height - keyboardHeight) * 0.4; // 40% of available height

        return Positioned(
          width: screenSize.width * 0.8, // 80% of screen width
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topCenter,
            followerAnchor: Alignment.bottomCenter,
            offset: const Offset(0, -8),
            child: Material(
              elevation: 0, // Remove shadow
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                ),
                margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1), // Center horizontally
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Consumer<CommonProvider>(
                  builder: (context, provider, child) {
                    final usersToShow = _getFilteredUsers(searchQuery, provider);

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Channel Members Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'CHANNEL MEMBERS',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (usersToShow.isEmpty && searchQuery?.isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                'No matching users found',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: usersToShow.length,
                              itemBuilder: (context, index) {
                                final user = usersToShow[index];
                                return InkWell(
                                  onTap: () => _onMentionSelected(user),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundImage: CachedNetworkImageProvider(
                                            ApiString.profileBaseUrl + (user?.avatarUrl ?? ''),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user?.username ?? 'Unknown',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (user?.fullName != null)
                                                Text(
                                                  user.fullName!,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                          // Special Mention Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            margin: EdgeInsets.only(top: 8),
                            child: Text(
                              'SPECIAL MENTION',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Special mention items
                          _buildSpecialMentionItem(
                            icon: Icons.group,
                            label: '@here',
                            onTap: () => _onMentionSelected({'username': 'here'}),
                          ),
                          _buildSpecialMentionItem(
                            icon: Icons.people,
                            label: '@channel',
                            onTap: () => _onMentionSelected({'username': 'channel'}),
                          ),
                          _buildSpecialMentionItem(
                            icon: Icons.people_outline,
                            label: '@all',
                            onTap: () => _onMentionSelected({'username': 'all'}),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _showMentionList = true);
  }

  void _removeMentionOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _showMentionList = false);
  }
  List<dynamic> _getFilteredUsers(String? searchQuery, CommonProvider provider) {
    final List<dynamic> initialUsers = [];
    final allMembers = Provider.of<ChannelChatProvider>(context, listen: false).channelMembersList;

    // If no search query, show current user and first member
    if (searchQuery?.isEmpty ?? true) {
      // Add current user first
      final currentUser = allMembers.firstWhere(
        (member) => member.sId == signInModel.data?.user?.id,
        orElse: () => allMembers.isNotEmpty ? allMembers[0] : MemberDetails(),
      );
      initialUsers.add(currentUser);

      // Add first member who is not the current user
      if (allMembers.length > 1) {
        final otherMember = allMembers.firstWhere(
          (member) => member.sId != signInModel.data?.user?.id,
          orElse: () => allMembers[0],
        );
        if (otherMember.sId != currentUser.sId) {
          initialUsers.add(otherMember);
        }
      }
      return initialUsers;
    }

    // Filter members based on search query
    final query = searchQuery!.toLowerCase();
    final matchingMembers = allMembers.where((member) =>
      ((member.username?.toLowerCase().contains(query) ?? false) ||
      (member.fullName?.toLowerCase().contains(query) ?? false))
    ).toList();

    return matchingMembers;
  }
  void _onMentionSelected(dynamic user) {
    final text = _messageController.text;

    // Find the last @ before cursor
    int lastAtIndex = text.substring(0, _mentionCursorPosition).lastIndexOf('@');
    if (lastAtIndex == -1) return;

    // Extract the substring after '@' to find the partial mention
    int endIndex = _mentionCursorPosition;
    while (endIndex < text.length && text[endIndex] != ' ') {
      endIndex++; // Move until space (end of mention)
    }

    // Get the text before @mention and after the partial mention
    final beforeMention = text.substring(0, lastAtIndex); // Text before @
    final afterMention = text.substring(endIndex); // Text after the partial mention

    // Handle both MemberDetails object and special mention map
    String mentionText;
    if (user is MemberDetails) {
      mentionText = '@${user.username} ';
    } else if (user is Map<String, dynamic>) {
      mentionText = '@${user['username']} ';
    } else {
      return; // Invalid user object
    }

    // Update the TextField with corrected mention text
    _messageController.value = TextEditingValue(
      text: beforeMention + mentionText + afterMention,
      selection: TextSelection.collapsed(
        offset: beforeMention.length + mentionText.length, // Move cursor after mention
      ),
    );

    _removeMentionOverlay();
  }
  Widget _buildSpecialMentionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReactionsList(BuildContext context, List<dynamic> reactions) {
    // Group reactions by user
    final Map<String, List<String>> userReactions = {};
    for (var reaction in reactions) {
      if (reaction.userId != null && reaction.userId!.sId != null) {
        if (!userReactions.containsKey(reaction.userId!.sId)) {
          userReactions[reaction.userId!.sId!] = [];
        }
        if (reaction.emoji != null) {
          userReactions[reaction.userId!.sId!]!.add(reaction.emoji!);
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppPreferenceConstants.themeModeBoolValueGet ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: userReactions.length,
                  itemBuilder: (context, index) {
                    final userId = userReactions.keys.elementAt(index);
                    final userEmojis = userReactions[userId]!;
                    final user = Provider.of<ChannelChatProvider>(context, listen: false).getUserById(userId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          profileIconWithStatus(
                            userID: userId,
                            userName: user?.username ?? '',
                            status: "",
                            needToShowIcon: false,
                            radius: 16,
                            otherUserProfile: user?.avatarUrl ?? '',
                            borderColor: AppColor.blueColor,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.username ?? "Unknown",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: userEmojis.map((emoji) => Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: CachedNetworkImage(
                                      imageUrl: emoji,
                                      height: 20,
                                      width: 20,
                                      errorWidget: (context, url, error) => Icon(Icons.error, size: 20),
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );

                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
