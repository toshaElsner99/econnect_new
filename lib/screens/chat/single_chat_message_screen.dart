
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_connect/cubit/channel_list/channel_list_cubit.dart';
import 'package:e_connect/cubit/chat/chat_cubit.dart';
import 'package:e_connect/cubit/common_cubit/common_cubit.dart';
import 'package:e_connect/main.dart';
import 'package:e_connect/model/get_user_model.dart';
import 'package:e_connect/model/message_model.dart';
import 'package:e_connect/providers/download_provider.dart';
import 'package:e_connect/screens/chat/files_listing_screen/files_listing_screen.dart';
// import 'package:e_connect/screens/chat/forward_message_dialog.dart';
import 'package:e_connect/screens/chat/pinned_posts_screen/pinned_posts_screen.dart';
import 'package:e_connect/screens/chat/reply_message_screen/reply_message_screen.dart';
import 'package:e_connect/socket_io/socket_io.dart';
import 'package:e_connect/utils/api_service/api_string_constants.dart';
import 'package:e_connect/utils/app_color_constants.dart';
import 'package:e_connect/providers/file_service_provider.dart';
import 'package:e_connect/utils/app_fonts_constants.dart';
import 'package:e_connect/utils/app_image_assets.dart';
import 'package:e_connect/utils/app_preference_constants.dart';
import 'package:e_connect/utils/common/common_function.dart';
import 'package:e_connect/utils/common/common_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'package:provider/provider.dart';

import '../../screens/chat/media_preview_screen.dart';
import '../../widgets/chat_profile_header.dart';


/// ///


class SingleChatMessageScreen extends StatefulWidget {
  final String userName;
  final String oppositeUserId;
  final bool? calledForFavorite;
  final bool? needToCallAddMessage;
  // final bool callForReadMsg;

  const SingleChatMessageScreen({super.key, required this.userName, required this.oppositeUserId, this.calledForFavorite, this.needToCallAddMessage});

  @override
  State<SingleChatMessageScreen> createState() => _SingleChatMessageScreenState();
}


