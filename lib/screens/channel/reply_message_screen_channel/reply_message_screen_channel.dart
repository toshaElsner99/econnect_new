


import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/model/get_user_model.dart';
import 'package:e_connect/providers/channel_chat_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
  // final commonProvider = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);
  // final channelListProvider = Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false);
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
  // GetUserModelSecondUser? userDetails;
  bool _isTextFieldEmpty = true;


  final TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    print("REPLY_CHANNEL_ID>>>> ${widget.msgID}");
    super.initState();
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      channelChatProvider.getReplyListUpdateSocketForChannel(widget.msgID);
      // socketProvider.socketListenPinMessageInReplyScreen(msgId: widget.messageId);
      // _fetchAndCacheUserDetails();
      print("I'm In initState");
      channelChatProvider.getReplyMessageListChannel(msgId: widget.msgID,fromWhere: "SCREEN INIT");
      // Provider.of<ChatProvider>(context, listen: false).seenReplayMessage(msgId: widget.channelID);
      // Provider.of<CommonProvider>(context, listen: false).getUserApi(id :widget.receiverId);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=> pop(popValue: true), icon: Icon(CupertinoIcons.back,color: Colors.white,)),
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
          SizedBox(height: 20,),
          inputTextFieldWithEditor(),
          selectedFilesWidget(),
        ],
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
                  child: profileIconWithStatus(userID: "${messageList.senderId!.sId}", status: "${messageList.senderId!.status}",otherUserProfile: "${messageList.senderId!.avatarUrl}",radius: 17),
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
                      commonHTMLText(message: message),
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
                                    profileIconWithStatus(userID: messageList.forwardFrom?.sId ?? "", status: messageList.forwardFrom?.senderId?.status ?? "offline",needToShowIcon: false,otherUserProfile: messageList.forwardFrom?.senderId?.avatarUrl),
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
                  opened:  false,
                  currentUserId: messageList.senderId?.sId ?? "",
                  onForward: () => pushScreen(screen: ForwardMessageScreen(userName: messageList.senderId?.username ?? messageList.senderId!.fullName ?? 'Unknown',time: formatDateString1(time),msgToForward: message,userID: userId,otherUserProfile: "${messageList.senderId!.avatarUrl}",forwardMsgId: messageId,)),
                  onPin: () {
                    // chatProvider.pinUnPinMessageForReply(receiverId: widget.receiverId, messageId: messageId.toString(), pinned: pinnedMsg = !pinnedMsg )
                  },
                  onCopy: () => copyToClipboard(context, message),
                  onEdit: () => setState(() {
                    _messageController.clear();
                    FocusScope.of(context).requestFocus(_focusNode);
                    int position = _messageController.text.length;
                    currentUserMessageId = messageId;
                    print("currentMessageId>>>>> $currentUserMessageId && 67c6af1c8ac51e0633f352b7");
                    _messageController.text = _messageController.text.substring(0, position) + message + _messageController.text.substring(position);
                  }),
                  onDelete: () {
                    channelChatProvider.deleteMessageForReply(messageId: messageId.toString(),firsMessageId: widget.msgID);
                  },
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: CompositedTransformTarget(
              link: _layerLink,
              child: TextField(
                key: _textFieldKey,
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: 5,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  suffixIcon: _messageController.text.isEmpty
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => FileServiceProvider.instance.pickFiles(),
                        child: const Icon(Icons.attach_file, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showCameraOptions(context),
                        child: const Icon(Icons.camera_alt, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                    ],
                  )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                  _onTextChanged();
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor.blueColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: AppColor.whiteColor, size: 20),
              onPressed: () async {
                final plainText = _messageController.text.trim();
                if(plainText.isEmpty && fileServiceProvider.selectedFiles.isEmpty) return;

                try {
                  if(fileServiceProvider.selectedFiles.isNotEmpty){
                    final filesOfList = await chatProvider.uploadFiles();
                    await channelChatProvider.sendMessage(
                        content: plainText,
                        channelId: widget.channelId,
                        files: filesOfList,
                        replyId: widget.msgID
                    );
                  } else {
                    await channelChatProvider.sendMessage(
                        content: plainText,
                        channelId: widget.channelId,
                        replyId: widget.msgID,
                        editMsgID: currentUserMessageId.isEmpty ? "" : currentUserMessageId
                    );
                  }

                  // Update reply count in single chat screen
                  ///////////////////////////////////////////////////////////
                  // chatProvider.updateReplyCount(widget.messageId);

                  setState(() {
                    currentUserMessageId = "";
                  });

                  _clearInputAndDismissKeyboard();
                } catch (e) {
                  print("Error sending message: $e");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  void _clearInputAndDismissKeyboard() {
    _focusNode.unfocus();
    _messageController.clear();
    FocusScope.of(context).unfocus();
  }

  void _pickImage(ImageSource source) {
    FileServiceProvider.instance.pickImages();
  }

  void _showCameraOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Capture Photo'),
                onTap: () {
                  Navigator.pop(context);
                  FileServiceProvider.instance.captureMedia(isVideo: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record Video'),
                onTap: () {
                  Navigator.pop(context);
                  FileServiceProvider.instance.captureMedia(isVideo: true);
                },
              ),
            ],
          ),
        );
      },
    );
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

    // Keep existing typing event
    /////////********/////
    // socketProvider.userTypingEvent(
    //     oppositeUserId: widget.receiverId,
    //     isReplyMsg: false,
    //     isTyping: text.trim().length > 1 ? 1 : 0
    // );
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
    final allUsers = provider.getUserMentionModel?.data?.users ?? [];

    // If no search query, show first two users from API response
    if (searchQuery?.isEmpty ?? true) {
      // Add first two users if available
      if (allUsers.isNotEmpty) {
        initialUsers.add(allUsers[0]);
        if (allUsers.length > 1) {
          initialUsers.add(allUsers[1]);
        }
      }
      return initialUsers;
    }

    // Filter users based on search query
    final query = searchQuery!.toLowerCase();

    // First add first two users if they match the search
    if (allUsers.isNotEmpty) {
      if (((allUsers[0].username?.toLowerCase().contains(query) ?? false) ||
          (allUsers[0].fullName?.toLowerCase().contains(query) ?? false))) {
        initialUsers.add(allUsers[0]);
      }
      if (allUsers.length > 1 &&
          ((allUsers[1].username?.toLowerCase().contains(query) ?? false) ||
              (allUsers[1].fullName?.toLowerCase().contains(query) ?? false))) {
        initialUsers.add(allUsers[1]);
      }
    }

    // Then add other matching users
    final otherUsers = allUsers.skip(2).where((user) =>
    ((user.username?.toLowerCase().contains(query) ?? false) ||
        (user.fullName?.toLowerCase().contains(query) ?? false))
    ).toList();

    return [...initialUsers, ...otherUsers];
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

    // Handle both Users object and special mention map
    String mentionText;
    print("User type = ${user.runtimeType}");
    if (user is Users) { // Users from user_mention_model.dart
      print("user = ${user.username}");
      mentionText = '@${user.username} ';
    }else if (user is SecondUser) {
      mentionText = '@${user.username} ';
    } else if (user is Map<String, dynamic>) {
      mentionText = '@${user['username']} ';
    } else if (user is User) {
      mentionText = '@${user.username} ';
    } else {
      print("user = ${user.username}");
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
}