class _SingleChatMessageScreenState extends State<SingleChatMessageScreen> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final chatProvider = Provider.of<ChatProvider>(navigatorKey.currentState!.context,listen: false);
  final commonProvider = Provider.of<CommonProvider>(navigatorKey.currentState!.context,listen: false);
  final channelListProvider = Provider.of<ChannelListProvider>(navigatorKey.currentState!.context,listen: false);
  final fileServiceProvider = Provider.of<FileServiceProvider>(navigatorKey.currentState!.context,listen: false);
  final socketProvider = Provider.of<SocketIoProvider>(navigatorKey.currentState!.context,listen: false);
  final FocusNode _focusNode = FocusNode();
  String? lastSentMessage;
  List<dynamic>? _lastSentDelta;
  bool _showToolbar = false;
  final Map<String, dynamic> userCache = {};
  GetUserModel? userDetails;
  String currentUserMessageId = "";
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context,listen: false).pagination(oppositeUserId: widget.oppositeUserId);
      commonProvider.updateStatusCall(status: "online");
      chatProvider.getTypingUpdate();
      _controller.addListener(() {
        socketProvider.userTypingEvent(oppositeUserId: widget.oppositeUserId, isReplyMsg: false, isTyping: _controller.document.toPlainText().trim().length > 1 ? 1 : 0);
      },);
      /// THis Is Socket Listening Event ///
      socketProvider.listenSingleChatScreen(oppositeUserId: widget.oppositeUserId);
      /// THis is Doing for update pin message and get Message List ///
      socketProvider.socketListenPinMessage(oppositeUserId: widget.oppositeUserId,callFun: (){
        chatProvider.getMessagesList(oppositeUserId: widget.oppositeUserId,needClearFirstTime: true);
        fetchOppositeUserDetails();
      });
      if(widget.needToCallAddMessage == true){
        channelListProvider.addUserToChatList(selectedUserId: widget.oppositeUserId);
      }
      chatProvider.getFileListingInChat(oppositeUserId: widget.oppositeUserId);
      channelListProvider.readUnreadMessages(oppositeUserId: widget.oppositeUserId,isCalledForFav: widget.calledForFavorite ?? false,isCallForReadMessage: true);
      chatProvider.getMessagesList(oppositeUserId: widget.oppositeUserId,needClearFirstTime: true);
      _fetchAndCacheUserDetails();
    },);
  }

  void fetchOppositeUserDetails()async{
    await commonProvider.getUserByIDCall2(userId: widget.oppositeUserId);
    userDetails = commonProvider.getUserModel!;
  }
  void _fetchAndCacheUserDetails() async {
    await commonProvider.getUserByIDCall2(userId: widget.oppositeUserId);
    await commonProvider.getUserByIDCallForSecondUser(userId: signInModel.data!.user!.id);
    userDetails = commonProvider.getUserModel!;
    userCache["${commonProvider.getUserModelSecondUser?.data!.user!.sId}"] = commonProvider.getUserModelSecondUser!;
    print("user>>>>>> ${userDetails?.data!.user!.username}");
    print("user>>>>>> ${commonProvider.getUserModelSecondUser?.data!.user!.username}");
    print("user>>>>>> ${commonProvider.getUserModelSecondUser?.data!.user!.sId}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommonProvider,ChatProvider>(builder: (context, commonProvider,chatProvider, child) {
      return Scaffold(
        appBar: buildAppBar(commonProvider, chatProvider),
        body: Column(
          children: [
            Divider(
              color: Colors.grey.shade800,
              height: 1,
            ),
            if(chatProvider.idChatListLoading)...{

            }else...{
              Visibility(
                visible:  userDetails != null,
                child: ChatProfileHeader(userName: userDetails!.data!.user!.fullName ?? userDetails!.data!.user!.username ?? 'Unknown', userImageUrl: ApiString.profileBaseUrl + (userDetails!.data!.user!.avatarUrl ?? ''),),
              ),
              Expanded(
                child: ListView(
                  controller: chatProvider.scrollController,
                  reverse: true,
                  children: [
                    dateHeaders(),
                  ],
                ),
              ),
              inputTextFieldWithEditor()
            }
          ],
        ),
      );
    },);
  }
  AppBar buildAppBar(CommonProvider commonProvider, ChatProvider chatProvider) {
    return AppBar(
      toolbarHeight: 60,
      leadingWidth: 35,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: IconButton(icon: Icon(CupertinoIcons.back,color: Colors.white,),color: Colors.white, onPressed: () {
          pop();
          channelListProvider.readUnreadMessages(oppositeUserId: widget.oppositeUserId,isCalledForFav: widget.calledForFavorite ?? false,isCallForReadMessage: true);
        },),
      ),
      titleSpacing: 20,
      title:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: commonText(
                  text: widget.userName,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ),
              Visibility(
                visible: userDetails?.data?.user?.isFavourite ?? false,
                child: Icon(Icons.star_rate_rounded, color: Colors.yellow, size: 18),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                getCommonStatusIcons(
                  size: 15,
                  status: userDetails?.data?.user?.status ?? "offline",
                  assetIcon: false,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: commonText(
                    text: (userDetails?.data!.user!.sId == chatProvider.oppUserIdForTyping && chatProvider.msgLength == 1)
                        ? "Typing..."
                        : getLastOnlineStatus(
                      userDetails?.data?.user?.status ?? ".....",
                      userDetails?.data?.user!.lastActiveTime,
                    ),
                    height: 1,
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
                Visibility(
                  visible: userDetails?.data?.user?.customStatusEmoji != null &&
                      userDetails?.data?.user?.customStatusEmoji!.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CachedNetworkImage(
                      imageUrl: userDetails?.data?.user!.customStatusEmoji ?? "",
                      height: 20,
                      width: 20,
                      errorWidget: (context, url, error) => Icon(Icons.error, size: 20), // Handle image errors
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Image.asset(AppImage.pinIcon, height: 15, width: 18, color: Colors.white),
                const SizedBox(width: 3),
                GestureDetector(
                  onTap: () => PinnedPostsScreen(userName: widget.userName, oppositeUserId: widget.oppositeUserId),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      commonText(
                        text: "${userDetails?.data?.user!.pinnedMessageCount ?? 0}",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                          onTap: () => pushScreen(screen: FilesListingScreen(userName: widget.userName,oppositeUserId: widget.oppositeUserId,)),
                          child: Image.asset(AppImage.fileIcon, height: 15, width: 15, color: Colors.white)),
                  ],),
                )
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColor.whiteColor),
          onPressed: () {
            // isMutedUser: signInModel.data?.user!.muteUsers!.contains(widget.oppositeUserId) ?? false != true,
            showChatSettingsBottomSheet(userId: widget.oppositeUserId);
          },
        ),
      ],
    );
  }

  void _clearInputAndDismissKeyboard() {
    _focusNode.unfocus();
    _controller.clear();
    setState(() {
      _showToolbar = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget inputTextFieldWithEditor() {
    return Container(
      decoration: BoxDecoration(
        color: AppPreferenceConstants.themeModeBoolValueGet ? AppColor.darkAppBarColor : AppColor.appBarColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade800,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          if (_showToolbar)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: quill.QuillToolbar.simple(
                configurations: quill.QuillSimpleToolbarConfigurations(
                    controller: _controller,
                    sharedConfigurations: const quill.QuillSharedConfigurations(
                      locale: Locale('en'),
                    ),
                    showDividers: false,
                    showFontFamily: false,
                    showFontSize: false,
                    showBoldButton: true,
                    showItalicButton: true,
                    showUnderLineButton: false,
                    showStrikeThrough: true,
                    showInlineCode: true,
                    showColorButton: false,
                    showBackgroundColorButton: false,
                    showClearFormat: false,
                    showAlignmentButtons: false,
                    showLeftAlignment: false,
                    showCenterAlignment: false,
                    showRightAlignment: false,
                    showJustifyAlignment: false,
                    showHeaderStyle: true,
                    showListNumbers: true,
                    showListBullets: true,
                    showListCheck: false,
                    showCodeBlock: true,
                    showQuote: true,
                    showIndent: false,
                    showLink: true,
                    showUndo: false,
                    showRedo: false,
                    showSearchButton: false,
                    showClipboardCut: false,
                    showClipboardCopy: false,
                    showClipboardPaste: false,
                    multiRowsDisplay: false,
                    showSubscript: false,
                    showSuperscript: false),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: _showToolbar ? Colors.blue : AppColor.whiteColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _showToolbar = !_showToolbar;
                    });
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: quill.QuillEditor(
                        controller: _controller,
                        focusNode: _focusNode,
                        scrollController: ScrollController(),
                        configurations: quill.QuillEditorConfigurations(
                          scrollable: true,
                          autoFocus: false,
                          checkBoxReadOnly: false,
                          placeholder: 'Write to ${userDetails?.data?.user!.username ?? userDetails?.data?.user!.fullName ?? "...."}',
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          maxHeight: 100,
                          minHeight: 40,
                          customStyles: const quill.DefaultStyles(
                            paragraph: quill.DefaultTextBlockStyle(
                                TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 16,
                                ),
                                quill.HorizontalSpacing.zero,
                                quill.VerticalSpacing.zero,
                                quill.VerticalSpacing.zero,
                                BoxDecoration(color: Colors.transparent)),
                            placeHolder: quill.DefaultTextBlockStyle(
                                TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                quill.HorizontalSpacing.zero,
                                quill.VerticalSpacing.zero,
                                quill.VerticalSpacing.zero,
                                BoxDecoration(color: Colors.transparent)),
                            quote: quill.DefaultTextBlockStyle(
                              TextStyle(
                                color: AppColor.whiteColor,
                                fontSize: 16,
                              ),
                              quill.HorizontalSpacing(16, 0),
                              quill.VerticalSpacing(8, 0),
                              quill.VerticalSpacing(8, 0),
                              BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: AppColor.whiteColor,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          selectedFilesWidget(),
          fileSelectionAndSendButtonRow()
        ],
      ),
    );
  }

  // File selected to send
  Widget selectedFilesWidget() {
    return Consumer<FileServiceProvider>(
      builder: (context, provider, _) {
        return Visibility(
          visible: provider.selectedFiles.isNotEmpty,
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.selectedFiles.length,
              itemBuilder: (context, index) {
                print("FILES>>>> ${provider.selectedFiles[index].path}");
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MediaPreviewScreen(
                              files: provider.selectedFiles,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: AppColor.commonAppColor,
                          child: getFileIcon(
                            provider.selectedFiles[index].extension!,
                            provider.selectedFiles[index].path,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          provider.removeFile(index);
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColor.blackColor,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColor.borderColor,
                            child: Icon(
                              Icons.close,
                              color: AppColor.blackColor,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showCameraOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.appBarColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              commonText(
                text: 'Camera Options',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.whiteColor,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading:
                const Icon(Icons.camera_alt, color: AppColor.whiteColor),
                title: commonText(
                  text: 'Capture Photo',
                  color: AppColor.whiteColor,
                ),
                onTap: () {
                  Navigator.pop(context);
                  FileServiceProvider.instance.captureMedia(isVideo: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: AppColor.whiteColor),
                title: commonText(
                  text: 'Record Video',
                  color: AppColor.whiteColor,
                ),
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

  Widget fileSelectionAndSendButtonRow() {
    return Container(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.alternate_email, color: AppColor.whiteColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.attach_file, color: AppColor.whiteColor),
            onPressed: () {
              FileServiceProvider.instance.pickFiles();
            },
          ),
          IconButton(
            icon: const Icon(Icons.image, color: AppColor.whiteColor),
            onPressed: () {
              FileServiceProvider.instance.pickImages();
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: AppColor.whiteColor),
            onPressed: () {
              showCameraOptionsBottomSheet(context);
            },
          ),
          GestureDetector(
            onTap: () async {
              final plainText = _controller.document.toPlainText().trim();
              if(fileServiceProvider.selectedFiles.isNotEmpty){
               final filesOfList = await chatProvider.uploadFiles();
               chatProvider.sendMessage(content: plainText, receiverId: widget.oppositeUserId, files: filesOfList);
               _clearInputAndDismissKeyboard();
              }else{
                chatProvider.sendMessage(content: plainText, receiverId: widget.oppositeUserId, editMsgID: currentUserMessageId).then((value) => setState(() {
                  currentUserMessageId = "";
                }),);
                _clearInputAndDismissKeyboard();
              }
            },
            child: Container(
                decoration: BoxDecoration(
                    color: AppColor.lightBlueColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                  child: Icon(Icons.send, color: AppColor.whiteColor),
                )),
          ),
        ],
      ),
    );
  }

  Widget dateHeaders() {
    return Consumer<ChatProvider>(builder: (context, value, child) {
      List<MessageGroups> sortedGroups = value.messageGroups..sort((a, b) => b.sId!.compareTo(a.sId!));
      return value.messageGroups.isEmpty ? SizedBox.shrink() : ListView.builder(
        shrinkWrap: true,
        reverse: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: sortedGroups.length,
        itemBuilder: (itemContext, index) {
          final group = sortedGroups[index];
          List<Messages> sortedMessages = (group.messages ?? [])..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
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
                        text: formatDateTime(DateTime.parse(group.sId!)),
                        fontSize: 12,
                        color: AppColor.whiteColor,
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: sortedMessages.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  Messages message = sortedMessages[index];
                  bool showUserDetails = previousSenderId != message.senderId;
                  previousSenderId = message.senderId;
                  return chatBubble(
                    index: index, // Pass index here
                    messageList: message,
                    messageId: sortedMessages[index].sId.toString(),
                    userId: message.senderId!,
                    message: message.content!,
                    time: DateTime.parse(message.createdAt!).toString(),
                    showUserDetails: showUserDetails,
                  );
                },
              )
            ],
          );
        },
      );
    },);
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    if (dateTime.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dateTime.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }



  Widget chatBubble({
    required int index,
    required Messages messageList,
    required String userId,
    required String messageId,
    required String message,
    required String time,
    bool showUserDetails = true,
  })  {
    if (!userCache.containsKey(userId))  {
      commonProvider.getUserByIDCall2(userId: userId);
    }
    return Consumer<CommonProvider>(builder: (context, commonProvider, child) {
      if (!userCache.containsKey(userId) && commonProvider.getUserModel!.data!.user!.sId! == userId) {
        commonProvider.getUserByIDCall2(userId: userId);
        userCache[userId] = commonProvider.getUserModel!;
      }
      final user = userCache[userId];
      bool pinnedMsg = messageList.isPinned ?? false;
      bool isEdited = messageList.isEdited ?? false;
      return Container(
        margin: EdgeInsets.only(top: 1),
        color:  pinnedMsg == true ? AppPreferenceConstants.themeModeBoolValueGet ? Colors.greenAccent.withOpacity(0.15) : AppColor.pinnedColorLight : null,
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: Column(
          children: [
            Visibility(
                visible: (messageList.isSeen == false && userId != signInModel.data?.user?.id),
                child: newMessageDivider()),
            Visibility(
                visible: pinnedMsg,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0,vertical: 5),
                  child: Row(
                    children: [
                      Image.asset(AppImage.pinMessageIcon,height: 12,width: 12,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: commonText(text: "Pinned",color: AppColor.blueColor),
                      ),
                    ],
                  ),
                )),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (showUserDetails) ...{
                  /// Profile  Section ///
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.5),
                    child: profileIconWithStatus(userID: "${user?.data!.user!.sId}", status: "${user?.data!.user!.status}",otherUserProfile: user?.data!.user!.avatarUrl ?? '',radius: 17),
                  )
                } else ...{
                  SizedBox(width: 50)
                },
                if (showUserDetails) SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showUserDetails)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            commonText(
                                height: 1.2,
                                text:
                                user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown', fontWeight: FontWeight.bold),
                            if (signInModel.data?.user!.id == user?.data!.user!.sId && commonProvider.customStatusUrl.isNotEmpty) ...{
                              SizedBox(width: 8,),
                              CachedNetworkImage(
                                width: 20,
                                height: 20,
                                imageUrl: commonProvider.customStatusUrl,
                              ),
                            } else if (userDetails?.data!.user!.customStatusEmoji != "" && userDetails?.data!.user!.customStatusEmoji != null) ...{
                            Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: CachedNetworkImage(
                                width: 20,
                                height: 20,
                                imageUrl: userDetails?.data!.user!.customStatusEmoji,
                              ),),
                            },
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: commonText(
                                  height: 1.2,
                                  text: formatTime(time), color: Colors.grey, fontSize: 12
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 5),
                        Wrap(
                          direction: Axis.horizontal,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: HtmlWidget(
                                      message,
                                      textStyle: TextStyle(
                                        height: 1.2,
                                        fontFamily: AppFonts.interFamily,
                                        color: AppPreferenceConstants.themeModeBoolValueGet ? Colors.white : Colors.black,
                                        fontSize: 16,
                                      ),
                                      customStylesBuilder: (element) {
                                        // Base styles for all text
                                        Map<String, String> styles = {
                                          'color': AppPreferenceConstants.themeModeBoolValueGet ? '#FFFFFF' : '#000000',
                                        };

                                        // Add additional styles for special formatting
                                        if (element.classes.contains('renderer_bold')) {
                                          styles['font-weight'] = 'bold';
                                        }
                                        if (element.classes.contains('renderer_italic')) {
                                          styles['font-style'] = 'italic';
                                        }
                                        if (element.classes.contains('renderer_strikethrough')) {
                                          styles['text-decoration'] = 'line-through';
                                        }
                                        if (element.classes.contains('renderer_link')) {
                                          styles['color'] = '#2196F3';
                                        }
                                        if (element.classes.contains('renderer_emoji')) {
                                          styles['display'] = 'inline-block';
                                          styles['vertical-align'] = 'middle';
                                        }

                                        return styles;
                                      },
                                      customWidgetBuilder: (element) {
                                        if (element.classes.contains('renderer_emoji')) {
                                          final imageUrl = element.attributes['style']?.split('url(\'')?.last?.split('\')').first;
                                          if (imageUrl != null) {
                                            return CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              width: 21,
                                              height: 21,
                                              fit: BoxFit.contain,
                                            );
                                          }
                                        }
                                        return null;
                                      },
                                      enableCaching: true,
                                    ),
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
                                  profileIconWithStatus(userID: messageList.senderOfForward?.id ?? "", status: messageList.senderOfForward?.status ?? "offline",needToShowIcon: false,otherUserProfile: messageList.senderOfForward?.avatarUrl),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        commonText(text: "${messageList.senderOfForward?.username}"),
                                        SizedBox(height: 3),
                                        commonText(text: formatDateString("${messageList.senderOfForward?.createdAt}"),color: AppColor.borderColor,fontWeight: FontWeight.w500),
                                      ],
                                    ),
                                  ),
                                ],),
                              ),
                              commonText(text: "${messageList.forwardInfo?.content}"),
                                Visibility(
                                  visible: messageList.forwardInfo?.files.length != 0 ? true : false,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: messageList.forwardInfo?.files.length ?? 0,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final filesUrl = messageList.forwardInfo?.files[index];
                                      String originalFileName = getFileName(messageList.forwardInfo!.files[index]);
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
                        Visibility(
                          visible: messageList.replies?.isNotEmpty ?? false,
                          child: GestureDetector(
                            onTap: () {
                              print("Simple Passing = ${messageId.toString()}");
                              pushScreenWithTransition(
                              ReplyMessageScreen(
                                userName: user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown',
                                messageId: messageId.toString(),
                                receiverId: widget.oppositeUserId,
                              ),
                            ).then((value) {
                              print("value>>> $value");
                              if (messageList.replies != null && messageList.replies!.isNotEmpty) {
                                for (var reply in messageList.replies!) {
                                  if (reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false) {
                                      setState(() =>
                                        reply.isSeen = true);
                                  }
                                }
                              }
                            });},
                            child: Container(
                              // color: Colors.red,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  // 🖼️ Overlapping profile images
                                  if (messageList.repliesSenderInfo != null && messageList.repliesSenderInfo!.isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.only(right :messageList.repliesSenderInfo!.length > 1 ? 22 : 7),
                                      // color: Colors.amber,
                                      child: Row(
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              profileIconWithStatus(
                                                userID: messageList.repliesSenderInfo![0].id,
                                                status: "",
                                                needToShowIcon: false,
                                                radius: 12,
                                                otherUserProfile: messageList.repliesSenderInfo![0].avatarUrl,
                                              ),
                                              if (messageList.repliesSenderInfo!.length > 1)
                                                Positioned(
                                                  left: 16,
                                                  child: profileIconWithStatus(
                                                    userID: messageList.repliesSenderInfo![1].id,
                                                    status: "",
                                                    needToShowIcon: false,
                                                    radius: 12,
                                                    otherUserProfile: messageList.repliesSenderInfo![1].avatarUrl,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),


                                  // 🔴 Red dot circle
                                  Visibility(
                                    replacement: SizedBox.shrink(),
                                    visible: messageList.replies != null && messageList.replies!.isNotEmpty &&
                                    messageList.replies!.any((reply) => reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false),
                                    child: Container(
                                      margin:EdgeInsets.only(right: 5),
                                      width: messageList.replies != null && messageList.replies!.isNotEmpty && messageList.replies!.any((reply) => reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false) ? 10 : 0,
                                      height: messageList.replies != null && messageList.replies!.isNotEmpty && messageList.replies!.any((reply) => reply.receiverId == signInModel.data?.user!.id && reply.isSeen == false) ? 10 : 0,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),

                                  // 🔄 Reply icon and text
                                  Padding(
                                    padding: EdgeInsets.only(left: 0.0,right: 4.0),
                                    child: Transform.flip(
                                      flipX: true,
                                      child: Image.asset(
                                        AppImage.forwardIcon,
                                        height: 15,
                                        width: 15,
                                        color: AppColor.borderColor,
                                      ),
                                    ),
                                  ),

                                  commonText(
                                    text: "${messageList.replyCount} ${messageList.replyCount! > 1 ? 'replies' : 'reply'}",
                                    fontSize: 12,
                                    color: AppColor.borderColor,
                                  ),

                                  SizedBox(width: 6),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: commonText(
                                        text: getTimeAgo(
                                            (messageList.replies != null && messageList.replies!.isNotEmpty)
                                                ? messageList.replies!.last.createdAt.toString()
                                                : DateTime.now().toString()
                                        ),
                                        fontSize: 10,
                                        color: AppColor.borderColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                  ),
                ),
                popMenu2(context,
                  onOpened: () =>  setState(() => _selectedIndex = index),
                  onClosed: () =>  setState(() => _selectedIndex = null),
                  opened: index == _selectedIndex ? true : false,
                  createdAt: messageList.createdAt!,
                  currentUserId: userId,
                  onForward: () => null,
                  onReply: () {
                    print("onReply Passing = ${messageId.toString()}");
                  pushScreen(screen: ReplyMessageScreen(userName: user?.data!.user!.fullName ?? user?.data!.user!.username ?? 'Unknown', messageId: messageId.toString(),receiverId: widget.oppositeUserId,));
                  },
                  onPin: () => chatProvider.pinUnPinMessage(receiverId: widget.oppositeUserId, messageId: messageId.toString(), pinned: pinnedMsg = !pinnedMsg ),
                  onCopy: () => copyToClipboard(context, message),
                  onEdit: () => setState(() {
                    int position = _controller.document.length - 1;
                    currentUserMessageId = messageId;
                    print("currentMessageId>>>>> $currentUserMessageId && 67b6d585d75f40cdb09398f5");
                    _controller.document.insert(position, message.toString());
                    _controller.updateSelection(
                      TextSelection.collapsed(offset: _controller.document.length),
                      quill.ChangeSource.local,
                    );
                  }),
                  onDelete: () => chatProvider.deleteMessage(messageId: messageId.toString(), receiverId: widget.oppositeUserId)),
              ],
            ),
          ],
        ),
      );
    },
    );
  }

  Row newMessageDivider() {
    return Row(children: [
                Expanded(child: Divider(color: Colors.orange,)),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: commonText(
                    text: "New Messages",
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                Expanded(child: Divider(color: Colors.orange,)),
              ],);
  }
}

